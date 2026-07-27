# std.Io — Writergate and the New I/O API (0.15 / 0.16)

The I/O API was completely rewritten in 0.15 ("Writergate") and the old `std.io` namespace was removed in 0.16. All I/O now goes through `std.Io` (capital I).

---

## Writergate (0.15)

[Previous Scandal](https://ziglang.org/download/0.9.0/release-notes.html#Allocgate)

All existing std.io readers and writers are deprecated in favor of the newly provided `std.Io.Reader` and `std.Io.Writer` which are *non-generic* and have the buffer above the vtable - in other words the buffer is **in the interface, not the implementation**. This means that although Reader and Writer are no longer generic, they are still transparent to optimization; all of the interface functions have a concrete hot path operating on the buffer, and only make vtable calls when the buffer is full.

These changes are extremely breaking. I am sorry for that, but I have carefully examined the situation and acquired confidence that this is the direction that Zig needs to go. I hope you will strap in your seatbelt and come along for the ride; it will be worth it.

### Motivation

-   The old interface was generic, poisoning structs that contain them and forcing all functions to be generic as well with `anytype`. The new interface is concrete.
    -   Bonus: the concreteness removes temptation to make APIs operate directly on networking streams, file handles, or memory buffers, giving us a more reusable body of code. For example, `http.Server` after the change no longer depends on `std.net` - it operates only on streams now.
-   The old interface passed errors through rather than defining its own set of error codes. This made errors in streams about as useful as `anyerror`. The new interface carefully defines precise error sets for each function with actionable meaning.
-   The new interface has the buffer in the interface, rather than as a separate "BufferedReader" / "BufferedWriter" abstraction. This is more optimizer friendly, particularly for debug mode.
-   The new interface supports high level concepts such as vectors, splatting, and direct file-to-file transfer, which can propagate through an entire graph of readers and writers, reducing syscall overhead, memory bandwidth, and CPU usage.
-   The new interface has "peek" functionality - a buffer awareness that offers API convenience for the user as well as simplicity for the implementation.

### New std.Io.Writer and std.Io.Reader API

These **ring buffers** have a bunch of handy new APIs that are more convenient, perform better, and are not generic. For instance look at how reading until a delimiter works now:

```zig
while (reader.takeDelimiterExclusive('\n')) |line| {
    // do something with line...
} else |err| switch (err) {
    error.EndOfStream, // stream ended not on a line break
    error.StreamTooLong, // line could not fit in buffer
    error.ReadFailed, // caller can check reader implementation for diagnostics
    => |e| return e,
}
```

These streams also feature some unique concepts compared with other languages' stream implementations:

-   The concept of **discarding** when reading: allows efficiently ignoring data. For instance a decompression stream, when asked to discard a large amount of data, can skip decompression of entire frames.
-   The concept of **splatting** when writing: this allows a logical "memset" operation to pass through I/O pipelines without actually doing any memory copying, turning an O(M\*N) operation into O(M) operation, where M is the number of streams in the pipeline and N is the number of repeated bytes. In some cases it can be even more efficient, such as when splatting a zero value that ends up being written to a file; this can be lowered as a seek forward.
-   Sending a file when writing: this allows an I/O pipeline to do direct fd-to-fd copying when the operating system supports it.
-   The stream user provides the buffer, but the stream implementation decides the minimum buffer size. This effectively moves state from the stream implementation into the user's buffer

### std.Io.File.Reader and std.Io.File.Writer

`std.Io.File.Reader` memoizes key information about a file handle such as:

-   The size from calling stat, or the error that occurred therein.
-   The current seek position.
-   The error that occurred when trying to seek.
-   Whether reading should be done positionally or streaming.
-   Whether reading should be done via fd-to-fd syscalls (e.g. `sendfile`)
    versus plain variants (e.g. `read`).

Fulfills the `std.Io.Reader` interface.

This API turned out to be super handy in practice. Having a concrete type to pass around that memoizes file size is really nice. Most code that previously was calling seek functions on a file handle should be updated to operate on this API instead, causing those seeks to become no-ops thanks to positional reads, while still supporting a fallback to streaming reading.

`std.Io.File.Writer` is the same idea but for writing.

### CountingWriter Deleted

-   If you were discarding the bytes, use `std.Io.Writer.Discarding`, which has a count.
-   If you were allocating the bytes, use `std.Io.Writer.Allocating`, since you can check how much was allocated.
-   If you were writing to a fixed buffer, use `std.Io.Writer.fixed`, and then check the `end` position.
-   Otherwise, try not to create an entire node in the stream graph solely for counting bytes. It's very disruptive to optimal buffering.

### BufferedWriter Deleted

```zig
// BEFORE
const stdout_file = std.Io.File.stdout().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

try stdout.print("Run `zig build test` to run the tests.\n", .{});

try bw.flush(); // Don't forget to flush!

// AFTER
var stdout_buffer: [4096]u8 = undefined;
var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
const stdout = &stdout_writer.interface;

try stdout.print("Run `zig build test` to run the tests.\n", .{});

try stdout.flush(); // Don't forget to flush!
```

Consider making your stdout buffer global.

### Adapter API (0.15 only — removed in 0.16)

If you have an old stream and you need a new one, you can use `adaptToNewApi()` like this:

```zig
fn foo(old_writer: anytype) !void {
    var adapter = old_writer.adaptToNewApi(&.{});
    const w: *std.Io.Writer = &adapter.new_interface;
    try w.print("{s}", .{"example"});
    // ...
}
```

**Note:** `adaptToNewApi` was removed in 0.16. It only existed as a migration bridge.

---

## std.Io (0.16)

In Zig 0.16, the `std.io` namespace (lowercase) is completely removed. `std.Io` (capital) is the I/O module.

### Upgrading std.io.getStdOut().writer().print()

Please use buffering! And **don't forget to flush**!

```zig
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buffer);
const stdout = &stdout_writer.interface;

// ...

try stdout.print("...", .{});

// ...

try stdout.flush();
```

### fixedBufferStream Removed

```zig
// WRONG (0.16) — std.io.fixedBufferStream removed
var buf: [512]u8 = undefined;
var stream = std.io.fixedBufferStream(&buf);
try std.fmt.format(stream.writer(), "{d}", .{value});
const result = stream.getWritten();

// CORRECT — use std.Io.Writer.fixed or std.fmt.bufPrint
var buf: [512]u8 = undefined;
var w: std.Io.Writer = .fixed(&buf);
try w.print("{d}", .{value});
const result = w.buffered();

// OR for simple formatting:
var buf: [512]u8 = undefined;
const result = try std.fmt.bufPrint(&buf, "{d}", .{value});
```

### Vtable Writer Parameter

```zig
// WRONG — *std.io.Writer (lowercase, removed)
fn drain(w: *std.io.Writer) error{WriteFailed}!usize { ... }

// CORRECT — *std.Io.Writer (capital)
fn drain(w: *std.Io.Writer) error{WriteFailed}!usize { ... }
```

---

## std.Io.Writer Reference

### Structure

```zig
const Writer = struct {
    vtable: *const VTable,
    buffer: []u8,      // Write buffer (can be zero-length for unbuffered)
    end: usize = 0,    // Bytes buffered (0..buffer.len)
};
```

### Factory Methods

```zig
// Fixed buffer writer (error when full)
var buf: [256]u8 = undefined;
var w: std.Io.Writer = .fixed(&buf);

// Discarding writer (discards output, tracks count)
var buffer: [256]u8 = undefined;
var discard: std.Io.Writer.Discarding = .init(&buffer);

// Allocating writer (auto-growing)
var aw: std.Io.Writer.Allocating = .init(allocator);
defer aw.deinit();
```

### Core Methods

#### Writing Data
```zig
// Write all bytes (may call drain multiple times)
try w.writeAll("hello");

// Write single byte
try w.writeByte('\n');

// Write with potential short write (returns bytes written)
const n = try w.write(data);

// Write vector of slices
var vecs: [2][]const u8 = .{ "hello", "world" };
try w.writeVecAll(&vecs);

// Write same byte N times
try w.splatByteAll(' ', 10);

// Write same slice N times
try w.splatBytesAll("na", 8);  // "nananananananana"
```

#### Formatted Output
```zig
// Format string (same syntax as before)
try w.print("Value: {d}, Name: {s}\n", .{ 42, "test" });

// Format specifiers:
// {d}  - decimal integer
// {x}  - hex lowercase
// {X}  - hex uppercase
// {s}  - string
// {c}  - ASCII character
// {b}  - binary
// {o}  - octal
// {e}  - scientific notation
// {f}  - call .format() method on type  // NEW in 0.15.x
// {any} - debug format
// {?}  - optional
// {!}  - error union
// {*}  - pointer address
```

#### Binary Data
```zig
// Write integer with endianness
try w.writeInt(u32, value, .big);
try w.writeInt(i16, value, .little);

// Write struct (extern or packed only)
const Header = extern struct { magic: u32, version: u16 };
try w.writeStruct(header, .little);

// Write slice with endianness
try w.writeSliceEndian(u32, values, .big);
```

#### Buffer Management
```zig
// Flush buffer to underlying sink
try w.flush();

// Get buffered data not yet flushed
const pending = w.buffered();

// Get writable slice for direct writes
const dest = try w.writableSlice(len);
@memcpy(dest, src);

// Advance after writing to writableSliceGreedy
const dest = try w.writableSliceGreedy(min_len);
// ... write to dest ...
w.advance(bytes_written);

// Get unused capacity
const remaining = w.unusedCapacitySlice();
```

---

## std.Io.Reader Reference

### Structure

```zig
const Reader = struct {
    vtable: *const VTable,
    buffer: []u8,       // Read buffer
    seek: usize,        // Consumed position
    end: usize,         // Buffered data end
};
```

### Factory Methods

```zig
// Fixed buffer reader (read from existing data)
var r: std.Io.Reader = .fixed("hello world");

// From file
var buf: [4096]u8 = undefined;
var reader = file.reader(io, &buf);
const r = &reader.interface;

// Limited reader (cap bytes readable)
var limited_buf: [256]u8 = undefined;
var limited = r.limited(.limited(1024), &limited_buf);
```

### Core Methods

#### Reading Bytes
```zig
// Read single byte
const byte = try r.takeByte();
const signed = try r.takeByteSigned();

// Peek without consuming
const byte = try r.peekByte();

// Read exact amount
const data = try r.take(n);      // Returns slice
const arr = try r.takeArray(n);  // Returns *[n]u8

// Read into provided buffer
try r.readSliceAll(buffer);

// Read up to buffer.len (short read OK)
const n = try r.readSliceShort(buffer);
```

#### Line/Delimiter Reading
```zig
// Read until delimiter (RECOMMENDED for line reading)
// - Consumes delimiter, returns content without it
// - Returns null at EOF (no EndOfStream error)
while (try r.takeDelimiter('\n')) |line| {
    // process line (doesn't include '\n')
}
// Loop ends when takeDelimiter returns null (EOF)

// Read until delimiter, exclude delimiter (doesn't consume delimiter!)
const line = try r.takeDelimiterExclusive('\n');
// If delimiter not found: error.EndOfStream at EOF, error.StreamTooLong if buffer full

// Read until delimiter, include delimiter (doesn't consume!)
const line_with_delim = try r.takeDelimiterInclusive('\n');

// Read null-terminated string (consumes null)
const str = try r.takeSentinel(0);

// Discard until delimiter (inclusive consumes delimiter)
try r.discardDelimiterInclusive('\n');
const n = try r.discardDelimiterExclusive('\n');  // doesn't consume delimiter
```

#### Binary Data
```zig
// Read integer with endianness
const val = try r.takeInt(u32, .big);
const val = try r.takeInt(i16, .little);

// Read variable-size integer
const val = try r.takeVarInt(u64, .big, byte_count);

// Read struct (extern or packed only)
const header = try r.takeStruct(Header, .little);

// Read enum
const e = try r.takeEnum(MyEnum, .little);

// Read LEB128 encoded integer
const val = try r.takeLeb128(i64);
```

#### Streaming
```zig
// Stream to writer
const n = try r.stream(writer, .limited(1024));
const n = try r.stream(writer, .unlimited);

// Stream exact amount
try r.streamExact(writer, exact_bytes);

// Stream until delimiter
const n = try r.streamDelimiter(writer, '\n');

// Stream remaining (until EOF)
const total = try r.streamRemaining(writer);
```

#### Buffer Management
```zig
// Get buffered data
const pending = r.buffered();
const len = r.bufferedLen();

// Fill buffer with at least n bytes
try r.fill(n);

// Consume buffered bytes without reading
r.toss(n);
r.tossBuffered();  // Consume all buffered

// Discard bytes (may read more)
try r.discardAll(n);
const n = try r.discardShort(max);
const total = try r.discardRemaining();
```

#### Allocation
```zig
// Read remaining into allocated slice
const data = try r.allocRemaining(allocator, .limited(max_size));
defer allocator.free(data);

// Append remaining to ArrayList
var list: std.ArrayList(u8) = .empty;
try r.appendRemaining(allocator, &list, .limited(max_size));
```

---

## File I/O Integration

### Reading Files

```zig
const file = try std.Io.Dir.cwd().openFile(io, "data.txt", .{});
defer file.close();

var buf: [4096]u8 = undefined;
var reader = file.reader(io, &buf);
const r = &reader.interface;

// Read lines (takeDelimiter returns null at EOF, no error)
while (try r.takeDelimiter('\n')) |line| {
    // process line (does not include '\n')
}
// Loop ends when null returned (EOF)
```

### Writing Files

```zig
const file = try std.Io.Dir.cwd().createFile(io, "out.txt", .{});
defer file.close();

var buf: [4096]u8 = undefined;
var writer = file.writer(io, &buf);
const w = &writer.interface;

try w.print("Hello {s}\n", .{"world"});
try w.writeAll("More data\n");
try w.flush();  // REQUIRED!
```

### Stdout/Stderr

```zig
// Stdout
var stdout_buf: [4096]u8 = undefined;
var stdout_writer = std.Io.File.stdout().writer(io, &stdout_buf);
const stdout = &stdout_writer.interface;

try stdout.print("Output: {d}\n", .{42});
try stdout.flush();

// Stderr
var stderr_buf: [4096]u8 = undefined;
var stderr_writer = std.Io.File.stderr().writer(io, &stderr_buf);
const stderr = &stderr_writer.interface;

try stderr.print("Error: {s}\n", .{msg});
try stderr.flush();
```

### Stdin

```zig
var stdin_buf: [4096]u8 = undefined;
var stdin_reader = std.Io.File.stdin().reader(io, &stdin_buf);
const stdin = &stdin_reader.interface;

// takeDelimiter returns ?[]u8 (null at EOF), wrapped in error union
const maybe_line = try stdin.takeDelimiter('\n');  // null if EOF
if (maybe_line) |line| {
    // process line
}
```

---

## Common Patterns

### Process Lines from File

```zig
fn processLines(path: []const u8) !void {
    const file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer file.close();

    var buf: [8192]u8 = undefined;
    var reader = file.reader(io, &buf);
    const r = &reader.interface;

    // takeDelimiter returns null at EOF (not EndOfStream error)
    while (try r.takeDelimiter('\n')) |line| {
        std.debug.print("Line: {s}\n", .{line});
    }
}
```

### Copy File

```zig
fn copyFile(src_path: []const u8, dst_path: []const u8) !void {
    const src = try std.Io.Dir.cwd().openFile(io, src_path, .{});
    defer src.close();

    const dst = try std.Io.Dir.cwd().createFile(io, dst_path, .{});
    defer dst.close();

    var read_buf: [4096]u8 = undefined;
    var reader = src.reader(io, &read_buf);

    var write_buf: [4096]u8 = undefined;
    var writer = dst.writer(io, &write_buf);

    _ = try reader.interface.streamRemaining(&writer.interface);
    try writer.interface.flush();
}
```

### Parse Binary Header

```zig
const FileHeader = extern struct {
    magic: [4]u8,
    version: u16,
    flags: u32,
    data_offset: u64,
};

fn parseHeader(file: std.Io.File) !FileHeader {
    var buf: [128]u8 = undefined;
    var reader = file.reader(io, &buf);
    const r = &reader.interface;

    const header = try r.takeStruct(FileHeader, .little);
    if (!std.mem.eql(u8, &header.magic, "MYFT")) {
        return error.InvalidMagic;
    }
    return header;
}
```

### Build String with Allocating Writer

```zig
fn buildMessage(allocator: Allocator, items: []const Item) ![]u8 {
    var aw: std.Io.Writer.Allocating = .init(allocator);
    errdefer aw.deinit();
    const w = &aw.writer;

    try w.writeAll("Items:\n");
    for (items, 0..) |item, i| {
        try w.print("  {d}. {s}\n", .{ i + 1, item.name });
    }

    return aw.toOwnedSlice();
}
```

### Streaming JSON to File

```zig
fn writeJson(file: std.Io.File, data: anytype) !void {
    var buf: [4096]u8 = undefined;
    var writer = file.writer(io, &buf);
    const w = &writer.interface;

    try std.json.stringify(data, .{}, w);
    try w.writeByte('\n');
    try w.flush();
}
```

---

## Specialized Writers and Readers

### Writer.Hashed
Wraps a writer to compute hash of written data.
```zig
var hash_buf: [64]u8 = undefined;
var hasher = std.crypto.hash.sha2.Sha256.init(.{});
var hashed = writer.hashed(&hasher, &hash_buf);
const w = &hashed.writer;

try w.writeAll("data to hash");
try w.flush();

var digest: [32]u8 = undefined;
hashed.hasher.final(&digest);
```

### Reader.Hashed
Wraps a reader to compute hash of read data.
```zig
var hash_buf: [64]u8 = undefined;
var hasher = std.crypto.hash.sha2.Sha256.init(.{});
var hashed = reader.hashed(&hasher, &hash_buf);
const r = &hashed.reader;

const data = try r.take(100);
// hasher updated with read data

var digest: [32]u8 = undefined;
hashed.hasher.final(&digest);
```

### Reader.Limited
Limits bytes readable from underlying reader.
```zig
var limited_buf: [256]u8 = undefined;
var limited = underlying_reader.limited(.limited(1024), &limited_buf);
// Can only read up to 1024 bytes total
```

---

## Error Types

```zig
// Writer errors
std.Io.Writer.Error = error{WriteFailed};

// Reader errors
std.Io.Reader.Error = error{ReadFailed, EndOfStream};
std.Io.Reader.StreamError = error{ReadFailed, WriteFailed, EndOfStream};
std.Io.Reader.DelimiterError = error{ReadFailed, EndOfStream, StreamTooLong};
```

---

## std.Io.Limit

Used to specify byte limits for streaming operations.

```zig
const Limit = enum(usize) {
    nothing = 0,
    unlimited = std.math.maxInt(usize),
    _,

    pub fn limited(n: usize) Limit;
    pub fn limited64(n: u64) Limit;
    pub fn min(a: Limit, b: Limit) Limit;
    pub fn toInt(l: Limit) ?usize;  // null for unlimited
    pub fn subtract(l: Limit, amount: usize) ?Limit;
};
```

---

## Format Method Changes (0.15)

### "{f}" Required to Call format Methods

Turn on `-freference-trace` to help you find all the format string breakage.

Example:

```zig
std.debug.print("{}", .{std.zig.fmtId("example")});
```

This will now cause a compile error:

```
error: ambiguous format string; specify {f} to call format method, or {any} to skip it
```

Fixed by:

```zig
std.debug.print("{f}", .{std.zig.fmtId("example")});
```

Motivation: eliminate these two footguns:

Introducing a `format` method to a struct caused a bug if there was formatting code somewhere that prints with {} and then starts rendering differently.

Removing a `format` method to a struct caused a bug if there was formatting code somewhere that prints with {} and is now changed without notice.

Now, introducing a `format` method will cause compile errors at all `{}` sites. In the future, it will have no effect.

Similarly, eliminating a `format` method will not change any sites that use `{}`.

Using `{f}` always tries to call a `format` method, causing a compile error if none exists.

### Format Methods No Longer Have Format Strings or Options

```zig
// BEFORE
pub fn format(
    this: @This(),
    comptime format_string: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void { ... }

// AFTER
pub fn format(this: @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void { ... }
```

The deleted `FormatOptions` are now for numbers only.

Any state that you got from the format string, there are three suggested alternatives:

1.  different format methods

```zig
pub fn formatB(foo: Foo, writer: *std.Io.Writer) std.Io.Writer.Error!void { ... }
```

This can be called with `"{f}", .{std.fmt.alt(Foo, .formatB)}`.

2.  `std.fmt.Alt`

```zig
pub fn bar(foo: Foo, context: i32) std.fmt.Alt(F, F.baz) {
    return .{ .data = .{ .context = context } };
}
const F = struct {
    context: i32,
    pub fn baz(f: F, writer: *std.Io.Writer) std.Io.Writer.Error!void { ... }
};
```

This can be called with `"{f}", .{foo.bar(1234)}`.

3.  return a struct instance that has a format method, combined with `{f}`.

```zig
pub fn bar(foo: Foo, context: i32) F {
    return .{ .context = 1234 };
}
const F = struct {
    context: i32,
    pub fn format(f: F, writer: *std.Io.Writer) std.Io.Writer.Error!void { ... }
};
```

This can be called with `"{f}", .{foo.bar(1234)}`.

### Formatted Printing No Longer Deals with Unicode

If you were relying on alignment combined with Unicode codepoints, it is now ASCII/bytes only. The previous implementation was not fully Unicode-aware. If you want to align Unicode strings you need full Unicode support which the standard library does not provide.

### New Formatted Printing Specifiers

-   {t} is shorthand for `@tagName()` and `@errorName()`
-   {d} and other integer printing can be used with custom types which calls `formatNumber` method.
-   {b64}: output string as standard base64

---

## std.Io.RwLock

A reader-writer lock: supports one writer OR many readers.

```zig
const rwlock: std.Io.RwLock = .init;

// Exclusive write lock
rwlock.lockUncancelable(io);
defer rwlock.unlock(io);
// ... write ...

// Shared read lock
rwlock.lockSharedUncancelable(io);
defer rwlock.unlockShared(io);
// ... read ...

// Non-blocking
if (rwlock.tryLock(io)) {
    defer rwlock.unlock(io);
    // write
}
```

Requires an `io: std.Io` instance for all operations.

## std.Io.Semaphore

An unsigned integer that blocks the kernel thread if the number would become negative.

```zig
var sem: std.Io.Semaphore = .{ .permits = 3 };

// Acquire permit (blocks if 0)
try sem.wait(io);
defer sem.post(io);
// ... use limited resource ...

// Uncancelable variants
sem.waitUncancelable(io);
sem.post(io);
```

Static initialization supported, no deinitialization required.

## std.Io.Select

Higher-level concurrency primitive wrapping a `Group` with a `Queue`. Dispatches tasks and collects results as a tagged union.

```zig
const Result = union(enum) {
    network: []const u8,
    disk: u64,
};

var buffer: [10]Result = undefined;
var sel = std.Io.Select(Result).init(io, &buffer);

// Dispatch tasks
sel.async(.network, fetchUrl, .{"https://example.com"});
sel.async(.disk, readFile, .{"/tmp/data.bin"});

// Wait for any result
const result = try sel.await();
switch (result) {
    .network => |data| { ... },
    .disk => |size| { ... },
}

// Wait for multiple results
var results: [5]Result = undefined;
const count = try sel.awaitMany(&results, 2);  // wait for at least 2
```
