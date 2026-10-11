# Common Errors and Pitfalls

Compiler errors and common mistakes when upgrading to Zig 0.16.

## Zig 0.17.0 delta

This file documents 0.16.0 errors; entries below are what changed in 0.17.0 — apply them for 0.17 targets, keep the 0.16 form for 0.16 targets.

| Error | Fix |
|-------|-----|
| `**` syntax error (array multiplication) | Use `@splat`: `var a: [N]u8 = @splat(0);` |
| `void{}` | Use `{}` |
| `errdefer capture` / `errdefer \|err\|` | Split into an inner fallible function and `catch \|err\|` |
| `no member 'cImport'` / `@cImport` | Use the `codeberg.org/ziglang/translate-c` package (`b.addTranslateC` also deprecated) |
| old `OptimizeMode` tag in `==`/`!=` | Tags lowercased: `.debug`/`.safe`/`.fast`/`.small` on `std.lang.Optimize` |
| `.fields`/`fieldInfo` on `@typeInfo` struct/union | Use `field_names`/`field_types`/`field_attrs`/`decl_names` (struct-of-arrays) |
| `std.gpu` not found | Renamed to `std.spirv` (no alias) |
| `getLast`/`getLastOrNull` | Use `last()` (returns `?T`); new `lastPtr()` returns `?*T` |
| `StackFallbackAllocator`/`stackFallback` | Use `std.heap.BufferFirstAllocator` (buffer is now an argument) |
| `addArtifactArg` | Use `addArtifactArg2` (likewise `addOutputFileArg2`, `addFileArg2`, `addDirectoryArg2`, ...) |
| observing `b.args` at configure time | Use `run_cmd.addPassthruArgs()` |
| `Uri.getHost` | Use `std.Io.net.HostName.fromUri(uri, &buffer)` (`getHostAlloc` removed; caller provides a `[HostName.max_len]u8` buffer) |
| `std.builtin` | Renamed to `std.lang` (alias deprecated) |
| `getDisplayName` | Use `format` (`"{f}"`); `LazyPath.basename` removed |
| `readPackedIntNative`/`readPackedIntForeign` | Use `std.mem.readPackedInt(T, bytes, bit_offset, endian)` |

## Quick Fixes

| Error | Fix |
|-------|-----|
| `no field 'root_source_file'` | Use `root_module = b.createModule(.{...})` |
| `'std.net' has no member 'Stream'` | Networking moved: use `std.Io.net.Stream` |
| `'std.net' has no member 'Address'` | Use `std.Io.net.IpAddress.parse(host, port)` |
| `no field 'addIncludePath' in 'Compile'` | Methods moved: `lib.root_module.addIncludePath(...)` |
| `'timestamp' not found in 'std.time'` | Removed: use `std.c.clock_gettime(.REALTIME, &ts)` |
| `'Mutex' not found in 'std.Thread'` | Removed: use POSIX `PthreadMutex` shim or `std.Io.Mutex` |
| `'random' not found in 'std.crypto'` | Removed: use `arc4random_buf` or `std.os.linux.getrandom` |
| `'lockStderrWriter' not found` | Renamed: use `std.debug.lockStderr(&buf)` |
| `local constant shadows declaration` | 0.16 forbids local names matching module-level `extern fn` — rename local |
| `signed integer division` | Use `@divTrunc(a, b)` not `a / b` for signed integers |
| `no field 'close' in 'posix'` | `std.posix.close` removed: use `_ = std.c.close(fd)` |
| `use of undefined value` | Arithmetic on `undefined` is now illegal — initialize explicitly |
| `type 'f32' cannot represent integer` | Use float literal: `123_456_789.0` not `123_456_789` |
| `ambiguous format string` | Use `{f}` for format methods |
| `no field 'append'` on ArrayList | Pass allocator: `list.append(allocator, val)` (unmanaged default) |
| `expected 2 arguments, found 1` on ArrayList | Add allocator param: `.append(allocator, val)`, `.deinit(allocator)` |
| `BoundedArray` not found | Use `std.ArrayList(T).initBuffer(&buf)` |
| `GenericWriter`/`GenericReader` | Use `std.Io.Writer`/`std.Io.Reader` |
| missing `.flush()` — no output | Always call `try writer.flush()` after writing |
| `enum has no member named 'Struct'` | `@typeInfo` fields now lowercase: `.@"struct"`, `.slice`, `.int` |
| `no field named 'encode'` on base64 | Use `std.base64.standard.Encoder.encode()` |
| `no field named 'open'` on HTTP | Use `client.request()` or `client.fetch()` |
| `expected error union, found Signature` | `Ed25519.Signature.fromBytes()` doesn't return error — remove `try` |
| `addSharedLibrary` not found | Use `b.addLibrary(.{ .linkage = .dynamic, ... })` |

## Common Pitfalls

- **Forgetting `defer`/`errdefer` cleanup** — place cleanup immediately after resource acquisition
- **Using `anyerror` instead of specific error sets** — explicit sets document failure modes
- **Ignoring error unions** — handle or propagate, never discard
- **Missing `errdefer` after allocations in multi-step init** — partial construction leaks
- **Expecting comptime side effects** — comptime code is evaluated lazily
- **Unhandled integer overflow** — Zig traps on overflow in debug builds
- **Missing null terminators for C strings** — use `:0` sentinel slices: `[:0]const u8`
- **Using `anytype` when `comptime T: type` works** — explicit types produce clearer errors
- **Scoped loggers**: always define per-module `const log = std.log.scoped(.my_module);` for filterable logging

## Verification Workflow

After writing or modifying Zig code, verify with this sequence:
1. `zig build` — catch compilation errors, match against Quick Fixes above
2. `zig build test` — run unit tests
3. `zig build -Doptimize=ReleaseFast test` — detect undefined behavior (UB checks enabled in optimized builds)

**Development speed tips:**
- `zig build --watch -fincremental` — incremental compilation, rebuilds on file change
- 0.16 uses self-hosted x86_64 backend by default — ~5x faster Debug builds than LLVM
