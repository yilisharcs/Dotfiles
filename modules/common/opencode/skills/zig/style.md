# Zig Style Guide

Combines Zig's official conventions, design principles, and TigerBeetle's
production-tested guidelines. Design goal priority: **Safety > Performance > Developer Experience**.

---

## Design Principles

### Type-First Development
Define types and function signatures before implementation. Let the compiler guide completeness:
1. Define data structures (structs, unions, error sets)
2. Define function signatures (parameters, return types, error unions)
3. Implement to satisfy types
4. Validate at compile-time

### Make Illegal States Unrepresentable
Use Zig's type system to prevent invalid states at compile time:
- **Tagged unions** over structs with optional fields — prevent impossible state combinations
- **Explicit error sets** over `anyerror` — document exactly which failures can occur
- **Distinct types** via `enum(u64) { _ }` — prevent mixing up IDs (user_id vs order_id)
- **Comptime validation** with `@compileError()` — catch invalid configurations at build time

### Module Structure
Larger cohesive files are idiomatic in Zig. Keep related code together — tests alongside
implementation, comptime generics at file scope, visibility controlled by `pub`. Split files
only for genuinely separate concerns. The std library demonstrates this with files like
`std/mem.zig` containing thousands of cohesive lines.

### Memory Ownership
- Pass allocators explicitly — never use global state for allocation
- Use `defer` immediately after acquiring a resource — cleanup next to acquisition
- Name allocators by contract: `gpa` (caller must free), `arena` (bulk-free at boundary), `scratch` (never escapes)
- Prefer `const` over `var` — immutability signals intent and enables optimizations
- Prefer slices over raw pointers — bounds safety

---

# TigerStyle: Zig Coding Guidelines

Distilled from TigerBeetle's [TIGER_STYLE.md](https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md).
Design goal priority: **Safety > Performance > Developer Experience**.

---

## 1. Safety

### Control Flow
- Use only **simple, explicit control flow**.
- Split compound conditions into nested `if/else` branches — ensure both the positive and negative
  spaces are handled or asserted.
- State invariants positively:

  ```zig
  // preferred
  if (index < length) { ... } else { ... }

  // avoid
  if (index >= length) { ... }
  ```

- Every `if` branch should prompt the question: does a corresponding `else` also need to be handled?

### Assertions
Assertions detect **programmer errors** — not expected runtime errors. The only correct response
to corrupt state is to crash. Assertions downgrade catastrophic correctness bugs into liveness bugs.

- A function must not operate blindly on data it has not checked; assert arguments at the entry point.
- The assertion density of the code must average a minimum of two assertions per function.
- Split compound assertions:

  ```zig
  // preferred
  assert(a);
  assert(b);

  // avoid
  assert(a and b);
  ```

- Use a single-line `if` to assert an implication: `if (a) assert(b);`
- **Assert relationships between compile-time constants** to verify design integrity before the
  program even runs:

  ```zig
  comptime assert(@sizeOf(Header) == 128);
  comptime assert(config.pipeline_max <= config.batch_max);
  ```

- Assert both the **positive space** (what you expect to be true) and the **negative space** (what
  you expect to be false) — the boundary between valid and invalid is where bugs hide.

### Memory
- Initialize large structs **in-place via an out pointer** to eliminate intermediate copies and
  guarantee pointer stability:

  ```zig
  // preferred
  fn init(target: *LargeStruct) !void {
      target.* = .{ ... };
  }

  // avoid
  fn init() !LargeStruct {
      return LargeStruct{ ... };
  }
  ```

  Keep in mind that in-place initializations are **viral** — if any field is initialized
  in-place, the entire container struct should be initialized in-place as well.

### Variable Scope
- Declare variables at the **smallest possible scope** to reduce the chance of misuse.
- Declare variables **close to where they are used** — do not introduce them before they are needed.
  This avoids POCPOU bugs (a distant cousin of TOCTOU).

### Loops and Queues
- All loops and queues must have a **fixed upper bound** to prevent infinite loops or tail-latency
  spikes. Follow the fail-fast principle.
- Loops that genuinely cannot terminate (e.g. an event loop) must be explicitly asserted as such.

### Error Handling
- **All errors must be handled.** Most catastrophic production failures stem from incorrect handling
  of non-fatal errors.
- Never discard error return values with `_`.

### Other
- Do not react directly to external events inline; let the program run at its own pace (enables
  batching and maintains control-flow ownership).
- Enforce a **hard limit of 70 lines per function**. There's a sharp discontinuity between a
  function fitting on a screen and having to scroll. Good function shape is often the inverse of
  an hourglass: a few parameters, a simple return type, and a lot of meaty logic between the braces.
- **Keep functions as small as possible.** When splitting, find semantically clean cut points:
  - Centralize all `if`/`switch` in the "parent" function; extract pure logic into helpers.
  - Let the parent own all mutable state; helpers compute what to change but don't apply it.
  - Rule of thumb: ["push `if`s up and `for`s down"](https://matklad.github.io/2023/11/15/push-ifs-up-and-fors-down.html).

---

## 2. Performance

- Solve performance in the **design phase** — the biggest wins (1000x) come from architecture,
  not post-hoc profiling.
- Do **back-of-the-envelope sketches** across the four resources (network, disk, memory, CPU) and
  their two characteristics (bandwidth, latency).
- Optimize slowest resources first: network → disk → memory → CPU, weighted by access frequency.
- **Batching** is the primary tool: amortize network, disk, memory, and CPU costs.
- Distinguish **control plane** from **data plane**; batching lets both coexist safely and fast.
- Extract hot-path loops into **standalone functions with primitive arguments** (no `self`) so the
  compiler can cache fields in registers and humans can spot redundant work:

  ```zig
  // hot loop extracted, no self
  fn process_batch(items: []const Item, result: []Output) void { ... }
  ```

- Be explicit. Do not rely on the compiler to do the right thing.
- **Always pass options explicitly** at library call sites — never rely on defaults:

  ```zig
  // preferred
  @prefetch(a, .{ .cache = .data, .rw = .read, .locality = 3 });

  // avoid
  @prefetch(a, .{});
  ```

---

## 3. Naming

- In general, functions are `camelCase`, types are `PascalCase`, variables are `lowercase_with_underscores`.
  One exception to those rules is functions that return types. They are `PascalCase`:
  ```zig
  pub fn ArrayList(comptime T: type) type {
    return ArrayListAligned(T, null);
  }
  ```
- Normally, file names are `lowercase_with_underscore`. However, files that expose a type directly should be `PascalCase`.
- **Do not abbreviate variable names** (except primitive integer loop indices in sorts/matrices).
- **Append units and qualifiers to names**, ordered by descending significance, so the most
  important word comes first:

  ```zig
  latency_ms_max    // not max_latency_ms
  latency_ms_min    // aligns nicely with the above
  message_size_max
  ```

- Choose related names with the **same character count** so they align visually:

  ```zig
  source         // same length as target
  target
  source_offset
  target_offset
  ```

- Name helper/callback functions with the caller's name as a prefix:
  `read_sector()` → `read_sector_callback()`
- **Callbacks go last** in the parameter list (mirrors invocation order).
- Infuse names with meaning: `gpa: Allocator` and `arena: Allocator` are far more informative
  than `allocator: Allocator`.
- Functions that take two or more arguments of the same type must use a named `options: struct` parameter to prevent argument confusion.

### Struct and File Layout

```zig
// Struct order: fields → type definitions → methods
time: Time,
process_id: ProcessID,

const ProcessID = struct { cluster: u128, replica: u8 };
const Tracer = @This();

pub fn init(gpa: std.mem.Allocator, time: Time) !Tracer { ... }
```

- The `main` function goes at the top of the file — readers see the most important thing first.
- Promote complex nested types to top-level structs.

---

## 4. Comments

- Comments are full sentences: space after `//`, capital letter, ending with a period (or colon
  when introducing something). Inline end-of-line comments may be phrases without punctuation.
- **Always say why.** Code shows what and how; comments explain the reasoning behind decisions.
- Add a description at the top of tests explaining the goal and methodology.
- On occasion, use an obviously-true assertion *instead of* a comment to document a critical,
  surprising invariant — the assertion is stronger documentation.

---

## 5. Formatting

- Always run `zig fmt`.
- **Hard limit of 100 columns per line**, no exceptions. Add a trailing comma and let `zig fmt`
  handle the wrapping.
- **Always add braces to `if` statements** unless the whole thing fits on one line:

  ```zig
  // single-line ok without braces
  if (ok) return;

  // multi-line always needs braces
  if (condition) {
      do_something();
  }
  ```

### Division — be explicit about rounding intent

```zig
@divExact(a, b)   // asserts no remainder
@divFloor(a, b)   // rounds toward negative infinity
div_ceil(a, b)    // rounds toward positive infinity
```

---

## 6. Off-by-One Errors

`index` (0-based), `count` (1-based), and `size` (= count × unit) are **distinct types** with
clear conversion rules:

- `index` → `count`: add 1
- `count` → `size`: multiply by the unit size
- Include units and qualifiers in variable names (see Naming) to make these conversions visible.

---

## 7. Dependencies and Tooling

- After a script has gone through enough iteration, consider rewriting it in Zig for performance
  and type safety where applicable.

---

## 8. Safety-Critical Software (Optional)

Additional rules for safety-critical systems (databases, financial software, embedded controllers,
avionics). These are too restrictive for general use but may be required when correctness is
paramount.

### Bounded Recursion

- No recursion unless provably bounded. Use iteration where possible.
- Recursive functions must have a clear base case and the recursion depth must be constrained
  by an upper bound that is enforced at runtime.

### Pair Assertions

- For any property you want to enforce, add assertions on at least two different code paths
  (e.g. just before writing to disk, and immediately after reading back).
- This catches corruption that occurred between the two assertion points.

### Explicit Sized Integers

- Use explicitly-sized integer types (`u32`, `i64`, etc.) instead of architecture-dependent
  `usize` when the value does not represent a size, index, or pointer arithmetic.
- This prevents portability bugs where code assumes one width but compiles for another.

### Zero Dependencies

- No external dependencies beyond the Zig toolchain.
- Reduces supply chain attack surface and eliminates external safety/performance risk.

### Static Allocation

- All memory must be statically allocated at startup. No memory may be dynamically allocated
  (or freed and reallocated) after initialization.
- This avoids unpredictable behavior that can significantly affect performance, and avoids
  use-after-free. It also forces more efficient, simpler designs that consider all possible
  memory usage patterns upfront as part of the design.

---

# Official Zig Style Guide

Official coding conventions from the Zig language reference. These are implemented and enforced by `zig fmt`.

## Naming Conventions

### Summary Table

| Element | Convention | Example |
|---------|-----------|---------|
| Types | `TitleCase` | `XmlParser`, `HashMap` |
| Namespace structs (0 fields) | `snake_case` | `std.json`, `std.mem` |
| Functions | `camelCase` | `readU32Be`, `parseJson` |
| Functions returning `type` | `TitleCase` | `ArrayList`, `HashMap` |
| Variables/constants | `snake_case` | `const_name`, `global_var` |
| File names (types) | `TitleCase.zig` | `ArrayList.zig` |
| File names (namespaces) | `snake_case.zig` | `mem.zig`, `json.zig` |
| Directories | `snake_case` | `std/`, `hash_map/` |

### Rules in Detail

**Types use `TitleCase`:**
```zig
const StructName = struct { field: i32 };
const TypeName = @import("dir_name/TypeName.zig");
```

**Exception: Namespace structs (0 fields) use `snake_case`:**
```zig
const namespace_name = @import("dir_name/file_name.zig");
```

**Functions use `camelCase`:**
```zig
fn functionName(param_name: TypeName) void { }
fn readU32Be() u32 { }  // Acronyms treated as words
```

**Functions returning `type` use `TitleCase`:**
```zig
fn ListTemplateFunction(comptime ChildType: type, comptime fixed_size: usize) type {
    return List(ChildType, fixed_size);
}

fn ShortList(comptime T: type, comptime n: usize) type {
    return struct {
        field_name: [n]T,
        fn methodName() void {}
    };
}
```

**Variables and constants use `snake_case`:**
```zig
var global_var: i32 = undefined;
const const_name = 42;
const primitive_type_alias = f32;
const string_alias = []u8;
```

### Acronyms and Initialisms

Acronyms follow normal casing rules—they're treated as regular words:

```zig
// XML loses its all-caps when used in identifiers
const XmlParser = struct { field: i32 };
fn parseXml() void {}
const xml_document = "...";

// BE (Big Endian) treated as a word
fn readU32Be() u32 {}

// URL, HTTP, etc. follow the same rule
const HttpClient = struct {};
fn parseUrl() void {}
const api_url = "...";
```

### Established Conventions

Follow established conventions when they exist (e.g., `ENOENT` from POSIX):
```zig
const ENOENT = error.FileNotFound;
```

## Avoid Redundancy in Names

### Words to Avoid in Type Names

Don't use these words—they apply to everything and communicate nothing:
- `Value`
- `Data`
- `Context`
- `Manager`
- `utils`, `misc`, or somebody's initials

```zig
// BAD
const JsonValue = union(enum) { ... };
const DataManager = struct { ... };
const misc = @import("misc.zig");

// GOOD
const Value = union(enum) { ... };  // In json namespace: json.Value
const Store = struct { ... };
// Put utilities at module root, no namespace needed
```

### Avoid Redundancy in Fully-Qualified Namespaces

Don't repeat the namespace in the type name:

```zig
// BAD - "json" appears twice in json.JsonValue
pub const json = struct {
    pub const JsonValue = union(enum) { number: f64, boolean: bool };
};

// GOOD - json.Value is clear and non-redundant
pub const json = struct {
    pub const Value = union(enum) { number: f64, boolean: bool };
};
```

The same applies to files (which are implicit structs):
```zig
// In json.zig:
// BAD
pub const JsonParser = struct { ... };

// GOOD
pub const Parser = struct { ... };  // Used as json.Parser
```

## Whitespace

- **Indentation:** 4 spaces (not tabs)
- **Braces:** Opening brace on same line, unless wrapping is needed
- **Line length:** Aim for ~100 characters; use common sense
- **Trailing commas:** Use trailing commas for lists with more than 2 items

```zig
// Short list - can be on one line
const pair = .{ a, b };

// Longer list - one item per line with trailing comma
const Config = struct {
    name: []const u8,
    port: u16,
    timeout: u32,
    max_connections: usize,  // trailing comma
};
```

**Line wrapping:**
```zig
// When arguments don't fit, wrap and align
fn processRequest(
    allocator: Allocator,
    request: *const Request,
    options: ProcessOptions,
) !Response {
    // ...
}
```

## Doc Comments

- **Omit redundant information** that's already clear from the name
- **Duplicate information** across similar functions (helps IDEs)
- Use **"assume"** for invariants that cause *unchecked* illegal behavior when violated
- Use **"assert"** for invariants that cause *safety-checked* illegal behavior when violated

```zig
/// Reads a little-endian u32 from the buffer.
///
/// Caller must **assume** buffer has at least 4 bytes remaining.
/// This is not checked and will cause undefined behavior if violated.
fn readU32Le(buf: []const u8) u32 {
    return std.mem.readInt(u32, buf[0..4], .little);
}

/// Pops the last element from the list.
///
/// **Asserts** the list is not empty. In safe modes, returns an error
/// or panics if the list is empty.
fn pop(self: *Self) T {
    std.debug.assert(self.items.len > 0);
    // ...
}
```

## Source Encoding

- **UTF-8** encoding required
- **LF** (`\n`, 0x0a) line endings (CRLF discouraged but tolerated)
- End files with a newline
- No hard tabs (spaces only)
- `zig fmt` enforces all these conventions

## Applying the Style Guide

Run `zig fmt` to automatically format code according to these conventions:

```bash
# Format a single file
zig fmt src/main.zig

# Format entire project
zig fmt .

# Check without modifying (useful for CI)
zig fmt --check src/
```

---

## Pre-Commit Checklist

Before submitting, verify:

- [ ] All lines are <= 100 columns; `zig fmt` has been run
- [ ] All errors are handled (no `_` discards)
- [ ] Variable names include units/qualifiers and are not abbreviated
- [ ] Compound conditions are split into nested `if/else`
- [ ] All loops have an explicit upper bound
- [ ] Comments explain *why*, not just *what*
- [ ] Compile-time constant relationships are verified with `comptime assert`
