---
name: zig
description: Guide to Zig 0.16.0 stable programming language. Use when writing, reviewing, or debugging Zig code, working with build.zig and build.zig.zon files, using comptime metaprogramming, or when the user mentions zig. Critical for avoiding outdated patterns from training data — especially std.net→std.Io.net, @Type removal, std.io→std.Io (Writergate), std.time timestamps removed, std.Thread.Mutex/Condition/sleep removed, std.crypto.random removed, build system APIs (root_module, Compile→Module), ArrayList unmanaged by default, and removed language features (async/await, usingnamespace).
metadata:
  version: "0.16.0"
  language: "zig"
  category: "programming-language"
---

# Zig 0.16.0 Stable Reference

This skill targets **Zig 0.16.0 stable**. All API references verified against the
[0.16.0 source](https://codeberg.org/ziglang/zig/src/tag/0.16.0) and
[release notes](https://ziglang.org/download/0.16.0/release-notes.html).

LLM training data typically covers Zig 0.11–0.14. Nearly every stdlib API has
changed since then. Always verify against this skill before generating Zig code.

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
