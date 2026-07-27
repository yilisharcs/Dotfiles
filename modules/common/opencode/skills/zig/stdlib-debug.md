# std.Testing, std.Debug, std.Log

Testing, debugging, and logging utilities in Zig 0.16. Verified against 0.16.0 source.

# std.testing

Unit testing utilities and assertions for Zig tests.

## Quick Reference

| Function | Purpose |
|----------|---------|
| `expect(bool)` | Assert condition is true |
| `expectEqual(expected, actual)` | Shallow equality (peer type resolution) |
| `expectEqualDeep(expected, actual)` | Deep equality (follows pointers, compares contents) |
| `expectEqualStrings(expected, actual)` | String equality with diff output |
| `expectEqualSlices(T, expected, actual)` | Slice equality with diff output |
| `expectError(error, result)` | Assert specific error returned |
| `expectApproxEqAbs/Rel(expected, actual, tolerance)` | Float comparison |
| `expectFmt(expected, template, args)` | Format string output |
| `expectStringStartsWith(actual, prefix)` | String prefix check |
| `expectStringEndsWith(actual, suffix)` | String suffix check |

## Basic Assertions

```zig
const testing = std.testing;

// Boolean condition
try testing.expect(value > 0);

// Equality (uses peer type resolution)
try testing.expectEqual(expected, actual);
try testing.expectEqual(@as(u32, 42), some_u32);

// String equality (with visual diff on failure)
try testing.expectEqualStrings("hello", slice);

// String prefix/suffix
try testing.expectStringStartsWith(path, "/home/");
try testing.expectStringEndsWith(filename, ".zig");

// Slice equality (with visual diff, works with any element type)
try testing.expectEqualSlices(u8, expected_bytes, actual_bytes);
try testing.expectEqualSlices(u32, &[_]u32{1, 2, 3}, result_slice);

// Sentinel-terminated slice equality
try testing.expectEqualSentinel(u8, 0, expected_cstr, actual_cstr);

// Deep equality (recursively compares structs, arrays, pointers)
try testing.expectEqualDeep(expected_struct, actual_struct);

// Float comparison (absolute tolerance)
try testing.expectApproxEqAbs(@as(f32, 1.0), result, 0.001);

// Float comparison (relative tolerance)
try testing.expectApproxEqRel(@as(f64, 100.0), result, 0.01);

### expectEqual vs expectEqualDeep

```zig
const Point = struct { x: i32, y: i32 };

// expectEqual - compares by value for primitives, by identity for pointers
const p1 = Point{ .x = 1, .y = 2 };
const p2 = Point{ .x = 1, .y = 2 };
try testing.expectEqual(p1, p2);  // OK - structs compared field-by-field

// For slices, expectEqual compares ptr and len (identity)
const a = [_]u8{ 1, 2, 3 };
const b = [_]u8{ 1, 2, 3 };
// testing.expectEqual(&a, &b);  // FAILS - different pointers

// expectEqualDeep - follows pointers, compares contents
try testing.expectEqualDeep(&a, &b);  // OK - compares contents
try testing.expectEqualDeep("abc", "abc");  // OK

## Error Assertions

```zig
// Expect specific error
try testing.expectError(error.OutOfMemory, fallible_function());

// Unwrap or fail test (using try directly)
const value = try fallible_function();  // fails test on any error

## Format Testing

```zig
// Test format string output
try testing.expectFmt("42", "{}", .{@as(u32, 42)});
try testing.expectFmt("hello world", "{s} {s}", .{"hello", "world"});

## Testing Allocator

`std.testing.allocator` is a `DebugAllocator` (formerly `GeneralPurposeAllocator`) that detects memory leaks and use-after-free. **Only available in test builds.**

```zig
test "with allocator" {
    // Detects leaks and use-after-free
    var list: std.ArrayList(u32) = .empty;
    defer list.deinit(testing.allocator);

    try list.append(testing.allocator, 42);
    try testing.expectEqual(@as(usize, 1), list.items.len);
}
// If defer is missing, test fails with leak report

## Failing Allocator

`std.testing.failing_allocator` always returns `error.OutOfMemory`. Use for testing error paths:

```zig
test "handle allocation failure" {
    try testing.expectError(
        error.OutOfMemory,
        testing.failing_allocator.alloc(u8, 100)
    );
}

### Configurable FailingAllocator

For controlled failure testing, use `FailingAllocator` to fail after N allocations:

```zig
test "fail on third allocation" {
    var failing = std.testing.FailingAllocator.init(std.testing.allocator, .{
        .fail_index = 2,  // First 2 allocations succeed, third fails
    });
    const allocator = failing.allocator();

    const a = try allocator.create(i32);  // succeeds (index 0)
    defer allocator.destroy(a);
    const b = try allocator.create(i32);  // succeeds (index 1)
    defer allocator.destroy(b);

    try testing.expectError(error.OutOfMemory, allocator.create(i32));  // fails (index 2)
}

// Configuration options
var failing = std.testing.FailingAllocator.init(backing_allocator, .{
    .fail_index = 5,         // Fail on 6th allocation (default: never)
    .resize_fail_index = 3,  // Fail on 4th resize (default: never)
});

// Inspect state after use
std.debug.print("Allocated: {} bytes\n", .{failing.allocated_bytes});
std.debug.print("Freed: {} bytes\n", .{failing.freed_bytes});
std.debug.print("Allocations: {}\n", .{failing.allocations});
std.debug.print("Deallocations: {}\n", .{failing.deallocations});

## Exhaustive Allocation Failure Testing

`checkAllAllocationFailures` tests that your code handles `OutOfMemory` at every allocation point without leaking:

```zig
fn myFunction(allocator: std.mem.Allocator, size: usize) !void {
    var foo = try allocator.alloc(u8, size);
    defer allocator.free(foo);
    var bar = try allocator.alloc(u8, size);
    defer allocator.free(bar);
    // ... use foo and bar
}

test "no leaks on allocation failure" {
    // Runs myFunction multiple times, failing each allocation in turn
    try std.testing.checkAllAllocationFailures(
        std.testing.allocator,
        myFunction,
        .{@as(usize, 10)},  // extra args tuple
    );
}

**How it works:**
1. Runs function once to count total allocations
2. Runs N more times, failing allocation 0, then 1, then 2...
3. Verifies `OutOfMemory` is returned and no memory leaked

**Errors returned:**
- `error.MemoryLeakDetected` - allocation failed but memory wasn't freed
- `error.SwallowedOutOfMemoryError` - `OutOfMemory` was caught but not propagated
- `error.NondeterministicMemoryUsage` - allocation count varies between runs

## Temporary Directory

Create an isolated temp directory for file system tests:

```zig
test "file operations" {
    var tmp = std.testing.tmpDir(.{});  // creates .zig-cache/tmp/<random>/
    defer tmp.cleanup();

    // Write and read files
    var file = try tmp.dir.createFile("test.txt", .{});
    defer file.close();
    try file.writeAll("hello");

    // Use tmp.dir for all operations
    const content = try tmp.dir.readFileAlloc(std.testing.allocator, "test.txt", 1024);
    defer std.testing.allocator.free(content);
    try testing.expectEqualStrings("hello", content);
}

## Test Organization

```zig
test "descriptive test name" {
    // test body
}

test {
    // Anonymous test, runs with others
}

// Reference other tests (pulls in tests from imported module)
test {
    _ = @import("other_module.zig");
}

// Force semantic analysis of all declarations (catches unused code errors)
comptime {
    std.testing.refAllDecls(@This());
}

// Recursive version for nested types
comptime {
    std.testing.refAllDeclsRecursive(@This());
}

## Skip Tests

```zig
test "skip this" {
    return error.SkipZigTest;
}

test "conditional skip" {
    if (builtin.os.tag == .windows) return error.SkipZigTest;
    // ...
}

test "skip if feature unavailable" {
    if (!@hasDecl(std.os, "linux")) return error.SkipZigTest;
    // Linux-specific test...
}

## Test Logging

```zig
test "with logging" {
    // Only shown when test fails or with --verbose
    std.debug.print("Debug info: {}\n", .{value});
}

// Configurable log level for tests
// std.testing.log_level = .debug;  // default is .warn

## Deterministic Randomness

Tests have access to a deterministic random seed for reproducible "random" tests:

```zig
test "deterministic random" {
    var prng = std.Random.DefaultPrng.init(std.testing.random_seed);
    const random = prng.random();

    const value = random.int(u32);
    // Same seed = same value on every run
}

## Fuzz Testing

**0.17.0-dev signature change:** `testOne` receives a `*std.testing.Smith`
value generator, **not** a `[]const u8`. Older examples (including most
training data) will not compile.

```zig
// A doc comment cannot be attached to a test -- `///` here is a compile error.
test "fuzz parser" {
    try std.testing.fuzz({}, fuzzOne, .{});   // .{ .corpus = &.{...} } to seed
}

fn fuzzOne(_: void, smith: *std.testing.Smith) !void {
    var buf: [2048]u8 = undefined;
    const n = smith.slice(&buf);              // returns bytes written
    _ = myParser.parse(buf[0..n]) catch |err| switch (err) {
        error.InvalidInput => return,          // expected
        else => return err,
    };
}

`Smith` produces structured values rather than raw input: `smith.value(T)`,
`smith.valueRangeAtMost(T, lo, hi)`, `smith.slice(buf)`,
`smith.eosWeightedSimple(false_w, true_w)`, `smith.boolWeighted(...)`.

```bash
zig build test --fuzz=200000   # bounded run, prints a coverage report
zig build test --fuzz          # unbounded + web UI of covered lines

A plain `zig build test` runs the fuzz test once with a trivial input.
The corpus persists in `.zig-cache/f/` and compounds across runs — that
accumulation, not the length of any single run, is where coverage-guided
fuzzing pays off. See [Quality Tooling](quality-tooling.md) for the
measurements and the traps.

## Common Patterns

### Table-Driven Tests

```zig
test "parameterized" {
    const cases = [_]struct { input: i32, expected: i32 }{
        .{ .input = 0, .expected = 0 },
        .{ .input = 1, .expected = 1 },
        .{ .input = -1, .expected = 1 },
    };

    for (cases) |case| {
        try testing.expectEqual(case.expected, abs(case.input));
    }
}

### Test Context/Fixture

```zig
const TestContext = struct {
    allocator: std.mem.Allocator,
    data: *Data,

    fn init(ally: std.mem.Allocator) !TestContext {
        const data = try ally.create(Data);
        return .{ .allocator = ally, .data = data };
    }

    fn deinit(self: *TestContext) void {
        self.allocator.destroy(self.data);
    }
};

test "with context" {
    var ctx = try TestContext.init(testing.allocator);
    defer ctx.deinit();
    // use ctx.data...
}

### Testing with ArenaAllocator

```zig
test "arena for test allocations" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    // No need for individual frees - arena handles cleanup
    const a = try ally.alloc(u8, 100);
    const b = try ally.alloc(u8, 200);
    _ = a; _ = b;
    // arena.deinit() frees everything
}

## Running Tests

```bash
zig build test                    # Run all tests
zig test src/lib.zig              # Test single file
zig test --test-filter "name"     # Filter by name substring
zig test -fsummary                # Show test summary
zig test --verbose                # Show debug output
# std.debug

Debugging utilities: panic handling, assertions, stack traces, hex dumps, and value tracing.

## Quick Reference

| Function | Purpose |
|----------|---------|
| `print(fmt, args)` | Printf-style debug output to stderr |
| `panic(fmt, args)` | Format message and abort |
| `assert(bool)` | Crash if false (optimized out in ReleaseFast) |
| `dumpCurrentStackTrace(addr)` | Print stack trace to stderr |
| `dumpHex(bytes)` | Print hexdump to stderr |

## Debug Printing

```zig
const std = @import("std");

// Quick debug output (64-byte buffer, auto-flush)
std.debug.print("value: {}\n", .{x});
std.debug.print("name: {s}, count: {d}\n", .{name, count});

// Print without newline
std.debug.print("loading...", .{});

**Note:** `std.debug.print` silently ignores errors. For production logging, use `std.log`.

## Format Specifiers

Format string syntax: `{[arg]:[fill][alignment][width][.precision][specifier]}`

### Type Specifiers

| Specifier | Types | Output |
|-----------|-------|--------|
| `{}` | any | Default formatting |
| `{s}` | `[]const u8`, `[*:0]const u8` | String |
| `{d}` | int, float, enum | Decimal |
| `{b}` | int, enum | Binary |
| `{o}` | int, enum | Octal |
| `{x}` | int, float, `[]u8`, enum | Lowercase hex |
| `{X}` | int, float, `[]u8`, enum | Uppercase hex |
| `{c}` | u8, u21 | ASCII character |
| `{u}` | u21 | Unicode codepoint |
| `{e}` | float | Scientific notation |
| `{*}` | pointer | Address (`Type@0x...`) |
| `{f}` | has `format` method | Custom formatter |
| `{any}` | any | Debug representation with depth limit |

### Examples

```zig
std.debug.print("{d}\n", .{42});           // "42"
std.debug.print("{x}\n", .{255});          // "ff"
std.debug.print("{X}\n", .{255});          // "FF"
std.debug.print("{b}\n", .{5});            // "101"
std.debug.print("{o}\n", .{64});           // "100"
std.debug.print("{s}\n", .{"hello"});      // "hello"
std.debug.print("{c}\n", .{'A'});          // "A"
std.debug.print("{*}\n", .{&value});       // "i32@7fff5fbff8a0"

// Floats
std.debug.print("{d}\n", .{3.14159});      // "3.14159"
std.debug.print("{e}\n", .{1234.5});       // "1.2345e+03"
std.debug.print("{x}\n", .{@as(f32, 1.0)}); // "0x1.0p0"

// Hex dump of bytes
std.debug.print("{x}\n", .{"hello"});      // "68656c6c6f"

### Width and Alignment

```zig
std.debug.print("{d:5}\n", .{42});         // "   42" (right-aligned, width 5)
std.debug.print("{d:<5}\n", .{42});        // "42   " (left-aligned)
std.debug.print("{d:^5}\n", .{42});        // " 42  " (center-aligned)
std.debug.print("{d:0>5}\n", .{42});       // "00042" (zero-padded)
std.debug.print("{s:_<10}\n", .{"hi"});    // "hi________" (custom fill)

### Precision

```zig
std.debug.print("{d:.2}\n", .{3.14159});   // "3.14"
std.debug.print("{e:.3}\n", .{1234.5});    // "1.234e+03"
std.debug.print("{x:.4}\n", .{@as(f32, 1.0)}); // "0x1.0000p0"

### Named and Positional Arguments

```zig
// Positional
std.debug.print("{0} {1} {0}\n", .{"a", "b"});  // "a b a"

// Named (with struct)
std.debug.print("{name}: {value}\n", .{ .name = "x", .value = 42 });

// Runtime width/precision
std.debug.print("{d:[width]}\n", .{ .width = 5, 42 });
std.debug.print("{d:.[precision]}\n", .{ .precision = 2, 3.14159 });

### Escape Braces

```zig
std.debug.print("{{literal braces}}\n", .{});  // "{literal braces}"

### Custom Format Method

Types can implement a `format` method for `{f}`:

```zig
const Point = struct {
    x: f32,
    y: f32,

    pub fn format(self: @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
        try writer.print("({d:.2}, {d:.2})", .{ self.x, self.y });
    }
};

const p = Point{ .x = 1.5, .y = 2.5 };
std.debug.print("{f}\n", .{p});  // "(1.50, 2.50)"

### Any Format (Debug Representation)

```zig
const data = .{ .x = 1, .list = &[_]u8{ 1, 2, 3 } };
std.debug.print("{any}\n", .{data});
// Prints struct with depth-limited recursion

## Assertions

```zig
// Runtime assertion (triggers illegal instruction on failure)
std.debug.assert(x > 0);
std.debug.assert(ptr != null);

// Debug/ReleaseSafe: generates check
// ReleaseFast/ReleaseSmall: optimized away (undefined behavior if false)

### Specialized Assertions

```zig
// Assert slice is readable (checks memory mapping)
std.debug.assertReadable(slice);

// Assert pointer alignment
std.debug.assertAligned(ptr, .@"16");  // 16-byte alignment

## Panic

```zig
// Formatted panic message
std.debug.panic("invalid state: {}", .{state});

// With explicit return address
std.debug.panicExtra(@returnAddress(), "error: {s}", .{msg});

Panic prints message + stack trace to stderr, then aborts.

## Stack Traces

### Dump Current Stack

```zig
// Print current stack trace to stderr
std.debug.dumpCurrentStackTrace(null);

// Skip frames until this address
std.debug.dumpCurrentStackTrace(@returnAddress());

### Dump to Writer

```zig
var buf: [4096]u8 = undefined;
const stderr = std.Io.File.stderr().writer(io, &buf);
try std.debug.dumpCurrentStackTraceToWriter(null, &stderr.interface);

### Capture Stack Trace

```zig
var addrs: [32]usize = undefined;
var trace: std.builtin.StackTrace = .{
    .instruction_addresses = &addrs,
    .index = 0,
};
std.debug.captureStackTrace(@returnAddress(), &trace);

// Later: print captured trace
std.debug.dumpStackTrace(trace);

### StackIterator

Walk the stack manually:

```zig
var it = std.debug.StackIterator.init(@returnAddress(), null);
defer it.deinit();

while (it.next()) |return_address| {
    const addr = return_address -| 1;
    std.debug.print("0x{x}\n", .{addr});
}

## Hex Dump

```zig
const data = "Hello, World!\x00\x01\x02";

// Quick dump to stderr
std.debug.dumpHex(data);
// Output:
// 7fff5fbff8a0  48 65 6C 6C 6F 2C 20 57  6F 72 6C 64 21 00 01 02  Hello, World!...

// Dump to writer
var buf: [256]u8 = undefined;
var aw: std.Io.Writer.Allocating = .init(allocator);
defer aw.deinit();
try std.debug.dumpHexFallible(&aw.writer, .no_color, data);

Output format:
- Address (lowercase hex)
- 16 bytes per line (uppercase hex)
- ASCII representation (`.` for non-printable, special chars for `\n`, `\r`, `\t`)

## Value Tracing

Track where values originate and mutate during debugging:

```zig
const Trace = std.debug.Trace;  // Pre-configured: 2 traces, 4 stack frames

const MyStruct = struct {
    value: u32,
    trace: Trace = .init,

    fn setValue(self: *@This(), v: u32) void {
        self.value = v;
        self.trace.add("setValue called");
    }
};

var s = MyStruct{ .value = 0 };
s.setValue(42);
s.trace.dump();  // Prints stack traces with notes

### Configurable Trace

```zig
// Custom configuration: 4 trace slots, 8 stack frames per trace
const MyTrace = std.debug.ConfigurableTrace(4, 8, true);

var trace: MyTrace = .init;
trace.add("first mutation");
trace.addAddr(@returnAddress(), "with explicit address");

// Check if tracing is enabled
if (MyTrace.enabled) {
    trace.dump();
}

// Use in format strings
std.debug.print("trace: {}", .{trace});

In release builds (`enabled = false`), all trace operations are no-ops with zero size.

## SafetyLock

Debug helper to detect concurrent access violations:

```zig
const SafetyLock = std.debug.SafetyLock;

var lock: SafetyLock = .{};

fn criticalSection() void {
    lock.lock();
    defer lock.unlock();
    // ... protected code
}

fn checkNotLocked() void {
    lock.assertUnlocked();  // Panics if locked
}

- In Debug/ReleaseSafe: actively tracks lock state
- In ReleaseFast/ReleaseSmall: all methods are no-ops

## Source Location

```zig
const SourceLocation = std.debug.SourceLocation;

const loc: SourceLocation = .{
    .line = 42,
    .column = 10,
    .file_name = "src/main.zig",
};

// Invalid/unknown location
const unknown = SourceLocation.invalid;

## Symbol Information

```zig
const Symbol = std.debug.Symbol;

// Symbol with resolved source location
const sym: Symbol = .{
    .name = "myFunction",
    .compile_unit_name = "main.zig",
    .source_location = .{ .line = 100, .column = 1, .file_name = "src/main.zig" },
};

// Unknown symbol
const unknown: Symbol = .{};  // name = "???", compile_unit_name = "???"

## Segfault Handling

```zig
// Check if platform supports segfault handling
if (std.debug.have_segfault_handling_support) {
    // Attach handler (prints stack trace on SIGSEGV/SIGBUS/etc)
    std.debug.attachSegfaultHandler();

    // Later: reset to default handler
    std.debug.resetSegfaultHandler();
}

// Check if handler is enabled by default
const enabled = std.debug.default_enable_segfault_handler;

**Note:** `maybeEnableSegfaultHandler()` is called automatically by the runtime if `std.options.enable_segfault_handler` is true.

## Thread Context

Platform-specific CPU register state for stack unwinding:

```zig
const ThreadContext = std.debug.ThreadContext;

var ctx: ThreadContext = undefined;
if (std.debug.getContext(&ctx)) {
    // ctx now contains register state
    std.debug.dumpStackTraceFromBase(&ctx, stderr);
}

// Copy context (handles internal pointers)
var ctx_copy: ThreadContext = undefined;
std.debug.copyContext(&original_ctx, &ctx_copy);

## Valgrind Detection

```zig
if (std.debug.inValgrind()) {
    // Running under Valgrind - may want different behavior
    std.debug.print("Valgrind detected\n", .{});
}

## Debug Info Access

```zig
// Get debug info for current executable
const info = try std.debug.getSelfDebugInfo();

// Get symbol at address
const symbol = try info.getSymbolAtAddress(allocator, address);
defer if (symbol.source_location) |sl| allocator.free(sl.file_name);

std.debug.print("{s}:{d}: {s}\n", .{
    symbol.source_location.?.file_name,
    symbol.source_location.?.line,
    symbol.name,
});

## Constants

```zig
// Whether runtime safety checks are enabled
std.debug.runtime_safety  // true in Debug/ReleaseSafe

// Whether platform can produce stack traces
std.debug.sys_can_stack_trace  // false on WASM, MIPS, etc.

// Whether platform has ucontext_t
std.debug.have_ucontext

## Submodules

| Module | Purpose |
|--------|---------|
| `std.debug.Dwarf` | DWARF debug info parser |
| `std.debug.Pdb` | Windows PDB debug info parser |
| `std.debug.SelfInfo` | Debug info for current executable |
| `std.debug.MemoryAccessor` | Safe memory access for unwinding |
| `std.debug.Coverage` | Code coverage support |

## FullPanic

Create custom panic handler with formatted safety messages:

```zig
pub const panic = std.debug.FullPanic(myPanicFn);

fn myPanicFn(msg: []const u8, ret_addr: ?usize) noreturn {
    // Custom panic handling (log to file, send telemetry, etc.)
    std.posix.abort();
}

// Now safety checks use myPanicFn with descriptive messages:
// - "sentinel mismatch: expected X, found Y"
// - "index out of bounds: index N, len M"
// - "attempt to unwrap error: ErrorName"
// etc.

## Locking stderr

For multi-line debug output without interleaving:

```zig
// Lock stderr and clear any progress indicators
std.debug.lockStdErr();
defer std.debug.unlockStdErr();

// Safe to write multiple lines
const stderr = std.Io.File.stderr();
try stderr.writeAll("Line 1\n");
try stderr.writeAll("Line 2\n");

Or with a writer:

```zig
// 0.15.x
var buf: [256]u8 = undefined;
const writer = std.debug.lockStderrWriter(&buf);
defer std.debug.unlockStderrWriter();
try writer.print("Complex output: {}\n", .{value});

// 0.16 — lockStderrWriter → lockStderr, different API
var buf: [4096]u8 = undefined;
const held = std.debug.lockStderr(&buf);
defer std.debug.unlockStderr();
// held.file_writer is a File.Writer; .interface is the Io.Writer
try held.file_writer.print("msg: {s}\n", .{text});
# std.log

Standardized logging interface with configurable scopes, levels, and output.

## Quick Reference

| Function | Purpose |
|----------|---------|
| `log.err(fmt, args)` | Log error (something went wrong) |
| `log.warn(fmt, args)` | Log warning (uncertain if wrong) |
| `log.info(fmt, args)` | Log info (general state) |
| `log.debug(fmt, args)` | Log debug (debugging only) |
| `log.scoped(.name)` | Create scoped logger |

## Basic Usage

```zig
const std = @import("std");
const log = std.log;

pub fn main() void {
    log.info("Starting application", .{});
    log.debug("Debug value: {}", .{x});  // Hidden in release builds
    log.warn("Config missing, using defaults", .{});
    log.err("Failed to connect: {s}", .{@errorName(e)});
}

## Log Levels

| Level | Build Mode Default | Purpose |
|-------|-------------------|---------|
| `.err` | Always shown | Something went wrong |
| `.warn` | Always shown | Uncertain if wrong, worth investigating |
| `.info` | Debug + Release | General program state |
| `.debug` | Debug only | Messages only useful for debugging |

Default level by build mode:
- **Debug**: `.debug` (all messages)
- **ReleaseSafe/Fast/Small**: `.info` (no debug messages)

## Scoped Logging

Create loggers with custom scopes for filtering:

```zig
const std = @import("std");

// Library logger with custom scope
const log = std.log.scoped(.my_library);

pub fn doWork() void {
    log.info("Processing...", .{});   // Prefixed with (my_library)
    log.debug("Details: {}", .{x});
}

Multiple scopes in one file:

```zig
const network_log = std.log.scoped(.network);
const db_log = std.log.scoped(.database);

fn fetchData() void {
    network_log.info("Connecting...", .{});
    db_log.debug("Query: {s}", .{sql});
}

## Configuration via std_options

Configure logging in your root file:

```zig
const std = @import("std");

pub const std_options: std.Options = .{
    // Global log level
    .log_level = .warn,  // Only show warn and err

    // Per-scope levels (override global)
    .log_scope_levels = &.{
        .{ .scope = .my_library, .level = .debug },  // Full debug for this scope
        .{ .scope = .noisy_lib, .level = .err },     // Errors only
    },

    // Custom log function
    .logFn = myLogFn,
};

## Custom Log Function

Replace the default log output:

```zig
const std = @import("std");

pub const std_options: std.Options = .{
    .logFn = myLogFn,
};

fn myLogFn(
    comptime level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    // Filter: only errors from unknown scopes
    const scope_prefix = switch (scope) {
        .my_app, .default => @tagName(scope),
        else => if (@intFromEnum(level) <= @intFromEnum(std.log.Level.err))
            @tagName(scope)
        else
            return,  // Skip non-error from other scopes
    };

    const level_txt = comptime level.asText();
    const prefix = "[" ++ level_txt ++ "] (" ++ scope_prefix ++ "): ";

    std.debug.lockStdErr();
    defer std.debug.unlockStdErr();

    var buf: [64]u8 = undefined;
    const stderr = std.Io.File.stderr().writer(io, &buf);
    nosuspend stderr.print(prefix ++ format ++ "\n", args) catch return;
    try stderr.flush();
}

## Check if Logging Enabled

Avoid expensive computations when logging is disabled:

```zig
const log = std.log.scoped(.my_scope);

fn process() void {
    // Check before expensive operation
    if (std.log.logEnabled(.debug, .my_scope)) {
        const debug_info = computeExpensiveDebugInfo();
        log.debug("Info: {}", .{debug_info});
    }

    // For default scope
    if (std.log.defaultLogEnabled(.debug)) {
        std.log.debug("Debug message", .{});
    }
}

## Level Methods

```zig
const level: std.log.Level = .warn;

// Get text representation
const text = level.asText();  // "warning"

// Compare levels (lower = more severe)
const is_error_or_worse = @intFromEnum(level) <= @intFromEnum(std.log.Level.err);

## Default Log Function

Forward to the standard implementation:

```zig
fn myLogFn(
    comptime level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    // Add timestamp, then forward to default
    std.debug.print("[{d}] ", .{std.time.timestamp()});
    std.log.defaultLog(level, scope, format, args);
}

## Output Format

Default output format:
level: message                     # default scope
level(scope): message              # named scope

Examples:
info: Server started on port 8080
warning(database): Connection pool exhausted
error(network): Failed to resolve hostname
debug: Variable x = 42

## Common Patterns

### Conditional Debug Logging

```zig
fn processItem(item: Item) void {
    if (comptime std.log.logEnabled(.debug, .default)) {
        log.debug("Processing: {}", .{item});
    }
    // ... process
}

### Error Context Logging

```zig
fn loadConfig(path: []const u8) !Config {
    return std.Io.Dir.cwd().openFile(io, path, .{}) catch |err| {
        log.err("Failed to open config '{s}': {s}", .{path, @errorName(err)});
        return err;
    };
}

### Library Logging Pattern

```zig
// In library code
pub const log = std.log.scoped(.my_lib);

// Users can filter with:
// .log_scope_levels = &.{ .{ .scope = .my_lib, .level = .warn } }

## Log to File

```zig
fn fileLogFn(
    comptime level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    const file = std.Io.Dir.cwd().openFile(io, "app.log", .{ .mode = .write_only }) catch return;
    defer file.close();
    file.seekFromEnd(0) catch return;

    var buf: [256]u8 = undefined;
    var writer = file.writer(&buf);
    const w = &writer.interface;

    const level_txt = comptime level.asText();
    const scope_txt = if (scope == .default) "" else "(" ++ @tagName(scope) ++ ")";

    w.print("[{s}]{s} " ++ format ++ "\n", .{level_txt, scope_txt} ++ args) catch return;
    w.flush() catch return;
}
