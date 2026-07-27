# Zig Patterns and Idioms

Common patterns, idioms, C interop, and production practices in Zig 0.16. Verified against 0.16.0 source.

# Zig Patterns Reference

Comprehensive patterns for writing idiomatic Zig code. This reference contains best practices extracted from the Zig standard library (0.15.x) and established community idioms.

## Table of Contents

### Quick Patterns
- [Memory and Allocators](#memory-and-allocators)
- [File I/O (0.15.x)](#file-io-015x)
- [HTTP Client (0.15.x)](#http-client-015x)
- [JSON](#json)
- [Testing](#testing)
- [Build System Patterns](#build-system-patterns)

### Idiomatic Code Patterns
- [I. Syntax Patterns](#i-syntax-patterns)
  - [Closure Pattern](#closure-pattern)
  - [Context Pattern](#context-pattern)
  - [Pointer Size Type Selection](#pointer-size-type-selection)
  - [Default Arguments via Options Struct](#default-arguments-via-options-struct)
  - [Side Computation Block](#side-computation-block)
  - [Destructuring Assignment](#destructuring-assignment)
  - [Hashed Mappings Storage](#hashed-mappings-storage)
  - [Module-wide Overridable Options](#module-wide-overridable-options)
  - [Self-referential Type Alias](#self-referential-type-alias)
  - [Variable Struct Initialization](#variable-struct-initialization)
  - [Return Value Struct Initialization](#return-value-struct-initialization)
- [II. Polymorphism Patterns](#ii-polymorphism-patterns)
  - [Duck Typing](#duck-typing)
  - [Generic Type](#generic-type)
  - [Generic Function](#generic-function)
  - [Basic Type Formatting](#basic-type-formatting)
  - [Custom Type Formatting](#custom-type-formatting)
  - [Custom Type JSON](#custom-type-json)
  - [Compile-time Implementation Switching](#compile-time-implementation-switching)
  - [Dynamic Dispatch (Fat Pointer)](#dynamic-dispatch-fat-pointer)
  - [Static Dispatch (Tagged Union)](#static-dispatch-tagged-union-with-inline-switch)
- [III. Safety Patterns](#iii-safety-patterns)
  - [Diagnostics](#diagnostics)
  - [Index-Based Data Structures](#index-based-data-structures)
  - [Error Payloads](#error-payloads)
  - [Compile-time Assertion](#compile-time-assertion)
  - [Granular Error Handling](#granular-error-handling)
  - [Deallocated Memory Poisoning](#deallocated-memory-poisoning)
  - [Deferred Resource Deinitialization](#deferred-resource-deinitialization)
  - [Error-deferred Resource Deinitialization](#error-deferred-resource-deinitialization)
  - [Compile-time Unreachable Switch Prong](#compile-time-unreachable-switch-prong)
  - [Compile-time Error Absence Guarantee](#compile-time-error-absence-guarantee)
  - [Reserve-First Exception Safety](#reserve-first-exception-safety)
- [IV. Performance Patterns](#iv-performance-patterns)
  - [Big Struct Constant Pointer Passing](#big-struct-constant-pointer-passing)
  - [Big Struct Constant Pointer Capturing](#big-struct-constant-pointer-capturing)
- [V. Workarounds](#v-workarounds)
  - [Inlined Loop with Runtime Logic](#inlined-loop-with-runtime-logic)

---

## Quick Patterns

### Memory and Allocators

> **Naming convention:** Name allocators by their memory contract (`gpa`, `arena`, `scratch`) not generically as `allocator`. See [Allocator Naming Conventions](stdlib-system.md#allocator-naming-conventions) for details.

#### Allocator Setup
```zig
// Debug allocator (development - detects leaks, use-after-free)
// Note: GeneralPurposeAllocator is now an alias for DebugAllocator
var gpa: std.heap.DebugAllocator(.{}) = .init;
defer _ = gpa.deinit();
const allocator = gpa.allocator();

// Arena (batch operations - free all at once)
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();
const allocator = arena.allocator();

// Fixed buffer (no heap, stack allocation)
var buffer: [4096]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buffer);
const allocator = fba.allocator();

#### Allocation Patterns
```zig
// Single item
const ptr = try allocator.create(T);
defer allocator.destroy(ptr);

// Slice
const slice = try allocator.alloc(u8, 100);
defer allocator.free(slice);

// Duplicate
const copy = try allocator.dupe(u8, source);
defer allocator.free(copy);

### File I/O (0.15.x)

#### Reading Files
```zig
const file = try std.Io.Dir.cwd().openFile(io, "data.txt", .{});
defer file.close();

var buf: [4096]u8 = undefined;
var reader = file.reader(&buf);
const r = &reader.interface;

// Line by line (takeDelimiter returns null at EOF)
while (try r.takeDelimiter('\n')) |line| {
    // process line (doesn't include '\n')
}

#### Writing Files
```zig
const file = try std.Io.Dir.cwd().createFile(io, "out.txt", .{});
defer file.close();

var buf: [4096]u8 = undefined;
var writer = file.writer(&buf);
const w = &writer.interface;

try w.print("Hello {s}\n", .{"world"});
try w.flush();

#### Stdout/Stderr
```zig
var stdout_buf: [4096]u8 = undefined;
var stdout_writer = std.Io.File.stdout().writer(&stdout_buf);
const stdout = &stdout_writer.interface;

try stdout.print("Output\n", .{});
try stdout.flush();

### HTTP Client (0.15.x)

See [stdlib-io.md](stdlib-io.md) for full documentation including server, WebSocket, and compression.

```zig
// Quick fetch (simple requests)
var client: std.http.Client = .{ .allocator = allocator };
defer client.deinit();

var body_buf: [65536]u8 = undefined;
var body_writer: std.Io.Writer = .fixed(&body_buf);

const result = try client.fetch(.{
    .location = .{ .url = "https://api.example.com/data" },
    .response_writer = &body_writer,
});

const body = body_writer.buffered();

```zig
// Full control (for headers, streaming, redirects)
var req = try client.request(.GET, try std.Uri.parse(url), .{
    .extra_headers = &.{
        .{ .name = "Authorization", .value = "Bearer token" },
    },
});
defer req.deinit();

try req.sendBodiless();

var redirect_buf: [8192]u8 = undefined;
var response = try req.receiveHead(&redirect_buf);

var reader_buf: [4096]u8 = undefined;
const body_reader = response.reader(&reader_buf);
// read body...

### JSON

#### Parsing
```zig
const Config = struct {
    name: []const u8,
    count: u32,
};

const parsed = try std.json.parseFromSlice(Config, allocator, json_bytes, .{});
defer parsed.deinit();
const config = parsed.value;

#### Stringifying
```zig
const json = try std.json.stringifyAlloc(allocator, config, .{});
defer allocator.free(json);

### Testing

```zig
const std = @import("std");
const testing = std.testing;

test "example" {
    try testing.expectEqual(4, 2 + 2);
    try testing.expectEqualStrings("hello", "hello");
    try testing.expect(condition);
}

test "with allocator" {
    var list: std.ArrayListUnmanaged(u32) = .empty;
    defer list.deinit(testing.allocator);
    try list.append(testing.allocator, 42);
}

### Build System Patterns

#### Basic Executable
```zig
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    run.step.dependOn(b.getInstallStep());
    b.step("run", "Run the app").dependOn(&run.step);
}

#### Adding Dependencies
```zig
const dep = b.dependency("pkg_name", .{ .target = target, .optimize = optimize });
exe.root_module.addImport("pkg_name", dep.module("module_name"));

#### Library + Executable
```zig
const lib_mod = b.createModule(.{
    .root_source_file = b.path("src/lib.zig"),
    .target = target,
    .optimize = optimize,
});

const exe = b.addExecutable(.{
    .name = "app",
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "mylib", .module = lib_mod }},
    }),
});

#### Tests
```zig
const tests = b.addTest(.{
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    }),
});
const run_tests = b.addRunArtifact(tests);
b.step("test", "Run tests").dependOn(&run_tests.step);

---

## Idiomatic Code Patterns

These patterns are extracted from the Zig standard library (0.15.x) and represent established idioms for writing clean, efficient Zig code.

### I. Syntax Patterns

#### Closure Pattern
Use a local struct with `@fieldParentPtr` to capture context when you need a function pointer with associated state.

```zig
pub fn spawnWg(pool: *Pool, wait_group: *WaitGroup, comptime func: anytype, args: anytype) void {
    wait_group.start();

    const Args = @TypeOf(args);
    const Closure = struct {
        arguments: Args,
        pool: *Pool,
        runnable: Runnable = .{ .runFn = runFn },
        wait_group: *WaitGroup,

        fn runFn(runnable: *Runnable, _: ?usize) void {
            const closure: *@This() = @alignCast(@fieldParentPtr("runnable", runnable));
            @call(.auto, func, closure.arguments);
            closure.wait_group.finish();
            closure.pool.allocator.destroy(closure);
        }
    };

    const closure = pool.allocator.create(Closure) catch return;
    closure.* = .{
        .arguments = args,
        .pool = pool,
        .wait_group = wait_group,
    };
    pool.run_queue.prepend(&closure.runnable.node);
}

**When to use:** Thread pools, callbacks, event handlers—anywhere you need a function pointer but also need captured state.

#### Context Pattern
Parameterize a generic type with *behavior*, not just data types. A context struct bundles related operations that the generic type calls at runtime, allowing callers to customize how the type operates.

**The principle:** When a generic type needs to perform operations that depend on how the caller wants to use it (comparison, hashing, ordering, formatting), accept a `Context` type parameter. The context provides methods the generic calls internally.

```zig
// DEFINING a generic type that accepts a context:
pub fn SortedSet(comptime T: type, comptime Context: type) type {
    return struct {
        items: std.ArrayList(T),
        ctx: Context,  // Store the context instance

        pub fn contains(self: *@This(), value: T) bool {
            for (self.items.items) |item| {
                // Call the context's comparison method
                if (self.ctx.eql(item, value)) return true;
            }
            return false;
        }

        pub fn insert(self: *@This(), value: T) !void {
            if (!self.contains(value)) {
                // Use context's lessThan for sorted insertion
                const pos = for (self.items.items, 0..) |item, i| {
                    if (self.ctx.lessThan(value, item)) break i;
                } else self.items.items.len;
                try self.items.insert(pos, value);
            }
        }
    };
}

**Stateless context** - when behavior doesn't need configuration, `self` is unused:
```zig
// Case-sensitive string comparison (no state needed)
const CaseSensitive = struct {
    pub fn eql(_: @This(), a: []const u8, b: []const u8) bool {
        return std.mem.eql(u8, a, b);
    }
    pub fn lessThan(_: @This(), a: []const u8, b: []const u8) bool {
        return std.mem.lessThan(u8, a, b);
    }
};

var set: SortedSet([]const u8, CaseSensitive) = .{
    .items = .empty,
    .ctx = .{},  // No state to initialize
};

**Stateful context** - when behavior needs configuration:
```zig
// Floating-point comparison with configurable tolerance
const ApproxEql = struct {
    tolerance: f64,

    pub fn eql(self: @This(), a: f64, b: f64) bool {
        return @abs(a - b) <= self.tolerance;
    }
    pub fn lessThan(self: @This(), a: f64, b: f64) bool {
        return a < b - self.tolerance;
    }
};

var precise: SortedSet(f64, ApproxEql) = .{
    .items = .empty,
    .ctx = .{ .tolerance = 0.0001 },
};
var loose: SortedSet(f64, ApproxEql) = .{
    .items = .empty,
    .ctx = .{ .tolerance = 1.0 },
};

**Standard library example** - HashMap requires `hash` and `eql`:
```zig
// Case-insensitive string keys
const CaseInsensitive = struct {
    pub fn hash(_: @This(), key: []const u8) u64 {
        var h = std.hash.Wyhash.init(0);
        for (key) |c| h.update(&.{std.ascii.toLower(c)});
        return h.final();
    }
    pub fn eql(_: @This(), a: []const u8, b: []const u8) bool {
        return std.ascii.eqlIgnoreCase(a, b);
    }
};

const Headers = std.HashMap([]const u8, []const u8, CaseInsensitive, 80);

**When to use:**
- Your generic type needs customizable comparison, hashing, ordering, or formatting
- Different use cases need different behavior for the same data type
- You want compile-time polymorphism without runtime vtable overhead

**Design guidelines:**
- Document which methods the context must provide
- Use `_: @This()` for stateless contexts (optimizer eliminates the parameter)
- Store `ctx: Context` as a field when the generic needs to call methods later
- Consider providing a default context type for common cases

#### Pointer Size Type Selection
Use `switch (@sizeOf(usize))` to select platform-appropriate types at compile time.

```zig
pub const Auxv = switch (@sizeOf(usize)) {
    4 => Elf32_auxv_t,
    8 => Elf64_auxv_t,
    else => @compileError("expected pointer size of 32 or 64"),
};

pub const Ehdr = switch (@sizeOf(usize)) {
    4 => Elf32_Ehdr,
    8 => Elf64_Ehdr,
    else => @compileError("expected pointer size of 32 or 64"),
};

**When to use:** FFI with C libraries, ELF parsing, or any code that needs different types for 32-bit vs 64-bit platforms.

#### Default Arguments via Options Struct
Use a struct with default field values to simulate optional/default function arguments.

```zig
pub const Options = struct {
    /// The alignment of the memory pool items. Use `null` for natural alignment.
    alignment: ?Alignment = null,
    /// If `true`, the memory pool can allocate additional items after initial setup.
    growable: bool = true,
};

pub fn MemoryPoolExtra(comptime Item: type, comptime pool_options: Options) type {
    return struct {
        // Implementation uses pool_options.alignment, pool_options.growable
    };
}

// Usage:
const Pool1 = MemoryPoolExtra(u32, .{});  // All defaults
const Pool2 = MemoryPoolExtra(u32, .{ .growable = false });  // Override one

**When to use:** Functions with many optional parameters, builder patterns, configuration structs.

#### Side Computation Block
Use labeled blocks to perform intermediate calculations with a clear scope boundary.

```zig
// Calculate length needed for resulting joined path buffer.
const total_len = blk: {
    var sum: usize = paths[first_path_index].len;
    var prev_path = paths[first_path_index];
    var i: usize = first_path_index + 1;
    while (i < paths.len) : (i += 1) {
        const this_path = paths[i];
        if (this_path.len == 0) continue;
        sum += this_path.len;
        prev_path = this_path;
    }
    if (zero) sum += 1;
    break :blk sum;
};

**When to use:** Complex expressions that need temporary variables, when you want to limit variable scope.

#### Destructuring Assignment
Unpack tuples, arrays, and vectors into individual variables.

```zig
// From function returning tuple
fn divmod(n: u32, d: u32) struct { u32, u32 } {
    return .{ n / d, n % d };
}
const div, const mod = divmod(10, 3);

// Array destructuring with swizzle
fn swizzleRgbaToBgra(rgba: [4]u8) [4]u8 {
    const r, const g, const b, const a = rgba;
    return .{ b, g, r, a };
}

// Ignore elements with _
const first, _, const third, _ = some_array;

// Works with comptime
comptime const x, const y = .{ 1, 2 };

**When to use:** Multiple return values, array element extraction, SIMD vector unpacking.

#### Hashed Mappings Storage
Use multiple `AutoArrayHashMapUnmanaged` fields when storing complex interned data.

```zig
// From llvm/Builder.zig - demonstrating the pattern of parallel maps for interned data
string_map: std.AutoArrayHashMapUnmanaged(void, void),
string_indices: std.ArrayListUnmanaged(u32),
string_bytes: std.ArrayListUnmanaged(u8),

types: std.AutoArrayHashMapUnmanaged(String, Type),
type_map: std.AutoArrayHashMapUnmanaged(void, void),
type_items: std.ArrayListUnmanaged(Type.Item),
type_extra: std.ArrayListUnmanaged(u32),

attributes: std.AutoArrayHashMapUnmanaged(Attribute.Storage, void),
attributes_map: std.AutoArrayHashMapUnmanaged(void, void),
attributes_indices: std.ArrayListUnmanaged(u32),

**When to use:** Interning strings/symbols, IR builders, AST storage, deduplication with stable indices.

#### Module-wide Overridable Options
Use `@import("root")` to allow users to customize library behavior.

```zig
const root = @import("root");

/// Stdlib-wide options that can be overridden by the root file.
pub const options: Options = if (@hasDecl(root, "std_options")) root.std_options else .{};

pub const Options = struct {
    enable_segfault_handler: bool = debug.default_enable_segfault_handler,
    log_level: log.Level = log.default_level,
    // ...
};

// In user's main.zig:
pub const std_options: std.Options = .{
    .log_level = .debug,
};

**When to use:** Library configuration, logging levels, feature flags that users can customize.

#### Self-referential Type Alias
Use `const Self = @This();` inside a struct for self-reference.

```zig
// GOOD: Simple alias at top of struct
pub fn EnumSet(comptime E: type) type {
    return struct {
        const Self = @This();

        pub const Indexer = EnumIndexer(E);
        pub const Key = Indexer.Key;

        bits: BitSet,

        pub fn contains(self: Self, key: Key) bool {
            return self.bits.isSet(Indexer.indexOf(key));
        }
    };
}

// ANTI-PATTERN: Unnecessary Self usage when @This() would be clearer
pub const PaxIterator = struct {
    size: usize,
    reader: *std.Io.Reader,

    const Self = @This();  // Unnecessary - only used once

    // Better: just use @This() inline or the actual type name
};

**When to use:** Generic types where `Self` is used multiple times. Avoid in non-generic structs where it adds no value.

#### Variable Struct Initialization
Use `pub const init: T = .{...};` for default/initial values.

```zig
// GOOD: Named constant with explicit type
pub const Recursive = struct {
    mutex: Mutex,
    thread_id: std.Thread.Id,
    lock_count: usize,

    pub const init: Recursive = .{
        .mutex = .{},
        .thread_id = invalid_thread_id,
        .lock_count = 0,
    };
};

// Usage:
var rec: Recursive = Recursive.init;

// ANTI-PATTERN: Using T{} syntax (older style)
var mutex = Mutex{};  // Works but .{} is preferred

**When to use:** Types with meaningful default states, especially when zero-initialization isn't appropriate.

#### Return Value Struct Initialization
Return `.{...}` directly instead of creating named locals.

```zig
// GOOD: Direct return
pub fn initContext(allocator: Allocator, ctx: Context) Self {
    return .{
        .unmanaged = .empty,
        .allocator = allocator,
        .ctx = ctx,
    };
}

// ANTI-PATTERN: Unnecessary named local
pub fn getEntryAdapted(self: Self, key: anytype, ctx: anytype) ?Entry {
    const index = self.getIndexAdapted(key, ctx) orelse return null;
    const slice = self.entries.slice();
    return Entry{  // Could just be: return .{
        .key_ptr = &slice.items(.key)[index],
        .value_ptr = &slice.items(.value)[index],
    };
}

**When to use:** Simple struct construction in return statements. Use named locals only when the struct is complex or needs multiple statements to build.

### II. Polymorphism Patterns

#### Duck Typing
Use `anytype` parameters with compile-time interface checking.

```zig
pub fn sort(
    comptime T: type,
    items: []T,
    context: anytype,  // Duck typed: must have lessThan behavior
    comptime lessThanFn: fn (@TypeOf(context), lhs: T, rhs: T) bool,
) void {
    std.sort.block(T, items, context, lessThanFn);
}

// Works with any type that can be passed to lessThanFn
sort(i32, &items, {}, struct {
    fn lt(_: void, a: i32, b: i32) bool { return a < b; }
}.lt);

**When to use:** Callbacks, comparators, iterators—when the exact type doesn't matter, only its capabilities.

#### Generic Type
Return a parameterized struct from a function.

```zig
pub fn HashMap(
    comptime K: type,
    comptime V: type,
    comptime Context: type,
    comptime max_load_percentage: u64,
) type {
    return struct {
        unmanaged: Unmanaged,
        allocator: Allocator,
        ctx: Context,

        pub const Unmanaged = HashMapUnmanaged(K, V, Context, max_load_percentage);
        pub const Entry = Unmanaged.Entry;
        // ...
    };
}

const MyMap = HashMap([]const u8, u32, std.hash_map.StringContext, 80);

**When to use:** Data structures, containers, any reusable component parameterized by types.

#### Generic Function
Use `comptime T: type` for functions operating on any type.

```zig
pub fn allEqual(comptime T: type, slice: []const T, scalar: T) bool {
    for (slice) |item| {
        if (item != scalar) return false;
    }
    return true;
}

// Usage:
const all_zero = std.mem.allEqual(u8, buffer, 0);
const all_space = std.mem.allEqual(u8, text, ' ');

**When to use:** Utility functions, algorithms that work on any type with certain properties.

#### Basic Type Formatting
Built-in format specifiers for `std.fmt.print`.

```zig
// x/X: hexadecimal
try w.print("{x}", .{255});       // "ff"
try w.print("{X}", .{255});       // "FF"

// s: strings and slices
try w.print("{s}", .{"hello"});   // "hello"

// t: tag names for enums/unions/errors
try w.print("{t}", .{MyEnum.foo}); // "foo"

// d: decimal, b: binary, o: octal
try w.print("{d} {b} {o}", .{10, 10, 10}); // "10 1010 12"

// e: scientific notation
try w.print("{e}", .{1234.5});    // "1.2345e+03"

// c: ASCII character, u: UTF-8 codepoint
try w.print("{c} {u}", .{65, 0x1F600}); // "A 😀"

// D: duration (nanoseconds)
try w.print("{D}", .{3_661_001_000_000}); // "1h1m1.001s"

// B/Bi: bytes in SI/IEC units
try w.print("{B} {Bi}", .{1536, 1536}); // "1.536kB 1.5KiB"

#### Custom Type Formatting
Implement `format` method for custom types (0.15.x signature).

```zig
const Version = struct {
    major: u32,
    minor: u32,
    patch: u32,
    pre: ?[]const u8 = null,
    build: ?[]const u8 = null,

    // 0.15.x signature: takes *std.Io.Writer, returns Writer.Error!void
    pub fn format(self: Version, w: *std.Io.Writer) std.Io.Writer.Error!void {
        try w.print("{d}.{d}.{d}", .{ self.major, self.minor, self.patch });
        if (self.pre) |pre| try w.print("-{s}", .{pre});
        if (self.build) |build| try w.print("+{s}", .{build});
    }
};

// Usage with {f} specifier (required in 0.15.x)
try stdout.print("{f}", .{version});

**When to use:** Any type that needs custom string representation.

#### Custom Type JSON
Implement `jsonParse`, `jsonParseFromValue`, and `jsonStringify` for JSON support.

```zig
pub fn ArrayHashMap(comptime T: type) type {
    return struct {
        map: std.StringArrayHashMapUnmanaged(T) = .empty,

        pub fn jsonParse(
            allocator: Allocator,
            source: anytype,
            options: ParseOptions,
        ) !@This() {
            var map: std.StringArrayHashMapUnmanaged(T) = .empty;
            errdefer map.deinit(allocator);

            if (.object_begin != try source.next()) return error.UnexpectedToken;
            while (true) {
                const token = try source.nextAlloc(allocator, options.allocate.?);
                switch (token) {
                    inline .string, .allocated_string => |k| {
                        const gop = try map.getOrPut(allocator, k);
                        gop.value_ptr.* = try innerParse(T, allocator, source, options);
                    },
                    .object_end => break,
                    else => unreachable,
                }
            }
            return .{ .map = map };
        }

        pub fn jsonStringify(self: @This(), w: anytype) !void {
            // ... serialize to JSON
        }
    };
}

**When to use:** Types with non-trivial JSON representation, maps with dynamic keys.

#### Compile-time Implementation Switching
Select platform-specific implementations at compile time.

```zig
const native_os = builtin.os.tag;
const use_libc = builtin.link_libc;

/// A libc-compatible API layer.
pub const system = if (use_libc)
    std.c
else switch (native_os) {
    .linux => linux,
    .plan9 => std.os.plan9,
    else => struct {
        pub const ucontext_t = void;
        pub const pid_t = void;
        pub const fd_t = void;
    },
};

pub const AF = system.AF;
pub const pid_t = system.pid_t;

**When to use:** Cross-platform code, OS-specific syscall wrappers, CPU architecture selection.

#### Dynamic Dispatch (Fat Pointer)
Use `ptr: *anyopaque` with `vtable: *const VTable` for runtime polymorphism.

```zig
const Allocator = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        alloc: *const fn (*anyopaque, len: usize, alignment: Alignment, ret_addr: usize) ?[*]u8,
        resize: *const fn (*anyopaque, []u8, Alignment, new_len: usize, ret_addr: usize) bool,
        free: *const fn (*anyopaque, []u8, Alignment, ret_addr: usize) void,
    };

    pub fn alloc(self: Allocator, len: usize, alignment: Alignment) ?[*]u8 {
        return self.vtable.alloc(self.ptr, len, alignment, @returnAddress());
    }
};

**When to use:** Allocators, I/O interfaces, plugin systems—when you need runtime polymorphism and can't use comptime generics.

#### Static Dispatch (Tagged Union with inline switch)
Use tagged unions with `inline else` for compile-time generated dispatch.

```zig
const U = union(enum) {
    a: u32,
    b: f32,
};

fn getNum(u: U) u32 {
    switch (u) {
        // Generates separate code paths at compile time
        inline else => |num, tag| {
            if (tag == .b) {
                return @intFromFloat(num);
            }
            return num;
        },
    }
}

// More common: uniform operations on all variants
const AnySlice = union(enum) {
    a: []const u8,
    b: []const u16,
    c: []const u32,
};

fn len(any: AnySlice) usize {
    return switch (any) {
        inline else => |slice| slice.len,
    };
}

**When to use:** Variants with similar operations, type-safe enums, when you want compiler-generated dispatch instead of vtables.

### III. Safety Patterns

#### Diagnostics
Use an optional diagnostics struct to provide detailed error information.

```zig
pub const ParseOptions = struct {
    string: ?[]const u8 = null,
    dynamic_linker: ?[]const u8 = null,

    /// If provided, the function will populate information about parsing failures.
    diagnostics: ?*Diagnostics = null,

    pub const Diagnostics = struct {
        arch: ?Target.Cpu.Arch = null,
        os_name: ?[]const u8 = null,
        os_tag: ?Target.Os.Tag = null,
        abi: ?Target.Abi = null,
        cpu_name: ?[]const u8 = null,
        unknown_feature_name: ?[]const u8 = null,
    };
};

pub fn parse(args: ParseOptions) !Query {
    var dummy_diags: ParseOptions.Diagnostics = undefined;
    const diags = args.diagnostics orelse &dummy_diags;

    // On error, populate diags before returning
    diags.arch = detected_arch;
    return error.UnknownArchitecture;
}

**When to use:** Parser functions, validators, anywhere you want to report multiple issues or provide context with errors.

#### Index-Based Data Structures

Zig enums are strongly-typed integer constants. By default, the compiler chooses a minimal backing type, but you can specify one explicitly with `enum(u32)`. Adding a trailing `_` field makes the enum *non-exhaustive*: any value of the backing type becomes valid, not just named members. This means `enum(u32) { _ }` is effectively "u32, but a distinct type"—the compiler won't implicitly convert between different enum types even if they share the same backing integer.

Use this to create distinct index types that the type system can distinguish. This pattern prevents bugs from accidentally mixing up indices into different arrays or confusing semantically different integers.

```zig
/// Index into `sections` array.
const SectionIndex = enum(u32) {
    _,
};

/// Index into `functions` array.
const FunctionIndex = enum(u32) {
    _,
};

/// Index into `symbols` array.
const SymbolIndex = enum(u32) {
    _,
};

These types are incompatible with each other, even though they share the same backing integer:

```zig
fn getSection(index: SectionIndex) *Section { ... }
fn getFunction(index: FunctionIndex) *Function { ... }

// COMPILE ERROR: type mismatch
const section = getSection(func_index);  // func_index is FunctionIndex, not SectionIndex

// CORRECT: types match
const section = getSection(section_index);

**Converting to/from the underlying integer:**
```zig
const index: SectionIndex = @enumFromInt(42);
const raw: u32 = @intFromEnum(index);

**Optional variants** - use a sentinel value for null representation:
```zig
/// Index into `functions`, or null.
const OptionalFunctionIndex = enum(u32) {
    none = std.math.maxInt(u32),
    _,

    pub fn unwrap(self: OptionalFunctionIndex) ?FunctionIndex {
        if (self == .none) return null;
        return @enumFromInt(@intFromEnum(self));
    }
};

/// Non-optional index with conversion helper.
const FunctionIndex = enum(u32) {
    _,

    pub fn toOptional(self: FunctionIndex) OptionalFunctionIndex {
        const result: OptionalFunctionIndex = @enumFromInt(@intFromEnum(self));
        std.debug.assert(result != .none);
        return result;
    }
};

**With sentinel states** - multiple special values:
```zig
const Parent = enum(u8) {
    /// Unallocated storage.
    unused = std.math.maxInt(u8) - 1,
    /// Indicates root node.
    none = std.math.maxInt(u8),
    /// Index into `node_storage`.
    _,

    fn unwrap(self: @This()) ?NodeIndex {
        return switch (self) {
            .unused, .none => null,
            _ => @enumFromInt(@intFromEnum(self)),
        };
    }
};

**When to use:**
- Any index into an array/slice where you have multiple arrays
- Handles, IDs, or tokens that should not be interchangeable
- Any integer with semantic meaning that could be confused with other integers
- Linkers, compilers, parsers, and any code managing multiple parallel data structures

**Benefits:**
- Compile-time detection of index mix-ups (otherwise painful runtime debugging)
- Self-documenting code - the type name explains what the integer represents
- Zero runtime cost - same representation as the underlying integer

**Why Indices Over Pointers**

Index-based data structures offer significant advantages over pointer-based ones:

- **Memory efficiency**: 4 bytes (u32) vs 8 bytes (pointer) per reference—50% savings
- **Cache locality**: Contiguous array storage means better cache utilization
- **Fewer allocations**: Append to array vs individual `create()` calls
- **Instant bulk frees**: One `deinit()` vs recursive traversal
- **Natural serialization**: Indices are relocatable; can `@memcpy` entire arrays

**Tree and Graph Modeling**

Use the "collective noun first" idiom: define the container (`Tree`) before the index type (`Node`). The index is just an integer—actual data lives in the container.

```zig
/// A tree structure using index-based nodes.
pub const Tree = struct {
    /// Node storage - the actual data lives here.
    nodes: std.MultiArrayList(Node.Data),
    /// Root is always index 0.
    root: Node = .root,

    pub const Node = enum(u32) {
        root = 0,
        _,

        /// Data stored for each node.
        pub const Data = struct {
            tag: Tag,
            parent: OptionalNode,
            children: Children,
            // ... other fields
        };

        pub const Tag = enum { leaf, branch };

        pub const Children = struct {
            start: Node,
            len: u32,
        };
    };

    pub const OptionalNode = enum(u32) {
        none = std.math.maxInt(u32),
        _,

        pub fn unwrap(self: OptionalNode) ?Node {
            if (self == .none) return null;
            return @enumFromInt(@intFromEnum(self));
        }
    };

    /// Access node data by index.
    pub fn get(self: *const Tree, node: Node) Node.Data {
        return self.nodes.get(@intFromEnum(node));
    }

    /// Get mutable pointer to node data.
    pub fn getPtr(self: *Tree, node: Node) *Node.Data {
        const slice = self.nodes.slice();
        return &slice.items(.tag)[@intFromEnum(node)];
    }
};

This pattern mirrors `std.zig.Ast` from the Zig standard library:
- `Ast.Node.Index` is `enum(u32) { _, }` (lines 3020-3035 in Ast.zig)
- Node data accessed via `ast.nodes.get(index)`
- Optional indices use `maxInt` sentinel: `Ast.Node.OptionalIndex`

**Index Ranges**

For variable-length children, use the `Index.Range` pattern from `Zoir.zig`:

```zig
pub const Node = enum(u32) {
    _,

    /// A range of contiguous node indices.
    pub const Range = struct {
        start: Node,
        len: u32,

        /// Get the node at offset `i` within this range.
        pub fn at(r: Range, i: u32) Node {
            std.debug.assert(i < r.len);
            return @enumFromInt(@intFromEnum(r.start) + i);
        }

        /// Iterate over all nodes in range.
        pub fn slice(r: Range) []const Node {
            // Note: requires nodes stored contiguously
            return @ptrCast(@as([*]const u32, @ptrFromInt(@intFromEnum(r.start)))[0..r.len]);
        }
    };
};

// Usage in tree traversal:
fn visitChildren(tree: *const Tree, node: Tree.Node) void {
    const data = tree.get(node);
    var i: u32 = 0;
    while (i < data.children.len) : (i += 1) {
        const child = data.children.at(i);
        visit(tree, child);
    }
}

**Freelist for Deletion**

When individual node deletion is needed, maintain a freelist stack:

```zig
pub const NodePool = struct {
    nodes: std.ArrayListUnmanaged(Node.Data),
    /// Head of freelist, or none if no free slots.
    free_head: OptionalNode = .none,

    pub fn alloc(self: *NodePool) !Node {
        if (self.free_head.unwrap()) |free| {
            // Reuse freed slot
            self.free_head = self.nodes.items[@intFromEnum(free)].next_free;
            return free;
        }
        // Allocate new slot
        const index: Node = @enumFromInt(self.nodes.items.len);
        try self.nodes.append(undefined);
        return index;
    }

    pub fn free(self: *NodePool, node: Node) void {
        // Push onto freelist
        self.nodes.items[@intFromEnum(node)].next_free = self.free_head;
        self.free_head = node.toOptional();
    }
};

**Stdlib examples of these patterns:**
| Pattern | File | Description |
|---------|------|-------------|
| `Node.Index` | `Ast.zig:3020-3035` | Basic index type |
| `Node.OptionalIndex` | `Ast.zig:3038-3050` | Optional with maxInt sentinel |
| `Index.Range` | `Zoir.zig:151-159` | Contiguous index ranges |
| Multiple sentinels | `Progress.zig:157-171` | `unused`, `none` states |
| Accessor pattern | `Ast.zig:88-106` | `ast.nodes.get(index)` |

#### Error Payloads
Use a tagged union to attach context to errors.

```zig
pub const Diagnostics = struct {
    errors: std.ArrayListUnmanaged(Error) = .empty,
    entries: usize = 0,

    pub const Error = union(enum) {
        unable_to_create_sym_link: struct {
            code: anyerror,
            file_name: []const u8,
            link_name: []const u8,
        },
        unable_to_create_file: struct {
            code: anyerror,
            file_name: []const u8,
        },
        unsupported_file_type: struct {
            file_name: []const u8,
            file_type: Header.Kind,
        },
    };
};

// Usage: collect errors instead of failing immediately
fn extract(d: *Diagnostics, ...) !void {
    file.create(...) catch |err| {
        try d.errors.append(allocator, .{
            .unable_to_create_file = .{ .code = err, .file_name = name },
        });
        return;
    };
}

**When to use:** Batch processing with multiple possible failures, when you need more context than error codes provide.

#### Compile-time Assertion
Use `comptime { assert(...); }` for compile-time invariant checking.

```zig
const upper_bound_msg_len = 1 + node_storage_buffer_len * @sizeOf(Node.Storage) +
    node_storage_buffer_len * @sizeOf(Node.OptionalIndex);
comptime assert(upper_bound_msg_len <= 4096);

// Also works with @compileError for custom messages
comptime {
    if (@sizeOf(MyStruct) > 64) {
        @compileError("MyStruct too large for cache line");
    }
}

**When to use:** Size constraints, alignment requirements, invariants that must hold at compile time.

#### Granular Error Handling
Use exhaustive switch on specific error values for precise handling.

```zig
fn oom(err: anytype) noreturn {
    switch (err) {
        error.OutOfMemory => @panic("out of memory"),
    }
}

// Or handle different errors differently:
file.open() catch |err| switch (err) {
    error.FileNotFound => return createDefault(),
    error.AccessDenied => return error.PermissionDenied,
    error.IsDir => return error.InvalidPath,
    else => return err,
};

**When to use:** When different errors need different handling, converting between error sets.

#### Deallocated Memory Poisoning
Set `self.* = undefined;` after deallocation to catch use-after-free.

```zig
pub fn deinit(self: *Self, gpa: Allocator) void {
    gpa.free(self.allocatedSlice());
    self.* = undefined;  // Poison the memory
}

**When to use:** In `deinit` functions to help catch use-after-free bugs in debug builds. Zig writes `0xaa` bytes to undefined memory in debug mode.

#### Deferred Resource Deinitialization
Use `defer` for unconditional cleanup.

```zig
fn doWork(self: *Self) void {
    self.mutex.lock();
    defer self.mutex.unlock();  // Always runs, even on error

    // ... work with locked resource
}

**When to use:** Mutexes, file handles, any resource that must be released regardless of control flow.

#### Error-deferred Resource Deinitialization
Use `errdefer` for cleanup only on error paths.

```zig
pub fn put(self: *BufMap, key: []const u8, value: []const u8) !void {
    const value_copy = try self.copy(value);
    errdefer self.free(value_copy);  // Only runs if we return an error

    const get_or_put = try self.hash_map.getOrPut(key);
    // ... if this succeeds, value_copy ownership is transferred
}

**When to use:** Partial initialization, multi-step construction where early steps need rollback on later failures.

#### Compile-time Unreachable Switch Prong
Use `else => comptime unreachable` for exhaustive compile-time switches.

```zig
fn shl(a: anytype, shift_amt: anytype) @TypeOf(a) {
    const casted_shift_amt = switch (@typeInfo(@TypeOf(shift_amt))) {
        .int => @as(Log2Int(@TypeOf(a)), @intCast(shift_amt)),
        .comptime_int => @as(Log2Int(@TypeOf(a)), shift_amt),
        else => comptime unreachable,  // Only int types allowed
    };
    return a << casted_shift_amt;
}

**When to use:** Generic functions where only certain type categories are valid.

#### Compile-time Error Absence Guarantee
Use `errdefer comptime unreachable;` to assert no errors can occur after a point.

```zig
fn spawnChild(self: *Child) !void {
    const pid_result = posix.fork();
    if (pid_result == 0) {
        // Child process
        posix.execvpeZ(...);
        forkChildErrReport(err_pipe[1], err);
    }

    // Parent process - after fork, we must not error
    errdefer comptime unreachable;  // Compile error if any code below can error

    posix.close(err_pipe[1]);
    self.err_pipe = err_pipe[0];
    // ... all operations here must be infallible
}

**When to use:** After point-of-no-return operations like fork(), to ensure subsequent code is truly infallible.

#### Reserve-First Exception Safety
When mutating data structures that can fail (e.g., growing arrays or hash maps), separate the fallible reservation phase from the infallible mutation phase. This ensures strong exception safety: if an error occurs, the object remains unchanged.

**The pattern:**
1. **Reserve** - Call `ensureUnusedCapacity` for all containers that will grow. These calls can fail but don't mutate data.
2. **Mark boundary** - Use `errdefer comptime unreachable;` to assert no errors can occur after this point.
3. **Mutate** - Use `*AssumeCapacity` methods which cannot fail.

```zig
// WRONG - exception safety bug
pub fn internString(state: *State, gpa: Allocator, bytes: []const u8) !String {
    // BUG: getOrPut inserts a slot, then ensureUnusedCapacity can fail,
    // leaving an uninitialized entry in the hash table
    const gop = try state.string_table.getOrPut(gpa, bytes);
    if (gop.found_existing) return gop.key_ptr.*;

    try state.string_bytes.ensureUnusedCapacity(gpa, bytes.len + 1);  // Can fail!
    // ... rest of function
}

// CORRECT - reserve first, then mutate
pub fn internString(state: *State, gpa: Allocator, bytes: []const u8) !String {
    // Phase 1: Reserve capacity (all fallible operations)
    try state.string_table.ensureUnusedCapacityContext(gpa, 1, .{
        .bytes = state.string_bytes.items,
    });
    try state.string_bytes.ensureUnusedCapacity(gpa, bytes.len + 1);

    errdefer comptime unreachable;  // Phase 2: No errors after this point

    // Phase 3: Mutate using AssumeCapacity methods (infallible)
    const gop = state.string_table.getOrPutAssumeCapacityAdapted(bytes, .{
        .bytes = state.string_bytes.items,
    });
    if (gop.found_existing) return gop.key_ptr.*;

    const new_off: String = @enumFromInt(state.string_bytes.items.len);
    state.string_bytes.appendSliceAssumeCapacity(bytes);
    state.string_bytes.appendAssumeCapacity(0);
    gop.key_ptr.* = new_off;

    return new_off;
}

**Real-world example from HashMap.grow:**
```zig
fn grow(self: *Self, allocator: Allocator, new_capacity: Size, ctx: Context) Allocator.Error!void {
    var map: Self = .{};
    try map.allocate(allocator, new_cap);    // Can fail
    errdefer comptime unreachable;           // No errors after this point

    map.initMetadatas();                     // Infallible
    map.available = @truncate((new_cap * max_load_percentage) / 100);

    // Copy all entries using putAssumeCapacityNoClobberContext (infallible)
    if (self.size != 0) {
        for (self.metadata.?[0..old_capacity], self.keys()[0..old_capacity], self.values()[0..old_capacity]) |m, k, v| {
            if (!m.isUsed()) continue;
            map.putAssumeCapacityNoClobberContext(k, v, ctx);  // Infallible
        }
    }
    // ... swap and cleanup
}

**Exception safety levels:**
- **Strong** (reserve-first): Object unchanged if error occurs
- **Basic**: Object left in valid but different state
- **None**: Object may be corrupted

**When to use:**
- Any function that must insert into multiple containers
- Growing data structures where partial mutation would corrupt state
- String/symbol interning (hash table + byte array)
- Any operation where failure after partial mutation leaves invalid state

**Key insight:** `ensureUnusedCapacity` is magic—it contains all the failure modes but changes nothing. Reservation failures are safe to retry; partial mutations are not.

### IV. Performance Patterns

#### Big Struct Constant Pointer Passing
Pass large structs by `*const` to avoid copies.

```zig
// GOOD: Pass by const pointer for large structs
pub fn format(uri: *const Uri, writer: *Writer) Writer.Error!void {
    return writeToStream(uri, writer, .all);
}

pub fn writeToStream(uri: *const Uri, writer: *Writer, flags: Format.Flags) Writer.Error!void {
    if (flags.scheme) {
        try writer.print("{s}:", .{uri.scheme});
    }
    // ...
}

**When to use:** Structs larger than ~2 pointers that are read-only. The calling convention may copy small structs in registers anyway.

#### Big Struct Constant Pointer Capturing
Use `*const` in closures to avoid copying large captured values.

```zig
if (m.resolved_target) |*target| {  // *target is a pointer, not a copy
    if (!target.query.isNative()) {
        try zig_args.appendSlice(&.{
            "-target", try target.query.zigTriple(b.allocator),
            "-mcpu",   try target.query.serializeCpuAlloc(b.allocator),
        });
    }
}

**When to use:** When capturing large structs in closures or iterating with payload capture on large items.

### V. Workarounds

#### Inlined Loop with Runtime Logic
When `inline for` doesn't work (e.g., modifying slice during iteration), use `comptime var` with `inline while`.

```zig
fn deinterlace(interlaced: anytype, comptime vec_count: usize) [vec_count]@Vector(...) {
    const vec_len = vectorLength(@TypeOf(interlaced)) / vec_count;
    const Child = std.meta.Child(@TypeOf(interlaced));

    var out: [vec_count]@Vector(vec_len, Child) = undefined;

    // inline for doesn't work here due to runtime slice mutation
    comptime var i: usize = 0;
    inline while (i < out.len) : (i += 1) {
        const indices = comptime iota(i32, vec_len) *
            @as(@Vector(vec_len, i32), @splat(@intCast(vec_count))) +
            @as(@Vector(vec_len, i32), @splat(@intCast(i)));
        out[i] = @shuffle(Child, interlaced, undefined, indices);
    }

    return out;
}

**When to use:** When you need compile-time loop unrolling but `inline for` fails due to control flow or mutation requirements.
# C Interoperability Reference

Zig can export C-compatible APIs for use from any language that supports the C ABI: Swift, Objective-C, Python, Ruby, Rust, etc. This enables architectures like Ghostty (93% Zig business logic + 4% platform-native GUI).

## Table of Contents
- [Quick Start](#quick-start)
- [Exporting Functions](#exporting-functions)
- [C-Compatible Types](#c-compatible-types)
- [Building C Libraries](#building-c-libraries)
- [Creating Header Files](#creating-header-files)
- [macOS Integration](#macos-integration)
- [Swift Integration](#swift-integration)
- [Common Patterns](#common-patterns)

## Quick Start

Minimal C-compatible library:

**src/lib.zig:**
```zig
const std = @import("std");

// Global state (opaque to C consumers)
var context: ?*Context = null;

const Context = struct {
    allocator: std.mem.Allocator,
    value: i32,
};

/// Initialize the library. Returns 0 on success, -1 on failure.
export fn mylib_init() c_int {
    const gpa = std.heap.c_allocator;
    context = gpa.create(Context) catch return -1;
    context.?.* = .{ .allocator = gpa, .value = 0 };
    return 0;
}

/// Clean up resources.
export fn mylib_deinit() void {
    if (context) |ctx| {
        ctx.allocator.destroy(ctx);
        context = null;
    }
}

/// Get the current value.
export fn mylib_get_value() c_int {
    return if (context) |ctx| ctx.value else 0;
}

/// Set the value.
export fn mylib_set_value(v: c_int) void {
    if (context) |ctx| ctx.value = v;
}

**build.zig:**
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "mylib",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Link libc if using std.heap.c_allocator
    lib.linkLibC();

    b.installArtifact(lib);

    // Install header alongside library
    b.installFile("include/mylib.h", "include/mylib.h");
}

**include/mylib.h:**
```c
#ifndef MYLIB_H
#define MYLIB_H

#ifdef __cplusplus
extern "C" {
#endif

int mylib_init(void);
void mylib_deinit(void);
int mylib_get_value(void);
void mylib_set_value(int v);

#ifdef __cplusplus
}
#endif

#endif /* MYLIB_H */

## Exporting Functions

### `export` Keyword

The `export` keyword creates a function with C ABI linkage:

```zig
// Creates symbol "add" with C calling convention
export fn add(a: c_int, b: c_int) c_int {
    return a + b;
}

Equivalent to:
```zig
fn add(a: c_int, b: c_int) callconv(.c) c_int {
    return a + b;
}
comptime {
    @export(&add, .{ .name = "add" });
}

### Custom Symbol Names

Use `@export` for custom symbol names:

```zig
fn zigAdd(a: c_int, b: c_int) callconv(.c) c_int {
    return a + b;
}

comptime {
    @export(&zigAdd, .{ .name = "mylib_add" });  // Symbol: mylib_add
}

### Calling Convention

For internal C-callable functions (not exported):

```zig
// C calling convention, but not exported as symbol
fn internalCallback(data: ?*anyopaque) callconv(.c) void {
    // Called by C code via function pointer
}

### Restrictions on Exported Functions

Exported function signatures are limited to C-compatible constructs:

**Allowed:**
- C integer types: `c_int`, `c_uint`, `c_long`, `c_ulong`, `c_char`, etc.
- Fixed-width integers matching C: `i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`
- Floating point: `f32` (`float`), `f64` (`double`)
- Pointers: `*T`, `[*]T`, `[*c]T`, `?*T`
- `bool` (maps to C `_Bool`)
- `void`
- `usize`, `isize` (map to `size_t`, `ptrdiff_t`)

**Not allowed in signatures:**
- Comptime parameters
- Generic types (`anytype`)
- Zig error unions (`!T`)
- Zig optionals (except optional pointers `?*T`)
- Slices (`[]T`) - use pointer + length instead
- Non-extern structs/unions/enums
- Arbitrary bit-width integers (`u3`, `i47`)

**Inside the function body**, all Zig features work:

```zig
export fn process(data: [*]const u8, len: usize) c_int {
    // Inside: full Zig features
    const slice = data[0..len];

    for (slice) |byte| {
        if (byte == 0) return -1;
    }

    return @intCast(slice.len);
}

## C-Compatible Types

### Integer Type Mapping

| Zig Type | C Type | Notes |
|----------|--------|-------|
| `c_char` | `char` | Signed or unsigned (platform-dependent) |
| `c_short` | `short` | |
| `c_int` | `int` | |
| `c_long` | `long` | 32-bit on Windows, 64-bit elsewhere |
| `c_longlong` | `long long` | |
| `c_uchar` | `unsigned char` | |
| `c_ushort` | `unsigned short` | |
| `c_uint` | `unsigned int` | |
| `c_ulong` | `unsigned long` | |
| `c_ulonglong` | `unsigned long long` | |
| `usize` | `size_t` | |
| `isize` | `ptrdiff_t` | |
| `i8`/`u8` | `int8_t`/`uint8_t` | |
| `i16`/`u16` | `int16_t`/`uint16_t` | |
| `i32`/`u32` | `int32_t`/`uint32_t` | |
| `i64`/`u64` | `int64_t`/`uint64_t` | |

### Pointer Type Mapping

| Zig Type | C Equivalent | Notes |
|----------|--------------|-------|
| `*T` | `T*` | Non-null pointer |
| `?*T` | `T*` | Nullable pointer |
| `[*]T` | `T*` | Many-item pointer |
| `[*c]T` | `T*` | C pointer (nullable, arithmetic allowed) |
| `*const T` | `const T*` | Const pointer |

### Extern Structs

For structs passed across FFI boundary:

```zig
// Extern struct: C-compatible layout
pub const Point = extern struct {
    x: f64,
    y: f64,
};

// Can be passed by value or pointer
export fn distance(a: Point, b: Point) f64 {
    const dx = a.x - b.x;
    const dy = a.y - b.y;
    return @sqrt(dx * dx + dy * dy);
}

### Extern Unions

```zig
pub const Value = extern union {
    i: c_int,
    f: f32,
    p: ?*anyopaque,
};

### Extern Enums

```zig
// Specify backing type for C compatibility
pub const Status = enum(c_int) {
    ok = 0,
    err_invalid = -1,
    err_nomem = -2,
};

export fn get_status() Status {
    return .ok;
}

## Building C Libraries

### Static Library

```zig
const lib = b.addLibrary(.{
    .name = "mylib",
    .linkage = .static,  // Creates libmylib.a
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    }),
});

lib.linkLibC();  // If using c_allocator or libc functions
b.installArtifact(lib);

### Dynamic/Shared Library

```zig
const lib = b.addLibrary(.{
    .name = "mylib",
    .linkage = .dynamic,  // Creates libmylib.so / libmylib.dylib / mylib.dll
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    }),
    .version = .{ .major = 1, .minor = 0, .patch = 0 },
});

lib.linkLibC();
b.installArtifact(lib);

### Cross-Compilation

Build for specific targets:

```zig
// Build for Apple Silicon Mac
const mac_arm = b.resolveTargetQuery(.{
    .cpu_arch = .aarch64,
    .os_tag = .macos,
});

const lib = b.addLibrary(.{
    .name = "mylib",
    .linkage = .static,
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = mac_arm,
        .optimize = .ReleaseFast,
    }),
});

### Multi-Target Build

```zig
const targets = [_]std.Target.Query{
    .{ .cpu_arch = .x86_64, .os_tag = .macos },
    .{ .cpu_arch = .aarch64, .os_tag = .macos },
    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .gnu },
};

for (targets) |t| {
    const resolved = b.resolveTargetQuery(t);
    const lib = b.addLibrary(.{
        .name = b.fmt("mylib-{s}-{s}", .{
            @tagName(t.cpu_arch.?),
            @tagName(t.os_tag.?),
        }),
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = resolved,
            .optimize = .ReleaseFast,
        }),
    });
    b.installArtifact(lib);
}

## Creating Header Files

Zig does not auto-generate C headers. Write them manually to match exported symbols.

### Header Template

```c
#ifndef MYLIB_H
#define MYLIB_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Opaque handle type */
typedef struct mylib_context mylib_context_t;

/* Lifecycle */
mylib_context_t* mylib_create(void);
void mylib_destroy(mylib_context_t* ctx);

/* Operations */
int mylib_process(mylib_context_t* ctx, const uint8_t* data, size_t len);
const char* mylib_get_error(mylib_context_t* ctx);

/* Callback type */
typedef void (*mylib_callback_t)(void* user_data, int result);
void mylib_set_callback(mylib_context_t* ctx, mylib_callback_t cb, void* user_data);

#ifdef __cplusplus
}
#endif

#endif /* MYLIB_H */

### Matching Zig Implementation

```zig
const std = @import("std");

pub const Context = struct {
    allocator: std.mem.Allocator,
    error_msg: ?[]const u8 = null,
    callback: ?Callback = null,

    const Callback = struct {
        func: *const fn (?*anyopaque, c_int) callconv(.c) void,
        user_data: ?*anyopaque,
    };
};

export fn mylib_create() ?*Context {
    const allocator = std.heap.c_allocator;
    return allocator.create(Context) catch null;
}

export fn mylib_destroy(ctx: ?*Context) void {
    if (ctx) |c| {
        c.allocator.destroy(c);
    }
}

export fn mylib_process(ctx: ?*Context, data: [*]const u8, len: usize) c_int {
    const c = ctx orelse return -1;
    const slice = data[0..len];

    // Process data...
    _ = slice;

    if (c.callback) |cb| {
        cb.func(cb.user_data, 0);
    }

    return 0;
}

export fn mylib_get_error(ctx: ?*Context) [*:0]const u8 {
    const c = ctx orelse return "null context";
    return if (c.error_msg) |msg|
        msg.ptr
    else
        "no error";
}

export fn mylib_set_callback(
    ctx: ?*Context,
    cb: ?*const fn (?*anyopaque, c_int) callconv(.c) void,
    user_data: ?*anyopaque,
) void {
    if (ctx) |c| {
        c.callback = if (cb) |f| .{ .func = f, .user_data = user_data } else null;
    }
}

## macOS Integration

### Universal Binaries (Fat Binaries)

Build for both architectures and combine with `lipo`:

**build.zig:**
```zig
pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    // Build for both architectures
    const arm64 = b.resolveTargetQuery(.{ .cpu_arch = .aarch64, .os_tag = .macos });
    const x86_64 = b.resolveTargetQuery(.{ .cpu_arch = .x86_64, .os_tag = .macos });

    const lib_arm64 = b.addLibrary(.{
        .name = "mylib",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = arm64,
            .optimize = optimize,
        }),
    });

    const lib_x86_64 = b.addLibrary(.{
        .name = "mylib",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = x86_64,
            .optimize = optimize,
        }),
    });

    // Use lipo to create universal binary
    const lipo = b.addSystemCommand(&.{
        "lipo", "-create", "-output",
    });
    const universal_lib = lipo.addOutputFileArg("libmylib.a");
    lipo.addFileArg(lib_arm64.getEmittedBin());
    lipo.addFileArg(lib_x86_64.getEmittedBin());

    // Install universal binary
    const install = b.addInstallFile(universal_lib, "lib/libmylib.a");

    const universal_step = b.step("universal", "Build universal binary");
    universal_step.dependOn(&install.step);
}

**Manual lipo usage:**
```bash
# Build each architecture
zig build -Dtarget=aarch64-macos -Doptimize=ReleaseFast
mv zig-out/lib/libmylib.a libmylib-arm64.a

zig build -Dtarget=x86_64-macos -Doptimize=ReleaseFast
mv zig-out/lib/libmylib.a libmylib-x86_64.a

# Combine into universal binary
lipo -create -output libmylib.a libmylib-arm64.a libmylib-x86_64.a

# Verify architectures
lipo -info libmylib.a

### XCFramework Creation

XCFrameworks are the modern way to distribute libraries for Apple platforms:

```bash
# 1. Build universal library (see above)

# 2. Create directory structure
mkdir -p MyLib.xcframework/macos-arm64_x86_64/Headers

# 3. Copy library and headers
cp libmylib.a MyLib.xcframework/macos-arm64_x86_64/
cp include/mylib.h MyLib.xcframework/macos-arm64_x86_64/Headers/

# 4. Create module map
cat > MyLib.xcframework/macos-arm64_x86_64/Headers/module.modulemap << 'EOF'
module MyLib {
    umbrella header "mylib.h"
    export *
}
EOF

# 5. Create Info.plist
cat > MyLib.xcframework/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AvailableLibraries</key>
    <array>
        <dict>
            <key>HeadersPath</key>
            <string>Headers</string>
            <key>LibraryIdentifier</key>
            <string>macos-arm64_x86_64</string>
            <key>LibraryPath</key>
            <string>libmylib.a</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
                <string>x86_64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>macos</string>
        </dict>
    </array>
    <key>CFBundlePackageType</key>
    <string>XFWK</string>
    <key>XCFrameworkFormatVersion</key>
    <string>1.0</string>
</dict>
</plist>
EOF

**Using xcodebuild (simpler):**
```bash
xcodebuild -create-xcframework \
    -library libmylib.a \
    -headers include/ \
    -output MyLib.xcframework

## Swift Integration

### Module Map

Create `module.modulemap` alongside your header:

```c
module MyLib {
    umbrella header "mylib.h"
    export *
}

### Using from Swift

```swift
import MyLib

// Use C functions directly
let result = mylib_init()
if result == 0 {
    mylib_set_value(42)
    print("Value: \(mylib_get_value())")
    mylib_deinit()
}

### Swift-Friendly Wrapper

```swift
import MyLib

class MyLibWrapper {
    private var initialized = false

    init?() {
        guard mylib_init() == 0 else { return nil }
        initialized = true
    }

    deinit {
        if initialized {
            mylib_deinit()
        }
    }

    var value: Int32 {
        get { mylib_get_value() }
        set { mylib_set_value(newValue) }
    }
}

### Xcode Project Integration

1. Drag `MyLib.xcframework` into Xcode project
2. Ensure "Embed & Sign" or "Do Not Embed" (for static libs)
3. Import module: `import MyLib`

For static libraries without XCFramework:
1. Add library to "Link Binary With Libraries"
2. Add header path to "Header Search Paths"
3. Create bridging header if not using module map

### Improving Swift Interop (Advanced)

For better Swift projection, use API notes (`.apinotes` files):

**MyLib.apinotes:**
```yaml
Name: MyLib
Functions:
  - Name: mylib_create
    SwiftName: "MyLibContext.create()"
    NullabilityOfRet: N  # Non-null (returns Optional in Swift)
  - Name: mylib_destroy
    SwiftName: "MyLibContext.destroy(self:)"
  - Name: mylib_get_error
    NullabilityOfRet: N
    ResultType: "const char * _Nonnull"

See [Swift.org: Improving the Usability of C APIs](https://www.swift.org/documentation/cxx-interop/) for more.

## Common Patterns

### Opaque Pointers

Hide implementation details from C consumers:

```zig
const std = @import("std");

const InternalState = struct {
    allocator: std.mem.Allocator,
    data: std.ArrayList(u8),
    // Complex internal state...
};

// C sees: typedef struct handle handle_t;
// (opaque, can't access fields)

export fn handle_create() ?*InternalState {
    const allocator = std.heap.c_allocator;
    const state = allocator.create(InternalState) catch return null;
    state.* = .{
        .allocator = allocator,
        .data = std.ArrayList(u8).init(allocator),
    };
    return state;
}

export fn handle_destroy(h: ?*InternalState) void {
    if (h) |state| {
        state.data.deinit();
        state.allocator.destroy(state);
    }
}

### Error Handling Across FFI

Zig errors can't cross FFI boundary. Use return codes or out parameters:

```zig
pub const ErrorCode = enum(c_int) {
    ok = 0,
    invalid_argument = -1,
    out_of_memory = -2,
    io_error = -3,
    unknown = -99,
};

export fn process_data(
    data: [*]const u8,
    len: usize,
    out_result: *c_int,
) ErrorCode {
    const slice = data[0..len];

    // Internal Zig code can use errors
    const result = processInternal(slice) catch |err| {
        return switch (err) {
            error.OutOfMemory => .out_of_memory,
            error.InvalidData => .invalid_argument,
            else => .unknown,
        };
    };

    out_result.* = result;
    return .ok;
}

fn processInternal(data: []const u8) !c_int {
    // Full Zig error handling here
    if (data.len == 0) return error.InvalidData;
    return @intCast(data.len);
}

### Callbacks

C callbacks with user data:

```zig
const CallbackFn = *const fn (
    user_data: ?*anyopaque,
    event_type: c_int,
    event_data: ?*const anyopaque,
) callconv(.c) void;

var stored_callback: ?CallbackFn = null;
var stored_user_data: ?*anyopaque = null;

export fn register_callback(cb: ?CallbackFn, user_data: ?*anyopaque) void {
    stored_callback = cb;
    stored_user_data = user_data;
}

export fn trigger_event(event_type: c_int) void {
    if (stored_callback) |cb| {
        cb(stored_user_data, event_type, null);
    }
}

### String Handling

Zig slices vs C strings:

```zig
const std = @import("std");

// Accept C string, return length
export fn string_length(s: [*:0]const u8) usize {
    return std.mem.len(s);
}

// Accept pointer + length (more efficient)
export fn process_string(s: [*]const u8, len: usize) c_int {
    const slice = s[0..len];
    // Process slice...
    _ = slice;
    return 0;
}

// Return C string (must be static or allocated)
const greeting: [:0]const u8 = "Hello from Zig!";

export fn get_greeting() [*:0]const u8 {
    return greeting.ptr;
}

// Allocate string for caller to free
export fn alloc_string(len: usize) ?[*:0]u8 {
    const allocator = std.heap.c_allocator;
    const buf = allocator.allocSentinel(u8, len, 0) catch return null;
    return buf.ptr;
}

export fn free_string(s: ?[*:0]u8) void {
    if (s) |ptr| {
        const allocator = std.heap.c_allocator;
        // Need to know length to free - typically tracked separately
        // or use c_allocator which can query allocation size
        _ = allocator;
        _ = ptr;
    }
}

### Thread Safety

For thread-safe libraries, use atomics or mutexes:

```zig
const std = @import("std");

var global_mutex: std.Thread.Mutex = .{};
var shared_value: c_int = 0;

export fn thread_safe_increment() c_int {
    global_mutex.lock();
    defer global_mutex.unlock();

    shared_value += 1;
    return shared_value;
}

// Or use atomics for simple cases
var atomic_counter: std.atomic.Value(c_int) = .init(0);

export fn atomic_increment() c_int {
    return atomic_counter.fetchAdd(1, .seq_cst) + 1;
}

### Versioning

Export version info for runtime checking:

```zig
pub const version_major: c_int = 1;
pub const version_minor: c_int = 2;
pub const version_patch: c_int = 3;

comptime {
    @export(&version_major, .{ .name = "mylib_version_major" });
    @export(&version_minor, .{ .name = "mylib_version_minor" });
    @export(&version_patch, .{ .name = "mylib_version_patch" });
}

export fn mylib_version_string() [*:0]const u8 {
    return "1.2.3";
}

**Header:**
```c
extern const int mylib_version_major;
extern const int mylib_version_minor;
extern const int mylib_version_patch;
const char* mylib_version_string(void);
# Production Zig Patterns

Real-world patterns extracted from Bun (JS runtime, 180k+ LoC), Ghostty (terminal emulator, 100k+ LoC), and TigerBeetle (financial database, 80k+ LoC). These complement [patterns.md](patterns.md) with battle-tested techniques from large-scale Zig projects.

## Table of Contents

- [Build System at Scale](#build-system-at-scale)
- [Memory Management](#memory-management)
- [Data Structures](#data-structures)
- [Concurrency](#concurrency)
- [SIMD & Vectorization](#simd--vectorization)
- [Error Handling](#error-handling)
- [Platform Abstraction](#platform-abstraction)
- [C Interop](#c-interop)
- [Comptime Patterns](#comptime-patterns)
- [String Optimization](#string-optimization)
- [Testing](#testing)
- [Performance](#performance)

---

## Build System at Scale

### Modular Build Architecture (Ghostty)

Large projects delegate build logic to specialized modules instead of one monolithic `build.zig`:

```zig
// build.zig — thin orchestrator
const buildpkg = @import("src/build/main.zig");

pub fn build(b: *std.Build) !void {
    const config = try buildpkg.Config.init(b, appVersion);
    const deps = try buildpkg.SharedDeps.init(b, &config);
    const exe = try buildpkg.GhosttyExe.init(b, &config, &deps);
    // ...
}

Central `Config` struct stores all build options. Each artifact (exe, lib, test) has isolated build logic in its own file.

### Hermetic Compiler Version Locking (TigerBeetle)

```zig
comptime {
    const expected = std.SemanticVersion{ .major = 0, .minor = 14, .patch = 1 };
    if (expected.major != builtin.zig_version.major or
        expected.minor != builtin.zig_version.minor or
        expected.patch != builtin.zig_version.patch)
    {
        @compileError(std.fmt.comptimePrint(
            "unsupported zig version: expected {}, found {}",
            .{ expected, builtin.zig_version },
        ));
    }
}

Prevents silent ABI/API mismatches from wrong compiler versions.

### CPU Feature Locking (TigerBeetle, Bun)

```zig
fn resolve_target(b: *std.Build, target: []const u8) !std.Build.ResolvedTarget {
    const arch_os, const cpu = inline for (
        .{ "aarch64-linux", "x86_64-linux" },
        .{ "baseline+aes+neon", "x86_64_v3+aes" },
    ) |triple, features| {
        if (std.mem.eql(u8, target, triple)) break .{ triple, features };
    } else return error.UnsupportedTarget;

    return b.resolveTargetQuery(try Query.parse(.{
        .arch_os_abi = arch_os,
        .cpu_features = cpu,
    }));
}

Locks feature sets per architecture for reproducible performance. `inline for` compiles to flat dispatch.

### Baseline Detection (Bun)

```zig
pub fn isBaseline(opts: *const BuildOptions) bool {
    return opts.arch.isX86() and
        !Target.x86.featureSetHas(opts.target.result.cpu.features, .avx2);
}

Detect at build time whether target supports AVX2. Ship separate baseline/optimized binaries.

---

## Memory Management

### Fast Libc Memory Ops with Fallback (Ghostty)

```zig
pub inline fn move(comptime T: type, dest: []T, source: []const T) void {
    if (builtin.link_libc) {
        _ = memmove(dest.ptr, source.ptr, source.len * @sizeOf(T));
    } else {
        @memmove(dest, source);
    }
}

extern "c" fn memmove(*anyopaque, *const anyopaque, usize) *anyopaque;

Libc `memmove` can be 10-20% faster than Zig builtin on large buffers. Inline preserves tight loop performance.

### Pre-Allocated Message Pool (TigerBeetle)

```zig
pub const Message = extern struct {
    header: *Header,
    buffer: *align(constants.sector_size) [constants.message_size_max]u8,
    references: u32 = 0,
    link: FreeList.Link,

    pub fn ref(message: *Message) *Message {
        assert(message.references > 0);
        message.references += 1;
        return message;
    }
};

All messages pre-allocated at startup. Sector-aligned buffers for Direct I/O. Reference counting enables zero-copy message passing. No hot-path allocations.

### Counting Allocator Wrapper (TigerBeetle)

```zig
pub fn allocator(self: *CountingAllocator) std.mem.Allocator {
    return .{
        .ptr = self,
        .vtable = &.{ .alloc = alloc, .resize = resize, .remap = remap, .free = free },
    };
}

pub fn live_size(self: *CountingAllocator) u64 {
    return self.alloc_size - self.free_size;
}

Wraps any allocator for non-intrusive memory tracking. Query `live_size()` for leak detection.

### Debug Leak Detection Scope (Bun)

```zig
const LockedState = struct {
    parent: std.mem.Allocator,
    history: *History,

    fn alloc(self: Self, len: usize, alignment: Alignment, ret_addr: usize) ![*]u8 {
        const result = self.parent.rawAlloc(len, alignment, ret_addr) orelse
            return error.OutOfMemory;
        errdefer self.parent.rawFree(result[0..len], alignment, ret_addr);
        try self.trackAllocation(result[0..len], ret_addr, .none);
        return result;
    }
};

Wraps allocator in Debug mode. Tracks allocation sites with stack traces. Catches use-after-free, double-free. Zero overhead in Release.

### Conditional Allocator Selection (Ghostty)

```zig
self.alloc = if (self.gpa) |*value|
    value.allocator()
else if (builtin.link_libc)
    std.heap.c_allocator
else
    unreachable;

Debug: GPA for leak detection. Release: libc malloc (faster). Valgrind: libc (instrumentable). Single decision at startup.

### Mimalloc Thread-Local Arena (Bun)

```zig
pub const Borrowed = struct {
    heap: *mimalloc.Heap,

    fn alignedAlloc(self: Borrowed, len: usize, alignment: Alignment) ?[*]u8 {
        const ptr = if (mimalloc.mustUseAlignedAlloc(alignment))
            mimalloc.mi_heap_malloc_aligned(self.heap, len, alignment.toByteUnits())
        else
            mimalloc.mi_heap_malloc(self.heap, len);
        return if (ptr) |p| @ptrCast(p) else null;
    }
};

Thread-local heaps eliminate contention. Borrowed/Owned makes ownership clear at the type level. 2-3x faster than system malloc under contention.

---

## Data Structures

### Segmented Pool for Stable Pointers (Ghostty)

```zig
pub fn SegmentedPool(comptime T: type, comptime prealloc: usize) type {
    return struct {
        list: std.SegmentedList(T, prealloc) = .{ .len = prealloc },
        available: usize = prealloc,

        pub fn getGrow(self: *Self, alloc: Allocator) !*T {
            if (self.available == 0) try self.grow(alloc);
            return try self.get();
        }

        fn grow(self: *Self, alloc: Allocator) !void {
            try self.list.growCapacity(alloc, self.list.len * 2);
            self.available = self.list.len;
            self.list.len *= 2;
        }
    };
}

Grows without reallocation — pointers never invalidated. Use when callers hold pointers to pool elements (e.g. I/O write requests).

### Fixed-Bucket Cache Table with LRU (Ghostty)

```zig
pub fn CacheTable(comptime K: type, comptime V: type, comptime bucket_count: usize, comptime bucket_size: u8) type {
    return struct {
        buckets: [bucket_count][bucket_size]KV = undefined,
        lengths: [bucket_count]u8 = @splat(0),

        pub fn put(self: *Self, key: K, value: V) ?KV {
            const idx: usize = @intCast(self.context.hash(key) % bucket_count);
            if (self.lengths[idx] < bucket_size) {
                self.buckets[idx][self.lengths[idx]] = kv;
                self.lengths[idx] += 1;
                return null;
            }
            // Rotate oldest out, insert at back
            const evicted = fastmem.rotateIn(KV, &self.buckets[idx], kv);
            if (comptime @hasDecl(Context, "evicted"))
                self.context.evicted(evicted.key, evicted.value);
            return evicted;
        }
    };
}

No allocations after init. LRU per bucket via rotate. Optional eviction callback via `@hasDecl`.

### Intrusive Linked Lists (Ghostty, TigerBeetle)

```zig
// TigerBeetle: zero-alloc stack via @fieldParentPtr
pub fn StackType(comptime T: type) type {
    return struct {
        any: StackAny,
        pub inline fn push(self: *Stack, node: *T) void { self.any.push(&node.link); }
        pub inline fn pop(self: *Stack) ?*T {
            const link = self.any.pop() orelse return null;
            return @fieldParentPtr("link", link);
        }
    };
}

Node lives inside the struct itself. O(1) insert/remove, zero allocator dependency. Foundation of TigerBeetle's I/O queues and Ghostty's surface lists.

### BoundedArray — Fixed Capacity, No Allocator (TigerBeetle)

```zig
pub fn BoundedArrayType(comptime T: type, comptime capacity: usize) type {
    return struct {
        buffer: [capacity]T = undefined,
        count_u32: u32 = 0,

        pub inline fn push(array: *Self, item: T) void {
            assert(!array.full());
            array.buffer[array.count_u32] = item;
            array.count_u32 += 1;
        }
        pub inline fn unused_capacity_slice(array: *Self) []T {
            return array.buffer[array.count_u32..];
        }
    };
}

Capacity baked into type. Stack-allocatable. `unused_capacity_slice` for efficient bulk appends.

### Static HashMap — Compile-Time Sized (Bun)

```zig
pub fn StaticHashMap(comptime K: type, comptime V: type, comptime capacity: usize) type {
    const shift = 63 - math.log2_int(u64, capacity) + 1;
    const overflow = capacity / 10 + (63 - @as(u64, shift) + 1) << 1;
    return struct {
        entries: [capacity + overflow]Entry = [_]Entry{.{}} ** (capacity + overflow),
        len: usize = 0,
    };
}

Power-of-two sizing with bit masking. Overflow area for probe chains. Zero allocations; lives on stack or in data section. `maxInt(u64)` as empty sentinel.

---

## Concurrency

### Blocking Queue for Message Passing (Ghostty)

```zig
pub fn BlockingQueue(comptime T: type, comptime capacity: usize) type {
    return struct {
        data: [capacity]T = undefined,
        write: u32 = 0,
        read: u32 = 0,
        mutex: std.Thread.Mutex = .{},
        cond_not_full: std.Thread.Condition = .{},

        pub fn push(self: *Self, value: T, timeout: Timeout) u32 {
            self.mutex.lock();
            defer self.mutex.unlock();
            if (self.full()) {
                switch (timeout) {
                    .instant => return 0,
                    .forever => self.cond_not_full.wait(&self.mutex),
                    .ns => |ns| self.cond_not_full.timedWait(&self.mutex, ns) catch return 0,
                }
            }
            // ... enqueue
        }
    };
}

Fixed capacity prevents unbounded memory growth. Timeout variants: instant (try), timed, forever.

### Work-Stealing Thread Pool (Bun)

```zig
const Sync = packed struct(u32) {
    idle: u14 = 0,
    spawned: u14 = 0,
    unused: bool = false,
    notified: bool = false,
    state: enum(u2) { pending, signaled, waking, shutdown } = .pending,
};

sync: std.atomic.Value(u32) = .init(@as(u32, @bitCast(Sync{}))),

Entire sync state fits in one `u32` — CAS updates are all-or-nothing. State machine prevents thundering herd (only one "waking thread" at a time). O(1) task dequeue via work stealing.

### Platform-Specific Mutex with Debug Tracking (Bun)

```zig
const Impl = if (builtin.mode == .Debug and !builtin.single_threaded)
    DebugImpl
else
    ReleaseImpl;

pub const ReleaseImpl = if (builtin.os.tag == .windows) WindowsImpl
    else if (builtin.os.tag.isDarwin()) DarwinImpl
    else FutexImpl;

const DebugImpl = struct {
    locking_thread: std.atomic.Value(Thread.Id) = .init(0),
    impl: ReleaseImpl = .{},
    // panics on double-lock from same thread
};

Zero overhead in Release. Debug catches deadlocks from double-locking.

---

## SIMD & Vectorization

### Comptime SIMD with Scalar Fallback (Ghostty)

```zig
pub fn decode(input: []const u8, output: []u8) error{Invalid}![]const u8 {
    if (comptime options.simd)
        return simd_decode(input, output);
    return scalar_decode(input, output);
}

// C-implemented SIMD backend
extern "c" fn ghostty_simd_base64_decode([*]const u8, usize, [*]u8) isize;

Build option `simd` (false for wasm, true for native). Single entry point; C side provides SSE4/AVX2 optimizations. Always include scalar fallback for testing and unsupported targets.

### @Vector for Parallel Aggregation (Bun)

```zig
const Vector = @Vector(char_freq_count, i32);

pub fn include(this: *CharFreq, other: CharFreq) void {
    const left: Vector = this.freqs;
    const right: Vector = other.freqs;
    this.freqs = left + right;  // compiles to SIMD add
}

pub fn scan(this: *CharFreq, text: string, delta: i32) void {
    if (text.len < scan_big_chunk_size) scanSmall(&this.freqs, text, delta)
    else scanBig(&this.freqs, text, delta);  // manual unroll, 32 bytes/iter
}

`@Vector` addition compiles to hardware SIMD when available. Dispatch on input size to avoid SIMD overhead on small inputs.

### Cache-Line Aligned Tournament Tree (TigerBeetle)

```zig
pub fn TournamentTreeType(comptime Key: type, comptime contestants_max: comptime_int) type {
    return struct {
        loser_keys: [node_count_max]Key align(64),   // SoA, cache-line aligned
        loser_ids: [node_count_max]u32 align(64),     // separate array
        win_key: Key,
        win_id: u32,
    };
}

SoA layout prevents false sharing. Each array independently aligned for streaming access. Tournament merge with minimal branches.

### Histogram-Based Radix Sort (TigerBeetle)

```zig
// Build all histograms in one pass
var histograms: Histograms align(64) = @splat(@splat(0));
for (values) |*value| {
    const key = key_from_value(value);
    inline for (0..radix_passes) |pass| {
        const partition_id = (key >> (pass * radix_bits)) & radix_mask;
        histograms[pass][partition_id] += 1;
    }
}
// Skip trivial passes (all items in one bucket)
inline for (0..radix_passes) |pass| {
    const trivial = for (histograms[pass]) |c| { if (c == count) break true; } else false;
    if (!trivial) { /* partition */ }
}

Single histogram pass amortizes cache misses. Skips passes where all items land in one bucket.

---

## Error Handling

### Explicit Error Sets per Method (Ghostty)

```zig
pub const Pty = switch (builtin.os.tag) {
    .windows => WindowsPty,
    .ios => NullPty,
    else => PosixPty,
};

const PosixPty = struct {
    pub const OpenError = error{OpenptyFailed};
    pub const GetModeError = error{GetModeFailed};
    pub const Error = OpenError || GetModeError || SetSizeError;

    pub fn open(size: winsize) OpenError!Pty { ... }
    pub fn getMode(self: Pty) GetModeError!Mode { ... }
};

Each method declares its own error set. Module `Error` is the union. Callers see exactly what can fail.

### Result Union with Error Payloads (Bun)

```zig
pub fn Result(comptime T: type, comptime E: type) type {
    return union(enum) {
        ok: T,
        err: E,
        pub inline fn asErr(this: *const @This()) ?E {
            if (this.* == .err) return this.err;
            return null;
        }
    };
}

Unlike Zig error sets, attaches arbitrary context. Inline unwrapping. Compiler enforces exhaustive matching.

### Comptime Layout Invariants (TigerBeetle)

```zig
const TransferPending = extern struct {
    timestamp: u64,
    status: TransferPendingStatus,
    padding: [7]u8 = @splat(0),

    comptime {
        assert(@sizeOf(TransferPending) == 16);
        assert(stdx.no_padding(TransferPending));
    }
};

Catches struct layout bugs at compile time. Ensures deterministic serialization (no implicit padding). Essential for wire protocols and disk formats.

---

## Platform Abstraction

### OS-Specific Type Selection (Ghostty)

```zig
pub const Pty = switch (builtin.os.tag) {
    .windows => WindowsPty,
    .ios => NullPty,
    else => PosixPty,
};

Single type at module level. Callers don't care which impl they get. Platform code isolated.

### Module Facade with Conditional Exports (Ghostty)

```zig
// os/main.zig — platform-agnostic facade
pub const getenv = env.getenv;
pub const setenv = env.setenv;
pub const TempDir = @import("TempDir.zig");

test {
    if (comptime builtin.os.tag == .linux) _ = kernel_info;
    if (comptime builtin.os.tag.isDarwin()) _ = macos;
}

Consumer: `const os = @import("os");` then `os.getenv(...)`. Submodules hidden. Platform-specific tests compiled only for their target OS.

### macOS Objective-C Bridge (Ghostty)

```zig
const objc = @import("objc");

pub fn isAtLeastVersion(major: i64, minor: i64, patch: i64) bool {
    const info = objc.getClass("NSProcessInfo").?.msgSend(
        objc.Object, objc.sel("processInfo"), .{},
    );
    return info.msgSend(bool, objc.sel("isOperatingSystemAtLeastVersion:"), .{
        NSOperatingSystemVersion{ .major = major, .minor = minor, .patch = patch },
    });
}

Zig handles memory/ownership, ObjC message sends for macOS APIs. Error sets combine allocator + domain errors.

---

## C Interop

### Opaque Type Wrapper with RAII (Ghostty)

```zig
pub const IOSurface = opaque {
    pub fn init(properties: Properties) Allocator.Error!*IOSurface {
        var dict = try foundation.Dictionary.create(...);
        defer dict.release();
        return @ptrFromInt(@intFromPtr(c.IOSurfaceCreate(@ptrCast(dict))))
            orelse return error.OutOfMemory;
    }

    pub fn deinit(self: *IOSurface) void {
        _ = c.IOSurfaceSetPurgeable(@ptrCast(self), c.kIOSurfacePurgeableEmpty, null);
        foundation.CFRelease(self);
    }
};

Opaque wraps C types. Safe ownership: `init/deinit` pair, RAII via defer. Type conversions only at boundary.

### Packed Struct for C Bitfields (Ghostty)

```zig
pub const MTLResourceOptions = packed struct(c_ulong) {
    cpu_cache_mode: CPUCacheMode = .default,
    storage_mode: StorageMode,
    hazard_tracking_mode: HazardTrackingMode = .default,
    _pad: @Type(.{ .int = .{ .signedness = .unsigned, .bits = @bitSizeOf(c_ulong) - 10 } }) = 0,

    pub const StorageMode = enum(u4) { shared = 0, managed = 1, private = 2, memoryless = 3 };
};

Packed struct with nested enums matches C layout exactly. Compiler handles bit packing. No manual shifts.

---

## Comptime Patterns

### Conditional Callback via @hasDecl (Ghostty)

```zig
pub fn put(self: *Self, key: K, value: V) ?KV {
    // ... evict logic ...
    if (comptime @hasDecl(Context, "evicted"))
        self.context.evicted(evicted.key, evicted.value);
    return evicted;
}

Optional interface methods without stubs. Callback only compiled in if present.

### Module-Level Comptime Assertions (TigerBeetle)

```zig
comptime {
    assert(std.math.isPowerOfTwo(bucket_count));
    assert(constants.message_size_max % constants.sector_size == 0);
}

Validate generic parameters and alignment requirements at compile time. No runtime cost.

### EnumUnionType — Generate Union from Enum (TigerBeetle)

```zig
pub fn EnumUnionType(
    comptime Enum: type,
    comptime TypeForVariant: fn (comptime variant: Enum) type,
) type {
    var fields: [std.enums.values(Enum).len]std.builtin.Type.UnionField = undefined;
    for (std.enums.values(Enum), 0..) |variant, i| {
        fields[i] = .{
            .name = @tagName(variant),
            .type = TypeForVariant(variant),
            .alignment = @alignOf(TypeForVariant(variant)),
        };
    }
    return @Type(.{ .@"union" = .{ .layout = .auto, .fields = &fields, .decls = &.{}, .tag_type = Enum } });
}

Generates variant-specific message types. Eliminates boilerplate union definitions. Used for protocol dispatch.

### Length-Indexed Comptime String Map (Bun)

```zig
const precomputed = comptime blk: {
    @setEvalBranchQuota(99999);
    var sorted: [kvs.len]KV = undefined;
    // sort by length, then alphabetically
    std.sort.pdq(KV, &sorted, {}, lenAsc);

    var len_indexes: [max_len + 1]usize = undefined;
    // ... build index: length -> start position
    break :blk .{ .sorted = sorted, .len_indexes = len_indexes, .min_len = min_len, .max_len = max_len };
};

pub fn get(key: []const u8) ?V {
    if (key.len < precomputed.min_len or key.len > precomputed.max_len) return null;
    const start = precomputed.len_indexes[key.len];
    for (precomputed.sorted[start..]) |kv| {
        if (kv.key.len != key.len) break;
        if (std.mem.eql(u8, kv.key, key)) return kv.value;
    }
    return null;
}

O(1) length check eliminates most misses. Binary search only among same-length keys. Entire map computed at compile time. Used for keyword tables, HTTP headers.

### Comptime Type Specialization (Bun)

```zig
pub fn NewLexer(comptime json_options: JSONOptions) type {
    return struct {
        const is_json = json_options.is_json;
        const JSONBool = if (is_json) bool else void;

        // if (is_json) branches eliminated at compile time
        // JSON lexer and JS lexer compiled as separate code
    };
}

Zero-cost branch elimination. Each specialization is a distinct type with no runtime dispatch.

### Comptime Type Validation (Bun)

```zig
pub fn banFieldType(comptime Container: type, comptime T: type) void {
    comptime {
        for (std.meta.fields(Container)) |field| {
            if (field.type == T)
                @compileError("Field of type " ++ @typeName(T) ++ " not allowed");
        }
    }
}

Enforce struct invariants at compile time (e.g. ban raw pointers in AST nodes).

---

## String Optimization

### Small String Optimization (Bun)

```zig
pub const SmolStr = packed struct(u128) {
    __len: u32,
    cap: u32,
    __ptr: [*]u8,

    pub const Inlined = packed struct(u128) {
        data: u120,   // 15 bytes inline
        __len: u7,
        _tag: u1,     // 1 = inlined
        const max_len: comptime_int = 15;
    };

    pub fn isInlined(this: *const SmolStr) bool {
        return @intFromPtr(this.__ptr) & 0x8000000000000000 != 0;
    }
};

15-byte inline storage for short strings (URLs, identifiers, method names). Tagged pointer: high bit = inline flag. Same 16-byte footprint whether inlined or heap-allocated.

---

## Testing

### Snapshot Testing (TigerBeetle)

```zig
test "prng distribution" {
    var prng = from_seed(92);
    var distribution: [8]u32 = @splat(0);
    for (0..1000) |_| distribution[prng.next() % 8] += 1;

    try snap(@src(),
        \\{ 134, 134, 117, 121, 117, 128, 131, 118 }
    ).diff_fmt("{d}", .{distribution});
}

Detect regressions in deterministic outputs. `snap` captures expected, `diff_fmt` shows diffs on failure.

### Edge-Biased Fuzz Generation (TigerBeetle)

```zig
pub fn int_edge_biased(prng: *PRNG, T: anytype) T {
    const bits = @typeInfo(T).int.bits;
    const bias_to = prng.range_inclusive(T, 0, bits * 2);
    if (bias_to > bits) return prng.int(T);  // ~50% uniform
    // ~50% biased toward power-of-2 boundaries +/- 8
    const center: T = if (bias_to == bits) std.math.maxInt(T)
        else std.math.pow(T, 2, bias_to);
    return prng.range_inclusive(T, center -| 8, center +| 8);
}

50/50 split: uniform vs edge-case biased. Targets min/max/power-of-2 boundaries. Finds overflow and boundary condition bugs.

### VOPR — Verification of Protocols via Randomized Testing (TigerBeetle)

```zig
pub fn main(allocator: Allocator, args: FuzzArgs) !void {
    var prng = stdx.PRNG.from_seed(args.seed);
    for (0..args.events_max orelse 50_000) |_| {
        const operation = prng.enum_uniform(StateMachine.Operation);
        const size = build_batch(&prng, operation, request_buffer);
        if (state_machine.input_valid(operation, request_buffer[0..size])) {
            context.prepare(operation, request_buffer[0..size]);
            _ = context.execute(op, operation, request_buffer[0..size], reply_buffer);
        }
    }
}

Fuzzes state machines with random operations and batch configurations. Seeded for reproducible failures. Varies batch counts and sizes.

### Conditional Test Compilation (Ghostty)

```zig
test {
    _ = i18n;
    _ = path;
    if (comptime builtin.os.tag == .linux) _ = kernel_info;
    if (comptime builtin.os.tag.isDarwin()) _ = macos;
}

Module-level test references all submodules. Platform-specific tests only compile for their target.

---

## Performance

### Inline Custom Assert (Ghostty)

```zig
pub const inlineAssert = switch (builtin.mode) {
    .Debug => std.debug.assert,
    .ReleaseSmall, .ReleaseSafe, .ReleaseFast => (struct {
        inline fn assert(ok: bool) void { if (!ok) unreachable; }
    }).assert,
};

Stdlib `assert` sometimes doesn't optimize out in ReleaseFast. Custom inline version with `unreachable` helps the compiler. Saves 15-20% in tight loops.

### Thread-Local Object Pool (Bun)

```zig
const HashMapPool = struct {
    threadlocal var list: LinkedList = undefined;
    threadlocal var loaded: bool = false;

    pub fn get(_: Allocator) *LinkedList.Node {
        if (loaded) {
            if (list.popFirst()) |node| {
                node.data.clearRetainingCapacity();
                return node;
            }
        }
        return default_allocator.create(LinkedList.Node) catch unreachable;
    }

    pub fn release(node: *LinkedList.Node) void {
        if (loaded) { list.prepend(node); return; }
        list = LinkedList{ .first = node };
        loaded = true;
    }
};

Per-thread reuse without contention. `clearRetainingCapacity()` resets without deallocating. Lazy init via `loaded` flag.

### Seeded PRNG without Floating Point (TigerBeetle)

```zig
// Custom PRNG avoids:
// - floating point (non-deterministic across platforms)
// - stdlib API churn
// - Lemire's algorithm for unbiased bounded integers

pub fn int_inclusive(prng: *PRNG, Int: anytype, max: Int) Int {
    var x = prng.int(Int);
    var m = math.mulWide(Int, x, less_than);
    var l: Int = @truncate(m);
    if (l < less_than) {
        var t = -%less_than;  // rejection sampling threshold
        while (l < t) { x = prng.int(Int); m = math.mulWide(Int, x, less_than); l = @truncate(m); }
    }
    return @intCast(m >> bits);
}

No floating point ensures cross-platform determinism. Lemire's algorithm: unbiased without modulo.

### Labeled Union State Machine (TigerBeetle)

```zig
pub const CommitStage = union(enum) {
    idle,
    start,
    prefetch,
    execute,
    checkpoint_data: CheckpointDataProgress,
    checkpoint_superblock,

    const CheckpointDataProgress = std.enums.EnumSet(CheckpointData);
};

Exhaustive pattern matching prevents invalid transitions. Nested enum sets for parallel subtask tracking.
# Quality Tooling for Zig

Coverage, dead code, duplication, linting and fuzzing. Zig ships none of these,
and the usual third-party answers each have a trap that silently produces a
green result. Everything below was verified against Zig `0.17.0-dev.1158` on
macOS (aarch64) and cross-checked on Linux targets.

## Quick Reference

| Want | Tool | The trap |
|------|------|----------|
| Line coverage | `kcov` on the test binary | tests share the file with the code, so they inflate the ratio |
| Unused constants | `zlint` (`unused-decls`, on by default) | the Homebrew `zlint` is a *certificate* linter |
| Unused **functions** | nothing — roll your own | compiler is lazy, `unused-decls` skips functions |
| Duplicate code | `jscpd --format c --formats-exts "c:zig"` | `--max-lines 1000` silently skips bigger files |
| Fuzzing | `std.testing.fuzz` + `zig build test --fuzz` | `testOne` takes `*Smith`, not `[]const u8` |

## The denominator problem (affects coverage *and* lint)

Zig unit tests normally live in the same file as the code they exercise —
that is the only way to reach private declarations. So "exclude the tests"
cannot be a file filter; it has to be a line range.

Measured on a real library: **99.7% over 1325 lines** with tests counted,
**99.5% over 382** without. The denominator differed by 3.5×, so the flattering
number was mostly tests covering themselves.

Convention that works: a banner line (`// --- tests ---`) marks where
scaffolding starts; post-process the report and drop anything at or below it.

## Coverage: kcov

Works on Zig binaries with no instrumentation, on macOS as well as Linux.

```bash
zig test src/lib.zig -lc -femit-bin=.cov/testbin --test-no-exec
kcov --include-pattern=src/ .cov/report .cov/testbin

Read `.cov/report/<binary>.<hash>/codecov.json` for **per-line** data — the
`coverage.json` sibling only has file-level summaries. Values are strings of
the form `"taken/total"` over a line's sub-conditions, so a line executed at
all iff the numerator is non-zero:

```python
taken = int(value.split("/", 1)[0])   # "0/4" -> never ran; "1/2" -> ran, one branch

Prefer this over the cobertura `cov.xml`: same data, no XML parser, no XXE
surface.

**What will never be covered** without syscall failure injection: `errdefer`
bodies (they need the constructor to fail after acquiring the resource) and
`EINTR` retry branches. Accept them or mock the syscall; do not contort the
code.

## Dead code: nothing finds unused functions

Three layers all miss it:

1. **The compiler.** Zig analyses lazily — an unreferenced private declaration
   is never analysed, so it compiles fine and warns about nothing.
2. **`zlint`'s `unused-decls`.** Enabled by default, but it covers constants
   and variables only. Verified by planting one of each: the `const` was
   reported, the `fn` was not, and `zig build test` stayed green.
3. **`pub`** is API surface, so it is correctly never reported.

Why not just fix zlint? Resolving `handler.onRecord(rec)` where
`handler: anytype` requires knowing the receiver's type, i.e. monomorphisation
— reimplementing a large part of the compiler. Same for `@field(T, name)`,
`std.meta.declarations` and `refAllDecls`, which reference by computed name.

### Technique 1 — rename probe (exact, N builds)

Rename each private definition and rebuild. If every call site still resolves,
nothing referenced it.

```python
line = line.replace(f"fn {name}(", f"fn {name}__probe(", 1)
# write, run `zig build test`, restore in a finally

Exact. Cost is one build per function (~14s for 24 functions with a warm
cache). Blind spot: a *recursive* dead function looks used, because renaming
breaks its own recursive call.

### Technique 2 — syntactic prefilter (instant, misses some)

A private function whose identifier occurs exactly once in the file — at its
own definition — is dead.

```python
len(re.findall(r"\b" + re.escape(name) + r"\b", source)) <= 1

**Errs only by missing.** A call spells the name out, so `x.foo()` counts as a
reference whether or not the receiver's type is known — `anytype` and generics
cannot make it accuse a live function. It does miss a dead `end` or `add` when
a live method shares that name. 0.2s vs 14s; use it as a prefilter (skip the
build for anything it already proves dead) and as a pre-commit hook.

### Technique 3 — symbol table (one build, unreliable)

Since unreferenced decls are never analysed, they emit no symbol:

```bash
zig test src/lib.zig -lc -femit-bin=tb --test-no-exec
llvm-nm tb | grep '_mymodule\.'      # symbols are _<module>.<container>.<fn>

Measured false-positive rate: **4 of 22** private functions had no symbol
despite being live (small ones get inlined even in Debug). Fine as a hint,
wrong as a gate.

Linker GC (`-ffunction-sections` + `--gc-sections`, `-dead_strip` on Darwin)
has the same inlining problem.

## Duplicate code: jscpd

No Zig tokenizer exists, but the C one is close enough:

```bash
jscpd src --format c --formats-exts "c:zig" --min-lines 5 --min-tokens 40 \
      --max-lines 100000

**`--max-lines` defaults to 1000 and skips longer files without saying so.**
A first run reported "0 clones" having silently analysed only the one small
file in the project. Always pass it, and sanity-check "Files analyzed" against
the real count.

## Linting: zlint

⚠️ **Name collision.** The Homebrew `zlint` is [zmap/zlint](https://github.com/zmap/zlint),
an X.509 certificate linter. It accepts `.zig` paths and reports nothing
useful. The Zig one is [DonIsaac/zlint](https://github.com/DonIsaac/zlint) —
install the release binary; it is not in Homebrew.

```bash
zlint                    # default rule set
zlint -f json            # one JSON object per finding, concatenated (no commas)
zlint --deny-warnings    # warnings become a non-zero exit
zlint --print-ast f.zig  # it uses std.zig.Ast, so tree-sitter adds nothing

Parsing JSON output needs `raw_decode` in a loop — the objects are
concatenated, not an array.

**Config replaces the rule set, it does not extend it.** A `zlint.json`
listing one rule silently switches every other rule off. Verified: 14 warnings
became 0. Prefer no config unless you list everything you want.

Silencing:
- `unsafe-undefined` — accepts a `// SAFETY: <reason>` comment on the line
  above, or wants the `undefined` moved out of a struct-field default.
- `suppressed-errors` (`catch {}`) — a comment does **not** silence it.
  Handle the error or accept the warning.

## Fuzzing: the built-in fuzzer

### Signature changed — `*Smith`, not `[]const u8`

```zig
// 0.17.0-dev: testOne receives a structured value generator
test "fuzz parsePacket" {
    try std.testing.fuzz({}, fuzzOne, .{});
}

fn fuzzOne(_: void, smith: *std.testing.Smith) !void {
    var buf: [2048]u8 = undefined;
    const n = smith.slice(&buf);          // returns the length written
    _ = parsePacket(buf[0..n], &handler);
}

`Smith` generates values, not raw bytes: `smith.value(T)`,
`smith.valueRangeAtMost(T, lo, hi)`, `smith.slice(buf)`,
`smith.eosWeightedSimple(a, b)`. `FuzzInputOptions` is `.{ .corpus = &.{...} }`.

**A doc comment cannot be attached to a `test`** — `///` above it is a compile
error. Use `//`.

### Running it

```bash
zig build test --fuzz=200000   # bounded, prints a report
zig build test --fuzz          # unbounded + web UI showing covered lines

A plain `zig build test` runs the fuzz test once with a trivial input, so it
costs nothing in the normal suite.

### The corpus is the asset — and it compounds

Coverage guidance only pays off through the persisted corpus in `.zig-cache/f/`.
Demonstrated by asserting "no generated input ever parses a record" and seeing
whether the fuzzer could break it:

| corpus | runs | broke the assertion? |
|--------|------|----------------------|
| empty | 400,764 | **no** |
| accumulated (1,152 unique inputs) | **5** | yes |

From scratch it is no better than blind random mutation. Which also means:

**Coverage plateaus if the harness feeds raw bytes.** Over 30M total runs,
coverage stalled at 75 edges after the first ~600k; a further 10M runs added
22 unique inputs and zero new coverage. Structure the harness (build the
header and records *from* Smith values) or seed `.corpus` with valid inputs —
running longer does not help.

### Two fuzzers, one corpus

thread N panic: corpus of '<test name>' is in use by another fuzzer

Concurrent runs abort, and the abort leaves a `.zig-cache/f/crash` artifact
that is **not** a real finding. Check the panic message before treating a
`crash` file as a bug.

## Hand-rolled fuzzing still earns its place

Blind mutation of a *valid seed input* reaches deep paths immediately, because
the structure is supplied by hand. On a DNS parser: 200k fully random buffers
parsed **0** records; 200k mutations of a valid packet parsed 415,869. It is
deterministic (fixed PRNG seed) so it works as a regression test, where the
coverage-guided fuzzer explores. Keep both.
