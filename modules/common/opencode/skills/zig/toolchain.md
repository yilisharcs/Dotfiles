# Toolchain (musl, glibc, zig cc, Incremental Compilation)

Zig toolchain details for 0.16.0.

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
