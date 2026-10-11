---
name: zig
description: Guide to Zig 0.16.0 and 0.17.0 (0.17 changes marked as deltas in each file). Use when writing, reviewing, or debugging Zig code, working with build.zig or build.zig.zon, using comptime metaprogramming, or when the user mentions zig. Corrects outdated pre-0.15 API patterns from LLM training data.
metadata:
  version: "0.16.0 / 0.17.0"
  language: "zig"
  category: "programming-language"
---

# Zig 0.16.0 Stable Reference (with 0.17.0 deltas)

This skill targets **Zig 0.16.0 stable** and documents **0.17.0 as labelled
deltas**. Every reference file starts with a `## Zig 0.17.0 delta` section:
apply those entries for 0.17 targets, keep the 0.16 form for 0.16 targets.
Verified against the [0.16.0 source](https://codeberg.org/ziglang/zig/src/tag/0.16.0),
the [0.17.0 source](https://codeberg.org/ziglang/zig/src/tag/0.17.0), the
[0.16.0 release notes](https://ziglang.org/download/0.16.0/release-notes.html),
and the [0.17.0 release notes](https://ziglang.org/download/0.17.0/release-notes.html).

LLM training data typically covers Zig 0.11–0.14. Nearly every stdlib API has
changed since then. Always verify against this skill before generating Zig code,
and match the user's Zig version before picking a form.

## Quick Old→New Translation

| Old (0.13–0.14) | New (0.16) |
|------------------|------------|
| `std.net.Stream` | `std.Io.net.Stream` |
| `std.net.Address` | `std.Io.net.IpAddress` |
| `std.io.getStdOut().writer()` | `std.Io.File.stdout().writer(&buf)` |
| `std.io.fixedBufferStream(buf)` | `std.Io.Writer.fixed(buf)` / `std.Io.Reader.fixed(data)` |
| `std.io.bufferedWriter(writer)` | Caller-provided buffer + `std.Io.Writer` |
| `std.time.timestamp()` | `std.Io.Timestamp.now` |
| `std.Thread.Mutex` | `std.Io.Mutex` |
| `std.Thread.sleep(ns)` | `std.Io.sleep(io, duration, clock)` |
| `std.crypto.random` | `std.Io.randomSecure(io, buf)` |
| `b.addSharedLibrary(...)` | `b.addLibrary(.{ .linkage = .dynamic, ... })` |
| `exe.addModule(...)` | `exe.root_module.addImport(...)` |
| `root_source_file` | `root_module = b.createModule(...)` |
| `@Type(.{ .Int = ... })` | `@Int(.unsigned, 8)` |
| `@setCold(true)` | `@branchHint(.cold)` |
| `@setAlignStack(16)` | `callconv(.withStackAlign(.c, 16))` |
| `@export(foo, .{})` | `@export(&foo, .{})` |
| `@typeInfo(T).Struct` | `@typeInfo(T).@"struct"` |
| `ArrayList.init(alloc)` | `ArrayList.empty` or `ArrayList.initCapacity(alloc, n)` |
| `GeneralPurposeAllocator` | `DebugAllocator` |
| `BoundedArray` | `std.ArrayList(T).initBuffer(&buf)` |

## 0.16 → 0.17 Quick Translation

Valid only for 0.17 targets; for 0.16 projects keep the 0.16 form:

| 0.16 | 0.17 |
|------|------|
| `std.builtin.*` | `std.lang.*` (alias deprecated, removed after 0.18) |
| `std.gpu` | `std.spirv` (no alias) |
| `std.lang.OptimizeMode.Debug` / `.ReleaseSafe` / `.ReleaseFast` / `.ReleaseSmall` | `std.lang.Optimize.debug` / `.safe` / `.fast` / `.small` |
| `@import("builtin").mode` | `@import("builtin").optimize` (tags lowercased) |
| `@import("builtin").cpu/.os/.abi/.object_format` | `@import("builtin").target.cpu/.os/.abi/.ofmt` |
| `@typeInfo(T).@"struct".fields` | `field_names` + `field_types` + `field_attrs` (struct-of-arrays; Struct/Union/Enum) |
| `@intFromEnum` / `@enumFromInt` | `@backingInt` / `@fromBackingInt` |
| `@Type` (deprecated) | removed — use `@Int`/`@Struct`/`@Union`/`@Enum`/`@Pointer`/`@Fn`/`@Tuple`/`@EnumLiteral` |
| `[1]T{X} ** N` | `@splat(X)` (`**` syntax removed) |
| `std.fmt.allocPrint(a, ...)` / `allocPrintSentinel` | `a.print(...)` / `a.printSentinel(...)` |
| `GeneralPurposeAllocator` / `DebugAllocator` | `std.heap.SafeAllocator` (`DebugAllocator`/`Check` deprecated) |
| `std.heap.StackFallbackAllocator` / `stackFallback` | `std.heap.BufferFirstAllocator` (`stackFallback` removed) |
| `ArrayList.getLast()` / `getLastOrNull()` | `ArrayList.last()` (`?T`); new `lastPtr()` (`?*T`) |
| `DoublyLinkedList.pop()` | `popLast()` |
| `std.bit_set.IntegerBitSet`/`ArrayBitSet`/`StaticBitSet`/`DynamicBitSetUnmanaged`/`DynamicBitSet` | `Integer`/`Array`/`Static`/`Dynamic`/`DynamicManaged` |
| `containsAtLeastScalar(T, list, minimum, element)` | `containsAtLeastScalar(T, list, element, minimum)` (params swapped — silent footgun) |
| `readPackedIntNative/Foreign` / `writePackedIntNative/Foreign` | `readPackedInt` / `writePackedInt` |
| `std.zon.parse.fromSlice(T, alloc, src, &diag, .{})` | `fromSlice(T, .{ .gpa, .arena, .source, .diagnostics })`; `free` removed (arena-owned) |
| `Uri.getHost` | `std.Io.net.HostName.fromUri(uri, &buf)` (`getHostAlloc` removed) |
| `errdefer |err|` | removed — split into inner fallible fn + `catch |err|` |
| `@cImport` / `b.addTranslateC` | external `codeberg.org/ziglang/translate-c` package |
| `if (b.args) \|args\| addArgs(args)` | `run_cmd.addPassthruArgs()` |
| `b.build_root` | `b.root` |
| `LazyPath.getDisplayName()` / `LazyPath.basename` | `format` / `{f}` / (basename removed) |
| `addArtifactArg`/`addOutputFileArg`/`addFileArg`/... | `addArtifactArg2`/`addOutputFileArg2`/`addFileArg2`/... |
| `b.findProgram` | `findProgram` (poisons config cache) vs `findProgramLazy` (LazyPath) |
| `lazyDependency` | `dependencyLazy` (returns `error.LazyDependencyNeeded`) |

## Common Compiler Errors → Fixes

| Error | Fix |
|-------|-----|
| `no field 'root_source_file'` | Use `root_module = b.createModule(.{...})` |
| `'std.net' has no member 'Stream'` | Networking moved: use `std.Io.net.Stream` (note: no `.read()`/`.writeAll()` — use Io vtable or raw syscalls) |
| `'std.net' has no member 'Address'` | Use `std.Io.net.IpAddress.parse(host, port)` |
| `no field 'addIncludePath' in 'Compile'` | Methods moved: `lib.root_module.addIncludePath(...)` |
| `'timestamp' not found in 'std.time'` | Removed: use `std.Io.Timestamp.now` (preferred) or `std.c.clock_gettime(.REALTIME, &ts)` (low-level) |
| `'Mutex' not found in 'std.Thread'` | Removed: use POSIX `PthreadMutex` shim or `std.Io.Mutex` |
| `'random' not found in 'std.crypto'` | Removed: use `io.random(buf)` or `io.randomSecure(io, buf)` (preferred); `arc4random_buf`/`getrandom` as fallback |
| `'lockStderrWriter' not found` | Renamed: use `std.debug.lockStderr(&buf)` |
| `local constant shadows declaration` | 0.16 forbids local names matching module-level `extern fn` — rename local |
| `signed integer division` | Use `@divTrunc(a, b)` not `a / b` for signed integers |
| `no field 'close' in 'posix'` | `std.posix.close` removed: use `_ = std.c.close(fd)` |
| `use of undefined value` | Arithmetic on `undefined` is now illegal — initialize explicitly |
| `type 'f32' cannot represent integer` | Use float literal: `123_456_789.0` not `123_456_789` |
| `ambiguous format string` | Use `{f}` to call format method, or `{any}` to skip it |
| `no field 'append'` on ArrayList | Pass allocator: `list.append(allocator, val)` (unmanaged default) |
| `expected 2 arguments, found 1` on ArrayList | Add allocator param: `.append(allocator, val)`, `.deinit(allocator)` |
| `BoundedArray` not found | Use `std.ArrayList(T).initBuffer(&buf)` with `appendBounded`/`appendSliceBounded` for bounded behavior |
| `GenericWriter`/`GenericReader` | Use `std.Io.Writer`/`std.Io.Reader` |
| missing `.flush()` — no output | Always call `try writer.flush()` after writing |
| `enum has no member named 'Struct'` | `@typeInfo` fields now lowercase: `.@"struct"`, `.slice`, `.int` |
| `no field named 'encode'` on base64 | Use `std.base64.standard.Encoder.encode()` |
| `no field named 'open'` on HTTP | Use `client.request()` or `client.fetch()` |
| `expected error union, found Signature` | `Ed25519.Signature.fromBytes()` doesn't return error — remove `try` |
| `addSharedLibrary` not found | Use `b.addLibrary(.{ .linkage = .dynamic, ... })` |
| `signed integer division` | Use `@divTrunc(a, b)` (or `@divCeil` (0.17) / `@divFloor`) not `a / b` |

0.17-specific errors (for 0.17 builds only; full table in [errors.md](errors.md)):

| Error | Fix |
|-------|-----|
| `**` (array multiplication) | `@splat(0)`: `var a: [N]u8 = @splat(0);` |
| `void{}` | `{}` |
| `errdefer` capture | Split into inner fallible fn + `catch \|err\|` |
| `no member 'cImport'` | translate-c package: `zig fetch --save git+https://codeberg.org/ziglang/translate-c` |
| old `.Debug`/`.ReleaseSafe` tag in `==` | `std.lang.Optimize` lowercase tags `.debug`/`.safe`/`.fast`/`.small` |
| `.fields` gone from `@typeInfo` struct/union/enum | `field_names`/`field_types`/`field_attrs` (struct-of-arrays) |
| `StackFallbackAllocator`/`stackFallback` | `std.heap.BufferFirstAllocator` (buffer is now an argument) |
| `b.args` not a field | `run_cmd.addPassthruArgs()` |
| `var diag.deinit` in `std.zon.parse` | arena-owned; `Diagnostics.fmt`/`.log`/`.fatal` |

## Additional References

- [language.md](language.md) — Language semantics changes (0.14/0.15/0.16)
- [builtins.md](builtins.md) — @Type removal, @cImport, @branchHint, new builtins
- [stdlib-io.md](stdlib-io.md) — Writergate, std.Io (Writer, Reader, Dir, File, net, sleep, Group, Mutex)
- [stdlib-containers.md](stdlib-containers.md) — ArrayList, HashMap, PriorityQueue, BitSet, linked lists
- [stdlib-data.md](stdlib-data.md) — mem, fmt, json, zon, unicode, base64, compress
- [stdlib-system.md](stdlib-system.md) — process, os, c, thread, atomic, crypto, time
- [stdlib-debug.md](stdlib-debug.md) — testing, debug, log, fuzzer
- [build-system.md](build-system.md) — build.zig, build.zig.zon, flags
- [toolchain.md](toolchain.md) — musl, glibc, zig cc, incremental compilation
- [patterns.md](patterns.md) — Idioms, allocator patterns, C interop, production patterns
- [errors.md](errors.md) — Full error table, common pitfalls
- [style.md](style.md) — TigerBeetle-derived style guide
