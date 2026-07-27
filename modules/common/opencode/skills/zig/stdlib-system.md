# std.System (Allocators, Process, Thread, Crypto, Time)

System-level APIs in Zig 0.16. Verified against 0.16.0 source.

# std.heap - Allocators

Zig has no default allocator. Functions that need heap memory accept an `Allocator` parameter.

## Quick Reference

| Allocator | Use Case | Thread-Safe |
|-----------|----------|-------------|
| `std.testing.allocator` | Unit tests (leak detection) | No |
| `std.heap.FixedBufferAllocator` | Stack-based, bounded size known | Optional |
| `std.heap.ArenaAllocator` | Batch free, CLI apps, request handlers | No |
| `std.heap.page_allocator` | Backing for other allocators | Yes |
| `std.heap.c_allocator` | Linking libc, interop | Yes |
| `std.heap.raw_c_allocator` | Libc arena backing (no alignment overhead) | Yes |
| `std.heap.DebugAllocator` | Debug builds, leak/corruption detection | Configurable |
| `std.heap.smp_allocator` | ReleaseFast production multithreaded | Yes |
| `std.heap.MemoryPool` | High-frequency same-type allocations | No |
| `std.heap.ThreadSafeAllocator` | Wrap non-thread-safe allocator | Yes (**removed in 0.16**) |
| `std.heap.StackFallbackAllocator` | Stack buffer with heap fallback | Depends |
| `std.heap.wasm_allocator` | WebAssembly targets | Yes |

## Allocator Naming Conventions

Using a generic `allocator` name hides memory ownership contracts. Name allocators by their **memory contract** to make code self-documenting:

| Name | Contract | Can Return Data? |
|------|----------|------------------|
| `gpa` | Caller **must** free with `defer gpa.free()` | Yes |
| `arena` | Bulk-deallocated at system boundary | Yes |
| `scratch` | Function-private temporary space | **Never** |

### The Problem

```zig
// BAD - "allocator" says nothing about ownership
fn process(allocator: Allocator) ![]u8 {
    const temp = try allocator.alloc(u8, 100);  // Who frees this?
    const result = try allocator.dupe(u8, temp); // Who owns this?
    allocator.free(temp);  // Is this correct?
    return result;  // Can caller free with same allocator?
}

### The Solution

Name allocators by their contract:

```zig
// GOOD - names communicate ownership contracts
fn process(
    gpa: Allocator,      // General-purpose: caller must free returned data
    scratch: Allocator,  // Temporary: never return data allocated here
) ![]u8 {
    // scratch is for intermediate computation only
    const temp = try scratch.alloc(u8, 100);
    defer scratch.free(temp);

    // gpa for data that outlives this function
    return try gpa.dupe(u8, computeResult(temp));
}

### Full Example with All Three

```zig
fn handleRequest(
    request: *Request,
    arena: Allocator,   // Response lifetime - bulk freed after response sent
    gpa: Allocator,     // Long-lived data - cache, shared state
    scratch: Allocator, // This function only - intermediate computation
) !Response {
    // Scratch: temporary parsing buffers (never escapes this function)
    const parsed = try parseBody(request.body, scratch);

    // GPA: update shared cache (outlives request)
    try updateCache(gpa, parsed.cache_key, parsed.value);

    // Arena: response data (freed when response completes)
    const response_body = try formatResponse(arena, parsed);

    return Response{ .body = response_body };
}

### Common Patterns

**CLI applications** - arena for everything, freed at exit:
```zig
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    try run(arena.allocator());  // Name as "arena" - bulk freed at end
}

**Request handlers** - arena per request, gpa for shared state:
```zig
fn handleRequest(gpa: Allocator, request: Request) !Response {
    var request_arena = std.heap.ArenaAllocator.init(gpa);
    defer request_arena.deinit();
    const arena = request_arena.allocator();

    // arena: request-scoped data
    // gpa: data that outlives the request (caches, connections)
}

**Functions with temporary allocations** - scratch parameter:
```zig
/// Computes result using scratch for intermediate work.
/// Caller owns returned slice (allocated from gpa).
fn compute(gpa: Allocator, scratch: Allocator, input: []const u8) ![]u8 {
    const temp = try scratch.alloc(u8, input.len * 2);
    defer scratch.free(temp);
    // ... use temp for intermediate computation ...
    return try gpa.dupe(u8, result);
}

## Allocator Interface

```zig
const Allocator = std.mem.Allocator;

// Single items: create/destroy
const ptr: *T = try allocator.create(T);
defer allocator.destroy(ptr);

// Slices: alloc/free
const slice: []T = try allocator.alloc(T, count);
defer allocator.free(slice);

// Duplicate existing slice
const copy = try allocator.dupe(u8, source);
defer allocator.free(copy);

// Resize (returns bool - true if resized in place)
if (allocator.resize(slice, new_len)) {
    // slice is now new_len (pointer unchanged)
}

// Reallocate (may move, returns new slice)
slice = try allocator.realloc(slice, new_len);

## Choosing an Allocator

**Decision flow:**

1. **Library code?** Accept `Allocator` parameter - let caller decide
2. **Unit test?** Use `std.testing.allocator` (has leak detection)
3. **Size known at comptime?** Use `FixedBufferAllocator` with stack buffer
4. **Stack with heap fallback?** Use `stackFallback(N, backing_allocator)`
5. **CLI app / one-shot?** Use `ArenaAllocator` wrapping `page_allocator`
6. **Request loop (web/game)?** Use `ArenaAllocator`, reset per iteration
7. **Many same-type objects?** Use `MemoryPool(T)` for fast create/destroy
8. **Debug build?** Use `DebugAllocator` for leak/corruption detection
9. **ReleaseFast production?** Use `std.heap.smp_allocator`
10. **Linking libc?** Use `c_allocator` or `raw_c_allocator` (as arena backing)

## Common Allocators

### Testing Allocator

```zig
test "example" {
    const allocator = std.testing.allocator;
    const data = try allocator.alloc(u8, 100);
    defer allocator.free(data);  // Leak detected if missing!
}

### FixedBufferAllocator

No heap allocations - allocates into a fixed buffer. Useful for kernels, embedded, or performance-critical code. Returns `OutOfMemory` when buffer exhausted:

```zig
var buffer: [4096]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buffer);
const allocator = fba.allocator();

const data = try allocator.alloc(u8, 100);
// Free/resize only works for most recent allocation
allocator.free(data);

// Reset to reuse buffer
fba.reset();

**Thread-safe variant** (allocate only - no resize/free):
```zig
const ts_allocator = fba.threadSafeAllocator();

**Ownership checks:**
```zig
if (fba.ownsPtr(ptr)) { ... }    // Check if pointer is within buffer
if (fba.ownsSlice(slice)) { ... } // Check if slice is within buffer

### ArenaAllocator

Wraps a child allocator. Allocate many times, free all at once with `.deinit()`. Individual `free()` only works for most recent allocation.

**0.16 change:** `ArenaAllocator`'s `Allocator` interface is now thread-safe (lock-free). However, `deinit()` and `reset()` are NOT thread-safe.

```zig
// CLI app pattern - allocate freely, free all at end
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const data = try allocator.alloc(u8, 1000);
    const more = try allocator.alloc(u8, 2000);
    // No need to free individual allocations
}

// Request loop pattern - reset per iteration
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();

while (running) {
    _ = arena.reset(.retain_capacity);  // Keep memory, reset state
    const allocator = arena.allocator();
    try handleRequest(allocator);
}

**Reset modes:**

- `.free_all` - Release all memory to backing allocator
- `.retain_capacity` - Keep allocated pages for reuse (faster)
- `.{ .retain_with_limit = N }` - Retain up to N bytes

**Query current usage:**
```zig
const bytes_used = arena.queryCapacity();  // Excludes internal overhead

**State optimization** - store just the state to save memory:
```zig
const State = std.heap.ArenaAllocator.State;
var state: State = .{};

// Promote to full allocator when needed
var arena = state.promote(std.heap.page_allocator);
defer arena.deinit();

### DebugAllocator

Detects leaks, double-free, use-after-free. Designed for safety over performance, but still faster than `page_allocator`. Safety checks and thread safety configurable:

```zig
var gpa: std.heap.DebugAllocator(.{}) = .init;
defer {
    const check = gpa.deinit();
    if (check == .leak) {
        std.debug.print("Memory leak detected!\n", .{});
    }
}
const allocator = gpa.allocator();

**Configuration options:**

```zig
var gpa: std.heap.DebugAllocator(.{
    .stack_trace_frames = 10,     // Capture more frames
    .enable_memory_limit = true,  // Track total bytes
    .safety = true,               // Enable safety checks
    .thread_safe = true,          // Multi-thread support
    .never_unmap = true,          // Debug use-after-free
    .retain_metadata = true,      // Better double-free detection
}) = .init;

### SmpAllocator

Maximum performance for multithreaded ReleaseFast builds. Few safety features:

```zig
const allocator = std.heap.smp_allocator;
const data = try allocator.alloc(u8, 1000);
allocator.free(data);

### C Allocator

Alternative when `smp_allocator` is not available. Requires linking libc (`-lc`):

```zig
const allocator = std.heap.c_allocator;

### Page Allocator

Requests entire pages from OS via syscall. A 1-byte allocation reserves multiple kibibytes - inefficient for small allocations. Use as backing allocator for `ArenaAllocator` or `DebugAllocator`:

```zig
const allocator = std.heap.page_allocator;

### MemoryPool

Fast allocator for many objects of the same type. Outperforms general-purpose allocators when allocating/freeing objects in rapid succession:

```zig
var pool = std.heap.MemoryPool(MyStruct).init(std.heap.page_allocator);
defer pool.deinit();

// Allocate objects (very fast)
const obj1 = try pool.create();
const obj2 = try pool.create();

// Free returns to pool for reuse (not to backing allocator)
pool.destroy(obj1);

// Reuses freed slot
const obj3 = try pool.create();  // likely same address as obj1

// Reset all - batch destroy without individual frees
_ = pool.reset(.retain_capacity);

**Options:**
```zig
// Pre-allocate slots
var pool = try std.heap.MemoryPool(T).initPreheated(allocator, 100);

// Custom alignment
var pool = std.heap.MemoryPoolAligned(T, .@"64").init(allocator);

// Non-growable (fixed capacity)
var pool = try std.heap.MemoryPoolExtra(T, .{ .growable = false }).initPreheated(allocator, 50);

### ThreadSafeAllocator (removed in 0.16)

**Removed in 0.16.** In 0.16, `ArenaAllocator`'s allocator interface is already thread-safe. For other allocators, use `std.Io.Mutex` or POSIX pthread shims.

Previously wrapped any allocator with mutex for thread safety:

```zig
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();

var ts = std.heap.ThreadSafeAllocator{
    .child_allocator = arena.allocator(),
};
const allocator = ts.allocator();  // Safe to use from multiple threads

### StackFallbackAllocator

Allocates from stack buffer first, falls back to another allocator when exhausted:

```zig
var fallback = std.heap.stackFallback(4096, std.heap.page_allocator);
const allocator = fallback.get();

// First 4KB comes from stack (no heap allocation)
const small = try allocator.alloc(u8, 100);

// Falls back to page_allocator if stack buffer exhausted
const large = try allocator.alloc(u8, 10000);

### raw_c_allocator

Direct malloc/free without alignment overhead. Use as `ArenaAllocator` backing when linking libc:

```zig
// More efficient than c_allocator when wrapping with ArenaAllocator
var arena = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);
defer arena.deinit();

Requires linking libc. Does not support custom alignment - asserts alignment <= `@alignOf(std.c.max_align_t)`.

### Wasm Allocator

Optimized for WebAssembly. Uses `@wasmMemoryGrow`:

```zig
const allocator = std.heap.wasm_allocator;  // Only on wasm32/wasm64

## Page Size Constants

```zig
std.heap.page_size_min  // Comptime minimum page size for target
std.heap.page_size_max  // Comptime maximum page size for target
std.heap.pageSize()     // Runtime page size (may be comptime if min == max)

## Passing Allocators

**In libraries - accept allocator parameter:**

```zig
pub fn MyContainer(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        data: []T,

        pub fn init(allocator: std.mem.Allocator) @This() {
            return .{ .allocator = allocator, .data = &.{} };
        }

        pub fn deinit(self: *@This()) void {
            if (self.data.len > 0) {
                self.allocator.free(self.data);
            }
        }

        pub fn add(self: *@This(), item: T) !void {
            // Use self.allocator for internal allocations
        }
    };
}

**Functions returning allocated memory - document ownership:**

```zig
/// Caller owns returned memory.
pub fn readFile(allocator: Allocator, path: []const u8) ![]u8 {
    // ...
    return try allocator.dupe(u8, content);
}

// Caller must free:
const content = try readFile(allocator, "file.txt");
defer allocator.free(content);

## Common Patterns

### Wrapping Allocators (Sub-Allocators)

```zig
// Arena on top of debug allocator
var gpa: std.heap.DebugAllocator(.{}) = .init;
defer _ = gpa.deinit();

var arena = std.heap.ArenaAllocator.init(gpa.allocator());
defer arena.deinit();

const allocator = arena.allocator();

### Temporary Allocations in Loops

```zig
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();

for (items) |item| {
    // Reset arena each iteration for automatic cleanup
    _ = arena.reset(.retain_capacity);
    const temp = try arena.allocator().alloc(u8, item.size);
    // temp is automatically "freed" on next reset
}

### Sentinel-Terminated Allocations

```zig
// Allocate with null terminator
const str = try allocator.allocSentinel(u8, len, 0);
defer allocator.free(str);

// Duplicate with sentinel
const c_str = try allocator.dupeZ(u8, "hello");  // [:0]u8
defer allocator.free(c_str);

## Error Handling

Always handle `error.OutOfMemory`:

```zig
// Option 1: Propagate
fn process(allocator: Allocator) !void {
    const data = try allocator.alloc(u8, size);
    defer allocator.free(data);
}

// Option 2: Handle gracefully
fn process(allocator: Allocator) void {
    const data = allocator.alloc(u8, size) catch {
        log.err("Out of memory", .{});
        return;
    };
    defer allocator.free(data);
}

## Initialization (0.15.x)

Use `.init` not `.{}`:

```zig
// WRONG - deprecated
var gpa: std.heap.DebugAllocator(.{}) = .{};

// CORRECT
var gpa: std.heap.DebugAllocator(.{}) = .init;

## Debugging Memory Issues

### Leak Detection

```zig
test "check for leaks" {
    // std.testing.allocator automatically reports leaks
    var list: std.ArrayList(u32) = .empty;
    try list.append(std.testing.allocator, 42);
    // Missing: list.deinit(std.testing.allocator);
    // Test will FAIL with leak report
}

### DebugAllocator in Main

```zig
pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer {
        const check = gpa.deinit();
        if (check == .leak) @panic("memory leak");
    }
    try run(gpa.allocator());
}

## Implementing Custom Allocators

Allocators implement `std.mem.Allocator.VTable`:

```zig
const MyAllocator = struct {
    // State fields here

    pub fn allocator(self: *MyAllocator) std.mem.Allocator {
        return .{
            .ptr = self,
            .vtable = &vtable,
        };
    }

    const vtable: std.mem.Allocator.VTable = .{
        .alloc = alloc,
        .resize = resize,
        .remap = remap,
        .free = free,
    };

    fn alloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, ra: usize) ?[*]u8 {
        const self: *MyAllocator = @ptrCast(@alignCast(ctx));
        _ = ra;  // return address for stack traces
        // Return aligned pointer or null
    }

    fn resize(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ra: usize) bool {
        // Return true if resize succeeded in-place
    }

    fn remap(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, new_len: usize, ra: usize) ?[*]u8 {
        // Return new pointer (may move) or null if can't remap
    }

    fn free(ctx: *anyopaque, buf: []u8, alignment: std.mem.Alignment, ra: usize) void {
        // Free memory
    }
};

**Validation wrapper** - for testing allocators:
```zig
var my_alloc = MyAllocator.init();
var validated = std.mem.validationWrap(my_alloc.allocator());
const allocator = validated.allocator();  // Adds safety checks
# std.process - Process Management API Reference

Process spawning, environment variables, argument parsing, and system utilities in Zig 0.15.x.

## Table of Contents
- [Module Structure](#module-structure)
- [Spawning Child Processes](#spawning-child-processes)
- [Environment Variables](#environment-variables)
- [Command Line Arguments](#command-line-arguments)
- [Process Utilities](#process-utilities)
- [Common Patterns](#common-patterns)

## Module Structure

```zig
std.process.Child         // Child process management (spawn, wait, kill)
std.process.EnvMap        // Environment variable hash map
std.process.ArgIterator   // Cross-platform argument iterator
std.process.exit          // Exit process immediately
std.process.abort         // Abort with core dump
std.process.currentPath    // Get current working directory
std.process.getEnvMap     // Snapshot all environment variables
std.process.getEnvVarOwned // Get single environment variable

## Spawning Child Processes

### Basic Spawn and Wait

```zig
var child = std.process.Child.init(&.{ "ls", "-la" }, allocator);
child.cwd = "/tmp";  // optional working directory

try child.spawn();
const term = try child.wait();

switch (term) {
    .Exited => |code| std.debug.print("Exited with {d}\n", .{code}),
    .Signal => |sig| std.debug.print("Killed by signal {d}\n", .{sig}),
    .Stopped => |sig| std.debug.print("Stopped by signal {d}\n", .{sig}),
    .Unknown => |status| std.debug.print("Unknown status {d}\n", .{status}),
}

### Capture Output

```zig
const result = try std.process.Child.run(.{
    .allocator = allocator,
    .argv = &.{ "git", "status", "--short" },
    .cwd = project_dir,               // optional
    .max_output_bytes = 50 * 1024,    // default
});
defer allocator.free(result.stdout);
defer allocator.free(result.stderr);

if (result.term == .Exited and result.term.Exited == 0) {
    std.debug.print("Output: {s}\n", .{result.stdout});
} else {
    std.debug.print("Error: {s}\n", .{result.stderr});
}

### Pipe to/from Child

```zig
var child = std.process.Child.init(&.{ "cat" }, allocator);
child.stdin_behavior = .Pipe;
child.stdout_behavior = .Pipe;
child.stderr_behavior = .Pipe;

try child.spawn();

// Write to child's stdin
var buf: [4096]u8 = undefined;
var writer = child.stdin.?.writer(io, &buf);
try writer.interface.writeAll("Hello from parent\n");
try writer.interface.flush();
child.stdin.?.close();
child.stdin = null;

// Read child's stdout
var stdout: std.ArrayList(u8) = .empty;
defer stdout.deinit(allocator);
var stderr: std.ArrayList(u8) = .empty;
defer stderr.deinit(allocator);

try child.collectOutput(allocator, &stdout, &stderr, 50 * 1024);
const term = try child.wait();

### StdIo Behaviors

```zig
child.stdin_behavior = .Inherit;  // share parent's stdin (default)
child.stdin_behavior = .Pipe;     // create pipe for communication
child.stdin_behavior = .Ignore;   // /dev/null
child.stdin_behavior = .Close;    // no stdin

// Same options for stdout_behavior and stderr_behavior

### Spawn with Custom Environment

```zig
var env = std.process.EnvMap.init(allocator);
defer env.deinit();
try env.put("PATH", "/usr/bin:/bin");
try env.put("MY_VAR", "value");

var child = std.process.Child.init(&.{ "my_program" }, allocator);
child.env_map = &env;
try child.spawn();

### Set Working Directory

```zig
var child = std.process.Child.init(&.{ "make" }, allocator);

// Option 1: path string
child.cwd = "/path/to/project";

// Option 2: directory handle (not yet on Windows)
var dir = try std.Io.Dir.cwd().openDir(io, "project", .{});
defer dir.close();
child.cwd_dir = dir;

try child.spawn();

### Kill Child Process

```zig
var child = std.process.Child.init(&.{ "sleep", "100" }, allocator);
try child.spawn();

// ... later
const term = try child.kill();  // sends SIGTERM on POSIX

### Resource Usage Statistics

```zig
var child = std.process.Child.init(&.{ "heavy_computation" }, allocator);
child.request_resource_usage_statistics = true;

try child.spawn();
_ = try child.wait();

if (child.resource_usage_statistics.getMaxRss()) |rss| {
    std.debug.print("Peak memory: {d} bytes\n", .{rss});
}

### POSIX-only: Change User/Group

```zig
var child = std.process.Child.init(&.{ "daemon" }, allocator);

// By name
try child.setUserName("nobody");

// Or directly
child.uid = 65534;
child.gid = 65534;
child.pgid = 0;  // create new process group

try child.spawn();

### Windows-only Options

```zig
var child = std.process.Child.init(&.{ "app.exe" }, allocator);
child.create_no_window = true;   // hide console window
child.start_suspended = true;    // start paused
try child.spawn();

### Darwin-only: Disable ASLR

```zig
var child = std.process.Child.init(&.{ "debugee" }, allocator);
child.disable_aslr = true;
try child.spawn();

## Environment Variables

### Get Single Variable

```zig
// With allocation (caller owns memory)
const home = try std.process.getEnvVarOwned(allocator, "HOME");
defer allocator.free(home);

// Check existence without allocation
if (std.process.hasEnvVarConstant("DEBUG")) {
    // DEBUG is set
}

// Check with dynamic key
const has_it = try std.process.hasEnvVar(allocator, key);

// Check non-empty
if (std.process.hasNonEmptyEnvVarConstant("PATH")) {
    // PATH is set and not empty
}

// Parse as integer
const port = std.process.parseEnvVarInt("PORT", u16, 10) catch 8080;

### Get All Variables

```zig
var env = try std.process.getEnvMap(allocator);
defer env.deinit();

// Iterate
var it = env.iterator();
while (it.next()) |entry| {
    std.debug.print("{s}={s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
}

// Lookup
if (env.get("PATH")) |path| {
    std.debug.print("PATH={s}\n", .{path});
}

### EnvMap Operations

```zig
var env = std.process.EnvMap.init(allocator);
defer env.deinit();

// Add/update (copies key and value)
try env.put("KEY", "value");

// Add/update (takes ownership, avoids copy)
const key = try allocator.dupe(u8, "KEY");
const val = try allocator.dupe(u8, "value");
try env.putMove(key, val);  // env now owns key and val

// Lookup
const value = env.get("KEY");       // ?[]const u8
const ptr = env.getPtr("KEY");      // ?*[]const u8

// Remove
env.remove("KEY");

// Count
const n = env.count();

**Note**: On Windows, environment variable names are case-insensitive. EnvMap handles this automatically.

## Command Line Arguments

### Cross-platform Iterator

```zig
// With allocator (required on Windows/WASI)
var args = try std.process.argsWithAllocator(allocator);
defer args.deinit();

// Skip program name
_ = args.skip();

while (args.next()) |arg| {
    std.debug.print("arg: {s}\n", .{arg});
}

### Get All Arguments as Slice

```zig
const argv = try std.process.argsAlloc(allocator);
defer std.process.argsFree(allocator, argv);

const program = argv[0];
for (argv[1..]) |arg| {
    // process arg
}

### POSIX-only (no allocation)

```zig
var args = std.process.ArgIterator.init();
while (args.next()) |arg| {
    std.debug.print("{s}\n", .{arg});
}

### Parse Response Files (shell-style)

```zig
const ArgParser = std.process.ArgIteratorGeneral(.{
    .comments = true,       // skip # comments
    .single_quotes = true,  // support 'quoted args'
});

var parser = try ArgParser.init(allocator, response_file_content);
defer parser.deinit();

while (parser.next()) |arg| {
    // process arg
}

## Process Utilities

### Current Working Directory

```zig
// Into provided buffer
var buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
const cwd_len = try std.process.currentPath(io, &buf);
const cwd = buf[0..cwd_len];

// With allocation
const cwd = try std.process.currentPathAlloc(io, allocator);
defer allocator.free(cwd);

### Exit Process

```zig
// Clean exit (in release: immediate exit; in debug: returns to allow cleanup testing)
std.process.cleanExit();

// Immediate exit with code
std.process.exit(0);   // success
std.process.exit(1);   // failure

// Abort (generates core dump on POSIX)
std.process.abort();

### Replace Current Process (POSIX only)

```zig
// Replace with new program (never returns on success)
std.process.execv(allocator, &.{ "/bin/sh", "-c", "echo hello" }) catch |err| {
    std.debug.print("exec failed: {}\n", .{err});
    std.process.exit(1);
};

// With custom environment
var env = std.process.EnvMap.init(allocator);
try env.put("PATH", "/bin");
std.process.execve(allocator, &.{ "my_program" }, &env) catch |err| {
    // handle error
};

### System Memory

```zig
const mem = try std.process.totalSystemMemory();
std.debug.print("Total RAM: {d} bytes\n", .{mem});

### User Information (POSIX only)

```zig
const info = try std.process.getUserInfo("nobody");
std.debug.print("uid={d} gid={d}\n", .{ info.uid, info.gid });

### Raise File Descriptor Limit

```zig
// Attempt to raise NOFILE limit (no-op on unsupported platforms)
std.process.raiseFileDescriptorLimit();

### Check Spawning Support

```zig
if (std.process.can_spawn) {
    // Can use Child.spawn()
}

if (std.process.can_execv) {
    // Can use execv/execve
}

## Common Patterns

### Run Command and Check Success

```zig
fn runCommand(allocator: Allocator, argv: []const []const u8) !void {
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
    });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    if (result.term != .Exited or result.term.Exited != 0) {
        std.debug.print("Command failed:\n{s}\n", .{result.stderr});
        return error.CommandFailed;
    }
}

### Pipe Between Processes

```zig
fn pipeCommands(allocator: Allocator) ![]u8 {
    // First command: generate output
    var producer = std.process.Child.init(&.{ "echo", "hello world" }, allocator);
    producer.stdout_behavior = .Pipe;
    try producer.spawn();

    // Second command: process output
    var consumer = std.process.Child.init(&.{ "tr", "a-z", "A-Z" }, allocator);
    consumer.stdin_behavior = .Pipe;
    consumer.stdout_behavior = .Pipe;
    try consumer.spawn();

    // Connect them (copy producer stdout to consumer stdin)
    var buf: [4096]u8 = undefined;
    while (true) {
        const n = try producer.stdout.?.read(&buf);
        if (n == 0) break;
        try consumer.stdin.?.writeAll(buf[0..n]);
    }
    consumer.stdin.?.close();
    consumer.stdin = null;

    // Collect result
    var stdout: std.ArrayList(u8) = .empty;
    var stderr: std.ArrayList(u8) = .empty;
    defer stderr.deinit(allocator);
    try consumer.collectOutput(allocator, &stdout, &stderr, 50 * 1024);

    _ = try producer.wait();
    _ = try consumer.wait();

    return stdout.toOwnedSlice(allocator);
}

### Environment Variable Fallback Chain

```zig
fn getConfigPath(allocator: Allocator) ![]const u8 {
    // Try specific var first
    if (std.process.getEnvVarOwned(allocator, "MY_APP_CONFIG")) |path| {
        return path;
    } else |_| {}

    // Fall back to XDG
    if (std.process.getEnvVarOwned(allocator, "XDG_CONFIG_HOME")) |xdg| {
        defer allocator.free(xdg);
        return std.Io.Dir.path.join(allocator, &.{ xdg, "myapp", "config.json" });
    } else |_| {}

    // Fall back to HOME
    const home = try std.process.getEnvVarOwned(allocator, "HOME");
    defer allocator.free(home);
    return std.Io.Dir.path.join(allocator, &.{ home, ".config", "myapp", "config.json" });
}

### Process Pool / Parallel Execution

```zig
fn runParallel(allocator: Allocator, commands: []const []const []const u8) !void {
    var children: std.ArrayList(std.process.Child) = .empty;
    defer children.deinit(allocator);

    // Start all processes
    for (commands) |argv| {
        var child = std.process.Child.init(argv, allocator);
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Pipe;
        try child.spawn();
        try children.append(allocator, child);
    }

    // Wait for all
    for (children.items) |*child| {
        const term = try child.wait();
        if (term != .Exited or term.Exited != 0) {
            return error.ChildFailed;
        }
    }
}

### Argument Parsing with Flags

```zig
pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip(); // skip program name

    var verbose = false;
    var output: ?[]const u8 = null;
    var positional: std.ArrayList([]const u8) = .empty;
    defer positional.deinit(allocator);

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--verbose")) {
            verbose = true;
        } else if (std.mem.eql(u8, arg, "-o")) {
            output = args.next() orelse return error.MissingOutputArg;
        } else if (std.mem.startsWith(u8, arg, "-")) {
            std.debug.print("Unknown option: {s}\n", .{arg});
            return error.InvalidArgument;
        } else {
            try positional.append(allocator, arg);
        }
    }

    // Use parsed arguments...
}

### Spawn with Timeout

```zig
fn runWithTimeout(allocator: Allocator, argv: []const []const u8, timeout_ns: u64) !std.process.Child.Term {
    var child = std.process.Child.init(argv, allocator);
    try child.spawn();

    const start = std.time.nanoTimestamp();
    while (true) {
        // Non-blocking wait check
        if (child.term) |term| {
            return term;
        }

        const elapsed: u64 = @intCast(std.time.nanoTimestamp() - start);
        if (elapsed > timeout_ns) {
            return child.kill();
        }

        std.time.sleep(10 * std.time.ns_per_ms);  // poll every 10ms
    }
}
# std.Thread - Threading and Concurrency API Reference (0.15.x → 0.16)

Thread spawning, synchronization primitives, and concurrent programming in Zig 0.15.x.

## Critical: Mutex, Condition, sleep Removed (0.16)

In Zig 0.16, `std.Thread.Mutex`, `std.Thread.Condition`, and `std.Thread.sleep` are **removed**. The 0.16 replacements (`std.Io.Mutex` / `std.Io.Condition`) require an `Io` instance, which is not always available (e.g. in libraries/vendored deps).

**POSIX shims (portable fallback):**

```zig
const PthreadMutex = struct {
    inner: std.c.pthread_mutex_t = std.c.PTHREAD_MUTEX_INITIALIZER,
    pub fn lock(m: *@This()) void { _ = std.c.pthread_mutex_lock(&m.inner); }
    pub fn unlock(m: *@This()) void { _ = std.c.pthread_mutex_unlock(&m.inner); }
    pub fn tryLock(m: *@This()) bool {
        return @intFromEnum(std.c.pthread_mutex_trylock(&m.inner)) == 0;
    }
};

const PthreadCondition = struct {
    inner: std.c.pthread_cond_t = std.c.PTHREAD_COND_INITIALIZER,
    pub fn signal(c: *@This()) void { _ = std.c.pthread_cond_signal(&c.inner); }
    pub fn broadcast(c: *@This()) void { _ = std.c.pthread_cond_broadcast(&c.inner); }
    pub fn timedWait(cond: *@This(), mutex: *PthreadMutex, timeout_ns: u64) !void {
        var ts: std.c.timespec = undefined;
        _ = std.c.clock_gettime(.REALTIME, &ts);
        const now_ns: u128 = @as(u128, @intCast(ts.sec)) * 1_000_000_000 +
                              @as(u128, @intCast(ts.nsec));
        const deadline = std.c.timespec{
            .sec = @intCast((now_ns + timeout_ns) / 1_000_000_000),
            .nsec = @intCast((now_ns + timeout_ns) % 1_000_000_000),
        };
        const rc = std.c.pthread_cond_timedwait(&cond.inner, &mutex.inner, &deadline);
        if (@intFromEnum(rc) == @intFromEnum(std.c.E.TIMEDOUT)) return error.Timeout;
    }
};

fn threadSleep(ns: u64) void {
    const ts = std.c.timespec{
        .sec = @intCast(ns / std.time.ns_per_s),
        .nsec = @intCast(ns % std.time.ns_per_s),
    };
    _ = std.c.nanosleep(&ts, null);
}

**Still present in 0.16:** `std.Thread.spawn`, `std.Thread.Pool`, `std.Thread.WaitGroup`, `std.Thread.ResetEvent`, `std.Thread.Semaphore`, `std.Thread.RwLock`, `std.Thread.Futex`.

## Table of Contents
- [Module Structure](#module-structure)
- [Spawning Threads](#spawning-threads)
- [Thread Utilities](#thread-utilities)
- [Synchronization Primitives](#synchronization-primitives)
  - [Mutex](#mutex)
  - [RwLock](#rwlock)
  - [Condition](#condition)
  - [Semaphore](#semaphore)
  - [ResetEvent](#resetevent)
  - [WaitGroup](#waitgroup)
- [Thread Pool](#thread-pool)
- [Common Patterns](#common-patterns)

## Module Structure

```zig
std.Thread                  // Thread spawning and management
std.Thread.Mutex            // Mutual exclusion lock
std.Thread.Mutex.Recursive  // Recursive mutex (same thread can lock multiple times)
std.Thread.RwLock           // Reader-writer lock
std.Thread.Condition        // Condition variable for signaling
std.Thread.Semaphore        // Counting semaphore
std.Thread.ResetEvent       // Boolean event flag with blocking
std.Thread.WaitGroup        // Wait for multiple tasks to complete
std.Thread.Pool             // Thread pool for parallel task execution
std.Thread.Futex            // Low-level futex operations (advanced)

> **0.16 Note:** `std.Thread.Mutex`, `std.Thread.Mutex.Recursive`, and `std.Thread.Condition` are removed in Zig 0.16. Use `std.Io.Mutex` / `std.Io.Condition` (requires an `Io` instance) or the POSIX pthread shims shown in the migration section above.

## Spawning Threads

### Basic Thread Spawn

```zig
const std = @import("std");

fn workerFn(id: usize) void {
    std.debug.print("Worker {d} running\n", .{id});
}

pub fn main() !void {
    const thread = try std.Thread.spawn(.{}, workerFn, .{42});
    thread.join();  // wait for completion
}

### Thread with Return Value

```zig
fn compute(x: i32) void {
    // Zig threads don't return values directly
    // Use shared state or channels for results
}

### Detached Threads

```zig
const thread = try std.Thread.spawn(.{}, workerFn, .{1});
thread.detach();  // thread cleans up itself on completion
// Cannot call join() after detach()

### Spawn Configuration

```zig
const thread = try std.Thread.spawn(.{
    .stack_size = 8 * 1024 * 1024,  // 8 MB stack (default: 16 MB)
    .allocator = allocator,          // required on WASI
}, workerFn, .{args});

### Thread Function Signatures

```zig
// Valid return types: void, !void, u8, noreturn
fn worker1() void { }
fn worker2() !void { return error.Failed; }
fn worker3() u8 { return 0; }  // exit status (ignored on pthreads)
fn worker4() noreturn { while (true) {} }

## Thread Utilities

### Get Current Thread ID

```zig
const id = std.Thread.getCurrentId();
std.debug.print("Thread ID: {d}\n", .{id});

### Get CPU Count

```zig
const cpu_count = std.Thread.getCpuCount() catch 1;
std.debug.print("CPUs: {d}\n", .{cpu_count});

### Sleep

**Note (0.16):** `std.Thread.sleep` is removed. Use `nanosleep` via `std.c.nanosleep` (see migration section above).

```zig
std.Thread.sleep(100 * std.time.ns_per_ms);  // sleep 100ms
std.Thread.sleep(std.time.ns_per_s);          // sleep 1 second

### Yield

```zig
std.Thread.yield() catch {};  // hint to scheduler

### Thread Names (Platform-dependent)

```zig
var thread = try std.Thread.spawn(.{}, worker, .{});

// Set thread name (max length varies by OS)
try thread.setName("worker-1");

// Get thread name
var name_buf: [std.Thread.max_name_len:0]u8 = undefined;
if (try thread.getName(&name_buf)) |name| {
    std.debug.print("Thread name: {s}\n", .{name});
}

## Synchronization Primitives

### Mutex

**Note (0.16):** `std.Thread.Mutex` is removed in Zig 0.16. Use `PthreadMutex` shim (see migration section above) or `std.Io.Mutex` if you have an `Io` instance.

Basic mutual exclusion lock. Use `defer` for exception-safe unlocking.

```zig
var mutex: std.Thread.Mutex = .{};
var shared_data: u64 = 0;

fn increment() void {
    mutex.lock();
    defer mutex.unlock();
    shared_data += 1;
}

// tryLock for non-blocking acquisition
if (mutex.tryLock()) {
    defer mutex.unlock();
    // critical section
} else {
    // lock not acquired
}

**Debug mode**: Detects deadlocks when same thread tries to lock twice.

#### Recursive Mutex

Allows same thread to lock multiple times (must unlock same number of times).

```zig
var rmutex: std.Thread.Mutex.Recursive = .{};

fn outer() void {
    rmutex.lock();
    defer rmutex.unlock();
    inner();  // can lock again
}

fn inner() void {
    rmutex.lock();
    defer rmutex.unlock();
    // ...
}

### RwLock

Reader-writer lock: multiple readers OR one writer.

```zig
var rwlock: std.Thread.RwLock = .{};
var data: []const u8 = "initial";

fn reader() void {
    rwlock.lockShared();
    defer rwlock.unlockShared();
    // read data safely (multiple readers allowed)
    _ = data;
}

fn writer(new_data: []const u8) void {
    rwlock.lock();
    defer rwlock.unlock();
    // exclusive write access
    data = new_data;
}

// Non-blocking variants
if (rwlock.tryLockShared()) {
    defer rwlock.unlockShared();
    // read
}

if (rwlock.tryLock()) {
    defer rwlock.unlock();
    // write
}

### Condition

**Note (0.16):** `std.Thread.Condition` is removed in Zig 0.16. Use `PthreadCondition` shim (see migration section above) or `std.Io.Condition` if you have an `Io` instance.

Wait for a condition to become true. Always use with a Mutex.

```zig
var mutex: std.Thread.Mutex = .{};
var cond: std.Thread.Condition = .{};
var ready = false;

fn consumer() void {
    mutex.lock();
    defer mutex.unlock();

    // Wait in a loop (handles spurious wakeups)
    while (!ready) {
        cond.wait(&mutex);  // atomically unlocks, waits, relocks
    }
    // Process data
}

fn producer() void {
    {
        mutex.lock();
        defer mutex.unlock();
        ready = true;
    }
    cond.signal();     // wake one waiter
    // cond.broadcast(); // wake all waiters
}

#### Timed Wait

```zig
fn timedConsumer() !void {
    mutex.lock();
    defer mutex.unlock();

    while (!ready) {
        cond.timedWait(&mutex, 5 * std.time.ns_per_s) catch |err| switch (err) {
            error.Timeout => return error.TimedOut,
        };
    }
}

### Semaphore

Counting semaphore for resource limiting.

```zig
var sem: std.Thread.Semaphore = .{ .permits = 3 };  // 3 permits available

fn worker() void {
    sem.wait();     // acquire permit (blocks if 0)
    defer sem.post();  // release permit
    // use limited resource
}

// Timed wait
sem.timedWait(1 * std.time.ns_per_s) catch |err| switch (err) {
    error.Timeout => { /* handle timeout */ },
};

### ResetEvent

Boolean flag with blocking wait. Useful for one-shot signaling.

```zig
var event: std.Thread.ResetEvent = .{};

fn waiter() void {
    event.wait();  // blocks until set
    // event.isSet() returns true
}

fn signaler() void {
    event.set();   // unblocks all waiters
}

// Reset for reuse
event.reset();

// Check without blocking
if (event.isSet()) {
    // already signaled
}

// Timed wait
event.timedWait(1 * std.time.ns_per_s) catch |err| switch (err) {
    error.Timeout => { /* handle timeout */ },
};

### WaitGroup

Wait for multiple concurrent tasks to complete.

```zig
var wg: std.Thread.WaitGroup = .{};

fn spawnTasks() void {
    for (0..10) |i| {
        wg.start();  // increment counter before spawning
        _ = std.Thread.spawn(.{}, task, .{ &wg, i }) catch {
            wg.finish();  // decrement if spawn fails
            continue;
        };
    }
}

fn task(wait_group: *std.Thread.WaitGroup, id: usize) void {
    defer wait_group.finish();  // always decrement when done
    // do work
    _ = id;
}

pub fn main() !void {
    spawnTasks();
    wg.wait();  // blocks until all tasks finish
}

#### Batch Operations

```zig
wg.startMany(10);  // increment by 10

// Check if done without blocking
if (wg.isDone()) {
    // all tasks completed
}

// Reset for reuse
wg.reset();

#### Spawn Manager Pattern

```zig
var wg: std.Thread.WaitGroup = .{};

// Spawns a detached thread that decrements wg on completion
wg.spawnManager(someFunc, .{arg1, arg2});

wg.wait();  // wait for manager and all its work

## Thread Pool

Reusable pool of worker threads for parallel task execution.

### Basic Usage

```zig
var pool: std.Thread.Pool = undefined;
try pool.init(.{
    .allocator = allocator,
    .n_jobs = null,  // default: CPU count
});
defer pool.deinit();

var wg: std.Thread.WaitGroup = .{};

// Queue work
for (items) |item| {
    pool.spawnWg(&wg, processItem, .{item});
}

// Wait for all work to complete
wg.wait();
// Or: participate in work while waiting
pool.waitAndWork(&wg);

### Pool Options

```zig
try pool.init(.{
    .allocator = allocator,
    .n_jobs = 4,              // number of worker threads (default: CPU count)
    .track_ids = true,        // enable thread IDs for spawnWgId
    .stack_size = 8 * 1024 * 1024,  // worker stack size
});

### Spawn Variants

```zig
// Basic spawn (fire and forget, may fallback to sync)
try pool.spawn(func, .{args});

// With WaitGroup tracking
pool.spawnWg(&wg, func, .{args});

// With thread ID (requires track_ids = true)
pool.spawnWgId(&wg, funcWithId, .{args});

fn funcWithId(thread_id: usize, args: anytype) void {
    // thread_id is dense 0..n_jobs
    _ = thread_id;
    _ = args;
}

### Get Thread Count

```zig
const total_threads = pool.getIdCount();  // 1 + n_jobs (includes main)

## Common Patterns

### Producer-Consumer Queue

```zig
fn BoundedQueue(comptime T: type, comptime capacity: usize) type {
    return struct {
        buffer: [capacity]T = undefined,
        head: usize = 0,
        tail: usize = 0,
        count: usize = 0,

        mutex: std.Thread.Mutex = .{},
        not_empty: std.Thread.Condition = .{},
        not_full: std.Thread.Condition = .{},

        pub fn push(self: *@This(), item: T) void {
            self.mutex.lock();
            defer self.mutex.unlock();

            while (self.count == capacity) {
                self.not_full.wait(&self.mutex);
            }

            self.buffer[self.tail] = item;
            self.tail = (self.tail + 1) % capacity;
            self.count += 1;

            self.not_empty.signal();
        }

        pub fn pop(self: *@This()) T {
            self.mutex.lock();
            defer self.mutex.unlock();

            while (self.count == 0) {
                self.not_empty.wait(&self.mutex);
            }

            const item = self.buffer[self.head];
            self.head = (self.head + 1) % capacity;
            self.count -= 1;

            self.not_full.signal();
            return item;
        }
    };
}

### Thread-Safe Counter

```zig
const Counter = struct {
    value: std.atomic.Value(u64) = std.atomic.Value(u64).init(0),

    pub fn increment(self: *@This()) void {
        _ = self.value.fetchAdd(1, .monotonic);
    }

    pub fn get(self: *const @This()) u64 {
        return self.value.load(.monotonic);
    }
};

### Parallel Map

```zig
fn parallelMap(
    pool: *std.Thread.Pool,
    allocator: std.mem.Allocator,
    comptime T: type,
    comptime U: type,
    items: []const T,
    comptime mapFn: fn (T) U,
) ![]U {
    const results = try allocator.alloc(U, items.len);
    var wg: std.Thread.WaitGroup = .{};

    for (items, 0..) |item, i| {
        pool.spawnWg(&wg, struct {
            fn work(r: []U, idx: usize, val: T) void {
                r[idx] = mapFn(val);
            }
        }.work, .{ results, i, item });
    }

    pool.waitAndWork(&wg);
    return results;
}

### Once Initialization

```zig
var initialized = std.atomic.Value(bool).init(false);
var init_mutex: std.Thread.Mutex = .{};
var global_resource: ?*Resource = null;

fn getResource() *Resource {
    // Fast path: already initialized
    if (initialized.load(.acquire)) {
        return global_resource.?;
    }

    init_mutex.lock();
    defer init_mutex.unlock();

    // Double-check after acquiring lock
    if (!initialized.load(.acquire)) {
        global_resource = initializeResource();
        initialized.store(true, .release);
    }

    return global_resource.?;
}

### Barrier Synchronization

```zig
const Barrier = struct {
    event: std.Thread.ResetEvent = .{},
    counter: std.atomic.Value(usize),

    pub fn init(count: usize) @This() {
        return .{ .counter = std.atomic.Value(usize).init(count) };
    }

    pub fn wait(self: *@This()) void {
        if (self.counter.fetchSub(1, .acq_rel) == 1) {
            self.event.set();  // last thread signals all
        } else {
            self.event.wait();  // others wait
        }
    }
};

### Scoped Lock Helper

```zig
fn withLock(mutex: *std.Thread.Mutex, comptime func: anytype, args: anytype) @TypeOf(@call(.auto, func, args)) {
    mutex.lock();
    defer mutex.unlock();
    return @call(.auto, func, args);
}

// Usage
const result = withLock(&mutex, computeValue, .{x, y});

### Thread-Local Storage

```zig
threadlocal var tls_buffer: [1024]u8 = undefined;
threadlocal var tls_counter: usize = 0;

fn perThreadWork() void {
    tls_counter += 1;  // each thread has its own counter
    // use tls_buffer for thread-local scratch space
}
# std.crypto - Cryptography Library

Comprehensive cryptographic primitives: hashing, encryption, signatures, key exchange, password hashing, and secure utilities.

## Quick Reference

| Category | Types/Functions |
|----------|-----------------|
| **Hash** | `hash.sha2.Sha256`, `hash.sha2.Sha512`, `hash.sha3.*`, `hash.Blake3`, `hash.blake2.*`, `hash.Md5`, `hash.Sha1` |
| **AEAD** | `aead.aes_gcm.Aes256Gcm`, `aead.chacha_poly.ChaCha20Poly1305`, `aead.aegis.*` |
| **MAC** | `auth.hmac.*`, `auth.siphash.*`, `auth.cmac.*` |
| **Signatures** | `sign.Ed25519`, `sign.ecdsa.*` |
| **Key Exchange** | `dh.X25519` |
| **KEM** | `kem.ml_kem.*` (post-quantum) |
| **Password** | `pwhash.argon2`, `pwhash.scrypt`, `pwhash.bcrypt`, `pwhash.pbkdf2` |
| **KDF** | `kdf.hkdf.HkdfSha256`, `kdf.hkdf.HkdfSha512` |
| **Random** | `random` (thread-local CSPRNG) |
| **Utilities** | `secureZero`, `timing_safe.*`, `codecs.*` |

## Choosing Algorithms

Need encryption?
├─ With authentication → AEAD (Aes256Gcm, ChaCha20Poly1305)
└─ Stream only → stream.chacha.* (usually want AEAD instead)

Need hashing?
├─ General purpose → Sha256, Sha512, Blake3
├─ Password storage → argon2, scrypt, bcrypt
└─ Legacy compatibility → Md5, Sha1 (NOT secure for new designs)

Need signatures?
├─ Standard choice → Ed25519
└─ ECDSA compatibility → ecdsa.EcdsaP256Sha256

Need key exchange?
├─ Standard choice → X25519
└─ Post-quantum → ml_kem.* (Kyber)

Need MAC?
├─ With key → HmacSha256, HmacSha512
└─ Hash table keying → siphash

## Hashing

### SHA-2 Family

```zig
const std = @import("std");
const sha2 = std.crypto.hash.sha2;

// One-shot hashing
var digest: [sha2.Sha256.digest_length]u8 = undefined;
sha2.Sha256.hash("hello world", &digest, .{});

// Streaming (incremental)
var hasher = sha2.Sha256.init(.{});
hasher.update("hello ");
hasher.update("world");
hasher.final(&digest);

// Peek at intermediate digest without consuming state
const intermediate = hasher.peek();

Available: `Sha224`, `Sha256`, `Sha384`, `Sha512`, `Sha512_224`, `Sha512_256`

### SHA-3 Family

```zig
const sha3 = std.crypto.hash.sha3;

var digest: [sha3.Sha3_256.digest_length]u8 = undefined;
sha3.Sha3_256.hash("data", &digest, .{});

// SHAKE (extendable output)
var shake = sha3.Shake128.init(.{});
shake.update("data");
var output: [64]u8 = undefined;
shake.squeeze(&output);

Available: `Sha3_224`, `Sha3_256`, `Sha3_384`, `Sha3_512`, `Shake128`, `Shake256`, `Keccak256`, `Keccak512`

### Blake3

```zig
const Blake3 = std.crypto.hash.Blake3;

// Standard hashing
var digest: [Blake3.digest_length]u8 = undefined;
Blake3.hash("data", &digest, .{});

// Keyed hashing (MAC)
var keyed: [Blake3.digest_length]u8 = undefined;
Blake3.hash("data", &keyed, .{ .key = key });

// Key derivation
var derived: [32]u8 = undefined;
Blake3.hash("material", &derived, .{ .context = "my app v1 key derivation" });

### Blake2

```zig
const blake2 = std.crypto.hash.blake2;

// Blake2b (64-byte output)
var digest: [blake2.Blake2b256.digest_length]u8 = undefined;
blake2.Blake2b256.hash("data", &digest, .{});

// With key
blake2.Blake2b256.hash("data", &digest, .{ .key = key });

Available: `Blake2b128`, `Blake2b256`, `Blake2b384`, `Blake2b512`, `Blake2s128`, `Blake2s224`, `Blake2s256`

## AEAD (Authenticated Encryption)

### AES-GCM

```zig
const Aes256Gcm = std.crypto.aead.aes_gcm.Aes256Gcm;

// Encryption
var ciphertext: [plaintext.len]u8 = undefined;
var tag: [Aes256Gcm.tag_length]u8 = undefined;
Aes256Gcm.encrypt(&ciphertext, &tag, plaintext, associated_data, nonce, key);

// Decryption
var decrypted: [ciphertext.len]u8 = undefined;
try Aes256Gcm.decrypt(&decrypted, &ciphertext, tag, associated_data, nonce, key);
// Returns error.AuthenticationFailed if tag doesn't verify

Key constants:
- `key_length`: 32 bytes (256 bits)
- `nonce_length`: 12 bytes
- `tag_length`: 16 bytes

### ChaCha20-Poly1305

```zig
const ChaCha20Poly1305 = std.crypto.aead.chacha_poly.ChaCha20Poly1305;

var ciphertext: [msg.len]u8 = undefined;
var tag: [ChaCha20Poly1305.tag_length]u8 = undefined;

ChaCha20Poly1305.encrypt(&ciphertext, &tag, msg, ad, nonce, key);
try ChaCha20Poly1305.decrypt(&decrypted, &ciphertext, tag, ad, nonce, key);

Key constants:
- `key_length`: 32 bytes
- `nonce_length`: 12 bytes (IETF) or 24 bytes (XChaCha)
- `tag_length`: 16 bytes

Available variants:
- `ChaCha20Poly1305` - Standard IETF
- `XChaCha20Poly1305` - Extended nonce (24 bytes, better for random nonces)
- `ChaCha12Poly1305`, `ChaCha8Poly1305` - Reduced rounds (faster, lower security margin)

### AEGIS

High-performance AEAD designed for modern CPUs with AES-NI:

```zig
const Aegis256 = std.crypto.aead.aegis.Aegis256;

var ciphertext: [msg.len]u8 = undefined;
var tag: [Aegis256.tag_length]u8 = undefined;

Aegis256.encrypt(&ciphertext, &tag, msg, ad, nonce, key);
try Aegis256.decrypt(&decrypted, &ciphertext, tag, ad, nonce, key);

## Message Authentication (MAC)

### HMAC

```zig
const HmacSha256 = std.crypto.auth.hmac.sha2.HmacSha256;

// One-shot
var mac: [HmacSha256.mac_length]u8 = undefined;
HmacSha256.create(&mac, message, key);

// Streaming
var hmac = HmacSha256.init(key);
hmac.update(data1);
hmac.update(data2);
hmac.final(&mac);

Available: `HmacMd5`, `HmacSha1`, `HmacSha224`, `HmacSha256`, `HmacSha384`, `HmacSha512`

### SipHash

Fast MAC for hash table keying (not for general authentication):

```zig
const SipHash = std.crypto.auth.siphash.SipHash64(2, 4);

const hash = SipHash.hash(key, data);

## Digital Signatures

### Ed25519

```zig
const Ed25519 = std.crypto.sign.Ed25519;

// Generate key pair
const kp = Ed25519.KeyPair.generate();

// Sign message
const sig = kp.sign(message, null);

// Verify signature
try kp.public_key.verify(sig, message);
// Returns error.SignatureVerificationFailed on failure

// Incremental signing (large messages)
var signer = try kp.signer(null);
signer.update(chunk1);
signer.update(chunk2);
const sig2 = signer.finalize();

Key lengths:
- Secret key: 64 bytes
- Public key: 32 bytes
- Signature: 64 bytes

### ECDSA

```zig
const EcdsaP256Sha256 = std.crypto.sign.ecdsa.EcdsaP256Sha256;

// Generate key pair
const kp = EcdsaP256Sha256.KeyPair.generate();

// Sign
const sig = try kp.sign(message, null);

// Verify
try sig.verify(message, kp.public_key);

Available: `EcdsaP256Sha256`, `EcdsaP256Sha3_256`, `EcdsaP384Sha384`, `EcdsaP384Sha3_384`, `EcdsaSecp256k1Sha256`

## Key Exchange

### X25519 (Diffie-Hellman)

```zig
const X25519 = std.crypto.dh.X25519;

// Generate key pairs for Alice and Bob
const alice = X25519.KeyPair.generate();
const bob = X25519.KeyPair.generate();

// Compute shared secret
const alice_shared = try X25519.scalarmult(alice.secret_key, bob.public_key);
const bob_shared = try X25519.scalarmult(bob.secret_key, alice.public_key);
// alice_shared == bob_shared

// IMPORTANT: Hash the shared secret before use
var key: [32]u8 = undefined;
std.crypto.hash.sha2.Sha256.hash(&alice_shared, &key, .{});

### ML-KEM (Post-Quantum)

```zig
const MlKem768 = std.crypto.kem.ml_kem.MlKem768;

// Key generation
const kp = MlKem768.KeyPair.generate();

// Encapsulation (sender)
const encaps = kp.public_key.encaps(null);
const shared_secret = encaps.shared_secret;
const ciphertext = encaps.ciphertext;

// Decapsulation (receiver)
const decaps_secret = try kp.secret_key.decaps(ciphertext);
// shared_secret == decaps_secret

Available: `MlKem512`, `MlKem768`, `MlKem1024`

## Key Derivation

### HKDF

```zig
const HkdfSha256 = std.crypto.kdf.hkdf.HkdfSha256;

// Extract: derive pseudorandom key from input keying material
const prk = HkdfSha256.extract(salt, input_key_material);

// Expand: derive output key from PRK
var output_key: [32]u8 = undefined;
HkdfSha256.expand(&output_key, context_info, prk);

// Streaming extract (large IKM)
var hkdf = HkdfSha256.extractInit(salt);
hkdf.update(ikm_part1);
hkdf.update(ikm_part2);
var prk2: [HkdfSha256.prk_length]u8 = undefined;
hkdf.final(&prk2);

## Password Hashing

### Argon2

Memory-hard password hashing (recommended for new applications):

```zig
const argon2 = std.crypto.pwhash.argon2;

// Hash password
var hash: [32]u8 = undefined;
try argon2.kdf(
    allocator,
    &hash,
    password,
    salt,
    .{
        .t = 3,      // time cost (iterations)
        .m = 65536,  // memory cost (KiB)
        .p = 4,      // parallelism
    },
    .argon2id,  // mode: argon2i, argon2d, or argon2id
);

// Use preset parameters
try argon2.kdf(allocator, &hash, password, salt, argon2.Params.interactive_2id, .argon2id);

// PHC string format (for storage)
var buf: [128]u8 = undefined;
const encoded = try argon2.strHash(password, salt, .interactive_2id, .argon2id, &buf);
// Returns: "$argon2id$v=19$m=65536,t=3,p=4$..."

// Verify PHC-encoded hash
try argon2.strVerify(encoded, password, null);

Parameter presets:
- `interactive_2id`: Fast verification (login forms)
- `moderate_2id`: Balanced
- `sensitive_2id`: High security (key derivation)
- `owasp_2id`: OWASP recommended

### Scrypt

Memory-hard KDF:

```zig
const scrypt = std.crypto.pwhash.scrypt;

var hash: [32]u8 = undefined;
try scrypt.kdf(
    allocator,
    &hash,
    password,
    salt,
    .{ .ln = 17, .r = 8, .p = 1 },  // N=2^17, r=8, p=1
);

// Presets
try scrypt.kdf(allocator, &hash, password, salt, scrypt.Params.interactive);

### bcrypt

```zig
const bcrypt = std.crypto.pwhash.bcrypt;

// Hash password
var hash: [bcrypt.hash_length]u8 = undefined;
try bcrypt.strHash(password, .{ .rounds = 10 }, &hash);

// Verify
try bcrypt.strVerify(hash_str, password);

### PBKDF2

```zig
const pbkdf2 = std.crypto.pwhash.pbkdf2;
const HmacSha256 = std.crypto.auth.hmac.sha2.HmacSha256;

var key: [32]u8 = undefined;
pbkdf2(HmacSha256, &key, password, salt, 100000);  // 100k iterations

## Secure Random

**Note (0.16):** `std.crypto.random` is removed. Use platform-specific alternatives:

```zig
// WRONG (0.16) — removed
std.crypto.random.bytes(&key);

// CORRECT — macOS + Linux glibc 2.36+
extern "c" fn arc4random_buf(buf: *anyopaque, nbytes: usize) void;
arc4random_buf(&key, key.len);

// CORRECT — Linux only (no glibc dependency)
_ = std.os.linux.getrandom(buf.ptr, buf.len, 0);

Thread-local cryptographically secure PRNG (0.15.x):

```zig
const random = std.crypto.random;

// Random bytes
var key: [32]u8 = undefined;
random.bytes(&key);

// Random integers
const n = random.int(u64);
const bounded = random.intRangeLessThan(u32, 0, 100);  // [0, 100)

// Random float [0, 1)
const f = random.float(f64);

// Shuffle
random.shuffle(u32, &items);

## Secure Utilities

### secureZero

Securely erase sensitive data (prevents optimizer from removing):

```zig
var secret: [32]u8 = undefined;
// ... use secret ...
std.crypto.secureZero(u8, &secret);  // guaranteed to zero

### Timing-Safe Operations

```zig
const timing_safe = std.crypto.timing_safe;

// Constant-time equality (for MACs, signatures)
const equal = timing_safe.eql([32]u8, mac1, mac2);

// Constant-time comparison
const order = timing_safe.compare(u8, &a, &b, .big);  // .lt, .eq, .gt

// Constant-time arithmetic
const overflow = timing_safe.add(u8, &a, &b, &result, .big);
const underflow = timing_safe.sub(u8, &a, &b, &result, .big);

### Codecs (Constant-Time)

```zig
const codecs = std.crypto.codecs;

// Hex encoding (constant-time)
var hex: [64]u8 = undefined;
try codecs.hex.encode(&hex, &binary, .lower);

// Hex decoding
var decoded: [32]u8 = undefined;
try codecs.hex.decode(&decoded, &hex);

// Base64
const base64 = codecs.base64;
// Similar API to hex

## Elliptic Curve Primitives

Low-level curve operations (usually use higher-level APIs):

```zig
const ecc = std.crypto.ecc;

// Edwards25519
const point = ecc.Edwards25519.basePoint;
const result = try point.mul(scalar);

// P-256 (NIST)
const p256_point = ecc.P256.basePoint;

// Ristretto255 (prime-order group)
const ristretto = ecc.Ristretto255.basePoint;

Available: `Curve25519`, `Edwards25519`, `Ristretto255`, `P256`, `P384`, `Secp256k1`

## Error Handling

```zig
const errors = std.crypto.errors;

// Common errors
error.AuthenticationFailed    // MAC/tag verification failed
error.SignatureVerificationFailed
error.IdentityElement         // Degenerate point in ECC
error.NonCanonical           // Input not in canonical form
error.InvalidEncoding        // Malformed input
error.WeakPublicKey          // Unsafe public key
error.PasswordVerificationFailed

## Common Patterns

### Encrypt-then-MAC

```zig
// Use AEAD instead - it handles this correctly
const Aes256Gcm = std.crypto.aead.aes_gcm.Aes256Gcm;
Aes256Gcm.encrypt(&ct, &tag, pt, ad, nonce, key);

### Key Generation

```zig
// For symmetric keys (0.15.x)
var key: [32]u8 = undefined;
std.crypto.random.bytes(&key);
// NOTE: std.crypto.random.bytes is removed in 0.16 — use arc4random_buf or std.os.linux.getrandom

// For asymmetric keys
const kp = std.crypto.sign.Ed25519.KeyPair.generate();

### Nonce Management

```zig
// Option 1: Counter (deterministic, never reuse)
var nonce: [12]u8 = undefined;
std.mem.writeInt(u64, nonce[0..8], counter, .big);
@memset(nonce[8..], 0);
counter += 1;

// Option 2: Random (safe with XChaCha's 24-byte nonce)
const XChaCha = std.crypto.aead.chacha_poly.XChaCha20Poly1305;
var nonce: [XChaCha.nonce_length]u8 = undefined;
std.crypto.random.bytes(&nonce);

### Secure Password Storage

```zig
const argon2 = std.crypto.pwhash.argon2;

// Registration: hash and store
var buf: [128]u8 = undefined;
const hash_str = try argon2.strHash(password, null, .interactive_2id, .argon2id, &buf);
// Store hash_str in database

// Login: verify
argon2.strVerify(stored_hash, password, null) catch |err| {
    if (err == error.PasswordVerificationFailed) {
        // Invalid password
    }
};

## Side-Channel Protection

Configure side-channel mitigations:

```zig
const SideChannelsMitigations = std.crypto.SideChannelsMitigations;

// Available levels:
// .none    - Fastest, no mitigations
// .basic   - Protects against most practical attacks
// .medium  - Default, good balance (increased resistance)
// .full    - Highest protection, significant performance impact

// Default is .medium
const default = std.crypto.default_side_channels_mitigations;

## Notes

- **Never use MD5 or SHA1 for security** - only for legacy compatibility
- **AEAD over separate encrypt+MAC** - AES-GCM or ChaCha20-Poly1305 handle this correctly
- **Hash shared secrets** - X25519 output should be passed through a KDF before use
- **Use argon2id for passwords** - it's the current best practice
- **XChaCha for random nonces** - 24-byte nonce has negligible collision probability
- **Timing attacks** - use `timing_safe.eql` for comparing secrets, not `==` or `std.mem.eql`
- **Zero secrets** - always `secureZero` sensitive data when done
# std.time - Time and Timing (0.15.x → 0.16)

Wall-clock timestamps, monotonic timers, high-precision timing, and epoch/calendar utilities.

## Critical: Wall-Clock Timestamps Removed (0.16)

`std.time.timestamp()`, `milliTimestamp()`, `microTimestamp()`, and `nanoTimestamp()` are **removed** in Zig 0.16. Use `std.c.clock_gettime` directly:

```zig
// WRONG (0.16) — functions removed
const secs = std.time.timestamp();
const ms = std.time.milliTimestamp();

// CORRECT — clock_gettime replacements
fn timestampSec() i64 {
    var ts: std.c.timespec = undefined;
    _ = std.c.clock_gettime(.REALTIME, &ts);
    return ts.sec;
}

fn milliTimestamp() i64 {
    var ts: std.c.timespec = undefined;
    _ = std.c.clock_gettime(.REALTIME, &ts);
    return @as(i64, ts.sec) * 1000 + @divTrunc(@as(i64, ts.nsec), 1_000_000);
}

fn nanoTimestamp() i128 {
    var ts: std.c.timespec = undefined;
    _ = std.c.clock_gettime(.REALTIME, &ts);
    return @as(i128, ts.sec) * 1_000_000_000 + @as(i128, ts.nsec);
}

**Important:** `ts.nsec` is signed — use `@divTrunc`, not `/` (0.16 enforces `@divTrunc` for signed integer division).

**Still present in 0.16:** `std.time.ns_per_s` and all time constants, `Instant`, `Timer`.

**Also removed in 0.16:** `std.Thread.sleep` — use `std.Io.sleep` if you have an `Io` instance, or `std.c.nanosleep` directly:
```zig
// Preferred (if Io available):
// std.Io.sleep(io, duration, clock);

// Fallback (no Io instance):
fn threadSleep(ns: u64) void {
    const ts = std.c.timespec{
        .sec = @intCast(ns / std.time.ns_per_s),
        .nsec = @intCast(ns % std.time.ns_per_s),
    };
    _ = std.c.nanosleep(&ts, null);
}
```

**Note:** `std.Io.sleep` requires an `io: std.Io` instance. For libraries or code without an Io instance, use the `std.c.nanosleep` fallback.

## Quick Reference

| Category | Types/Functions |
|----------|-----------------|
| Timestamps | `timestamp`, `milliTimestamp`, `microTimestamp`, `nanoTimestamp` |
| Monotonic | `Instant`, `Timer` |
| Epoch | `epoch.EpochSeconds`, `epoch.EpochDay`, `epoch.DaySeconds` |
| Calendar | `epoch.Year`, `epoch.Month`, `epoch.YearAndDay`, `epoch.MonthAndDay` |
| Constants | `ns_per_*`, `us_per_*`, `ms_per_*`, `s_per_*` |

## Choosing the Right Function

Need wall-clock time (date/time)?
├─ Yes → timestamp(), milliTimestamp(), microTimestamp(), nanoTimestamp()
└─ No → Need elapsed time / benchmarking?
       ├─ Yes → Timer or Instant
       └─ No → Need monotonic guarantee?
              ├─ Yes → Timer (saturates on backward jumps)
              └─ No → Instant.now()

| Function | Resolution | Range | Use Case |
|----------|------------|-------|----------|
| `timestamp()` | 1 second | i64 | Log timestamps, file dates |
| `milliTimestamp()` | 1 ms | i64 | General timing, UI |
| `microTimestamp()` | 1 μs | i64 | Profiling |
| `nanoTimestamp()` | 1-100 ns | i128 | High-precision timing |
| `Instant.now()` | ~1 ns | u64 | Elapsed time, ticks during suspend |
| `Timer` | ~1 ns | u64 | Benchmarking with monotonic guarantee |

## Wall-Clock Timestamps

**Note (0.16):** These functions are removed in Zig 0.16. See migration section above for replacements.

Get current time relative to Unix epoch (1970-01-01 UTC):

```zig
const std = @import("std");

pub fn main() void {
    // Seconds since epoch
    const secs = std.time.timestamp();  // i64

    // Higher precision
    const ms = std.time.milliTimestamp();  // i64
    const us = std.time.microTimestamp();  // i64
    const ns = std.time.nanoTimestamp();   // i128
}

**Platform notes:**
- Windows: 100ns granularity via `RtlGetSystemTimePrecise`
- POSIX: Uses `clock_gettime(REALTIME)`
- WASI/UEFI: Platform-specific implementations

## Instant - High-Resolution Timestamps

`Instant` samples the system's fastest clock, ticking during suspend:

```zig
const std = @import("std");

pub fn main() !void {
    const start = try std.time.Instant.now();

    // ... work ...

    const end = try std.time.Instant.now();
    const elapsed_ns = end.since(start);  // u64 nanoseconds

    std.debug.print("Elapsed: {} ns\n", .{elapsed_ns});
}

### Instant Methods

```zig
// Get current instant (may fail on hostile environments)
const instant = try std.time.Instant.now();

// Compare two instants
const order = instant.order(other);  // .lt, .eq, or .gt

// Elapsed time in nanoseconds
const ns = later.since(earlier);

**Platform-specific clocks:**
- macOS/iOS: `UPTIME_RAW` (ticks during suspend)
- Linux: `BOOTTIME` (ticks during suspend)
- FreeBSD: `MONOTONIC_FAST`
- Windows: `QueryPerformanceCounter`

## Timer - Monotonic Benchmarking

`Timer` provides monotonic timing by saturating on backward clock jumps:

```zig
const std = @import("std");

pub fn main() !void {
    var timer = try std.time.Timer.start();

    // ... first phase ...
    const phase1_ns = timer.lap();  // read and reset

    // ... second phase ...
    const phase2_ns = timer.lap();

    // Total since start
    timer.reset();
    // ... final phase ...
    const total_ns = timer.read();
}

### Timer Methods

```zig
// Initialize timer
var timer = try std.time.Timer.start();  // error.TimerUnsupported if no clock

// Read elapsed nanoseconds since start/reset
const elapsed = timer.read();

// Reset timer to zero/now
timer.reset();

// Read and reset in one call
const lap_time = timer.lap();

## Time Unit Constants

```zig
// Nanosecond divisions
std.time.ns_per_us;    // 1_000
std.time.ns_per_ms;    // 1_000_000
std.time.ns_per_s;     // 1_000_000_000
std.time.ns_per_min;   // 60 * ns_per_s
std.time.ns_per_hour;  // 60 * ns_per_min
std.time.ns_per_day;   // 24 * ns_per_hour
std.time.ns_per_week;  // 7 * ns_per_day

// Microsecond divisions
std.time.us_per_ms;    // 1_000
std.time.us_per_s;     // 1_000_000
// ... us_per_min, us_per_hour, us_per_day, us_per_week

// Millisecond divisions
std.time.ms_per_s;     // 1_000
// ... ms_per_min, ms_per_hour, ms_per_day, ms_per_week

// Second divisions
std.time.s_per_min;    // 60
std.time.s_per_hour;   // 3_600
std.time.s_per_day;    // 86_400
std.time.s_per_week;   // 604_800

## Epoch Module - Calendar Conversions

Convert epoch timestamps to year/month/day/time components:

### EpochSeconds to Calendar

```zig
const std = @import("std");
const epoch = std.time.epoch;

pub fn main() void {
    const secs: u64 = @intCast(std.time.timestamp());
    const es = epoch.EpochSeconds{ .secs = secs };

    // Get day and time components
    const day = es.getEpochDay();
    const time = es.getDaySeconds();

    // Get year and day-of-year
    const year_day = day.calculateYearDay();
    // year_day.year: u16 (e.g., 2024)
    // year_day.day: u9 (0-365, day of year)

    // Get month and day-of-month
    const month_day = year_day.calculateMonthDay();
    // month_day.month: Month enum (.jan to .dec)
    // month_day.day_index: u5 (0-30, day of month)

    // Get time of day
    const hours = time.getHoursIntoDay();      // u5 (0-23)
    const minutes = time.getMinutesIntoHour(); // u6 (0-59)
    const seconds = time.getSecondsIntoMinute(); // u6 (0-59)
}

### Month Enum

```zig
const epoch = std.time.epoch;

const month: epoch.Month = .jun;
const num = month.numeric();  // 6 (u4, 1-12)

// All months
// .jan, .feb, .mar, .apr, .may, .jun, .jul, .aug, .sep, .oct, .nov, .dec

### Leap Year and Days

```zig
const epoch = std.time.epoch;

// Check leap year
const is_leap = epoch.isLeapYear(2024);  // true

// Days in year
const days = epoch.getDaysInYear(2024);  // 366

// Days in month
const feb_days = epoch.getDaysInMonth(2024, .feb);  // 29

### Epoch Reference Values

Convert between epoch systems (values are seconds offset from Unix epoch):

```zig
const epoch = std.time.epoch;

epoch.posix;   // 0          (Jan 01, 1970 - Unix)
epoch.unix;    // 0          (alias for posix)
epoch.dos;     // 315532800  (Jan 01, 1980 - DOS/VFAT/BIOS)
epoch.windows; // -11644473600 (Jan 01, 1601 - NTFS)
epoch.ios;     // 978307200  (Jan 01, 2001 - Apple)
epoch.gps;     // 315964800  (Jan 06, 1980 - GPS/ATSC)
epoch.ntp;     // -2208988800 (Jan 01, 1900 - NTP/z/OS)
epoch.clr;     // -62135769600 (Jan 01, 0001 - .NET/Go)

## Common Patterns

### Simple Benchmark

```zig
pub fn benchmark(comptime func: anytype) u64 {
    var timer = std.time.Timer.start() catch return 0;
    func();
    return timer.read();
}

// Usage
const ns = benchmark(myExpensiveFunction);
std.debug.print("Took {} ns\n", .{ns});

### Format Timestamp as ISO 8601

```zig
fn formatTimestamp(secs: u64, buf: []u8) []u8 {
    const epoch = std.time.epoch;
    const es = epoch.EpochSeconds{ .secs = secs };
    const day = es.getEpochDay();
    const time = es.getDaySeconds();
    const yd = day.calculateYearDay();
    const md = yd.calculateMonthDay();

    return std.fmt.bufPrint(buf, "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z", .{
        yd.year,
        md.month.numeric(),
        md.day_index + 1,  // day_index is 0-based
        time.getHoursIntoDay(),
        time.getMinutesIntoHour(),
        time.getSecondsIntoMinute(),
    }) catch buf[0..0];
}

### Timeout Loop

```zig
fn waitWithTimeout(timeout_ns: u64) !void {
    const start = try std.time.Instant.now();

    while (true) {
        if (try checkCondition()) return;

        const now = try std.time.Instant.now();
        if (now.since(start) >= timeout_ns) return error.Timeout;

        // 0.15.x: std.Thread.sleep
        // 0.16: Thread.sleep removed — use std.c.nanosleep instead
        std.Thread.sleep(std.time.ns_per_ms);  // 1ms
    }
}

### Rate Limiter

```zig
const RateLimiter = struct {
    interval_ns: u64,
    last: ?std.time.Instant,

    pub fn init(ops_per_second: u64) RateLimiter {
        return .{
            .interval_ns = std.time.ns_per_s / ops_per_second,
            .last = null,
        };
    }

    pub fn acquire(self: *RateLimiter) void {
        const now = std.time.Instant.now() catch return;
        if (self.last) |last| {
            const elapsed = now.since(last);
            if (elapsed < self.interval_ns) {
                std.Thread.sleep(self.interval_ns - elapsed);
            }
        }
        self.last = std.time.Instant.now() catch null;
    }
};

### Elapsed Time Formatting

```zig
fn formatElapsed(ns: u64) struct { value: u64, unit: []const u8 } {
    if (ns < std.time.ns_per_us) return .{ .value = ns, .unit = "ns" };
    if (ns < std.time.ns_per_ms) return .{ .value = ns / std.time.ns_per_us, .unit = "us" };
    if (ns < std.time.ns_per_s) return .{ .value = ns / std.time.ns_per_ms, .unit = "ms" };
    return .{ .value = ns / std.time.ns_per_s, .unit = "s" };
}

// Usage
const result = formatElapsed(timer.read());
std.debug.print("Elapsed: {} {s}\n", .{ result.value, result.unit });

### Convert Between Epoch Systems

```zig
fn unixToWindows(unix_secs: i64) i64 {
    return unix_secs - std.time.epoch.windows;
}

fn windowsToUnix(windows_secs: i64) i64 {
    return windows_secs + std.time.epoch.windows;
}

## Notes

- `timestamp()` and variants return signed `i64`/`i128` (dates before 1970 are negative)
- `Instant` and `Timer` use unsigned `u64` nanoseconds (~585 years max range)
- `Instant.now()` can return `error.Unsupported` in restricted environments
- `Timer` saturates on clock jumps backward (always monotonic)
- `epoch.EpochSeconds` expects unsigned `u64` (use `@intCast` from `timestamp()`)
- Day and month indices in epoch module are 0-based
- For sleeping: `std.Thread.sleep(ns)` (0.15.x) or `nanosleep` via `std.c.nanosleep` (0.16 — `Thread.sleep` removed)
