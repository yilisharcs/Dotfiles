# Language Changes (0.14 / 0.15 / 0.16)

All language-level changes across versions 0.14 through 0.16. Each section starts with a concise upgrade checklist, followed by the full verbatim release notes.

---

## 0.14.0

### Upgrade Checklist (0.13 → 0.14)

| Change | Before | After |
|--------|--------|-------|
| `@setCold` | `@setCold(true)` | `@branchHint(.cold)` (must be first statement) |
| `@fence` | `@fence(.seq_cst)` | Use stronger atomics or new atomic variable |
| `@export` | `@export(foo, .{})` | `@export(&foo, .{})` (takes pointer) |
| `@setAlignStack` | `@setAlignStack(16)` | `callconv(.withStackAlign(.c, 16))` |
| `@typeInfo` fields | `.Int`, `.Struct`, `.Pointer` | `.int`, `.@"struct"`, `.pointer` (lowercase) |
| Pointer.Size | `.One` | `.one` |
| `sentinel` | `ptr.sentinel.?` | `ptr.sentinel().?` (use helper) |
| `default_value` | `field.default_value` | `field.default_value_ptr` |
| `addLibrary` | `addSharedLibrary`/`addStaticLibrary` | `addLibrary(.{ .linkage = .dynamic/.static })` |
| `root_source_file` | on Compile step | `root_module = b.createModule(...)` |

New features: `@branchHint`, `@FieldType`, `@splat` on arrays, decl literals, labeled switch.

### Labeled Switch

Zig 0.14.0 implements [an accepted proposal](https://github.com/ziglang/zig/issues/8220) which allows `switch` statements to be labeled, and to be targeted by `continue` statements. Such a `continue` statement takes a single operand (like `break` can to return a value from a block or loop); this value is treated as a replacement operand to the original `switch` expression. This construct is semantically equivalent to a `switch` statement inside of a loop, with a variable tracking the `switch` operand; for instance, the following tests are equivalent:

```zig
test "labeled switch" {
    foo: switch (@as(u8, 1)) {
        1 => continue :foo 2,
        2 => continue :foo 3,
        3 => return,
        4 => {},
        else => unreachable,
    }
    return error.Unexpected;
}

test "emulate labeled switch" {
    var op: u8 = 1;
    while (true) {
        switch (op) {
            1 => {
                op = 2;
                continue;
            },
            2 => {
                op = 3;
                continue;
            },
            3 => return,
            4 => {},
            else => unreachable,
        }
        break;
    }
    return error.Unexpected;
}
```

These constructs differ in two ways. The most obvious difference is in clarity: the new syntax form is clearer at times, for instance when implementing Finite State Automata where one can write `continue :fsa new_state` to represent a state transition. However, a key motivation for this language feature lies in its code generation. This is expanded on below.

It is also possible to `break` from a labeled `switch`. This simply terminates evaluation of the `switch` expression, causing it to result in the given value, as though the case body were a labeled block. As with blocks, an unlabeled `break` will never target a `switch` statement; only a `while` or `for` loop.

Unlike a typical `switch` statement, a labeled `switch` with one or more `continue`s targeting it is not implicitly evaluated at compile-time (this is similar to how loops behave). However, as with loops, compile-time evaluation can be forced by evaluating such an expression in a `comptime` context.

#### Code Generation Properties

This language construct is designed to generate code which aids the CPU in predicting branches between cases of the switch, allowing for increased performance in hot loops, particularly those dispatching instructions, evaluating FSAs, or performing similar case-based evaluations. To achieve this, the generated code may be different to what one would intuitively expect.

If the operand to `continue` is comptime-known, then it can be translated to an unconditional branch to the relevant case. Such a branch is perfectly predicted, and hence typically very fast to execute.

If the operand is runtime-known, then each `continue` can become a separate conditional branch (ideally via a shared jump table) back to the same set of potential branch targets. The advantage of this pattern is that it aids the CPU's branch predictor by providing different branch instructions which can be associated with distinct prediction data. For instance, when evaluating an FSA, if case `a` is very likely to be followed by case `b`, while case `c` is very likely to be followed by case `d`, then the branch predictor can use the direct jumps between `switch` cases to predict the control flow more accurately, whereas a loop-based lowering causes the state dispatches to be "collapsed" into a single indirect branch or similar, hindering branch prediction.

This lowering can inflate code size compared to a simple "switch in a loop" lowering, and any Zig implementation is, of course, free to lower this syntax however it wishes provided the language semantics are obeyed. However, the official ZSF compiler implementation will attempt to match the lowering described above, particularly in the `ReleaseFast` build mode.

[Updating Zig's tokenizer to take advantage of this feature resulted in a 13% performance boost](https://github.com/ziglang/zig/pull/21367).

### Decl Literals

Zig 0.14.0 extends the "enum literal" syntax (`.foo`) to provide a new feature, known as "decl literals". Now, an enum literal `.foo` doesn't necessarily refer to an enum variant, but, using [Result Location Semantics](https://ziglang.org/documentation/0.14.0/#Result-Location-Semantics), can also refer to any declaration on the target type. For instance, consider the following example:

```zig
const S = struct {
    x: u32,
    const default: S = .{ .x = 123 };
};
test "decl literal" {
    const val: S = .default;
    try std.testing.expectEqual(123, val.x);
}
const std = @import("std");
```

Since the initialization expression of `val` has a result type of `S`, the initialization is effectively equivalent to `S.default`. This can be particularly useful when initializing struct fields to avoid having to specify the type again:

```zig
const S = struct {
    x: u32,
    y: u32,
    const default: S = .{ .x = 1, .y = 2 };
    const other: S = .{ .x = 3, .y = 4 };
};
const Wrapper = struct {
    val: S = .default,
};
test "decl literal initializing struct field" {
    const a: Wrapper = .{};
    try std.testing.expectEqual(1, a.val.x);
    try std.testing.expectEqual(2, a.val.y);
    const b: Wrapper = .{ .val = .other };
    try std.testing.expectEqual(3, b.val.x);
    try std.testing.expectEqual(4, b.val.y);
}
const std = @import("std");
```

It can also help in avoiding [Faulty Default Field Values](https://ziglang.org/documentation/0.14.0/#Faulty-Default-Field-Values), like in the following example:

```zig
/// `ptr` points to a `[len]u32`.
pub const BufferA = extern struct { ptr: ?[*]u32 = null, len: usize = 0 };
// The default values given above are trying to make the buffer default to "empty".
var empty_buf_a: BufferA = .{};
// However, they violate the guidance given in the language reference, because you can write this:
var bad_buf_a: BufferA = .{ .len = 10 };
// That's not safe, because the `null` and `0` defaults are "tied together". Decl literals make it
// convenient to represent this case correctly:

/// `ptr` points to a `[len]u32`.
pub const BufferB = extern struct {
    ptr: ?[*]u32,
    len: usize,
    pub const empty: BufferB = .{ .ptr = null, .len = 0 };
};
// We can still easily create an empty buffer:
var empty_buf_b: BufferB = .empty;
// ...but the language no longer hides incorrect field overrides from us!
// If we want to override a field, we'd have to specify both, making the error obvious:
var bad_buf_b: BufferB = .{ .ptr = null, .len = 10 }; // clearly wrong!
```

Many existing uses of field default values may be more appropriately handled by a declaration named `default` or `empty` or similar, to ensure data invariants are not violated by overriding single fields.

Decl literals also support function calls, like this:

```zig
const S = struct {
    x: u32,
    y: u32,
    fn init(val: u32) S {
        return .{ .x = val + 1, .y = val + 2 };
    }
};
test "call decl literal" {
    const a: S = .init(100);
    try std.testing.expectEqual(101, a.x);
    try std.testing.expectEqual(102, a.y);
}
const std = @import("std");
```

As before, this syntax can be particularly useful when initializing struct fields. It also supports calling functions which return error unions via `try`. The following example uses these in combination to initialize a thin wrapper around an `ArrayListUnmanaged`:

```zig
const Buffer = struct {
    data: std.ArrayListUnmanaged(u32),
    fn initCapacity(allocator: std.mem.Allocator, capacity: usize) !Buffer {
        return .{ .data = try .initCapacity(allocator, capacity) };
    }
};
test "initialize Buffer with decl literal" {
    var b: Buffer = try .initCapacity(std.testing.allocator, 5);
    defer b.data.deinit(std.testing.allocator);
    b.data.appendAssumeCapacity(123);
    try std.testing.expectEqual(1, b.data.items.len);
    try std.testing.expectEqual(123, b.data.items[0]);
}
const std = @import("std");
```

The introduction of decl literals comes with some standard library changes. In particular, unmanaged containers, including `ArrayListUnmanaged` and `HashMapUnmanaged`, should no longer be default-initialized with `.{}`, because the default field values here violate the guidance discussed above. Instead, they should be initialized using their `empty` declaration, which can be conveniently accessed via decl literals:

```zig
const Buffer = struct {
    foo: std.ArrayListUnmanaged(u32) = .empty,
};
test "default initialize Buffer" {
    var b: Buffer = .{};
    defer b.foo.deinit(std.testing.allocator);
    try b.foo.append(std.testing.allocator, 123);
    try std.testing.expectEqual(1, b.foo.items.len);
    try std.testing.expectEqual(123, b.foo.items[0]);
}
const std = @import("std");
```

Similarly, `std.heap.GeneralPurposeAllocator` should now be initialized with its `.init` declaration.

The deprecated default field values for these data structures will be removed in the next release cycle.

#### Fields and Declarations Cannot Share Names

Zig 0.14.0 introduces a restriction that container types (`struct`, `union`, `enum` and `opaque`) cannot have fields and declarations (`const`/`var`/`fn`) with the same names. This restriction has been added to deal with the problem that whether `MyEnum.foo` looks up a declaration or an enum field is ambiguous (a problem amplified by Decl Literals). Generally, this can be avoided by following the standard naming conventions:

```zig
// BEFORE
const Foo = struct {
    Thing: Thing,
    const Thing = struct {
        Data: u32,
    };
};

// AFTER
const Foo = struct {
    thing: Thing,
    const Thing = struct {
        data: u32,
    };
};
```

One upside of this restriction is that documentation comments can now unambiguously refer to field names, thus enabling such references to be hyperlinks.

### @splat Supports Arrays

Zig 0.14.0 expands the `@splat` builtin to apply not only to vectors, but to arrays. This is useful when default-initializing an array to a constant value. For instance, in conjunction with Decl Literals, we can elegantly initialize an array of "color" values:

```zig
const Rgba = struct {
    r: u8,
    b: u8,
    g: u8,
    a: u8,
    pub const black: Rgba = .{ .r = 0, .g = 0, .b = 0, .a = 255 };
};
var pixels: [width][height]Rgba = @splat(@splat(.black));
```

The operand may be comptime-known or runtime-known. In addition, this builtin can also be used to initialize sentinel-terminated arrays.

```zig
const std = @import("std");
const assert = std.debug.assert;
const expect = std.testing.expect;
test "initialize sentinel-terminated array" {
    // the sentinel does not need to match the value
    const arr: [2:0]u8 = @splat(10);
    try expect(arr[0] == 10);
    try expect(arr[1] == 10);
    try expect(arr[2] == 0);
}
test "initialize runtime array" {
    var runtime_known: u8 = undefined;
    runtime_known = 123;
    // the operand can be runtime-known, giving a runtime-known array
    const arr: [2]u8 = @splat(runtime_known);
    try expect(arr[0] == 123);
    try expect(arr[1] == 123);
}
test "initialize zero-length sentinel-terminated array" {
    var runtime_known: u8 = undefined;
    runtime_known = 123;
    const arr: [0:10]u8 = @splat(runtime_known);
    // the operand was runtime-known, but since the array length was zero, the result is comptime-known
    comptime assert(arr[0] == 10);
}
```

### Global Variables can be Initialized with Address of Each Other

This works now:

```zig
const std = @import("std");
const expect = std.testing.expect;

const Node = struct {
    next: *const Node,
};

const a: Node = .{ .next = &b };
const b: Node = .{ .next = &a };

test "example" {
    try expect(a.next == &b);
    try expect(b.next == &a);
}
```

### @export Operand is Now a Pointer

This release of Zig simplifies the `@export` builtin. In previous versions of Zig, this builtin's first operand syntactically appeared to be the *value* which was to be exported, which was restricted to an identifier or field access of a local variable or container-level declaration. This system was unnecessarily restrictive, and moreover, syntactically confusing and inconsistent; it is reasonable to export constant comptime-known values, and this usage implied that the *value* was somehow being exported, whereas in reality its *address* was the relevant piece of information. To resolve this, `@export` has a new usage which closely mirrors that of `@extern`; its first operand is a *pointer*, which points to the data being exported. In most cases, solving this will just consist of adding a `&` operator:

```zig
// BEFORE
const foo: u32 = 123;
test "@export" {
    @export(foo, .{ .name = "bar" });
}

// AFTER
const foo: u32 = 123;
test "@export" {
    @export(&foo, .{ .name = "bar" });
}
```

### New @branchHint Builtin, Replacing @setCold

In high-performance code, it is sometimes desirable to hint to the optimizer which branch of a condition is more likely; this can allow more efficient machine code to be generated. Some languages offer this through a "likely" annotation on a boolean condition; for instance, GCC and Clang implement the `__builtin_expect` function. Zig 0.14.0 introduces a mechanism to communicate this information: the new `@branchHint(comptime hint: std.builtin.BranchHint)` builtin. This builtin, rather than modifying a condition, appears as the first statement in a block to communicate whether control flow is likely to reach the block in question:

```zig
fn warnIf(cond: bool, message: []const u8) void {
    if (cond) {
        @branchHint(.unlikely); // we expect warnings to *not* happen most of the time!
        std.log.warn("{s}", message);
    }
}
const std = @import("std");
```

The `BranchHint` type is as follows:

```zig
pub const BranchHint = enum(u3) {
    /// Equivalent to no hint given.
    none,
    /// This branch of control flow is more likely to be reached than its peers.
    /// The optimizer should optimize for reaching it.
    likely,
    /// This branch of control flow is less likely to be reached than its peers.
    /// The optimizer should optimize for not reaching it.
    unlikely,
    /// This branch of control flow is unlikely to *ever* be reached.
    /// The optimizer may place it in a different page of memory to optimize other branches.
    cold,
    /// It is difficult to predict whether this branch of control flow will be reached.
    /// The optimizer should avoid branching behavior with expensive mispredictions.
    unpredictable,
};
```

As well as being the first statement of a block behind a condition, `@branchHint` is also permitted as the first statement of any function. The expectation is that the optimizer may propagate likelihood information to branches containing these calls; for instance, if a given branch of control flow always calls a function which is marked `@branchHint(.unlikely)`, then the optimizer may assume that the branch in question is unlikely to be reached.

This feature combined with the existence of the `.cold` variant of `BranchHint` means that the old `@setCold` builtin, which could be used to communicate that a function is unlikely to ever be called, becomes redundant. Therefore, `@setCold` has been removed in favor of `@branchHint`. In most cases, the migration will be very simple; just replace `@setCold(true)` with `@branchHint(.cold)`:

```zig
// BEFORE
fn foo() void {
    @setCold(true);
    // ...
}

// AFTER
fn foo() void {
    @branchHint(.cold);
    // ...
}
```

However, remember that `@branchHint` must be the *first statement* in the enclosing block, which in this case is the function. This restriction did not exist for `@setCold`, so non-trivial usages may require small refactors:

```zig
// BEFORE
fn foo(comptime x: u8) void {
    if (x == 0) {
        @setCold(true);
    }
    // ...
}

// AFTER
fn foo(comptime x: u8) void {
    @branchHint(if (x == 0) .cold else .none);
    // ...
}
```

### Removal of @fence

In Zig 0.14, `@fence` has been removed. `@fence` was provided to be consistent with the C11 memory model, however, it complicates semantics by modifying the memory orderings of all [previous](https://en.cppreference.com/w/cpp/atomic/atomic_thread_fence#Atomic-fence_synchronization) and [future](https://en.cppreference.com/w/cpp/atomic/atomic_thread_fence#Fence-atomic-synchronization) atomic operations. This creates unforeseen constraints that are [hard to model in a sanitizer](https://github.com/google/sanitizers/issues/1415). Fences can be substituted by either upgrading atomic memory orderings or adding new atomic operations.

The most common use cases for `@fence` can be replaced by utilizing stronger memory orderings or by introducing a new atomic variable.

#### StoreLoad Barriers

The most common use case is `@fence(.seq_cst)`. This is primarily used to ensure a consistent order between multiple operations on different atomic variables.

For example:

```
thread-1:                     thread-2:
store X         // A          store Y          // C
fence(seq_cst)  // F1         fence(seq_cst)   // F2
load  Y         // B          load  X          // D
```

The goal is to ensure either `load X` (D) sees `store X` (A), or `load Y` (B) sees `store Y` (C). The pair of Sequentially Consistent fences guarantees this via [two](https://en.cppreference.com/w/cpp/atomic/memory_order#Strongly_happens-before:~:text=for%20every%20pair%20of%20atomic%20operations%20A%20and%20B%20on%20an%20object%20M%2C%20where%20A%20is%20coherence-ordered-before%20B%3A) [invariance](https://en.cppreference.com/w/cpp/atomic/memory_order#Strongly_happens-before:~:text=if%20a%20memory_order_seq_cst%20fence%20X%20happens-before%20A%2C%20and%20B%20happens-before%20a%20memory_order_seq_cst%20fence%20Y%2C%20then%20X%20precedes%20Y%20in%20S.).

Now that `@fence` is removed, there are other ways of achieving this relationship:

-   Making all related stores and loads (A, B, C, and D) `SeqCst`, including them all in the total order.
-   Making a store (A/C) `Acquire` and its matching load (D/B) `Release`. Semantically, this would mean upgrading them to read-modify-write operations, which could be such ordering. Loads can be replaced with a non-mutating RMW, i.e. `fetchAdd(0)` or `fetchOr(0)`.

Optimizers like LLVM may reduce this into a `@fence(.seq_cst) + load` internally.

#### Conditional Barriers

Another use case for fences is conditionally creating a *synchronizes-with* relationship with previous or future atomic operations, using `Acquire` or `Release` respectively. A simple example of this in the real world is an atomic reference counter:

```zig
fn inc(counter: *RefCounter) void {
  _ = counter.rc.fetchAdd(1, .monotonic);
}

fn dec(counter: *RefCounter) void {
  if (counter.rc.fetchSub(1, .release) == 1) {
      @fence(.acquire);
      counter.deinit();
  }
}
```

The load in the `fetchSub(1)` only needs to be `Acquire` for the last ref-count decrement to ensure previous decrements *happen-before* the `deinit()`. The `@fence(.acquire)` here creates this relationship using the load part of the `fetchSub(1)`.

Without `@fence`, there are two approaches here:

1.  Unconditionally strengthen the desired atomic operations with the fence's ordering.

    ```zig
    if (counter.rc.fetchSub(1, .acq_rel) == 1) {
    ```

2.  Conditionally duplicate the desired store or load with the fence's ordering.

    ```zig
    if (counter.rc.fetchSub(1, .release) == 1) {
        _ = counter.rc.load(.acquire);
    ```

The `Acquire` will *synchronize-with* the longest release-sequence in `rc`'s modification order, making all previous decrements *happen-before* the `deinit()`.

#### Synchronize External Operations

The least common usage of `@fence` is providing additional synchronization to atomic operations the programmer has no control over (i.e. external function calls). Using a `@fence` in this situation relies on the "hidden" functions having atomic operations with undesirably weak orderings.

Ideally, the "hidden" functions would be accessible to the user and they could simply increase the order in the source code. But if this isn't possible, a last resort is introducing an atomic variable to simulate the fence's barriers. For example:

```
thread-1:                    thread-2:
  queue.push()                e = signal.listen()
  fence(seq_cst)             fence(seq_cst)
  signal.notify()             if queue.empty(): e.wait()
```

```
thread-1:                    thread-2:
  queue.push()                e = signal.listen()
  fetchAdd(0, .seq_cst)       fetchAdd(0, .seq_cst)
  signal.notify()             if queue.empty(): e.wait()
```

### Packed Struct Equality

Packed structs can now be equated directly, without a `@bitCast` to the underlying integer type.

```zig
const std = @import("std");
const expect = std.testing.expect;

test "packed struct equality" {
    const S = packed struct {
        a: u4,
        b: u4,
    };
    const x: S = .{ .a = 1, .b = 2 };
    const y: S = .{ .b = 2, .a = 1 };
    try expect(x == y);
}
```

### Packed Struct Atomics

Packed structs can now be used in atomic operations, without a `@bitCast` to the underlying integer type.

```zig
const std = @import("std");
const expect = std.testing.expect;

test "packed struct atomics" {
    const S = packed struct {
        a: u4,
        b: u4,
    };
    var x: S = .{ .a = 1, .b = 2 };
    const y: S = .{ .a = 3, .b = 4 };
    const prev = @atomicRmw(S, &x, .Xchg, y, .seq_cst);
    try expect(prev.b == 2);
    try expect(x.b == 4);
}
```

### @ptrCast Allows Changing Slice Length

[#22706](https://github.com/ziglang/zig/pull/22706)

### Remove Anonymous Struct Types, Unify Tuples

This change reworks how anonymous struct literals and tuples work.

Previously, an untyped anonymous struct literal (e.g. `const x = .{ .a = 123 }`) was given an "anonymous struct type", which is a special kind of struct which coerces using structural equivalence. This mechanism was a holdover from before we used [Result Location Semantics](https://ziglang.org/documentation/0.14.0/#Result-Location-Semantics) as the primary mechanism of type inference. This change changes the language so that the type assigned here is a "normal" struct type. It uses a form of equivalence based on the AST node and the type's structure, much like a reified (`@Type`) type.

Additionally, tuples have been simplified. The distinction between "simple" and "complex" tuple types is eliminated. All tuples, even those explicitly declared using `struct { ... }` syntax, use structural equivalence, and do not undergo staged type resolution. Tuples are very restricted: they cannot have non-`auto` layouts, cannot have aligned fields, and cannot have default values with the exception of `comptime` fields. Tuples currently do not have optimized layout, but this can be changed in the future.

This change simplifies the language, and fixes some problematic coercions through pointers which led to unintuitive behavior.

### Calling Convention Enhancements and @setAlignStack Replaced

Zig allows setting the calling convention of a function with the `callconv(...)` annotation, where the value in parentheses is of type `std.builtin.CallingConvention`. In previous versions of Zig, this type was a simple `enum` listing a small number of common calling conventions, such as `.Stdcall` for x86 and `.AAPCS` for ARM. The `.C` variant referred to the default C calling convention for the target.

Zig 0.14.0 changes `CallingConvention` to be far more exhaustive: it now contains every major calling convention for every target currently supported by Zig. Variants have names like `.x86_64_sysv`, `.arm_aapcs`, and `.riscv64_interrupt`. In addition, instead of an enum, `CallingConvention` is now a tagged union; this allows *options* to be specified on a calling convention.

Most available calling conventions have a payload of `std.builtin.CallingConvention.CommonOptions`, which allows overriding the expected alignment of the stack when the function is called:

```zig
/// Options shared across most calling conventions.
pub const CommonOptions = struct {
    /// The boundary the stack is aligned to when the function is called.
    /// `null` means the default for this calling convention.
    incoming_stack_alignment: ?u64 = null,
};
```

This is useful when, for instance, interacting with C code compiled with the `-mpreferred-stack-boundary` GCC flag.

A small number of calling conventions have more complex options, for instance:

```zig
/// Options for x86 calling conventions which support the regparm attribute to pass some
/// arguments in registers.
pub const X86RegparmOptions = struct {
    /// The boundary the stack is aligned to when the function is called.
    /// `null` means the default for this calling convention.
    incoming_stack_alignment: ?u64 = null,
    /// The number of arguments to pass in registers before passing the remaining arguments
    /// according to the calling convention.
    /// Equivalent to `__attribute__((regparm(x)))` in Clang and GCC.
    register_params: u2 = 0,
};
```

**The default C calling convention is no longer represented by a special tag.** Instead, `CallingConvention` contains a declaration named `c` which is defined as follows:

```zig
/// This is an alias for the default C calling convention for this target.
/// Functions marked as `extern` or `export` are given this calling convention by default.
pub const c = builtin.target.cCallingConvention().?;
```

When combined with Decl Literals, this permits writing `callconv(.c)` to specify this calling convention.

Zig 0.14.0 includes declarations named `Unspecified`, `C`, `Naked`, `Stdcall`, etc, to allow existing usages of `callconv` to continue working thanks to Decl Literals. These declarations are deprecated, and will be removed in a future version of Zig.

As previously mentioned, most calling conventions have an `incoming_stack_alignment` options to specify the byte boundary the stack will be aligned to when a function is called, which can be used to interop with code using stack alignments lower than the ABI mandates. Previously, the `@setAlignStack` builtin could be used for this use case; however, its behavior was somewhat ill-defined, and applying it to this use case required knowing the expected stack alignment for your ABI. As such, the `@setAlignStack` builtin has been removed. Instead, users should annotate on their `callconv` the expected stack alignment, allowing the optimizer to realign if necessary. This also allows the optimizer to *avoid* unnecessarily realigning the stack when such a function is called. For convenience, `CallingConvention` has a `withStackAlign` function which can be used to change the incoming stack alignment. Upgrading is generally fairly simple:

```zig
// BEFORE
// This function will be called by C code which uses a 4-byte aligned stack.
export fn foo() void {
    // I know that my target's ABI expects a 16-byte aligned stack.
    @setAlignStack(16);
    // ...
}

// AFTER
// This function will be called by C code which uses a 4-byte aligned stack.
// We simply specify that on the `callconv`.
export fn foo() callconv(.withStackAlign(.c, 4)) void {
    // ...
}
```

### std.builtin.Type Fields Renamed

In most cases, Zig's standard library follows [naming conventions](https://ziglang.org/documentation/0.14.0/#Names). Zig 0.14.0 updates the fields of the `std.builtin.Type` tagged union to follow these conventions by lowercasing them:

```zig
pub const Type = union(enum) {
    type: void,
    void: void,
    bool: void,
    noreturn: void,
    int: Int,
    float: Float,
    pointer: Pointer,
    array: Array,
    @"struct": Struct,
    comptime_float: void,
    comptime_int: void,
    undefined: void,
    null: void,
    optional: Optional,
    error_union: ErrorUnion,
    error_set: ErrorSet,
    @"enum": Enum,
    @"union": Union,
    @"fn": Fn,
    @"opaque": Opaque,
    frame: Frame,
    @"anyframe": AnyFrame,
    vector: Vector,
    enum_literal: void,
    // ...
};
```

Note that this requires using "quoted identifier" syntax for `@"struct"`, `@"union"`, `@"enum"`, `@"opaque"`, and `@"anyframe"`, because these identifiers are also keywords.

This change is widely breaking, but upgrading is simple:

```zig
// BEFORE
test "switch on type info" {
    const x = switch (@typeInfo(u8)) {
        .Int => 0,
        .ComptimeInt => 1,
        .Struct => 2,
        else => 3,
    };
    try std.testing.expect(0, x);
}
test "reify type" {
    const U8 = @Type(.{ .Int = .{
        .signedness = .unsigned,
        .bits = 8,
    } });
    const S = @Type(.{ .Struct = .{
        .layout = .auto,
        .fields = &.{},
        .decls = &.{},
        .is_tuple = false,
    } });
    try std.testing.expect(U8 == u8);
    try std.testing.expect(@typeInfo(S) == .Struct);
}

// AFTER
test "switch on type info" {
    const x = switch (@typeInfo(u8)) {
        .int => 0,
        .comptime_int => 1,
        .@"struct" => 2,
        else => 3,
    };
    try std.testing.expect(0, x);
}
test "reify type" {
    const U8 = @Type(.{ .int = .{
        .signedness = .unsigned,
        .bits = 8,
    } });
    const S = @Type(.{ .@"struct" = .{
        .layout = .auto,
        .fields = &.{},
        .decls = &.{},
        .is_tuple = false,
    } });
    try std.testing.expect(U8 == u8);
    try std.testing.expect(@typeInfo(S) == .@"struct");
}
```

### std.builtin.Type.Pointer.Size Field Renamed

The fields of the `std.builtin.Type.Pointer.Size` enum have been renamed to lowercase, just like the fields of `std.builtin.Type`. Again, this is a breaking change, but one which is very easily updated to:

```zig
// BEFORE
test "pointer type info" {
    comptime assert(@typeInfo(*u8).pointer.size == .One);
}
test "reify pointer" {
    comptime assert(@Type(.{ .pointer = .{
        .size = .One,
        .is_const = false,
        .is_volatile = false,
        .alignment = 0,
        .address_space = .generic,
        .child = u8,
        .is_allowzero = false,
        .sentinel_ptr = null,
    } }) == *u8);
}

// AFTER
test "pointer type info" {
    comptime assert(@typeInfo(*u8).pointer.size == .one);
}
test "reify pointer" {
    comptime assert(@Type(.{ .pointer = .{
        .size = .one,
        .is_const = false,
        .is_volatile = false,
        .alignment = 0,
        .address_space = .generic,
        .child = u8,
        .is_allowzero = false,
        .sentinel_ptr = null,
    } }) == *u8);
}
```

### Simplify Usage Of ?*const anyopaque In std.builtin.Type

The `default_value` field on `std.builtin.Type.StructField`, and the `sentinel` fields on `std.builtin.Type.Array` and `std.builtin.Type.Pointer`, have to use `?*const anyopaque`, because Zig does not provide a way for the struct's type to depend on a field's value. This isn't a problem; however, it isn't particularly ergonomic at times.

Zig 0.14.0 renames these fields to `default_value_ptr` and `sentinel_ptr` respectively, and adds helper methods `defaultValue()` and `sentinel()` to load the value with the correct type as an optional.

```zig
// BEFORE
test "get pointer sentinel" {
    const T = [:0]const u8;
    const ptr = @typeInfo(T).pointer;
    const s = @as(*const ptr.child, @ptrCast(@alignCast(ptr.sentinel.?))).*;
    comptime assert(s == 0);
}
test "reify array" {
    comptime assert(@Type(.{ .array = .{ .len = 1, .child = u8, .sentinel = null } }) == [1]u8);
    comptime assert(@Type(.{ .array = .{ .len = 1, .child = u8, .sentinel = &@as(u8, 0) } }) == [1:0]u8);
}

// AFTER
test "get pointer sentinel" {
    const T = [:0]const u8;
    const ptr = @typeInfo(T).pointer;
    const s = ptr.sentinel().?;
    comptime assert(s == 0);
}
test "reify array" {
    comptime assert(@Type(.{ .array = .{ .len = 1, .child = u8, .sentinel_ptr = null } }) == [1]u8);
    comptime assert(@Type(.{ .array = .{ .len = 1, .child = u8, .sentinel_ptr = &@as(u8, 0) } }) == [1:0]u8);
}
```

### Non-Scalar Sentinel Types Disallowed

Sentinel values are now forbidden from being aggregate types. In other words, only types that support the `==` operator are allowed.

```zig
export fn foo() void {
    const S = struct { a: u32 };
    var arr = [_]S{ .{ .a = 1 }, .{ .a = 2 } };
    const s = arr[0..1 :.{ .a = 1 }];
    _ = s;
}
```

```
error: non-scalar sentinel type 'foo.S'
```

### @FieldType builtin

Zig 0.14.0 introduces the `@FieldType` builtin. This serves the same purpose as the `std.meta.FieldType` function: given a type and the name of one of its fields, it returns the type of that field.

```zig
const assert = @import("std").debug.assert;
test "struct @FieldType" {
    const S = struct { a: u32, b: f64 };
    comptime assert(@FieldType(S, "a") == u32);
    comptime assert(@FieldType(S, "b") == f64);
}
test "union @FieldType" {
    const U = union { a: u32, b: f64 };
    comptime assert(@FieldType(U, "a") == u32);
    comptime assert(@FieldType(U, "b") == f64);
}
test "tagged union @FieldType" {
    const U = union(enum) { a: u32, b: f64 };
    comptime assert(@FieldType(U, "a") == u32);
    comptime assert(@FieldType(U, "b") == f64);
}
```

### @src Gains Module Field

`std.builtin.SourceLocation`:

```zig
pub const SourceLocation = struct {
    /// The name chosen when compiling. Not a file path.
    module: [:0]const u8,
    /// Relative to the root directory of its module.
    file: [:0]const u8,
    fn_name: [:0]const u8,
    line: u32,
    column: u32,
};
```

The `module` field is new.

### @memcpy Rules Adjusted

-   The langspec definition of `@memcpy` has been changed so that the source and destination element types must be in-memory coercible, allowing all such calls to be raw copying operations, not actually applying any coercions.
-   Implement aliasing check for comptime `@memcpy`; a compile error will now be emitted if the arguments alias.
-   Implement more efficient comptime `@memcpy` by loading and storing a whole array at once, similar to how `@memset` is implemented.

This is a breaking change because while the old coercion behavior triggered an "unimplemented" compile error at runtime, it did actually work at comptime.

### Unsafe In-Memory Coercions Disallowed

[#22243](https://github.com/ziglang/zig/pull/22243)

### callconv, align, addrspace, linksection Cannot Reference Function Arguments

[#22264](https://github.com/ziglang/zig/pull/22264)

### Branch Quota Rules Adjusted for Function Calls

[#22414](https://github.com/ziglang/zig/pull/22414)

---

## 0.15.0

### Upgrade Checklist (0.14 → 0.15)

| Change | Before | After |
|--------|--------|-------|
| `usingnamespace` | `pub usingnamespace @import(...)` | Zero-bit fields + `@fieldParentPtr`, or inline |
| `async`/`await` | `async fn`, `await` | Removed from language |
| Inline asm clobbers | `: "rcx", "r11"` | `: .{ .rcx = true, .r11 = true }` |
| Format methods | `format(self, fmt, options, writer)` | `format(self, writer: *std.Io.Writer)` |
| Format specifier | `{}` for custom types | `{f}` to call format method |
| Linked lists | `std.DoublyLinkedList(T).Node` | `struct { node: std.DoublyLinkedList.Node, data: T }` |
| ArrayList | `std.ArrayList` (managed) | `std.ArrayList` (unmanaged, allocator per call) |
| BoundedArray | `std.BoundedArray(T, N)` | `std.ArrayList(T).initBuffer(&buf)` |
| I/O types | `std.io` (lowercase) | `std.Io` (capital) |
| Writer types | `GenericWriter`, `AnyWriter` | `std.Io.Writer` (concrete) |
| Reader types | `GenericReader`, `AnyReader` | `std.Io.Reader` (concrete) |
| `BufferedWriter` | `std.io.bufferedWriter(w)` | Caller-provided buffer + `std.Io.Writer` |
| `FixedBufferStream` | `std.io.fixedBufferStream(buf)` | `std.Io.Writer.fixed(buf)` / `std.Io.Reader.fixed(data)` |
| `root_source_file` | on Compile step | Fully removed → `root_module` |

Major: Writergate (I/O rewrite). `std.io` → `std.Io`.

### usingnamespace Removed

This keyword added distance between the "expected" definition of a declaration and its "actual" definition. Without it, discovering a declaration's definition site is incredibly simple: find the definition of the namespace you are looking in, then find the identifier being defined within that type declaration. With `usingnamespace`, however, the programmer can be led on a wild goose chase through different types and files.

Not only does this harm readability for humans, but it is also problematic for tooling; for instance, Autodoc cannot reasonably see through non-trivial uses of `usingnamespace` (try looking for dl_iterate_phdr under std.c in the 0.14.1 documentation).

By eliminating this feature, all identifiers can be trivially traced back to where they are imported - by humans and machines alike.

Additionally, `usingnamespace` encourages poor namespacing. When declarations are stored in a separate file, that typically means they share something in common which is not shared with the contents of another file. As such, it is likely a very reasonable choice to actually expose the contents of that file via a separate namespace, rather than including them in a more general parent namespace. To put it shortly: **namespacing is good, actually**.

Finally, removal of this feature makes Incremental Compilation fundamentally simpler.

#### Use Case: Conditional Inclusion

`usingnamespace` can be used to conditionally include a declaration as follows:

```zig
pub usingnamespace if (have_foo) struct {
    pub const foo = 123;
} else struct {};
```

The solution here is pretty simple: usually, you can just include the declaration unconditionally. Zig's lazy compilation means that it will not be analyzed unless referenced, so there are no problems!

```zig
pub const foo = 123;
```

Occasionally, this is not a good solution, as it lacks safety. Perhaps analyzing `foo` will always work, but will only give a meaningful result if `have_foo` is true, and it would be a bug to use it in any other case. In such cases, the declaration can be conditionally made a compile error:

```zig
pub const foo = if (have_foo)
    123
else
    @compileError("foo not supported on this target");
```

This does break feature detection with `@hasDecl`. If feature detection is needed, a better approach—less prone to typos and bitrotting—is to conditionally initialize the declaration to some "sentinel" value which can be detected. A good choice is often the `void` value `{}`:

```zig
const something = struct {
    // In this example, `foo` is supported but `bar` is not.
    const have_foo = true;
    const have_bar = false;
    pub const foo = if (have_foo) 123 else {};
    pub const bar = if (have_bar) undefined else {};
};

test "use foo if supported" {
    if (@TypeOf(something.foo) == void) return error.SkipZigTest; // unsupported
    try expect(something.foo == 123);
}

test "use bar if supported" {
    if (@TypeOf(something.bar) == void) return error.SkipZigTest; // unsupported
    try expect(something.bar == 456);
}

const expect = @import("std").testing.expect;
```

#### Use Case: Implementation Switching

A close cousin of conditional inclusion, `usingnamespace` can also be used to select from multiple implementations of a declaration at comptime:

```zig
pub usingnamespace switch (target) {
    .windows => struct {
        pub const target_name = "windows";
        pub fn init() T {
            // ...
        }
    },
    else => struct {
        pub const target_name = "something good";
        pub fn init() T {
            // ...
        }
    },
};
```

The alternative to this is simpler and results in better code: make the definition itself a conditional.

```zig
pub const target_name = switch (target) {
    .windows => "windows",
    else => "something good",
};
pub const init = switch (target) {
    .windows => initWindows,
    else => initOther,
};
fn initWindows() T {
    // ...
}
fn initOther() T {
    // ...
}
```

#### Use Case: Mixins

A very common use case for `usingnamespace` in the wild was to implement mixins:

```zig
/// Mixin to provide methods to manipulate the `count` field.
pub fn CounterMixin(comptime T: type) type {
    return struct {
        pub fn incrementCounter(x: *T) void {
            x.count += 1;
        }
        pub fn resetCounter(x: *T) void {
            x.count = 0;
        }
    };
}

pub const Foo = struct {
    count: u32 = 0,
    pub usingnamespace CounterMixin(Foo);
};
```

The alternative for this is based on the key observation made above: **namespacing is good, actually**. The same logic can be applied to mixins. The word "counter" in `incrementCounter` and `resetCounter` already kind of *is* a namespace in spirit—it's like how we used to have `std.ChildProcess` but have since renamed it to `std.process.Child`. The same idea can be applied here: what if instead of `foo.incrementCounter()`, you called `foo.counter.increment()`?

This can be achieved using a zero-bit field and `@fieldParentPtr`. Here is the above example ported to use this mechanism:

```zig
/// Mixin to provide methods to manipulate the `count` field.
pub fn CounterMixin(comptime T: type) type {
    return struct {
        pub fn increment(m: *@This()) void {
            const x: *T = @alignCast(@fieldParentPtr("counter", m));
            x.count += 1;
        }
        pub fn reset(m: *@This()) void {
            const x: *T = @alignCast(@fieldParentPtr("counter", m));
            x.count = 0;
        }
    };
}

pub const Foo = struct {
    count: u32 = 0,
    counter: CounterMixin(Foo) = .{},
};
```

This code works just like before, except the usage is `foo.counter.increment()` rather than `foo.incrementCounter()`. We have applied namespacing to our mixin using zero-bit fields. In fact, this mechanism is *more* useful, because it allows you to also include fields! For instance, in this case, we could move the `count` field to `CounterMixin`. In this case that actually wouldn't be a mixin at all, since that field is the only state `CounterMixin` uses—in fact, this is a demonstration that the need for mixins is relatively rare. But in cases where a mixin *is* appropriate, yet requires additional state, this approach allows using the mixin without needing to duplicate fields at each mixin site.

### async and await keywords removed

Also removed `@frameSize`.

While `suspend`, `resume`, and other machinery might remain depending on [Proposal: stackless coroutines as low-level primitives](https://github.com/ziglang/zig/issues/23446), it is settled that there will not be async/await keywords in the language. Instead, they will be in the Standard Library as part of the Io Interface.

### switch on non-exhaustive enums

Switching on non-exhaustive enums now allows mixing explicit tags with the `_` prong (which represents all the unnamed values):

```zig
switch (enum_val) {
    .special_case_1 => foo(),
    .special_case_2 => bar(),
    _, .special_case_3 => baz(),
}
```

Additionally, it is now allowed to have both `else` and `_`:

```zig
const Enum = enum(u32) {
    A = 1,
    B = 2,
    C = 44,
    _
};

fn someOtherFunction(value: Enum) void {
    // Does not compile giving "error: else and '_' prong in switch expression"
    switch (value) {
        .A   => {},
        .C   => {},
        else => {}, // Named tags go here (so, .B in this case)
        _    => {}, // Unnamed tags go here
    }
}
```

### Allow more operators on bool vectors

Allow binary not, binary and, binary or, binary xor, and boolean not operators on vectors of `bool`.

### Inline Assembly: Typed Clobbers

Until now these were stringly typed. It's kinda obvious when you think about it.

```zig
// BEFORE
pub fn syscall1(number: usize, arg1: usize) usize {
    return asm volatile ("syscall"
        : [ret] "={rax}" (-> usize),
        : [number] "{rax}" (number),
          [arg1] "{rdi}" (arg1),
        : "rcx", "r11"
    );
}

// AFTER
pub fn syscall1(number: usize, arg1: usize) usize {
    return asm volatile ("syscall"
        : [ret] "={rax}" (-> usize),
        : [number] "{rax}" (number),
          [arg1] "{rdi}" (arg1),
        : .{ .rcx = true, .r11 = true });
}
```

To auto-upgrade, run `zig fmt`.

### Allow @ptrCast Single-Item Pointer to Slice

This is essentially an extension of the 0.14.0 change which allowed `@ptrCast` to change the length of a slice. It can now also cast from a single-item pointer to any slice, returning a slice which refers to the same number of bytes as the operand.

```zig
const std = @import("std");

test "value to byte slice with @ptrCast" {
    const val: u32 = 1;
    const bytes: []const u8 = @ptrCast(&val);
    switch (@import("builtin").target.cpu.arch.endian()) {
        .little => try std.testing.expect(std.mem.eql(u8, bytes, "\x01\x00\x00\x00")),
        .big => try std.testing.expect(std.mem.eql(u8, bytes, "\x00\x00\x00\x01")),
    }
}
```

Note that in a future release, it is planned to move this functionality from `@ptrCast` to a new `@memCast` builtin, with the intention that the latter is a safer builtin which helps avoid unintentional out-of-bounds memory access. For more information, see [issue #23935](https://github.com/ziglang/zig/issues/23935).

### New Rules for Arithmetic on undefined

Zig 0.15.x begins to standardise the rules around how `undefined` behaves in different contexts—in particular, how it behaves as an operand to arithmetic operators. In summary, only operators which can never trigger Illegal Behavior permit `undefined` as an operand. Any other operator will trigger Illegal Behavior (or a compile error if evaluated at `comptime`) if any operand is `undefined`.

Generally, it is always best practice to avoid any operation on `undefined`. If you do that, this language change, and any that follow, are unlikely to affect you. If you are affected by this language change, you might see a compile error on code which previously worked:

```zig
const a: u32 = 0;
const b: u32 = undefined;

test "arithmetic on undefined" {
    // This addition now triggers a compile error
    _ = a + b;
    // The solution is to simply avoid this operation!
}
```

```
error: use of undefined value here causes illegal behavior
    _ = a + b;
            ^
```

### Error on Lossy Coercion from Int to Float

This compile error has always been intended, but has gone unimplemented until now. The compiler will now emit a compile error if an integer value is coerced to a float at `comptime` but the integer value could not be precisely represented due to floating-point precision limitations. If you encounter this, you will get a compile error like this:

```zig
test "big float literal" {
    const val: f32 = 123_456_789;
    _ = val;
}
```

```
error: type 'f32' cannot represent integer value '123456789'
    const val: f32 = 123_456_789;
                     ^~~~~~~~~~~
```

The solution is typically just to change an integer literal to a floating-point literal, thereby opting in to floating-point rounding behavior:

```zig
test "big float literal" {
    const val: f32 = 123_456_789.0;
    _ = val;
}
```

---

## 0.16.0

### Upgrade Checklist (0.15 → 0.16)

| Change | Before | After |
|--------|--------|-------|
| `@Type` | `@Type(.{ .int = ... })` | `@Int(.unsigned, 8)`, `@Struct(...)`, etc. |
| `@cImport` | `@cImport({ @cInclude(...) })` | `b.addTranslateC(...)` in build.zig (deprecated) |
| `std.fs` | `std.fs.cwd().openFile(...)` | `std.Io.Dir.cwd().openFile(io, ...)` (entire ns deprecated) |
| `File.writer()` | `file.writer(&buf)` | `file.writer(io, &buf)` (requires io param) |
| `File.reader()` | `file.reader(&buf)` | `file.reader(io, &buf)` (requires io param) |
| `std.net` | `std.net.tcpConnectToHost(...)` | `std.Io.net.IpAddress.resolve(...).connect(io)` |
| `std.time.timestamp()` | `std.time.timestamp()` | `std.c.clock_gettime(.REALTIME, &ts)` |
| `std.Thread.sleep` | `std.Thread.sleep(ns)` | `std.Io.sleep(io, duration, clock)` |
| `std.Thread.Mutex` | `std.Thread.Mutex` | `std.Io.Mutex` (requires io) |
| `std.Thread.Condition` | `std.Thread.Condition` | `std.Io.Condition` (requires io) |
| `std.crypto.random` | `std.crypto.random.bytes(...)` | `arc4random_buf(...)` or `std.os.linux.getrandom` |
| `std.process.getCwd` | `std.process.getCwd(&buf)` | `std.process.currentPath(io, &buf)` |
| `build.zig.zon` name | `.name = "pkg"` | `.name = .pkg` (enum literal) |
| `build.zig.zon` fingerprint | (none) | `.fingerprint = 0x...` (required) |
| `exe.addModule` | `exe.addModule(...)` | `exe.root_module.addImport(...)` |
| `exe.addIncludePath` | `exe.addIncludePath(...)` | `exe.root_module.addIncludePath(...)` |
| `PriorityQueue.init` | `.init(allocator, ctx)` | `.empty` or `.initContext(ctx)` |
| `PriorityQueue.add` | `.add(elem)` | `.push(allocator, elem)` |
| `PriorityQueue.remove` | `.remove()` | `.pop()` |
| `BitSet.initEmpty` | `initEmpty()` | `.empty` |
| `ThreadSafeAllocator` | exists | removed (ArenaAllocator now thread-safe) |
| `fmt.Formatter` | `std.fmt.Formatter` | `std.fmt.Alt` |
| `fmt.format` helper | `std.fmt.format(...)` | Removed |
| `std.meta.intToEnum` | `std.meta.intToEnum(...)` | `std.enums.fromInt(...)` |

Major: `std.fs` → `std.Io`, `@Type` removed, every I/O op needs `io` instance.

### switch

`packed struct` and `packed union` may now be used as switch prong items. They are compared solely based on their backing integer, just like in equality comparisons:

```zig
const U = packed union(u2) {
    a: i2,
    b: u2,
};

const u: U = .{ .a = -1 };
switch (u) {
    .{ .b = 3 } => {},
    else => unreachable,
}
```

Other newly implemented features:

-   decl literals and everything else requiring a result type (e.g. `@enumFromInt`) may now be used as switch prong items
-   union tag captures are now allowed for all prongs, not just `inline` ones
-   switch prongs may contain errors which are not in the error set being switched on, if these prongs contain `=> comptime unreachable`
-   switch prong captures may no longer all be discarded

Bug fixes:

-   lots of issues with switching on one-possible-value types are now fixed
-   the rules around unreachable `else` prongs when switching on errors now apply to *any* switch on an error, not just to `switch_block_err_union`, and are applied properly based on the AST
-   switching on `void` no longer requires an `else` prong unconditionally
-   lazy values are properly resolved before any comparisons with prong items
-   evaluation order between all kinds of switch statements is now the same, with or without label

### Equality Comparisons on Packed Unions

This used to already be possible by wrapping the `packed union` into a `packed struct`. Now it's also possible without having to do that.

### @cImport Moving to Build System

In the future, C Translation will be handled via the Build System rather than the `@cImport` language builtin, which is now deprecated.

Upgrade guide:

```zig
// BEFORE: c.zig
pub const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("math.h");
    @cInclude("time.h");
    @cInclude("stdlib.h");
    @cInclude("epoxy/gl.h");
    @cInclude("GLFW/glfw3.h");
});
// main.zig
const c = @import("c.zig").c;
```

```c
// AFTER: c.h
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>
#include <epoxy/gl.h>
#include <GLFW/glfw3.h>
```

```zig
// build.zig
const translate_c = b.addTranslateC(.{
    .root_source_file = b.path("src/c.h"),
    .target = target,
    .optimize = optimize,
});
translate_c.linkSystemLibrary("glfw", .{});
translate_c.linkSystemLibrary("epoxy", .{});

const exe = b.addExecutable(.{
    .name = "tetris",
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
        .imports = &.{
            .{
                .name = "c",
                .module = translate_c.createModule(),
            },
        },
    }),
});
// main.zig
const c = @import("c");
```

By doing this, the translated C code will be identical to how it was before with `@cImport`.

Alternately, you can add [the official translate-c package](https://codeberg.org/ziglang/translate-c) as an explicit dependency and gain access to more [translation customization options](https://codeberg.org/ziglang/translate-c/src/commit/41c10fa66ac81343c33f2b8c746f181b41eaaa27/build/Translator.zig#L40).

### @Type Replaced with Individual Type-Creating Builtin Functions

Zig 0.16.0 implements long-accepted proposal [#10710](https://github.com/ziglang/zig/issues/10710) to remove the `@Type` builtin from the language and replace it with individual builtins like `@Int` and `@Struct`. While `@Type` is a simple parallel to `@typeInfo`, in practice, it was clunky to use for common tasks, leading users to reach for helpers like `std.meta.Int`. Ignoring `@Vector`, which already existed, `@Type` has been replaced with 8 new builtin functions:

```zig
@EnumLiteral() type

@Int(comptime signedness: std.builtin.Signedness, comptime bits: u16) type

@Tuple(comptime field_types: []const type) type

@Pointer(
    comptime size: std.builtin.Type.Pointer.Size,
    comptime attrs: std.builtin.Type.Pointer.Attributes,
    comptime Element: type,
    comptime sentinel: ?Element,
) type

@Fn(
    comptime param_types: []const type,
    comptime param_attrs: *const [param_types.len]std.builtin.Type.Fn.Param.Attributes,
    comptime ReturnType: type,
    comptime attrs: std.builtin.Type.Fn.Attributes,
) type

@Struct(
    comptime layout: std.builtin.Type.ContainerLayout,
    comptime BackingInt: ?type,
    comptime field_names: []const []const u8,
    comptime field_types: *const [field_names.len]type,
    comptime field_attrs: *const [field_names.len]std.builtin.Type.StructField.Attributes,
) type

@Union(
    comptime layout: std.builtin.Type.ContainerLayout,
    /// Either the integer tag type, or the integer backing type, depending on `layout`.
    comptime ArgType: ?type,
    comptime field_names: []const []const u8,
    comptime field_types: *const [field_names.len]type,
    comptime field_attrs: *const [field_names.len]std.builtin.Type.UnionField.Attributes,
) type

@Enum(
    comptime TagInt: type,
    comptime mode: std.builtin.Type.Enum.Mode,
    comptime field_names: []const []const u8,
    comptime field_values: *const [field_names.len]TagInt,
) type
```

#### Enum Literal

`@EnumLiteral()` returns the "enum literal" type, which is the type of uncoerced enum literals like `.foo`. While it is equivalent to `@TypeOf(.something)`, the new `@EnumLiteral()` is preferred for consistency.

```zig
// BEFORE
@Type(.enum_literal)

// AFTER
@EnumLiteral()
```

#### Integer

`@Int` is perhaps the most useful new builtin for simple metaprogramming. The usage is equivalent to the now-deprecated `std.meta.Int` helper: given a signedness and bit count, it returns an integer type with those properties. This new usage results in significantly more concise and readable code.

```zig
// BEFORE
@Type(.{ .int = .{ .signedness = .unsigned, .bits = 10 } })

// AFTER
@Int(.unsigned, 10)
```

#### Tuple

`@Tuple` is equivalent to the now-deprecated `std.meta.Tuple` helper. It accepts a slice of types, and returns a tuple type whose fields have those types.

```zig
// BEFORE
@Type(.{ .@"struct" = .{
    .layout = .auto,
    .fields = &.{.{
        .name = "0",
        .type = u32,
        .default_value_ptr = null,
        .is_comptime = false,
        .alignment = @alignOf(u32),
    }, .{
        .name = "1",
        .type = [2]f64,
        .default_value_ptr = null,
        .is_comptime = false,
        .alignment = @alignOf([2]f64),
    }},
    .decls = &.{},
    .is_tuple = true,
} })

// AFTER
@Tuple(&.{ u32, [2]f64 })
```

To simplify the language, it is no longer possible to reify tuple types with `comptime` fields.

#### Pointer

`@Pointer` returns a pointer type, equivalent to `@Type(.{ .pointer = ... })`. Notably, it uses the new `std.builtin.Type.Pointer.Attributes` type, which uses struct field default values to make the usage more concise and more closely aligned with literal pointer type syntax.

```zig
// BEFORE
@Type(.{ .pointer = .{
    .size = .one,
    .is_const = true,
    .is_volatile = false,
    .alignment = @alignOf(u32),
    .address_space = .generic,
    .child = u32,
    .is_allowzero = false,
    .sentinel_ptr = null,
} })

// AFTER
@Pointer(.one, .{ .@"const" = true }, u32, null)
```

```zig
// BEFORE
@Type(.{ .pointer = .{
    .size = .many,
    .is_const = false,
    .is_volatile = false,
    .alignment = 1,
    .address_space = .generic,
    .child = u64,
    .is_allowzero = false,
    .sentinel_ptr = &@as(u64, 0),
} })

// AFTER
@Pointer(.many, .{ .@"align" = 1 }, u64, 0)
```

#### Function

`@Fn` returns a function type, equivalent to `@Type(.{ .@"fn" = ... })`. Like for pointers, new helper types have been introduced to make this builtin simpler to use. Parameters are specified with two separate arguments: the first specifies all parameter types, and the second specifies "attributes" (which currently consist only of the `noalias` flag).

```zig
// BEFORE
@Type(.{ .@"fn" = .{
    .calling_convention = .c,
    .is_generic = false,
    .is_var_args = true,
    .return_type = u32,
    .params = &.{.{
        .is_generic = false,
        .is_noalias = false,
        .type = f64,
    }, .{
        .is_generic = false,
        .is_noalias = true,
        .type = *const anyopaque,
    }},
} })

// AFTER
@Fn(
    &.{ f64, *const anyopaque },
    &.{ .{}, .{ .@"noalias" = true } },
    u32,
    .{ .@"callconv" = .c, .varargs = true },
)
```

This is one of several of the new builtins which accepts arguments in a "struct of arrays" style. An advantage of this style is that it makes it easy to specify a fixed value for all elements. For instance, to use the "default" attributes `.{}` for all parameters, use `&@splat(.{})`:

```zig
@Fn(param_types, &@splat(.{}), ReturnType, .{ .@"callconv" = .c })
```

#### Struct

`@Struct` returns a `struct` type, equivalent to `@Type(.{ .@"struct" = ... })`. Like `@Fn`, it uses a "struct of arrays" strategy to pass information about fields. Fields are passed as three separate arrays—field names, field types, and field attributes—where the latter includes alignment, the `comptime` flag, and the field's default value (if any).

```zig
// BEFORE
@Type(.{ .@"struct" = .{
    .layout = .@"extern",
    .fields = &.{.{
        .name = "foo",
        .type = [2]f64,
        .default_value_ptr = null,
        .is_comptime = false,
        .alignment = 1,
    }, .{
        .name = "bar",
        .type = u32,
        .default_value_ptr = &@as(u32, 123),
        .is_comptime = true,
        .alignment = @alignOf(u32),
    }},
    .decls = &.{},
    .is_tuple = false,
} })

// AFTER
@Struct(
    .@"extern",
    null,
    &.{ "foo", "bar" },
    &.{ [2]f64, u32 },
    &.{
        .{ .@"align" = 1 },
        .{ .@"comptime" = true, .default_value_ptr = &@as(u32, 123) },
    },
)
```

Again, `&@splat(.{})` is useful for specifying "default" field attributes. In some cases, it is even useful to use `@splat` for the field types. For instance, to create a struct with homogeneous field types of `FieldType` where the field names match the names of an enum type `MyEnum`:

```zig
const MyStruct = @Struct(.auto, null, std.meta.fieldNames(MyEnum), &@splat(FieldType), &@splat(.{}));
```

#### Union

`@Union` returns a `union` type, equivalent to `@Type(.{ .@"union" = ... })`. It is quite similar to `@Struct` in usage.

```zig
// BEFORE
@Type(.{ .@"union" = .{
    .layout = .auto,
    .tag_type = MyEnum,
    .fields = &.{.{
        .name = "foo",
        .type = i64,
        .alignment = @alignOf(i64),
    }, .{
        .name = "bar",
        .type = f64,
        .alignment = @alignOf(f64),
    }},
    .decls = &.{},
} })

// AFTER
@Union(
    .auto,
    MyEnum,
    &.{ "foo", "bar" },
    &.{ i64, f64 },
    &@splat(.{}),
)
```

#### Enum

`@Enum` returns an `enum` type, equivalent to `@Type(.{ .@"enum" = ... })`. It is somewhat similar to `@Struct` in usage, but accepts an array of field *tag values* rather than field *types*.

```zig
// BEFORE
@Type(.{ .@"enum" = .{
    .tag_type = u32,
    .fields = &.{.{
        .name = "foo",
        .value = 0,
    }, .{
        .name = "bar",
        .value = 1,
    }},
    .decls = &.{},
    .is_exhaustive = true,
} })

// AFTER
@Enum(
    u32,
    .exhaustive,
    &.{ "foo", "bar" },
    &.{ 0, 1 },
)
```

#### Float

There is no `@Float` builtin, because there are only 5 runtime floating-point types, so this functionality is trivially implemented in userland. The function `std.meta.Float` can be used if creating float types from a bit count is required.

#### Array

There is no `@Array` builtin, because this functionality is trivial to implement with normal array syntax. A general `Array` function would look like this:

```zig
fn Array(comptime len: usize, comptime Elem: type, comptime sentinel: ?Elem) type {
    return if (sentinel) |s| [len:s]Elem else [len]Elem;
}
```

In practice, this generality is not usually necessary, and use sites can simply be replaced with one of `[len]Elem` or `[len:s]Elem`.

#### Opaque

There is no `@Opaque` builtin. Instead, write `opaque {}`.

#### Optional

There is no `@Optional` builtin. Instead, write `?T`.

#### Error Union

There is no `@ErrorUnion` builtin. Instead, write `E!T`.

#### Error Set

There is no `@ErrorSet` builtin. To simplify the language, it is no longer possible to reify error sets. Instead, declare your error sets explicitly using `error{ ... }` syntax.

### Allow Small Integer Types to Coerce to Floats

If all possible values of an integer type can fit in a floating point type without rounding, the integer may coerce to the float without an explicit conversion. This is determined by comparing the number of bits of precision in the integer type and the significand in the floating point type. Larger integer types will still require `@floatFromInt`.

```zig
// BEFORE
var foo_int: u24 = 123;
var foo_float: f32 = @floatFromInt(foo_int);

var bar_int: u25 = 123;
var bar_float: f32 = @floatFromInt(bar_int);

// AFTER
var foo_int: u24 = 123;
var foo_float: f32 = foo_int; // Safe coercion

var bar_int: u25 = 123;
var bar_float: f32 = @floatFromInt(bar_int); // Explicit conversion is still required
```

This is part of a larger effort to improve ergonomics for making video games in Zig.

### Forbid Runtime Vector Indexes

Upgrade guide:

```zig
// BEFORE
for (0..vector_len) |i| {
   _ = vector[i];
}

// AFTER
// coerce the vector to an array
const vector_type = @typeInfo(@TypeOf(vector)).vector;
const array: [vector_type.len]vector_type.child = vector;
for (&array) |elem| {
    _ = elem;
}
```

This was changed as part of Reworked Byval Syntax Lowering.

### Vectors and Arrays No Longer Support In-Memory Coercion

If you were using `@ptrCast` to convert between array memory and vector memory, use coercion instead.

If you were coercing from `anyerror![4]i32` to `anyerror!@Vector(4, i32)` or similar, you need to unwrap the error first.

### Forbid Trivial Local Address Returned from Functions

One thing that Zig beginners struggle with - particularly those unfamiliar with manual memory management - is returning pointers to local variables from functions.

This is challenging to address, because it is legal to return an invalid pointer:

```zig
fn foo() *i32 {
    return undefined;
}
```

This is a perfectly valid function - the illegal operation only occurs if the returned pointer is dereferenced. Even then, it's legal to have a function that unconditionally invokes illegal behavior:

```zig
fn bar() noreturn {
    unreachable; // equivalent to foo().*
}
```

Given this function, the expression `bar()` is equivalent to the expression `unreachable`.

So how then, can we make it a compile error to return an invalid pointer from a function? Syntactic pedantry. We forbid all expressions that trivially (i.e. without type checking) lower to `return undefined` with the justification that the expression should instead be written canonically as `return undefined`.

Thus the following compile error was born:

```zig
fn foo() *i32 {
    var x: i32 = 1234;
    return &x;
}
```

```
error: returning address of expired local variable 'x'
    return &x;
            ^
note: declared runtime-known here
    var x: i32 = 1234;
        ^
```

[More compile errors of this nature are planned.](https://github.com/ziglang/zig/issues/25312)

### Unary Float Builtins Forward Result Type

Previously Zig would not forward a result type through the following builtin functions,

```zig
@sqrt
@sin
@cos
@tan
@exp
@exp2
@log
@log2
@log10
@floor
@ceil
@trunc
@round
```

This has now been changed. Where previous you couldn't write,

```zig
const x: f64 = @sqrt(@floatFromInt(N));
```

since `@sqrt` would not forward the `f64` result type to `@floatFromInt`, now you can.

This is part of a larger effort to improve ergonomics for making video games in Zig.

### @floor, @ceil, @round, @trunc Conversion to Integers

`@floor`, `@ceil`, `@round`, and `@trunc` now can be used to convert a floating-point value to an integer value:

```zig
const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "round to int" {
    try example(12, 12.34);
    try example(13, 12.50);
}

fn example(expected: u8, value: f32) !void {
    const actual: u8 = @round(value);
    try expectEqual(expected, actual);
}
```

`@intFromFloat` is now redundant with `@trunc` and is therefore deprecated.

This is part of a larger effort to improve ergonomics for making video games in Zig.

### Forbid Unused Bits in Packed Unions

There was not plainly one possible way of mapping packed union representation to bits, a desirable feature of other packed types. For example, `enum (u5) { ... }` plainly represents 5 bits in an obvious manner and is allowed in packed contexts, but `?u8` has two reasonable ways of mapping to 9 bits and is therefore not allowed in packed contexts.

This ambiguity is resolved by requiring all fields of a packed union to have the same `@bitSizeOf` as a backing integer type.

Upgrade guide:

```zig
// BEFORE
const U = packed union {
    x: u8,
    y: u16,
};

// AFTER
const U = packed union(u16) {
    x: packed struct(u16) {
        data: u8,
        padding: u8 = 0,
    },
    y: u16,
};
```

### Forbid Pointers in Packed Structs and Unions

Fields of `packed struct` and `packed union` types are no longer permitted to be pointers, implementing proposal [#24657](https://github.com/ziglang/zig/issues/24657).

The primary reason for this change is that constant values containing non-byte-aligned pointers cannot be represented in the vast majority of binary formats. Additionally, there are some targets on which pointers cannot be represented merely as their address bits, but have additional metadata bits too—in this case it does not make sense to pack pointers into an integer, as `packed` types purport to do.

If you were relying on pointers in `packed` types, you can instead use a `usize` field and convert to and from a pointer using `@ptrFromInt` and `@intFromPtr`.

### Allow Explicit Backing Integers on Packed Unions

Although previous versions of Zig allowed `packed struct` types to specify their backing integer type with the syntax `packed struct(T)`, this was not previously permitted for `packed union` types. In Zig 0.16.0, this has now been allowed.

```zig
const Split16 = packed union(u16) {
    raw: MaybeSigned16,
    split: packed struct { low: u8, high: u8 },
};

const MaybeSigned16 = @Union(
    .@"packed",
    u16,
    &.{ "unsigned", "signed" },
    &.{ u16, i16 },
    &@splat(.{}),
);

test "use packed union type with explicit backing integer" {
    const u: Split16 = .{ .raw = .{ .unsigned = 0xFFFE } };
    try testing.expectEqual(-2, u.raw.signed);
    try testing.expectEqual(0xFE, u.split.low);
    try testing.expectEqual(0xFF, u.split.high);
}

const testing = @import("std").testing;
```

Note that due to Forbid Enum and Packed Types with Implicit Backing Types in Extern Contexts, specifying a backing type like this is sometimes required.

### Forbid Enum and Packed Types with Implicit Backing Types in Extern Contexts

`enum` types with inferred integer tag types, and `packed struct` and `packed union` types with inferred integer backing types, are no longer considered valid `extern` types. This implements proposal [#24714](https://github.com/ziglang/zig/issues/24714).

This breaking change was made to avoid the ABI of a type being determined entirely implicitly based solely on its fields. In particular, this matters because `u8` and `i8` may have differing ABIs in some contexts, and it is not clear which is being used if the choice is implicit.

If this has introduced a compile error in your code, resolve it by adding an explicit tag type or backing type. (See Allow Explicit Backing Integers on Packed Unions for a related language change in Zig 0.16.0.)

```zig
// BEFORE — compile error
const Enum = enum { a, b, c, d };
const PackedStruct = packed struct { a: u4, b: u4 };
const PackedUnion = packed union { a: u8, b: i8 };

export var some_enum: Enum = .a;
export var some_packed_struct: PackedStruct = .{ .a = 1, .b = 2 };
export var some_packed_union: PackedUnion = .{ .a = 123 };

// AFTER
const Enum = enum(u8) { a, b, c, d };
const PackedStruct = packed struct(u8) { a: u4, b: u4 };
const PackedUnion = packed union(u8) { a: u8, b: i8 };

export var some_enum: Enum = .a;
export var some_packed_struct: PackedStruct = .{ .a = 1, .b = 2 };
export var some_packed_union: PackedUnion = .{ .a = 123 };
```

### Lazy Field Analysis

A problem we noticed since introducing I/O as an Interface is that if a type is used as a namespace, its fields will be analyzed anyway. For instance, using `std.Io.Writer` in any way pulls in the vtable of `std.Io`. Some cases of this could even result in unnecessary codegen, which can bloat binaries.

Now, `struct` (reminder that files are structs), `union`, `enum`, and `opaque` are only resolved when its size or the type of one of its fields is required. This means that not only can you use types as namespaces without referencing them, but you can even use non-dereferenced pointers `*T` without needing `T` to be resolved.

This was changed as part of Reworked Type Resolution.

### Pointers to Comptime-Only Types Are No Longer Comptime-Only

For instance, though `comptime_int` is a comptime-only type, `*comptime_int` is not, and neither is `[]comptime_int`. This may seem confusing at first—the easiest way to understand it is to consider function pointers. The type `*const fn () void` is a runtime type. However, you are not allowed to *dereference* it at runtime, because the element type (the function body type `fn () void`) is comptime-only. So these pointers can *exist* at runtime, but may only be *dereferenced* at compile-time. This makes them more-or-less useless at runtime—but there's actually an exception to that! Suppose you have a `[]const std.builtin.Type.StructField`, and you want to pass the `name` of each field to runtime code somehow. Previously, you would have done this by constructing a separate `[]const []const u8`. However, now, you can pass the `[]const std.builtin.Type.StructField` directly to a runtime function. Naturally, this function cannot load a `StructField` from this slice at runtime. However, what it *can* do is load the `name` field, because *it* has a runtime type!

This was changed as part of Reworked Type Resolution.

### Explicitly-Aligned Pointer Types Now Distinct from Naturally-Aligned Pointer Types

Previously, `*u8` and `*align(1) u8` were considered by Zig to be literally the same type; they would compare equal, and `*u8` was considered the canonical spelling (it's what the compiler would print). Now, those two types are no longer considered equivalent.

**Crucially, the two types can still be used interchangeably.** They coerce to one another, even through pointers (what the compiler calls "in-memory coercions"), and in almost every case there is no need to care which one you have. You could think of this difference as being like the difference between `u32` and `c_uint`: technically they are different types, but (assuming your target has 32-bit `int`) they act identically for all intents and purposes, and it doesn't technically matter which one you pick.

This was changed as part of Reworked Type Resolution.

### Simplified Dependency Loop Rules

There are new cases which are now dependency loops when they previously were not.

However, it's now more obvious *why* a dependency loop exists due to simplified type checking rules and enhanced compile errors. This also reduces the difficulty of formally specifying the Zig language.

This was changed as part of Reworked Type Resolution.

### Zero-bit Tuple Fields No Longer Implicitly comptime

Back in 0.14.0, a rule was unintentionally introduced that tuple fields with zero-bit types are implicitly promoted to `comptime` fields:

```zig
comptime {
    const S = struct { void };
    @compileLog(@typeInfo(S).@"struct".fields[0].is_comptime); // @as(bool, true)
}
```

Zig 0.16.0 reverts this change: the above tuple field is no longer considered a `comptime` field. However, this does *not* prevent the field value from always being comptime-known:

```zig
test "zero-bit tuple field is comptime-known" {
    const S = struct { u32, void };
    var runtime_known: S = undefined;
    runtime_known = .{ 123, {} };
    // Even though the tuple is runtime-known, the zero-bit field is comptime-known:
    comptime assert(runtime_known[1] == {});
}
const assert = @import("std").debug.assert;
```

In other words, this change is almost entirely non-breaking. The only case where it could affect old code is if you were directly relying on `std.builtin.StructField.is_comptime` from `@typeInfo`, or on the equivalence of tuples with and without explicitly declared `comptime` fields:

```zig
//! These tests both passed in Zig 0.15.x, but fail in Zig 0.16.x.
test "zero-bit tuple field is comptime" {
    const S = struct { void };
    try expect(@typeInfo(S).@"struct".fields[0].is_comptime);
}
test "comptime annotation on zero-bit field is irrelevant to type equivalence" {
    const A = struct { void };
    const B = struct { comptime void = {} };
    try expect(A == B);
}
const expect = @import("std").testing.expect;
```
