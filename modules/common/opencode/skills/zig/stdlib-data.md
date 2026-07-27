# std.Data Processing

Memory, formatting, JSON, and ZON utilities in Zig 0.16. Verified against 0.16.0 source.

# std.mem

Memory manipulation utilities: slice operations, searching, splitting, alignment, endianness, and byte conversion.

## Slice Comparison & Search

```zig
// Equality
std.mem.eql(u8, "hello", "hello")  // true
std.mem.order(u8, "abc", "abd")    // .lt

// Find substring/element
std.mem.indexOf(u8, "hello world", "wor")       // ?usize = 6
std.mem.lastIndexOf(u8, "ababa", "ab")          // ?usize = 2
std.mem.indexOfScalar(u8, "hello", 'l')         // ?usize = 2
std.mem.lastIndexOfScalar(u8, "hello", 'l')     // ?usize = 3

// Find any/none of characters
std.mem.indexOfAny(u8, "hello", "aeiou")        // ?usize = 1 (first vowel)
std.mem.indexOfNone(u8, "   hello", " ")        // ?usize = 3 (first non-space)

// Check prefix/suffix
std.mem.startsWith(u8, "hello", "hel")          // true
std.mem.endsWith(u8, "hello.txt", ".txt")       // true

// Count occurrences
std.mem.count(u8, "ababa", "ab")                // 2
std.mem.containsAtLeast(u8, "ababa", 2, "ab")   // true

## Tokenize vs Split

**Tokenize**: Skip empty tokens (like shell word splitting)
```zig
var it = std.mem.tokenizeAny(u8, "  hello   world  ", " ");
while (it.next()) |token| {
    // "hello", "world"
}

// Other tokenize variants
std.mem.tokenizeScalar(u8, "a,b,c", ',');       // single delimiter
std.mem.tokenizeSequence(u8, "a::b::c", "::");  // exact sequence

**Split**: Preserve empty tokens
```zig
var it = std.mem.splitScalar(u8, "a,,b", ',');
while (it.next()) |part| {
    // "a", "", "b"
}

// Other split variants
std.mem.splitAny(u8, "a,b;c", ",;");            // any of delimiters
std.mem.splitSequence(u8, "a::b::c", "::");     // exact sequence

// Split backwards
var it = std.mem.splitBackwardsScalar(u8, "a/b/c", '/');
// "c", "b", "a"

## Window Iterator

Sliding window over slice:
```zig
var it = std.mem.window(u8, "hello", 3, 1);  // size=3, advance=1
while (it.next()) |w| {
    // "hel", "ell", "llo"
}

## Join & Concat

```zig
const allocator = std.heap.page_allocator;

// Join with separator
const joined = try std.mem.join(allocator, ", ", &.{ "a", "b", "c" });
defer allocator.free(joined);  // "a, b, c"

// Join with null terminator
const joinedZ = try std.mem.joinZ(allocator, "/", &.{ "path", "to", "file" });
// [:0]u8 = "path/to/file"

// Concatenate without separator
const concatted = try std.mem.concat(allocator, u8, &.{ "hello", " ", "world" });
// "hello world"

## Trim

```zig
std.mem.trim(u8, "  hello  ", " ")       // "hello"
std.mem.trimStart(u8, "  hello", " ")    // "hello" (left only)
std.mem.trimEnd(u8, "hello  ", " ")      // "hello" (right only)

// Trim multiple characters
std.mem.trim(u8, "\n\thello\n\t", " \t\n")

## Replace

```zig
// In-place replace (returns count)
var buf: [100]u8 = undefined;
const count = std.mem.replace(u8, "hello", "l", "L", &buf);
// buf contains "heLLo", count = 2

// Allocate new slice
const result = try std.mem.replaceOwned(u8, allocator, "hello", "l", "L");
defer allocator.free(result);  // "heLLo"

// Replace single scalar
var data = [_]u8{ 'a', 'b', 'a' };
std.mem.replaceScalar(u8, &data, 'a', 'x');  // "xbx"

// Calculate replacement size first
const size = std.mem.replacementSize(u8, "hello", "l", "LL");  // 7

## Byte Conversion

```zig
// Value to bytes
const val: u32 = 0xDEADBEEF;
const bytes = std.mem.asBytes(&val);      // *const [4]u8
const byte_copy = std.mem.toBytes(val);   // [4]u8 (copy)

// Bytes to value
const bytes = [_]u8{ 0xEF, 0xBE, 0xAD, 0xDE };
const ptr = std.mem.bytesAsValue(u32, &bytes);  // *const u32
const val = std.mem.bytesToValue(u32, &bytes);  // u32 (copy)

// Slice conversions
const u16_slice = [_]u16{ 0x0102, 0x0304 };
const u8_slice = std.mem.sliceAsBytes(&u16_slice);  // []const u8

const u8_data = [_]u8{ 1, 0, 2, 0, 3, 0, 4, 0 };
const u16_view = std.mem.bytesAsSlice(u16, &u8_data);  // []const u16

## Alignment

```zig
// Align forward (round up)
std.mem.alignForward(usize, 7, 4)     // 8
std.mem.alignForward(usize, 8, 4)     // 8
std.mem.alignForward(usize, 9, 4)     // 12

// Align backward (round down)
std.mem.alignBackward(usize, 7, 4)    // 4
std.mem.alignBackward(usize, 8, 4)    // 8

// Check alignment
std.mem.isAligned(8, 4)               // true
std.mem.isAligned(7, 4)               // false
std.mem.isValidAlign(4)               // true (power of 2)
std.mem.isValidAlign(3)               // false

// Align pointer
const ptr: [*]u8 = @ptrFromInt(0x123);
const aligned = std.mem.alignPointer(ptr, 0x100);  // ?[*]u8 = 0x200

// Find aligned slice within bytes
const aligned_slice = std.mem.alignInBytes(bytes, 16);  // ?[]align(16) u8

## Alignment Type

```zig
const align_val: std.mem.Alignment = .@"16";  // 16-byte alignment
const bytes = align_val.toByteUnits();        // 16

// From byte units
const a = std.mem.Alignment.fromByteUnits(8); // .@"8"

// From type
const a = std.mem.Alignment.of(u64);          // .@"8"

// Forward/backward with Alignment
const addr = align_val.forward(0x123);        // next aligned address
const addr = align_val.backward(0x123);       // previous aligned address
const ok = align_val.check(0x100);            // true if aligned

## Endianness Conversion

```zig
// To/from native endianness
const native = std.mem.littleToNative(u32, 0x12345678);
const native = std.mem.bigToNative(u32, 0x12345678);
const little = std.mem.nativeToLittle(u32, native_val);
const big = std.mem.nativeToBig(u32, native_val);

// General conversion
const val = std.mem.toNative(u32, x, .little);     // from little to native
const val = std.mem.nativeTo(u32, x, .big);        // from native to big

// Byte swap all fields in struct
std.mem.byteSwapAllFields(MyStruct, &my_struct);

// Byte swap all elements in slice
std.mem.byteSwapAllElements(u32, slice);

## Packed Integer Read/Write

Read/write integers at bit offsets:
```zig
var bytes = [_]u8{ 0, 0, 0, 0 };

// Write u12 at bit offset 4
std.mem.writePackedInt(u12, &bytes, 4, 0xABC, .little);

// Read it back
const val = std.mem.readPackedInt(u12, &bytes, 4, .little);

// Variable-width read/write
std.mem.writeVarPackedInt(&bytes, bit_offset, bit_count, value, .little);
const val = std.mem.readVarPackedInt(u32, &bytes, bit_offset, bit_count, .little, .unsigned);

## Zero Initialization

```zig
// Zero-initialize a type
const zeroed: MyStruct = std.mem.zeroes(MyStruct);
// All numeric fields = 0, optionals = null, slices = empty

// Partial initialization with zeros for rest
const partial = std.mem.zeroInit(MyStruct, .{
    .name = "foo",      // explicit value
    // other fields zeroed
});

## Min/Max

```zig
const slice = [_]i32{ 3, 1, 4, 1, 5 };

std.mem.min(i32, &slice)          // 1
std.mem.max(i32, &slice)          // 5
std.mem.minMax(i32, &slice)       // .{ 1, 5 }

std.mem.indexOfMin(i32, &slice)   // 1
std.mem.indexOfMax(i32, &slice)   // 4
std.mem.indexOfMinMax(i32, &slice) // .{ 1, 4 }

## Reverse & Rotate

```zig
var arr = [_]u8{ 1, 2, 3, 4, 5 };

std.mem.reverse(u8, &arr);        // [5, 4, 3, 2, 1]
std.mem.rotate(u8, &arr, 2);      // rotate left by 2

// Swap two values
std.mem.swap(u32, &a, &b);

// Reverse iterator (no mutation)
var it = std.mem.reverseIterator(&arr);
while (it.next()) |val| {
    // 5, 4, 3, 2, 1
}

## Other Utilities

```zig
// All elements equal to value
std.mem.allEqual(u8, slice, 0)    // true if all zeros

// Sentinel-terminated length
const len = std.mem.len(c_string);  // length of null-terminated string

// Span from sentinel pointer (convert [*:0]T to []T)
const slice = std.mem.span(c_string);

// Index of first difference
std.mem.indexOfDiff(u8, "hello", "helps")  // ?usize = 3

// Collapse repeated elements
var data = "aabbcc".*;
const len = std.mem.collapseRepeatsLen(u8, &data, 'a');  // "abbcc", 5

## Benchmark Utility

```zig
// Prevent compiler from optimizing away a value
std.mem.doNotOptimizeAway(result);
# std.fmt - String Formatting and Parsing

String formatting and parsing utilities: format strings, integer/float parsing, hex encoding/decoding, and custom formatters.

## Table of Contents
- [Format String Syntax](#format-string-syntax)
- [Format Specifiers](#format-specifiers)
- [Integer Parsing](#integer-parsing)
- [Float Parsing](#float-parsing)
- [Hex Encoding/Decoding](#hex-encodingdecoding)
- [Buffer Printing](#buffer-printing)
- [Allocating Print](#allocating-print)
- [Comptime Print](#comptime-print)
- [Custom Formatters](#custom-formatters)
- [Format String Parser](#format-string-parser)

## Format String Syntax

Full syntax: `{[arg]:[fill][alignment][width][.precision][specifier]}`

### Components

| Component | Description | Example |
|-----------|-------------|---------|
| `arg` | Argument index or name | `{0}`, `{name}` |
| `fill` | Padding character | `{:0>5}` uses `0` |
| `alignment` | `<` left, `^` center, `>` right | `{:<10}` |
| `width` | Minimum field width | `{:10}` |
| `precision` | Decimal places for floats | `{:.2}` |
| `specifier` | Output format | `{d}`, `{x}`, `{s}` |

### Examples

```zig
std.debug.print("{d:0>8}\n", .{42});        // "00000042"
std.debug.print("{s:_^10}\n", .{"hi"});     // "____hi____"
std.debug.print("{d:.2}\n", .{3.14159});    // "3.14"
std.debug.print("{0} {1} {0}\n", .{"a", "b"}); // "a b a"

### Named Arguments

```zig
std.debug.print("{name}: {value}\n", .{ .name = "x", .value = 42 });

### Runtime Width/Precision

```zig
std.debug.print("{d:[width]}\n", .{ .width = @as(usize, 8), 42 });
std.debug.print("{d:.[prec]}\n", .{ .prec = @as(usize, 2), 3.14159 });

### Escape Braces

```zig
std.debug.print("{{literal}}\n", .{});  // "{literal}"

## Format Specifiers

### Type Specifiers

| Specifier | Types | Output |
|-----------|-------|--------|
| `{}` | any | Default formatting |
| `{d}` | int, float, enum | Decimal |
| `{b}` | int, enum | Binary |
| `{o}` | int, enum | Octal |
| `{x}` | int, float, `[]u8`, enum | Lowercase hex |
| `{X}` | int, float, `[]u8`, enum | Uppercase hex |
| `{s}` | `[]const u8`, `[*:0]const u8` | String |
| `{c}` | u8 | ASCII character |
| `{u}` | u21 | UTF-8 codepoint |
| `{e}` | float | Scientific notation |
| `{f}` | has `format` method | Custom formatter (0.15.x) |
| `{*}` | pointer | Address (`Type@0x...`) |
| `{?}` | optional | Value or `null` |
| `{!}` | error union | Value or `error.Name` |
| `{any}` | any | Debug representation |

### Integer Examples

```zig
std.debug.print("{d}\n", .{255});      // "255"
std.debug.print("{x}\n", .{255});      // "ff"
std.debug.print("{X}\n", .{255});      // "FF"
std.debug.print("{b}\n", .{5});        // "101"
std.debug.print("{o}\n", .{64});       // "100"
std.debug.print("{c}\n", .{'A'});      // "A"
std.debug.print("{u}\n", .{0x1F310});  // globe emoji

### Float Examples

```zig
std.debug.print("{d}\n", .{3.14159});           // "3.14159"
std.debug.print("{d:.2}\n", .{3.14159});        // "3.14"
std.debug.print("{e}\n", .{1234.5});            // "1.2345e3"
std.debug.print("{e:.3}\n", .{1234.5});         // "1.234e3"
std.debug.print("{x}\n", .{@as(f32, 1.0)});     // "0x1p0"
std.debug.print("{x:.5}\n", .{@as(f32, 1.0)});  // "0x1.00000p0"

### Special Float Values

```zig
std.debug.print("{}\n", .{std.math.nan(f64)});  // "nan"
std.debug.print("{}\n", .{std.math.inf(f64)});  // "inf"
std.debug.print("{}\n", .{-std.math.inf(f64)}); // "-inf"

### Slice/Array Formatting

```zig
const bytes: []const u8 = "hello";
std.debug.print("{s}\n", .{bytes});    // "hello"
std.debug.print("{x}\n", .{bytes});    // "68656c6c6f"
std.debug.print("{any}\n", .{bytes});  // "{ 104, 101, 108, 108, 111 }"

### Padding and Alignment

```zig
std.debug.print("{d:5}\n", .{42});      // "   42" (right, default)
std.debug.print("{d:<5}\n", .{42});     // "42   " (left)
std.debug.print("{d:^5}\n", .{42});     // " 42  " (center)
std.debug.print("{d:0>5}\n", .{42});    // "00042" (zero-pad)
std.debug.print("{d:=>5}\n", .{42});    // "===42" (custom fill)

## Integer Parsing

### parseInt

Parse signed or unsigned integers with optional base detection.

```zig
const std = @import("std");

// Explicit base
const a = try std.fmt.parseInt(i32, "-123", 10);    // -123
const b = try std.fmt.parseInt(u32, "ff", 16);      // 255
const c = try std.fmt.parseInt(u8, "101", 2);       // 5

// Auto-detect base (base = 0)
const d = try std.fmt.parseInt(i32, "0x1f", 0);     // 31  (hex)
const e = try std.fmt.parseInt(i32, "0b101", 0);    // 5   (binary)
const f = try std.fmt.parseInt(i32, "0o17", 0);     // 15  (octal)
const g = try std.fmt.parseInt(i32, "42", 0);       // 42  (decimal)

// Underscores allowed between digits
const h = try std.fmt.parseInt(u32, "1_000_000", 10);  // 1000000
const i = try std.fmt.parseInt(u32, "0xff_ff", 0);     // 65535

**Errors:**
- `error.InvalidCharacter` - Invalid digit for base, leading/trailing underscore, empty string
- `error.Overflow` - Result doesn't fit in type

### parseUnsigned

Parse unsigned integers only (rejects `+` and `-` signs).

```zig
const a = try std.fmt.parseUnsigned(u16, "65535", 10);  // 65535
const b = try std.fmt.parseUnsigned(u8, "ff", 16);      // 255

// These return error.InvalidCharacter:
// std.fmt.parseUnsigned(u8, "+10", 10)
// std.fmt.parseUnsigned(u8, "-10", 10)

### parseIntSizeSuffix

Parse integers with SI size suffixes (K, M, G, T, P, E, Z, Y, R, Q).

```zig
const std = @import("std");

const a = try std.fmt.parseIntSizeSuffix("2", 10);      // 2
const b = try std.fmt.parseIntSizeSuffix("2B", 10);     // 2
const c = try std.fmt.parseIntSizeSuffix("2k", 10);     // 2000
const d = try std.fmt.parseIntSizeSuffix("2kB", 10);    // 2000
const e = try std.fmt.parseIntSizeSuffix("2Ki", 10);    // 2048  (binary)
const f = try std.fmt.parseIntSizeSuffix("2KiB", 10);   // 2048  (binary)
const g = try std.fmt.parseIntSizeSuffix("1M", 10);     // 1000000
const h = try std.fmt.parseIntSizeSuffix("1Mi", 10);    // 1048576
const i = try std.fmt.parseIntSizeSuffix("aKiB", 16);   // 10240 (hex base)

### charToDigit / digitToChar

Convert between characters and digit values.

```zig
const d = try std.fmt.charToDigit('a', 16);  // 10
const c = std.fmt.digitToChar(10, .lower);   // 'a'
const C = std.fmt.digitToChar(10, .upper);   // 'A'

## Float Parsing

### parseFloat

Parse floating-point numbers from strings.

```zig
const std = @import("std");

// Decimal notation
const a = try std.fmt.parseFloat(f64, "3.14159");      // 3.14159
const b = try std.fmt.parseFloat(f32, "-123.456");     // -123.456
const c = try std.fmt.parseFloat(f64, "1e10");         // 1e10
const d = try std.fmt.parseFloat(f64, "1.5e-3");       // 0.0015
const e = try std.fmt.parseFloat(f64, "+0");           // 0.0
const f = try std.fmt.parseFloat(f64, "-0");           // -0.0

// Hexadecimal notation
const g = try std.fmt.parseFloat(f64, "0x1p0");        // 1.0
const h = try std.fmt.parseFloat(f64, "0x1.8p1");      // 3.0
const i = try std.fmt.parseFloat(f32, "-0x1p-1");      // -0.5

// Special values
const nan = try std.fmt.parseFloat(f64, "nan");        // NaN
const inf = try std.fmt.parseFloat(f64, "inf");        // +Inf
const ninf = try std.fmt.parseFloat(f64, "-inf");      // -Inf

// Underscores allowed between digits
const j = try std.fmt.parseFloat(f64, "1_234.567_8");  // 1234.5678

**Supported types:** `f16`, `f32`, `f64`, `f80`, `f128`

**Errors:**
- `error.InvalidCharacter` - Invalid format, empty string, invalid underscore placement

## Hex Encoding/Decoding

### bytesToHex

Convert bytes to hexadecimal string.

```zig
const input = "hello";
const hex_lower = std.fmt.bytesToHex(input, .lower);  // "68656c6c6f"
const hex_upper = std.fmt.bytesToHex(input, .upper);  // "68656C6C6F"

### hexToBytes

Decode hexadecimal string to bytes.

```zig
var buf: [32]u8 = undefined;
const decoded = try std.fmt.hexToBytes(&buf, "48656c6c6f");  // "Hello"

**Errors:**
- `error.InvalidCharacter` - Non-hex character
- `error.InvalidLength` - Odd number of hex digits
- `error.NoSpaceLeft` - Output buffer too small

### hex

Convert unsigned integer to little-endian hex bytes.

```zig
const h = std.fmt.hex(@as(u32, 0xdeadbeef));  // "efbeadde"

## Buffer Printing

### bufPrint

Format into a fixed buffer, returns slice of written data.

```zig
var buf: [256]u8 = undefined;
const result = try std.fmt.bufPrint(&buf, "Hello {s}!", .{"world"});
// result = "Hello world!"

**Errors:**
- `error.NoSpaceLeft` - Buffer too small

### bufPrintZ

Format into buffer with null terminator.

```zig
var buf: [256]u8 = undefined;
const result = try std.fmt.bufPrintZ(&buf, "Hello {s}!", .{"world"});
// result is [:0]u8 = "Hello world!" (null-terminated)

### count

Count characters needed for format (without allocating).

```zig
const len = std.fmt.count("Value: {d}, Name: {s}", .{ 42, "test" });
// len = 21

## Allocating Print

### allocPrint

Format with dynamic allocation.

```zig
const allocator = std.heap.page_allocator;
const result = try std.fmt.allocPrint(allocator, "Hello {s}!", .{"world"});
defer allocator.free(result);
// result = "Hello world!"

### allocPrintSentinel

Format with allocation and sentinel terminator.

```zig
const result = try std.fmt.allocPrintSentinel(allocator, "Hello {s}", .{"world"}, 0);
defer allocator.free(result);
// result is [:0]u8 = "Hello world" (null-terminated)

## Comptime Print

### comptimePrint

Format at compile time, returns pointer to comptime-known string.

```zig
const msg = comptime std.fmt.comptimePrint("Value: {d}", .{100});
// msg: *const [10:0]u8 = "Value: 100"

## Custom Formatters

### Using `{f}` Specifier (0.15.x)

Types with a `format` method use `{f}`:

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

### Alt (Formatter Wrapper)

Create a type that wraps data with a custom format function.

```zig
const std = @import("std");

fn formatReversed(data: []const u8, writer: *std.Io.Writer) std.Io.Writer.Error!void {
    var i = data.len;
    while (i > 0) {
        i -= 1;
        try writer.writeByte(data[i]);
    }
}

const Reversed = std.fmt.Alt([]const u8, formatReversed);

pub fn main() !void {
    const rev = Reversed{ .data = "hello" };
    std.debug.print("{f}\n", .{rev});  // "olleh"
}

### alt Helper

Call alternate format methods by name.

```zig
const Example = struct {
    number: u8,

    pub fn asHex(self: @This(), writer: *std.Io.Writer) std.Io.Writer.Error!void {
        try writer.print("0x{x:0>2}", .{self.number});
    }
};

const ex = Example{ .number = 42 };
std.debug.print("{f}\n", .{std.fmt.alt(ex, .asHex)});  // "0x2a"

## Format String Parser

For implementing custom formatters compatible with std.fmt.

### Parser

Stream-based parser for format strings.

```zig
const std = @import("std");

var parser: std.fmt.Parser = .{ .bytes = "hello:world", .i = 0 };

// Parse until delimiter
const before = parser.until(':');  // "hello"

// Consume delimiter
_ = parser.char();  // ':'

// Check for character
if (parser.maybe('w')) {
    // consumed 'w'
}

// Parse number
parser = .{ .bytes = "42abc", .i = 0 };
const num = parser.number();  // 42

// Peek without consuming
const next = parser.peek(0);  // 'a'

### Placeholder

Parse format placeholder syntax.

```zig
const ph = std.fmt.Placeholder.parse("0d:0>8.2");
// ph.arg = .{ .number = 0 }
// ph.specifier_arg = "d"
// ph.fill = '0'
// ph.alignment = .right
// ph.width = .{ .number = 8 }
// ph.precision = .{ .number = 2 }

### Specifier

Argument reference in format string.

```zig
const Specifier = union(enum) {
    none,              // {} - auto-increment
    number: usize,     // {0} - positional
    named: []const u8, // {name} - named
};

## Utility Functions

### digits2

Fast conversion of 0-99 to two-digit string.

```zig
const d = std.fmt.digits2(42);  // "42"
const z = std.fmt.digits2(7);   // "07"

### printInt

Print integer to buffer, returns end index.

```zig
var buf: [32]u8 = undefined;
const end = std.fmt.printInt(&buf, @as(i32, -42), 10, .lower, .{});
const result = buf[0..end];  // "-42"

## Types

### Options

Formatting options for numbers.

```zig
const Options = struct {
    precision: ?usize = null,
    width: ?usize = null,
    alignment: Alignment = .right,
    fill: u8 = ' ',
};

### Number

Extended options for numeric formatting.

```zig
const Number = struct {
    mode: Mode = .decimal,    // .decimal, .binary, .octal, .hex, .scientific
    case: Case = .lower,      // .lower, .upper
    precision: ?usize = null,
    width: ?usize = null,
    alignment: Alignment = .right,
    fill: u8 = ' ',
};

### Alignment

```zig
const Alignment = enum { left, center, right };

### Case

```zig
const Case = enum { lower, upper };

## Error Types

```zig
const ParseIntError = error{ Overflow, InvalidCharacter };
const ParseFloatError = error{ InvalidCharacter };
const BufPrintError = error{ NoSpaceLeft };

## Constants

```zig
const default_max_depth = 3;        // Default recursion depth for {any}
const hex_charset = "0123456789abcdef";
# std.json - JSON Parsing and Serialization

JSON RFC 8259 compliant parsing and stringification in Zig 0.15.x.

## Table of Contents
- [Parsing JSON](#parsing-json)
- [Serializing to JSON](#serializing-to-json)
- [Dynamic Values](#dynamic-values)
- [Custom Serialization](#custom-serialization)
- [Streaming API](#streaming-api)
- [Common Patterns](#common-patterns)

## Parsing JSON

### Parse into Struct

```zig
const Config = struct {
    name: []const u8,
    port: u16,
    enabled: bool = true,  // default value for missing fields
};

const json_str =
    \\{"name": "server", "port": 8080}
;

const parsed = try std.json.parseFromSlice(Config, allocator, json_str, .{});
defer parsed.deinit();

const config = parsed.value;
// config.name == "server"
// config.port == 8080
// config.enabled == true (default)

### ParseOptions

```zig
const parsed = try std.json.parseFromSlice(T, allocator, json_str, .{
    // What to do with duplicate fields
    .duplicate_field_behavior = .@"error",  // .use_first, .use_last, .@"error" (default)

    // Allow unknown fields (default: error)
    .ignore_unknown_fields = true,

    // Max string/number length (default: input length for slices)
    .max_value_len = 4096,

    // Parse numbers vs keep as strings
    .parse_numbers = true,  // default: true
});

### Supported Types

| Zig Type | JSON |
|----------|------|
| `bool` | `true`, `false` |
| `i32`, `u64`, etc. | number or string |
| `f32`, `f64` | number or string |
| `?T` | value or `null` |
| `[]const u8` | string |
| `[N]u8` | string (fixed length) |
| `[]T`, `[N]T` | array |
| `struct` | object |
| `union(enum)` | object with single field |
| `enum` | string |
| `std.json.Value` | any JSON value |

### Parse into Dynamic Value

Use `std.json.Value` when structure is unknown at compile time:

```zig
const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json_str, .{});
defer parsed.deinit();

const value = parsed.value;
switch (value) {
    .object => |obj| {
        if (obj.get("name")) |name| {
            std.debug.print("name: {s}\n", .{name.string});
        }
    },
    .array => |arr| {
        for (arr.items) |item| { ... }
    },
    .string => |s| { ... },
    .integer => |i| { ... },
    .float => |f| { ... },
    .bool => |b| { ... },
    .null => { ... },
    .number_string => |s| { ... },  // unparsed number
}

### Leaky Parsing (Arena Allocator)

When using an arena, skip the `Parsed` wrapper:

```zig
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();

const config = try std.json.parseFromSliceLeaky(
    Config,
    arena.allocator(),
    json_str,
    .{},
);
// No deinit needed - arena handles cleanup

## Serializing to JSON

### Simple Serialization

```zig
const config = Config{ .name = "app", .port = 3000 };

// To allocated string
const json = try std.json.Stringify.valueAlloc(allocator, config, .{});
defer allocator.free(json);
// json == {"name":"app","port":3000}

// To writer
var buf: [4096]u8 = undefined;
var writer = std.Io.File.stdout().writer(&buf);
try std.json.Stringify.value(config, .{}, &writer.interface);
try writer.interface.flush();

### Stringify Options

```zig
try std.json.Stringify.value(data, .{
    // Whitespace formatting
    .whitespace = .minified,     // default: no whitespace
    // .whitespace = .indent_2,  // 2-space indent
    // .whitespace = .indent_4,  // 4-space indent
    // .whitespace = .indent_tab,

    // Include null optional fields? (default: true)
    .emit_null_optional_fields = false,

    // Emit []u8 as array of numbers instead of string
    .emit_strings_as_arrays = false,

    // Escape non-ASCII unicode as \uXXXX
    .escape_unicode = false,

    // Large integers as strings for JS compatibility
    .emit_nonportable_numbers_as_strings = false,
}, writer);

### Supported Types for Serialization

- `bool` → `true`/`false`
- `?T` → value or `null`
- integers → number (or string if > 2^53 with option)
- floats → number (or string if not precisely representable as f64)
- `[]const u8` → string (or array with option)
- `[]T`, `[N]T` → array
- tuples → array
- `struct` → object (fields in declaration order)
- `union(enum)` → object with one field
- `enum` → string
- `*T` → serialization of `T`
- `error` → string

## Dynamic Values

### Value Type

```zig
pub const Value = union(enum) {
    null,
    bool: bool,
    integer: i64,
    float: f64,
    number_string: []const u8,  // unparsed number
    string: []const u8,
    array: Array,               // std.ArrayList(Value)
    object: ObjectMap,          // StringArrayHashMap(Value)
};

### Building Values Manually

```zig
var obj = std.json.ObjectMap.init(allocator);
try obj.put("name", .{ .string = "test" });
try obj.put("count", .{ .integer = 42 });

var arr = std.json.Array.init(allocator);
try arr.append(.{ .integer = 1 });
try arr.append(.{ .integer = 2 });
try obj.put("items", .{ .array = arr });

const value = std.json.Value{ .object = obj };

### Accessing Values

```zig
// Object access
if (value.object.get("key")) |v| {
    switch (v) {
        .string => |s| std.debug.print("{s}\n", .{s}),
        else => {},
    }
}

// Array iteration
for (value.array.items) |item| {
    if (item == .integer) {
        std.debug.print("{d}\n", .{item.integer});
    }
}

## Custom Serialization

### Custom jsonParse

Define `jsonParse` for custom deserialization:

```zig
const Point = struct {
    x: i32,
    y: i32,

    // Parse from "x,y" string format
    pub fn jsonParse(
        allocator: std.mem.Allocator,
        source: anytype,
        options: std.json.ParseOptions,
    ) !@This() {
        _ = allocator;
        _ = options;
        const token = try source.next();
        const str = switch (token) {
            .string, .allocated_string => |s| s,
            else => return error.UnexpectedToken,
        };
        var it = std.mem.splitScalar(u8, str, ',');
        return .{
            .x = try std.fmt.parseInt(i32, it.next() orelse return error.UnexpectedToken, 10),
            .y = try std.fmt.parseInt(i32, it.next() orelse return error.UnexpectedToken, 10),
        };
    }
};

// Parses: "10,20" → Point{ .x = 10, .y = 20 }

### Custom jsonStringify

Define `jsonStringify` for custom serialization:

```zig
const Point = struct {
    x: i32,
    y: i32,

    pub fn jsonStringify(self: @This(), jw: anytype) !void {
        // Serialize as "x,y" string
        try jw.print("\"{d},{d}\"", .{ self.x, self.y });
    }
};

// Serializes: Point{ .x = 10, .y = 20 } → "10,20"

## Streaming API

### Stringify (Write Stream)

Build JSON incrementally:

```zig
var out: std.Io.Writer.Allocating = .init(allocator);
defer out.deinit();

var jw: std.json.Stringify = .{
    .writer = &out.writer,
    .options = .{ .whitespace = .indent_2 },
};

try jw.beginObject();
try jw.objectField("users");
try jw.beginArray();

for (users) |user| {
    try jw.beginObject();
    try jw.objectField("name");
    try jw.write(user.name);
    try jw.objectField("age");
    try jw.write(user.age);
    try jw.endObject();
}

try jw.endArray();
try jw.endObject();

const json = out.written();

### Scanner (Low-Level Parsing)

Token-based parsing for streaming:

```zig
var scanner = std.json.Scanner.initCompleteInput(allocator, json_str);
defer scanner.deinit();

while (true) {
    const token = try scanner.next();
    switch (token) {
        .object_begin => { ... },
        .object_end => { ... },
        .array_begin => { ... },
        .array_end => { ... },
        .string => |s| { ... },
        .number => |n| { ... },
        .true, .false, .null => { ... },
        .end_of_document => break,
        else => {},
    }
}

## Common Patterns

### Config File Loading

```zig
const Config = struct {
    host: []const u8 = "localhost",
    port: u16 = 8080,
    debug: bool = false,
};

fn loadConfig(allocator: std.mem.Allocator, path: []const u8) !Config {
    const file = std.Io.Dir.cwd().openFile(io, path, .{}) catch |err| switch (err) {
        error.FileNotFound => return Config{},  // defaults
        else => return err,
    };
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    const parsed = try std.json.parseFromSlice(Config, allocator, content, .{
        .ignore_unknown_fields = true,
    });
    defer parsed.deinit();

    // Copy strings to owned memory since parsed will be freed
    return Config{
        .host = try allocator.dupe(u8, parsed.value.host),
        .port = parsed.value.port,
        .debug = parsed.value.debug,
    };
}

### API Response Handling

```zig
const ApiResponse = struct {
    success: bool,
    data: ?Data = null,
    @"error": ?[]const u8 = null,  // use @"error" for reserved words

    const Data = struct {
        id: u64,
        name: []const u8,
    };
};

fn handleResponse(json: []const u8, allocator: std.mem.Allocator) !void {
    const parsed = try std.json.parseFromSlice(ApiResponse, allocator, json, .{
        .ignore_unknown_fields = true,
    });
    defer parsed.deinit();

    if (!parsed.value.success) {
        std.debug.print("Error: {s}\n", .{parsed.value.@"error" orelse "unknown"});
        return error.ApiError;
    }

    if (parsed.value.data) |data| {
        std.debug.print("Got: {s} (id={})\n", .{ data.name, data.id });
    }
}

### Pretty Print JSON

```zig
fn prettyPrint(allocator: std.mem.Allocator, json: []const u8) ![]u8 {
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, json, .{});
    defer parsed.deinit();

    return std.json.Stringify.valueAlloc(allocator, parsed.value, .{
        .whitespace = .indent_2,
    });
}

### Serialize with Filtering

```zig
fn serializePublicFields(allocator: std.mem.Allocator, user: User) ![]u8 {
    // Create anonymous struct with only public fields
    const public = .{
        .id = user.id,
        .name = user.name,
        // Exclude: .password, .internal_state
    };
    return std.json.Stringify.valueAlloc(allocator, public, .{});
}
# std.zon - ZON Parsing and Serialization

ZON ("Zig Object Notation") parsing and stringification in Zig 0.15.x. ZON's grammar is a subset of Zig's syntax.

## Table of Contents
- [ZON Format Overview](#zon-format-overview)
- [Parsing ZON](#parsing-zon)
- [Serializing to ZON](#serializing-to-zon)
- [Low-Level Serializer API](#low-level-serializer-api)
- [Supported Types](#supported-types)
- [Common Patterns](#common-patterns)

## ZON Format Overview

ZON is a data format using Zig's literal syntax:

```zig
// Example ZON file
.{
    .name = "my-project",
    .version = .{ 0, 1, 0 },
    .dependencies = .{
        .@"std-lib" = .{ .url = "https://...", .hash = "abc123" },
    },
    .build_options = .{
        .optimize = .release_safe,
        .strip = true,
    },
}

### Supported Primitives
- Boolean literals: `true`, `false`
- Number literals: `42`, `-3.14`, `0xFF`, `nan`, `inf`, `-inf`
- Character literals: `'a'`, `'\n'`, `'\u{1F600}'`
- Enum literals: `.foo`, `.bar`
- `null` literal
- String literals: `"hello"`, multiline strings

### Supported Containers
- Anonymous struct literals: `.{ .x = 1, .y = 2 }`
- Anonymous tuple literals: `.{ 1, 2, 3 }`

**Note:** ZON may not contain type names. Use `@import` for compile-time ZON parsing.

## Parsing ZON

### Parse into Struct (Runtime)

```zig
const std = @import("std");

const Config = struct {
    name: []const u8,
    port: u16 = 8080,
    debug: bool = false,
};

const zon_str: [:0]const u8 =
    \\.{
    \\    .name = "server",
    \\    .port = 3000,
    \\}
;

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const config = try std.zon.parse.fromSlice(Config, allocator, zon_str, null, .{});
    defer std.zon.parse.free(allocator, config);

    // config.name == "server"
    // config.port == 3000
    // config.debug == false (default)
}

### Parse with Diagnostics

```zig
var diag: std.zon.parse.Diagnostics = .{};
defer diag.deinit(allocator);

const result = std.zon.parse.fromSlice(Config, allocator, zon_str, &diag, .{}) catch |err| {
    // Print diagnostic errors
    var errors = diag.iterateErrors();
    while (errors.next()) |parse_err| {
        const loc = parse_err.getLocation(&diag);
        std.debug.print("{d}:{d}: {f}\n", .{
            loc.line + 1,
            loc.column + 1,
            parse_err.fmtMessage(&diag),
        });
    }
    return err;
};
defer std.zon.parse.free(allocator, result);

### Parse Options

```zig
const result = try std.zon.parse.fromSlice(T, allocator, zon_str, diag, .{
    // Ignore unknown fields (default: false - errors on unknown)
    .ignore_unknown_fields = true,

    // Free partially parsed values on error (default: true)
    // Disable if using arena allocation
    .free_on_error = false,
});

### Compile-Time Parsing with @import

```zig
// build.zig.zon is automatically imported at comptime
const build_zon = @import("build.zig.zon");

// Access fields directly
const name = build_zon.name;
const version = build_zon.version;

### Free Parsed Values

```zig
const result = try std.zon.parse.fromSlice(T, allocator, zon_str, null, .{});
defer std.zon.parse.free(allocator, result);

## Serializing to ZON

### Simple Serialization

```zig
const std = @import("std");

const Config = struct {
    name: []const u8,
    port: u16,
    enabled: bool,
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const config = Config{
        .name = "server",
        .port = 8080,
        .enabled = true,
    };

    // Serialize to allocated buffer
    var aw: std.Io.Writer.Allocating = .init(allocator);
    defer aw.deinit();

    try std.zon.stringify.serialize(config, .{}, &aw.writer);
    const zon_str = aw.written();
    // .{
    //     .name = "server",
    //     .port = 8080,
    //     .enabled = true,
    // }
}

### Serialize Options

```zig
try std.zon.stringify.serialize(value, .{
    // Include whitespace for readability (default: true)
    .whitespace = true,   // false for minified output

    // Emit codepoints as character literals (default: .never)
    .emit_codepoint_literals = .never,       // always emit as integers
    // .emit_codepoint_literals = .printable_ascii,  // 'a' for printable ASCII
    // .emit_codepoint_literals = .always,   // '⚡' for all valid codepoints

    // Emit []u8 as tuple instead of string (default: false)
    .emit_strings_as_containers = false,

    // Skip fields equal to their default value (default: true)
    .emit_default_optional_fields = true,  // false to omit defaults
}, &writer);

### Serialization with Depth Limits (Recursive Types)

```zig
// For potentially recursive types, use depth-limited versions:

// Returns error.ExceededMaxDepth if depth exceeded
try std.zon.stringify.serializeMaxDepth(value, .{}, &writer, 16);

// No depth checking - caller must ensure no cycles
try std.zon.stringify.serializeArbitraryDepth(value, .{}, &writer);

## Low-Level Serializer API

Use `std.zon.Serializer` for fine-grained control over output.

### Manual Struct Serialization

```zig
var aw: std.Io.Writer.Allocating = .init(allocator);
defer aw.deinit();

var s: std.zon.Serializer = .{ .writer = &aw.writer };

var container = try s.beginStruct(.{});
try container.field("x", 10, .{});
try container.field("y", 20, .{});
try container.field("name", "point", .{});
try container.end();

// Output: .{
//     .x = 10,
//     .y = 20,
//     .name = "point",
// }

### Manual Tuple Serialization

```zig
var s: std.zon.Serializer = .{ .writer = &aw.writer };

var tuple = try s.beginTuple(.{});
try tuple.field(1, .{});
try tuple.field(2, .{});
try tuple.field(3, .{});
try tuple.end();

// Output: .{
//     1,
//     2,
//     3,
// }

### Container Options

```zig
// Control wrapping behavior
var container = try s.beginStruct(.{
    .whitespace_style = .{ .wrap = true },   // Always wrap fields
    // .whitespace_style = .{ .wrap = false }, // Never wrap (single line)
    // .whitespace_style = .{ .fields = 2 },   // Auto-wrap if > 2 fields
});

### Nested Containers

```zig
var s: std.zon.Serializer = .{ .writer = &aw.writer };

var root = try s.beginStruct(.{});

// Nested tuple
var coords = try root.beginTupleField("coords", .{});
try coords.field(10, .{});
try coords.field(20, .{});
try coords.end();

// Nested struct
var meta = try root.beginStructField("meta", .{});
try meta.field("id", 42, .{});
try meta.end();

try root.end();

// Output: .{
//     .coords = .{
//         10,
//         20,
//     },
//     .meta = .{
//         .id = 42,
//     },
// }

### Primitive Serialization

```zig
var s: std.zon.Serializer = .{ .writer = &aw.writer };

// Integer
try s.int(42);

// Float
try s.float(3.14);

// String
try s.string("hello\nworld");  // "hello\nworld"

// Multiline string
try s.multilineString("line1\nline2", .{});
// \\line1
// \\line2

// Identifier/enum literal
try s.ident("foo");  // .foo
try s.ident("var");  // .@"var" (escaped keyword)

// Unicode codepoint
try s.codePoint('a');  // 'a'
try s.codePoint('⚡'); // '\u{26a1}'

### Value Serialization with Options

```zig
var s: std.zon.Serializer = .{ .writer = &aw.writer };

try s.value(my_value, .{
    .emit_codepoint_literals = .always,
    .emit_strings_as_containers = false,
    .emit_default_optional_fields = true,
});

## Supported Types

### Parse-able Types

| Zig Type | ZON Syntax |
|----------|------------|
| `bool` | `true`, `false` |
| `i32`, `u64`, etc. | `42`, `-5`, `0xFF` |
| `f32`, `f64` | `3.14`, `-0.0`, `nan`, `inf` |
| `?T` | value or `null` |
| `[]const u8` | `"string"`, multiline strings |
| `[]T` | `.{ item1, item2, ... }` |
| `[N]T` | `.{ item1, item2, ... }` (exact length) |
| `struct` | `.{ .field = value, ... }` |
| `struct (tuple)` | `.{ value1, value2, ... }` |
| `union(enum)` | `.tag` or `.{ .tag = value }` |
| `enum` | `.variant` |
| `*T` | value (auto-allocated) |
| `@Vector(N, T)` | `.{ elem1, elem2, ... }` |

### Non-serializable Types

These types cannot be serialized:
- `type`, `void` (except as union payload), `noreturn`
- Error sets/error unions
- Untagged unions
- Non-exhaustive enums
- Many-pointers (`[*]T`) or C-pointers (`[*c]T`)
- Opaque types (`anyopaque`)
- Async frame types (`anyframe`)
- Functions

## Common Patterns

### Build Configuration File

```zig
// build.zig.zon
.{
    .name = "my-project",
    .version = "0.1.0",
    .dependencies = .{
        .zap = .{
            .url = "https://github.com/...",
            .hash = "...",
        },
    },
    .paths = .{ "src", "build.zig", "build.zig.zon" },
}

```zig
// build.zig - reading build.zig.zon at comptime
const build_zon = @import("build.zig.zon");
const project_name = build_zon.name;

### Config File with Defaults

```zig
const Config = struct {
    host: []const u8 = "localhost",
    port: u16 = 8080,
    workers: u8 = 4,
    debug: bool = false,
};

fn loadConfig(allocator: std.mem.Allocator, path: []const u8) !Config {
    const file = std.Io.Dir.cwd().openFile(io, path, .{}) catch |err| switch (err) {
        error.FileNotFound => return Config{},
        else => return err,
    };
    defer file.close();

    const content = try file.readToEndAllocOptions(
        allocator,
        1024 * 1024,
        null,
        @alignOf(u8),
        0,  // null terminator
    );
    defer allocator.free(content);

    return std.zon.parse.fromSlice(Config, allocator, content, null, .{
        .ignore_unknown_fields = true,
        .free_on_error = true,
    });
}

### Serialize to File

```zig
fn saveConfig(allocator: std.mem.Allocator, config: Config, path: []const u8) !void {
    var aw: std.Io.Writer.Allocating = .init(allocator);
    defer aw.deinit();

    try std.zon.stringify.serialize(config, .{ .whitespace = true }, &aw.writer);

    const file = try std.Io.Dir.cwd().createFile(io, path, .{});
    defer file.close();

    try file.writeAll(aw.written());
}

### Union Serialization

```zig
const Value = union(enum) {
    int: i64,
    float: f64,
    string: []const u8,
    none,  // void payload
};

const v1 = Value{ .int = 42 };
// Serializes as: .{ .int = 42 }

const v2 = Value.none;
// Serializes as: .none

### Skip Default Fields

```zig
const Settings = struct {
    theme: []const u8 = "dark",
    font_size: u8 = 12,
    custom_value: u32,
};

const settings = Settings{ .custom_value = 100 };

try std.zon.stringify.serialize(settings, .{
    .emit_default_optional_fields = false,
}, &writer);

// Output: .{ .custom_value = 100 }
// (theme and font_size omitted because they equal defaults)

### Round-Trip ZON Data

```zig
fn roundTrip(comptime T: type, allocator: std.mem.Allocator, value: T) !T {
    // Serialize
    var aw: std.Io.Writer.Allocating = .init(allocator);
    defer aw.deinit();
    try std.zon.stringify.serialize(value, .{}, &aw.writer);

    // Add null terminator for parsing
    try aw.writer.writeByte(0);
    const zon_str = aw.written();
    const terminated: [:0]const u8 = zon_str[0 .. zon_str.len - 1 :0];

    // Parse back
    return std.zon.parse.fromSlice(T, allocator, terminated, null, .{});
}
