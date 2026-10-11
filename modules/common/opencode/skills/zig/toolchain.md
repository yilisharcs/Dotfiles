# Toolchain (musl, glibc, zig cc, Incremental Compilation)

Zig toolchain details for 0.16.0.

## Zig 0.17.0 delta

This file documents 0.16.0 toolchain facts; entries below are the 0.17.0 state — apply them for 0.17 targets, keep the 0.16 rows above for 0.16 targets.

| 0.16.0 (still valid for 0.16) | 0.17.0 | notes |
|-------------------------------|--------|-------|
| LLVM/Clang/LLD 21.x (`zig cc` Clang 21.1.8) | LLVM 22.1.8 (`zig cc` / `zig c++` Clang 22.1.8) | covers Clang, libc++, libc++abi, libunwind, libtsan |
| loop vectorization disabled (LLVM workaround) | still disabled | fix merged in LLVM main but not in LLVM 22; re-enabled in 0.18.0 (LLVM 23) |
| musl 1.2.5 | musl 1.2.5 (+backported security/portability fixes) | unchanged version; 0.18.0 -> 1.2.6 |
| glibc 2.43 | glibc 2.44 | |
| Linux 6.19 headers | Linux 7.2 headers | |
| macOS 26.4 headers | macOS 27.0 headers | |
| MinGW-w64 (latest) | MinGW-w64 commit `31bd54ab7d5fe03c67ed2bb1a57e531b9c7f8cc4` | many functions now from zig libc |
| — | NetBSD 11.0 libc | new for cross-compilation in 0.17.0 |
| dynamically-linked OpenBSD libc (0.16) | OpenBSD 7.9 libc | new libc version |
| WASI libc (updated) | WASI libc pinned commit `c89896107d7b57aef69dcadede47409ee4f702ee` | 0.18.0 replaces third-party WASI libc with zig libc |
| `libc.txt` key `gcc_dir` | `libc.txt` key `cc_dir` | old name still accepted; `cc_dir` now **required** on Linux. Android/OpenHarmony may set `cc_dir` to the `crt_dir` path |
| legacy self-hosted ELF linker default off | new ELF linker: full x86_64 + SPARC64, partial loongarch; still **not default** | enabled by default with incremental compilation; legacy linker removal planned next release |
| — | COFF linker: `.obj`/`.lib`/implibs, TLS, exports, entrypoint detection, `.drectve` handling | |
| — | SPIR-V linker rewritten | supports incremental compilation and external `.spv` objects |
| — | `zig objdump` | linker snapshot testing + COFF dev (`--all-headers`, `--exports[=sort]`, `--imports`, `--redact=[rva|va|ord|size|all]`, `-s/--snapshot`, ...) |
| — | `zig fmt --complexity` | prints token + AST-node counts per file and a total |

### Target support changes (0.17)

- `aarch64-openbsd` is now tested natively in Zig's CI.
- Dropped `powerpc-linux-gnueabi[hf]` (glibc only supports the "double-double" `long double`; `powerpc-linux-musleabi[hf]` remain) and `powerpc64-linux-gnu` (ELFv2 big-endian not supported by glibc). All PowerPC targets now enforce `-mabi=ieeelongdouble`.
- Baseline CPU model changed for several targets, e.g. `aarch64-haiku` -> `cortex_a55`, `m68k-*` -> `M68030`, `powerpc64-linux` -> `pwr8`, `s390x-*` -> `arch11`, `sparc64-*` -> `ultrasparc`, `xtensa-*` -> `esp32`.
- Native libc version detection in target queries now only happens when the triple actually uses native libc (ABI component omitted).

### Notable regressions (0.17.0)

- #37006: compiler-rt fails to compile for soft-float x86.
- `std.debug.simple_panic` fails to compile.
- #36986: weak zig libc symbols cannot be reliably overridden.
- #36444: maker/configurer split breaks response files for `std.Build.Step.Run`.
- #37050: SPIR-V backend regressions.

---

## musl 1.2.5

Zig 0.16.0 distributes musl 1.2.5 plus backported security fixes. Meanwhile, upstream has tagged 1.2.6. A future release of Zig will update to musl 1.2.6.

When targeting musl statically, many functions are now provided by zig libc rather than source files copied from musl. Specifically, 331 fewer musl C source files are now distributed with Zig, with 1,206 remaining. Therefore, if you encounter bugs with musl libc provided by Zig, please respect upstream by reporting them to Zig's issue tracker rather than musl's.

Note that Zig 0.16.0 is not believed to be affected by CVE-2026-40200 due to musl's `qsort` and `qsort_r` no longer being used.

## glibc 2.43

glibc version 2.43 is now available when cross-compiling.

## zig cc

`zig cc` and `zig c++` are now based on Clang 21.1.8.

9 bugs were fixed.

## Incremental Compilation

Incremental compilation [still has known bugs, including some miscompilations](https://ziglang.org/download/0.16.0/release-notes.html#This-Release-Contains-Bugs), and therefore remains disabled by default in 0.16.0. **Despite this, we still encourage enabling it.**

Usage:

```bash
zig build -fincremental --watch
```

Key improvements in 0.16.0:

1. "Over-analysis" eliminated — recompiles only what changed (milliseconds vs entire compiler rebuild)
2. No more incremental-vs-non-incremental dependency loop inconsistency
3. New ELF linker enabled by default for self-hosted backends
4. General stability greatly improved
5. LLVM Backend now supports incremental (speeds up bitcode building, not LLVM emit-object)

**Not production-ready.** Still experimental, with known miscompilations. The roadmap says future releases will continue focus on it.

---

## LLVM 21

Zig 0.16.0 ships LLVM/Clang/LLD 21.x. This affects:

- Codegen quality (better optimizations)
- Available intrinsics for SIMD and platform-specific code
- Cross-compilation target support
- `zig cc` / `zig c++` behavior (based on Clang 21)

## musl 1.2.5

See above.

## glibc 2.43

See above.

## Linux 6.19 Headers

Zig 0.16.0 ships Linux 6.19 headers for cross-compilation.

## macOS 26.4 Headers

Zig 0.16.0 ships macOS 26.4 headers for cross-compilation.

## MinGW-w64

Updated to latest MinGW-w64 for Windows cross-compilation.

## FreeBSD 15.0 libc

Zig 0.16.0 includes FreeBSD 15.0 libc for cross-compilation.

## WASI libc

Updated WASI libc.

## zig libc

Zig's own libc implementation continues to improve, replacing more musl source files.

## zig cc

`zig cc` and `zig c++` are now based on Clang 21.1.8. 9 bugs were fixed.

## Support dynamically-linked OpenBSD libc when cross-compiling

New in 0.16.0.
