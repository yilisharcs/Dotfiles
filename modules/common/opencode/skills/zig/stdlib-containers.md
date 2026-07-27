# std.Data Structures (Containers)

All standard library container types and their usage in Zig 0.16. Verified against 0.16.0 source.

# std.ArrayList

Dynamic array (vector) that grows as needed.

**Note:** `std.ArrayListUnmanaged` is now deprecated - use `std.ArrayList` (same type, unmanaged is now the default pattern in Zig 0.15.x).

## Initialization

```zig
// CRITICAL: Use .empty, not .{}
var list: std.ArrayList(u32) = .empty;
defer list.deinit(allocator);

// With pre-allocated capacity
var list = try std.ArrayList(u32).initCapacity(allocator, 100);

// From existing slice (takes ownership)
var list = std.ArrayList(u32).fromOwnedSlice(existing_slice);

// Fixed buffer (no allocator needed for operations)
var buffer: [8]i32 = undefined;
var stack = std.ArrayList(i32).initBuffer(&buffer);

## Basic Operations

```zig
// Append
try list.append(allocator, 42);
try list.appendSlice(allocator, &[_]u32{1, 2, 3});

// Append without allocation (asserts capacity exists)
list.appendAssumeCapacity(42);
list.appendSliceAssumeCapacity(&[_]u32{1, 2, 3});

// Access items
const items = list.items;  // []T slice
const first = list.items[0];
const last = list.getLast();  // returns ?T
const popped = list.pop();    // returns ?T, removes last

// Insert at index
try list.insert(allocator, 2, value);
try list.insertSlice(allocator, 2, slice);

// Remove
const removed = list.orderedRemove(index);   // O(n), preserves order
const removed = list.swapRemove(index);      // O(1), doesn't preserve order

## Capacity Management

```zig
// Ensure space for N more items
try list.ensureUnusedCapacity(allocator, 10);

// Ensure total capacity is at least N
try list.ensureTotalCapacity(allocator, 100);

// Shrink to fit
list.shrinkAndFree(allocator, list.items.len);

// Clear
list.clearRetainingCapacity();  // keeps memory
list.clearAndFree(allocator);   // frees memory

## Ownership Transfer

```zig
// Get owned slice (empties list, caller owns memory)
const owned = try list.toOwnedSlice(allocator);
defer allocator.free(owned);

// Get null-terminated slice
const z_str = try list.toOwnedSliceSentinel(allocator, 0);

## Iteration

```zig
for (list.items) |item| {
    // read-only
}

for (list.items) |*item| {
    item.* += 1;  // modify in place
}

for (list.items, 0..) |item, i| {
    // with index
}

## Common Patterns

```zig
// Collect from iterator
var list: std.ArrayList(u8) = .empty;
for (some_iterator) |item| {
    try list.append(allocator, item);
}

// Build string
var buf: std.ArrayList(u8) = .empty;
try buf.appendSlice(allocator, "Hello ");
try buf.appendSlice(allocator, name);
const result = try buf.toOwnedSlice(allocator);

// Remove while iterating (iterate backwards)
var i: usize = list.items.len;
while (i > 0) {
    i -= 1;
    if (shouldRemove(list.items[i])) {
        _ = list.swapRemove(i);
    }
}

## Reserve-First Pattern (Exception Safety)

When inserting into multiple containers or when partial mutation would corrupt state, use **reserve-first**: separate fallible reservation from infallible mutation.

```zig
// BAD - partial failure leaves invalid state
fn addItem(list: *std.ArrayList(u32), map: *std.AutoHashMap(u32, usize), gpa: Allocator, value: u32) !void {
    try list.append(gpa, value);              // Can fail
    try map.put(gpa, value, list.items.len);  // If this fails, list has orphan entry!
}

// GOOD - reserve first, then mutate
fn addItem(list: *std.ArrayList(u32), map: *std.AutoHashMap(u32, usize), gpa: Allocator, value: u32) !void {
    // Phase 1: Reserve (fallible, but no mutation)
    try list.ensureUnusedCapacity(gpa, 1);
    try map.ensureUnusedCapacity(gpa, 1);

    errdefer comptime unreachable;  // Phase 2: No errors after this point

    // Phase 3: Mutate (infallible)
    list.appendAssumeCapacity(value);
    map.getOrPutAssumeCapacity(value).value_ptr.* = list.items.len;
}

**Key methods:**
- `ensureUnusedCapacity(gpa, n)` - Reserve space for n more items (can fail, doesn't mutate)
- `appendAssumeCapacity(item)` - Append without allocation (cannot fail, asserts capacity)
- `appendSliceAssumeCapacity(items)` - Append slice without allocation

See **[Reserve-First Exception Safety](patterns.md#reserve-first-exception-safety)** for detailed explanation and real-world examples.

## BoundedArray Replacement

`std.BoundedArray` was REMOVED in 0.15.x. Use `initBuffer` instead:

```zig
// OLD (removed)
var arr = std.BoundedArray(u8, 64){};

// NEW
var buffer: [64]u8 = undefined;
var arr = std.ArrayList(u8).initBuffer(&buffer);
// Note: Operations will panic if capacity exceeded
try arr.appendBounded(value);  // returns error.OutOfMemory if full
# std.HashMap / std.AutoHashMap

Hash maps for key-value storage. Use `AutoHashMap` for simple keys, `StringHashMap` for string keys.

## Types Overview

```zig
// AutoHashMap - automatic hash/eql for simple types
std.AutoHashMap(KeyType, ValueType)
std.AutoHashMapUnmanaged(KeyType, ValueType)  // no stored allocator

// StringHashMap - optimized for string keys
std.StringHashMap(ValueType)
std.StringHashMapUnmanaged(ValueType)

// ArrayHashMap - preserves insertion order, fast iteration
std.ArrayHashMap(K, V, Context, store_hash)
std.StringArrayHashMap(V)

## AutoHashMap Usage

```zig
// Initialization
var map = std.AutoHashMap(u32, []const u8).init(allocator);
defer map.deinit();

// Insert
try map.put(42, "answer");

// Get
if (map.get(42)) |value| {
    // value is []const u8
}

// Get pointer (for modification)
if (map.getPtr(42)) |ptr| {
    ptr.* = "new value";
}

// Remove
if (map.fetchRemove(42)) |kv| {
    // kv.key, kv.value - removed entry
}
_ = map.remove(42);  // returns bool

// Check existence
const exists = map.contains(42);

// Count
const n = map.count();

## Unmanaged Variant

```zig
// No stored allocator - pass to each method
var map: std.AutoHashMapUnmanaged(u32, []const u8) = .empty;
defer map.deinit(allocator);

try map.put(allocator, 42, "answer");
const val = map.get(42);

## StringHashMap

```zig
var map = std.StringHashMap(i32).init(allocator);
defer map.deinit();

try map.put("foo", 123);
const val = map.get("foo");  // ?i32

## getOrPut Pattern

Efficient insert-or-update without double lookup:

```zig
const gop = try map.getOrPut(key);
if (gop.found_existing) {
    // Update existing
    gop.value_ptr.* += 1;
} else {
    // Initialize new entry
    gop.value_ptr.* = 1;
}

## Iteration

```zig
// Iterate entries
var iter = map.iterator();
while (iter.next()) |entry| {
    const key = entry.key_ptr.*;
    const value = entry.value_ptr.*;
}

// Keys only
for (map.keys()) |key| { }

// Values only
for (map.values()) |value| { }

## Capacity

```zig
try map.ensureTotalCapacity(100);
map.clearRetainingCapacity();
map.clearAndFree();

## Custom Context

For custom hash/equality functions:

```zig
const Context = struct {
    pub fn hash(self: @This(), key: MyKey) u64 {
        _ = self;
        // compute hash
    }
    pub fn eql(self: @This(), a: MyKey, b: MyKey) bool {
        _ = self;
        // compare
    }
};

var map = std.HashMap(MyKey, Value, Context, 80).init(allocator);
// Or with context instance:
var map = std.HashMap(MyKey, Value, Context, 80).initContext(allocator, context);

## ArrayHashMap (Ordered)

Preserves insertion order, supports indexed access:

```zig
var map = std.StringArrayHashMap(i32).init(allocator);
defer map.deinit();

try map.put("b", 2);
try map.put("a", 1);

// Iterate in insertion order: "b", "a"
for (map.keys(), map.values()) |k, v| { }

// Index access
const key = map.keys()[0];  // "b"
const val = map.values()[0]; // 2

// Swap remove (O(1) but changes order)
map.swapRemove("b");

// Ordered remove (O(n) but preserves order)
map.orderedRemove("a");

## Common Patterns

```zig
// Word frequency counter
var counts = std.StringHashMap(usize).init(allocator);
for (words) |word| {
    const gop = try counts.getOrPut(word);
    if (gop.found_existing) {
        gop.value_ptr.* += 1;
    } else {
        gop.value_ptr.* = 1;
    }
}

// Cache with owned keys
var cache = std.StringHashMap(Data).init(allocator);
// When inserting, dupe the key if needed:
const key_copy = try allocator.dupe(u8, external_key);
errdefer allocator.free(key_copy);
try cache.put(key_copy, data);
# std.ArrayHashMap

A hash map that preserves insertion order and stores keys/values in contiguous arrays. Combines hash table lookup with array-like iteration.

## When to Use

- Need deterministic iteration order (insertion order)
- Need array-style access to keys/values
- JSON object preservation
- When iteration performance matters more than removal performance

## Variants

| Type | Description |
|------|-------------|
| `AutoArrayHashMap(K, V)` | Auto-hashing for common key types |
| `ArrayHashMap(K, V, Ctx, store_hash)` | Custom hash/equal context |
| `StringArrayHashMap(V)` | String keys |
| `ArrayHashMapUnmanaged(...)` | No stored allocator |

## Basic Usage

```zig
const std = @import("std");

var map = std.AutoArrayHashMap(u32, []const u8).init(allocator);
defer map.deinit();

// Insert
try map.put(1, "one");
try map.put(2, "two");
try map.put(3, "three");

// Lookup
if (map.get(2)) |value| {
    std.debug.print("2 = {s}\n", .{value});
}

// Check existence
if (map.contains(1)) {
    // key exists
}

## Insertion Order Preserved

```zig
try map.put(10, "ten");
try map.put(5, "five");
try map.put(15, "fifteen");

// Iteration is in insertion order: 10, 5, 15
var it = map.iterator();
while (it.next()) |entry| {
    std.debug.print("{}: {s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
}

## Array Access

```zig
// Direct access to underlying arrays
const keys = map.keys();     // []K slice of all keys
const values = map.values(); // []V slice of all values

// Access by index
for (keys, values) |k, v| {
    std.debug.print("{}: {s}\n", .{ k, v });
}

## Removal (Two Options)

```zig
// O(1) removal - swaps with last element, changes order
_ = map.swapRemove(key);

// O(n) removal - shifts elements, preserves order
_ = map.orderedRemove(key);

// Fetch and remove
if (map.fetchSwapRemove(key)) |kv| {
    std.debug.print("removed {}: {s}\n", .{ kv.key, kv.value });
}

## Get or Put

```zig
// Get existing or insert new
const result = try map.getOrPut(key);
if (!result.found_existing) {
    result.value_ptr.* = "new_value";
}

// Get or put with default value
const result2 = try map.getOrPutValue(key, "default");

## Index-Based Operations

```zig
// Get index of key
if (map.getIndex(key)) |idx| {
    // Remove by index
    map.swapRemoveAt(idx);
    // or
    map.orderedRemoveAt(idx);
}

## Capacity Management

```zig
try map.ensureTotalCapacity(100);
try map.ensureUnusedCapacity(10);

const cap = map.capacity();
const len = map.count();

map.clearRetainingCapacity();
map.clearAndFree();

## String Keys

```zig
var map = std.StringArrayHashMap(i32).init(allocator);
defer map.deinit();

try map.put("apple", 1);
try map.put("banana", 2);

// Keys are stored by reference, not copied
// Make sure string lifetime exceeds map usage

## Custom Context

```zig
const CaseInsensitiveContext = struct {
    pub fn hash(_: @This(), key: []const u8) u32 {
        var h: u32 = 0;
        for (key) |c| {
            h = h *% 31 +% std.ascii.toLower(c);
        }
        return h;
    }
    pub fn eql(_: @This(), a: []const u8, b: []const u8, _: usize) bool {
        return std.ascii.eqlIgnoreCase(a, b);
    }
};

var map = std.ArrayHashMap(
    []const u8,
    i32,
    CaseInsensitiveContext,
    true,  // store_hash for better performance
).initContext(allocator, .{});
defer map.deinit();

try map.put("Hello", 1);
_ = map.get("HELLO");  // finds it!

## Complete Example: Word Counter

```zig
const std = @import("std");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();

    var counts = std.StringArrayHashMap(u32).init(gpa.allocator());
    defer counts.deinit();

    const words = [_][]const u8{ "apple", "banana", "apple", "cherry", "banana", "apple" };

    for (words) |word| {
        const result = try counts.getOrPut(word);
        if (result.found_existing) {
            result.value_ptr.* += 1;
        } else {
            result.value_ptr.* = 1;
        }
    }

    // Print in insertion order
    var it = counts.iterator();
    while (it.next()) |entry| {
        std.debug.print("{s}: {}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
    // Output (insertion order):
    // apple: 3
    // banana: 2
    // cherry: 1
}

## Comparison with HashMap

| Feature | HashMap | ArrayHashMap |
|---------|---------|--------------|
| Lookup | O(1) | O(1) |
| Insert | O(1) amortized | O(1) amortized |
| swapRemove | O(1) | O(1) |
| orderedRemove | N/A | O(n) |
| Iteration order | Undefined | Insertion order |
| Key/value arrays | No | Yes |
| Memory layout | Scattered | Contiguous |

## Notes

- Iteration order equals insertion order
- `swapRemove` is O(1) but changes order
- `orderedRemove` preserves order but is O(n)
- Use `store_hash=true` when `eql` is expensive
- Keys/values are stored in `MultiArrayList` (cache-friendly)
- Pointer stability only guaranteed with pre-allocated capacity
# std.MultiArrayList

Struct-of-Arrays container for cache-efficient struct storage. Stores each field in a separate contiguous array, reducing padding overhead and improving cache locality when accessing individual fields.

## When to Use

- Storing many structs where you often access only some fields
- Performance-critical code benefiting from cache-friendly access patterns
- Tagged unions (stores tags and data separately)

## Initialization

```zig
const Item = struct {
    id: u32,
    name: []const u8,
    score: f32,
};

var list: std.MultiArrayList(Item) = .{};
defer list.deinit(allocator);

// Pre-allocate capacity
try list.ensureTotalCapacity(allocator, 100);

## Basic Operations

```zig
// Append
try list.append(allocator, .{ .id = 1, .name = "foo", .score = 0.5 });
list.appendAssumeCapacity(.{ .id = 2, .name = "bar", .score = 0.8 });

// Get/set individual elements
const item = list.get(0);          // returns full struct
list.set(0, new_item);             // set full struct

// Access individual field arrays (MAIN BENEFIT)
const ids = list.items(.id);       // []u32 slice
const scores = list.items(.score); // []f32 slice

// Modify field directly
list.items(.score)[0] = 1.0;

// Pop last element
const last = list.pop();  // returns ?Item

// Length
const n = list.len;

## Slice API (More Efficient)

When accessing multiple fields, use `slice()` to compute pointers once:

```zig
const slices = list.slice();

// Now access fields without recomputing offsets
for (slices.items(.id), slices.items(.score)) |id, score| {
    // process id and score together
}

// Get/set via slice
const item = slices.get(index);
slices.set(index, new_item);

## Removal

```zig
// O(1) but doesn't preserve order
list.swapRemove(index);

// O(n) but preserves order
list.orderedRemove(index);

// Remove multiple indices (must be sorted ascending)
list.orderedRemoveMany(&.{ 1, 5, 7, 9 });

## Tagged Union Support

MultiArrayList works with tagged unions, storing tags separately:

```zig
const Value = union(enum) {
    int: i64,
    float: f64,
    string: []const u8,
};

var values: std.MultiArrayList(Value) = .{};
try values.append(allocator, .{ .int = 42 });
try values.append(allocator, .{ .float = 3.14 });

// Access tags and data separately
const tags = values.items(.tags);   // []meta.Tag(Value)
const data = values.items(.data);   // []Value.Bare (untagged union)

// Reconstruct full union
const full = values.get(0);  // Value{ .int = 42 }

## Sorting

```zig
// Sort with custom comparator (index-based)
list.sort(struct {
    scores: []const f32,

    pub fn lessThan(ctx: @This(), a: usize, b: usize) bool {
        return ctx.scores[a] < ctx.scores[b];
    }
}{ .scores = list.items(.score) });

// Also: sortUnstable, sortSpan, sortSpanUnstable

## Capacity Management

```zig
try list.ensureTotalCapacity(allocator, 100);
try list.ensureUnusedCapacity(allocator, 10);
try list.resize(allocator, new_len);  // doesn't initialize
list.shrinkAndFree(allocator, new_len);
list.shrinkRetainingCapacity(new_len);
list.clearRetainingCapacity();
list.clearAndFree(allocator);

## Clone and Transfer

```zig
const copy = try list.clone(allocator);
const owned_slice = list.toOwnedSlice();  // empties list, caller owns
# std.DoublyLinkedList / std.SinglyLinkedList

Intrusive linked lists for O(1) insertion/removal. Nodes are embedded in user structs via `@fieldParentPtr`.

## When to Use

- O(1) insertion/removal anywhere in list
- Elements that need to be in multiple lists
- Preallocated/arena-allocated nodes
- No allocation on insert (nodes already exist)

## DoublyLinkedList

Bidirectional traversal, O(1) removal of any node.

```zig
const std = @import("std");

const Item = struct {
    data: u32,
    node: std.DoublyLinkedList.Node = .{},  // embed node
};

var list: std.DoublyLinkedList = .{};

// Create items (you manage memory)
var a: Item = .{ .data = 1 };
var b: Item = .{ .data = 2 };
var c: Item = .{ .data = 3 };

// Insert
list.append(&a.node);         // add to end
list.prepend(&b.node);        // add to start
list.insertAfter(&a.node, &c.node);   // insert c after a
list.insertBefore(&a.node, &c.node);  // insert c before a

// Remove
list.remove(&a.node);         // O(1) remove specific node
const last = list.pop();      // remove and return last
const first = list.popFirst(); // remove and return first

// Get data from node
if (list.first) |node| {
    const item: *Item = @fieldParentPtr("node", node);
    std.debug.print("data: {}\n", .{item.data});
}

// Traverse forward
var it = list.first;
while (it) |node| : (it = node.next) {
    const item: *Item = @fieldParentPtr("node", node);
    // use item.data
}

// Traverse backward
var it = list.last;
while (it) |node| : (it = node.prev) {
    const item: *Item = @fieldParentPtr("node", node);
    // use item.data
}

// Concatenate (moves all from list2 to end of list1)
list1.concatByMoving(&list2);

// Length (O(n) - consider tracking separately)
const n = list.len();

## SinglyLinkedList

Forward-only, minimal memory (one pointer per node).

```zig
const Item = struct {
    data: u32,
    node: std.SinglyLinkedList.Node = .{},
};

var list: std.SinglyLinkedList = .{};

var a: Item = .{ .data = 1 };
var b: Item = .{ .data = 2 };

// Insert (only at front or after existing node)
list.prepend(&a.node);         // add to front
a.node.insertAfter(&b.node);   // insert b after a

// Remove
const first = list.popFirst(); // remove and return first
_ = a.node.removeNext();       // remove node after a
list.remove(&b.node);          // O(n) - must find predecessor

// Traverse (forward only)
var it = list.first;
while (it) |node| : (it = node.next) {
    const item: *Item = @fieldParentPtr("node", node);
    // use item.data
}

// Find last (O(n))
if (list.first) |first| {
    const last = first.findLast();
}

// Reverse in place
std.SinglyLinkedList.Node.reverse(&list.first);

// Length (O(n))
const n = list.len();

## Node Methods

```zig
// DoublyLinkedList.Node
node.prev  // ?*Node
node.next  // ?*Node

// SinglyLinkedList.Node
node.next           // ?*Node
node.insertAfter(new_node)
node.removeNext()   // ?*Node - removes and returns next
node.findLast()     // *Node
node.countChildren() // usize
node.reverse(&optional_ptr)

## Common Pattern: LRU Cache

```zig
const Entry = struct {
    key: []const u8,
    value: Value,
    node: std.DoublyLinkedList.Node = .{},
};

var lru_list: std.DoublyLinkedList = .{};
var entries: std.StringHashMap(*Entry) = .init(allocator);

fn access(key: []const u8) ?*Entry {
    const entry = entries.get(key) orelse return null;
    // Move to front (most recently used)
    lru_list.remove(&entry.node);
    lru_list.prepend(&entry.node);
    return entry;
}

fn evictOldest() void {
    if (lru_list.pop()) |node| {
        const entry: *Entry = @fieldParentPtr("node", node);
        _ = entries.remove(entry.key);
        // free entry
    }
}
# std.PriorityQueue

A binary heap-based priority queue. Efficiently retrieves elements by priority order.

## When to Use

- Need to repeatedly extract min or max element
- Task scheduling by priority
- Dijkstra's algorithm, A* pathfinding
- Event-driven simulation (process earliest event first)

## Initialization

```zig
const std = @import("std");

// Min-heap comparator (smallest first)
fn lessThan(context: void, a: u32, b: u32) std.math.Order {
    _ = context;
    return std.math.order(a, b);
}

const PQ = std.PriorityQueue(u32, void, lessThan);

var queue = PQ.init(allocator, {});
defer queue.deinit();

## Max-Heap

```zig
fn greaterThan(context: void, a: u32, b: u32) std.math.Order {
    _ = context;
    return std.math.order(a, b).invert();
}

const MaxPQ = std.PriorityQueue(u32, void, greaterThan);

## Basic Operations

```zig
// Add elements
try queue.add(54);
try queue.add(12);
try queue.add(7);

// Add multiple
try queue.addSlice(&[_]u32{ 1, 2, 3 });

// Peek at highest priority (doesn't remove)
if (queue.peek()) |top| {
    std.debug.print("top: {}\n", .{top});  // 7 for min-heap
}

// Remove highest priority
const top = queue.remove();       // asserts non-empty
const maybe = queue.removeOrNull(); // returns ?T

// Size
const n = queue.count();
const cap = queue.capacity();

## From Existing Slice

```zig
// Take ownership of slice, heapify in place
var items = try allocator.dupe(u32, &[_]u32{ 5, 3, 8, 1, 2 });
var queue = PQ.fromOwnedSlice(allocator, items, {});
defer queue.deinit();
// Now queue is a valid heap

## Update Priority

```zig
// Change priority of existing element
try queue.update(old_value, new_value);
// Error if old_value not found

## Remove by Index

```zig
// Remove element at specific position (not priority order)
const removed = queue.removeIndex(index);

## Iteration (Non-Priority Order)

```zig
// Iterate without removing (order is NOT priority order!)
var it = queue.iterator();
while (it.next()) |elem| {
    // process elem
}
it.reset();  // restart iteration

## Capacity Management

```zig
try queue.ensureTotalCapacity(100);
try queue.ensureUnusedCapacity(10);
queue.shrinkAndFree(new_capacity);
queue.clearRetainingCapacity();
queue.clearAndFree();

## Context-Based Comparator

For comparing by external data (e.g., indices into an array):

```zig
fn compareByScore(scores: []const u32, a: usize, b: usize) std.math.Order {
    return std.math.order(scores[a], scores[b]);
}

const IndexPQ = std.PriorityQueue(usize, []const u32, compareByScore);

const scores = [_]u32{ 50, 30, 80, 20 };
var queue = IndexPQ.init(allocator, &scores);
defer queue.deinit();

try queue.add(0);  // score 50
try queue.add(1);  // score 30
try queue.add(2);  // score 80
try queue.add(3);  // score 20

// Removes index 3 (score 20 is smallest)
const best = queue.remove();  // 3

## Complete Example: Task Scheduler

```zig
const std = @import("std");

const Task = struct {
    name: []const u8,
    priority: u32,  // lower = more urgent
};

fn taskCompare(_: void, a: Task, b: Task) std.math.Order {
    return std.math.order(a.priority, b.priority);
}

const TaskQueue = std.PriorityQueue(Task, void, taskCompare);

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();

    var tasks = TaskQueue.init(gpa.allocator(), {});
    defer tasks.deinit();

    try tasks.add(.{ .name = "low priority", .priority = 100 });
    try tasks.add(.{ .name = "urgent", .priority = 1 });
    try tasks.add(.{ .name = "medium", .priority = 50 });

    while (tasks.removeOrNull()) |task| {
        std.debug.print("Processing: {s}\n", .{task.name});
    }
    // Output:
    // Processing: urgent
    // Processing: medium
    // Processing: low priority
}

## Notes

- Heap property: parent has higher priority than children
- `remove()` is O(log n), `peek()` is O(1)
- Iterator order is NOT priority order (it's heap array order)
- Use `removeOrNull()` for safe extraction from potentially empty queue
# std.PriorityDequeue

A min-max heap that efficiently supports both min and max extraction. Unlike `PriorityQueue`, you can pop from either end.

## When to Use

- Need both min and max extraction
- Double-ended priority queue
- Sliding window min/max
- Median maintenance (with two heaps)

## Initialization

```zig
const std = @import("std");

fn compare(context: void, a: u32, b: u32) std.math.Order {
    _ = context;
    return std.math.order(a, b);
}

const PDQ = std.PriorityDequeue(u32, void, compare);

var dequeue = PDQ.init(allocator, {});
defer dequeue.deinit();

## Basic Operations

```zig
// Add elements
try dequeue.add(54);
try dequeue.add(12);
try dequeue.add(7);

// Add multiple
try dequeue.addSlice(&[_]u32{ 1, 2, 3 });

// Peek at min/max (doesn't remove)
if (dequeue.peekMin()) |min| {
    std.debug.print("min: {}\n", .{min});
}
if (dequeue.peekMax()) |max| {
    std.debug.print("max: {}\n", .{max});
}

// Remove min/max
const min = dequeue.removeMin();        // asserts non-empty
const max = dequeue.removeMax();        // asserts non-empty

// Safe removal (returns null if empty)
const maybe_min = dequeue.removeMinOrNull();
const maybe_max = dequeue.removeMaxOrNull();

// Size
const n = dequeue.count();
const cap = dequeue.capacity();

## From Existing Slice

```zig
// Take ownership of slice, heapify in place
var items = try allocator.dupe(u32, &[_]u32{ 5, 3, 8, 1, 2 });
var dequeue = PDQ.fromOwnedSlice(allocator, items, {});
defer dequeue.deinit();

## Update Priority

```zig
try dequeue.update(old_value, new_value);
// Error if old_value not found

## Remove by Index

```zig
const removed = dequeue.removeIndex(index);

## Iteration

```zig
// Iterate (order is NOT priority order)
var it = dequeue.iterator();
while (it.next()) |elem| {
    // process elem
}
it.reset();

## Capacity Management

```zig
try dequeue.ensureTotalCapacity(100);
try dequeue.ensureUnusedCapacity(10);
dequeue.shrinkAndFree(new_capacity);

## Context-Based Comparator

```zig
fn compareByScore(scores: []const u32, a: usize, b: usize) std.math.Order {
    return std.math.order(scores[a], scores[b]);
}

const IndexPDQ = std.PriorityDequeue(usize, []const u32, compareByScore);

const scores = [_]u32{ 50, 30, 80, 20 };
var dequeue = IndexPDQ.init(allocator, &scores);

## Complete Example: Bounded Range Tracker

```zig
const std = @import("std");

fn order(_: void, a: i32, b: i32) std.math.Order {
    return std.math.order(a, b);
}

const RangePDQ = std.PriorityDequeue(i32, void, order);

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();

    var tracker = RangePDQ.init(gpa.allocator(), {});
    defer tracker.deinit();

    // Add values
    try tracker.add(10);
    try tracker.add(5);
    try tracker.add(20);
    try tracker.add(3);
    try tracker.add(15);

    // Get range without removing
    const min = tracker.peekMin().?;  // 3
    const max = tracker.peekMax().?;  // 20
    const range = max - min;           // 17

    std.debug.print("Range: {} to {} = {}\n", .{ min, max, range });

    // Pop from both ends
    _ = tracker.removeMin();  // removes 3
    _ = tracker.removeMax();  // removes 20

    // New range is 5 to 15
}

## Difference from PriorityQueue

| Feature | PriorityQueue | PriorityDequeue |
|---------|--------------|-----------------|
| Pop min | Yes | Yes |
| Pop max | No (unless you reverse comparator) | Yes |
| Peek min | Yes | Yes |
| Peek max | No | Yes |
| Structure | Binary heap | Min-max heap |

## Notes

- Both `removeMin()` and `removeMax()` are O(log n)
- `peekMin()` is O(1), `peekMax()` is O(1) after first 2 elements
- Iterator order is heap array order, not priority order
- Use when you need efficient access to both extremes
# std.bit_set

Densely stored sets of integers with efficient set operations (union, intersection, complement). Each integer gets a single bit.

## When to Use

- Track presence/absence of items from a known finite set
- Set operations (union, intersection, difference)
- Bit flags with variable size
- Compact storage when max value is known

## Variants

| Type | Size | Allocation |
|------|------|------------|
| `IntegerBitSet(N)` | Compile-time, N <= 128 | None (single integer) |
| `ArrayBitSet(usize, N)` | Compile-time, any N | None (array) |
| `StaticBitSet(N)` | Compile-time | Auto-selects Integer or Array |
| `DynamicBitSet` | Runtime | Allocator (managed) |
| `DynamicBitSetUnmanaged` | Runtime | Allocator (unmanaged) |

## Static Bit Set (Compile-Time Size)

```zig
const std = @import("std");

// StaticBitSet auto-selects best implementation
const Flags = std.StaticBitSet(64);

var flags = Flags.initEmpty();
flags.set(5);
flags.set(10);

if (flags.isSet(5)) {
    // bit 5 is set
}

flags.unset(5);
flags.toggle(10);

const count = flags.count();  // number of set bits

## Dynamic Bit Set (Runtime Size)

```zig
var bits = try std.DynamicBitSet.initEmpty(allocator, 1000);
defer bits.deinit();

bits.set(42);
bits.set(100);

// Resize dynamically
try bits.resize(2000, false);  // false = new bits are 0
try bits.resize(2000, true);   // true = new bits are 1

// Clone
var copy = try bits.clone(allocator);
defer copy.deinit();

## Set Operations

```zig
var a = Flags.initEmpty();
var b = Flags.initEmpty();
a.set(1); a.set(2);
b.set(2); b.set(3);

// In-place operations (modify a)
a.setUnion(b);        // a = a | b  (bits in either)
a.setIntersection(b); // a = a & b  (bits in both)
a.toggleSet(b);       // a = a ^ b  (flip bits that are in b)

// Return new set (pure functions)
const union_set = a.unionWith(b);
const intersection = a.intersectWith(b);
const xor_set = a.xorWith(b);
const diff = a.differenceWith(b);  // a - b
const comp = a.complement();        // ~a

## Comparison

```zig
if (a.eql(b)) {
    // same bits set
}

if (a.subsetOf(b)) {
    // all bits in a are also in b
}

if (a.supersetOf(b)) {
    // all bits in b are also in a
}

## Iteration

```zig
var flags = Flags.initEmpty();
flags.set(1); flags.set(5); flags.set(10);

// Iterate set bits (ascending order by default)
var it = flags.iterator(.{});
while (it.next()) |index| {
    std.debug.print("bit {} is set\n", .{index});
}

// Iterate unset bits
var unset_it = flags.iterator(.{ .kind = .unset });

// Reverse order
var rev_it = flags.iterator(.{ .direction = .reverse });

## Range Operations

```zig
// Set/unset a range of bits
flags.setRangeValue(.{ .start = 10, .end = 20 }, true);   // set bits 10-19
flags.setRangeValue(.{ .start = 10, .end = 20 }, false);  // unset bits 10-19

## Find Operations

```zig
// Find first/last set bit
if (flags.findFirstSet()) |index| {
    // index of lowest set bit
}

if (flags.findLastSet()) |index| {
    // index of highest set bit
}

// Find and toggle (atomic-like)
if (flags.toggleFirstSet()) |index| {
    // returns index and unsets the bit
}

## Toggle All

```zig
flags.toggleAll();  // flip every bit

## Unmanaged Dynamic BitSet

```zig
// For when you don't want to store the allocator
var bits: std.DynamicBitSetUnmanaged = .{};
try bits.resize(allocator, 100, false);
defer bits.deinit(allocator);

bits.set(50);

## Complete Example: Permission Flags

```zig
const std = @import("std");

const Permission = enum(u8) {
    read = 0,
    write = 1,
    execute = 2,
    delete = 3,
    admin = 4,
};

const Permissions = std.StaticBitSet(8);

fn hasPermission(perms: Permissions, p: Permission) bool {
    return perms.isSet(@intFromEnum(p));
}

fn grant(perms: *Permissions, p: Permission) void {
    perms.set(@intFromEnum(p));
}

fn revoke(perms: *Permissions, p: Permission) void {
    perms.unset(@intFromEnum(p));
}

pub fn main() void {
    var user_perms = Permissions.initEmpty();
    grant(&user_perms, .read);
    grant(&user_perms, .write);

    var admin_perms = Permissions.initFull();

    // Check if user has all admin permissions
    if (user_perms.subsetOf(admin_perms)) {
        // user can do everything admin can (not in this case)
    }

    // Grant user all of admin's permissions
    user_perms.setUnion(admin_perms);
}

## Notes

- `StaticBitSet` is zero-allocation, copyable by value
- `DynamicBitSet` requires allocation, call `deinit()`
- `initFull()` creates set with all bits set
- Iteration order is index order, not insertion order
- Use `std.enums.EnumSet` for enum-based bit flags
# std.enums

Utilities for working with enums: sets, maps, arrays, and iteration backed by bit operations.

## EnumSet

Bit-backed set of enum values. Zero allocation, copyable by value.

```zig
const std = @import("std");

const Color = enum { red, green, blue, yellow };
const ColorSet = std.enums.EnumSet(Color);

// Initialize
var colors = ColorSet.initEmpty();
var all = ColorSet.initFull();

// Struct-style init
var primary = ColorSet.init(.{
    .red = true,
    .green = true,
    .blue = true,
    .yellow = false,
});

// From slice
var some = ColorSet.initMany(&.{ .red, .blue });

// Single element
var just_red = ColorSet.initOne(.red);

## EnumSet Operations

```zig
// Insert/remove
colors.insert(.red);
colors.remove(.blue);
colors.toggle(.green);
colors.setPresent(.yellow, true);

// Check
if (colors.contains(.red)) {
    // red is in set
}

const n = colors.count();  // number of elements

// Set operations (in-place)
colors.setUnion(other);        // add all from other
colors.setIntersection(other); // keep only common
colors.toggleSet(other);       // XOR
colors.toggleAll();            // invert all

// Set operations (return new set)
const u = colors.unionWith(other);
const i = colors.intersectWith(other);
const x = colors.xorWith(other);
const d = colors.differenceWith(other);  // colors - other
const c = colors.complement();           // all except colors

// Comparison
if (colors.eql(other)) { }
if (colors.subsetOf(other)) { }
if (colors.supersetOf(other)) { }

## EnumSet Iteration

```zig
var it = colors.iterator();
while (it.next()) |color| {
    std.debug.print("{}\n", .{color});
}

## EnumMap

Map from enum to value. Fixed-size, zero allocation.

```zig
const Color = enum { red, green, blue };
const ColorMap = std.enums.EnumMap(Color, u32);

// Empty map
var map = ColorMap{};

// Struct-style init (null = not present)
var scores = ColorMap.init(.{
    .red = 100,
    .green = 50,
    .blue = null,  // not in map
});

## EnumMap Operations

```zig
// Insert
map.put(.red, 42);

// Get
if (map.get(.red)) |value| {
    std.debug.print("red = {}\n", .{value});
}

// Get with default
const value = map.getOrDefault(.blue, 0);

// Get pointer
if (map.getPtr(.red)) |ptr| {
    ptr.* += 1;  // modify in place
}

// Remove
map.remove(.red);

// Check
if (map.contains(.red)) { }

// Count
const n = map.count();

## EnumMap Iteration

```zig
// Iterate entries
var it = map.iterator();
while (it.next()) |entry| {
    std.debug.print("{}: {}\n", .{ entry.key, entry.value.* });
}

// Iterate keys only
var key_it = map.keyIterator();
while (key_it.next()) |key| {
    std.debug.print("{}\n", .{key});
}

## EnumArray

Dense array indexed by enum. All values always present.

```zig
const Color = enum { red, green, blue };
const ColorArray = std.enums.EnumArray(Color, u32);

// Initialize all to same value
var arr = ColorArray.initFill(0);

// Struct-style init (all must be present)
var rgb = ColorArray.init(.{
    .red = 255,
    .green = 128,
    .blue = 64,
});

// Access
const r = rgb.get(.red);     // 255
rgb.set(.green, 200);
rgb.getPtr(.blue).* = 100;

## EnumArray Iteration

```zig
// By key
for (std.enums.values(Color)) |color| {
    std.debug.print("{}: {}\n", .{ color, rgb.get(color) });
}

// Direct slice access
const slice = rgb.values;  // [3]u32

## EnumIndexer

Convert between enum values and dense indices.

```zig
const Indexer = std.enums.EnumIndexer(Color);

const idx = Indexer.indexOf(.green);   // 1
const color = Indexer.keyForIndex(1);  // .green
const count = Indexer.count;           // 3

## Utility Functions

```zig
// Get all values as slice
const colors = std.enums.values(Color);  // [3]Color

// Safe tag name (works with non-exhaustive)
const name = std.enums.tagName(Color, .red);  // "red" or null

// Safe int-to-enum
const maybe = std.enums.fromInt(Color, 1);  // ?.green

## Direct Enum Array (Sparse Enums)

For enums with gaps in values:

```zig
const Sparse = enum(u8) { a = 1, b = 5, c = 10 };

// Create array indexed by enum int value
const arr = std.enums.directEnumArray(
    Sparse,
    bool,
    8,  // max_unused_slots (gaps allowed)
    .{ .a = true, .b = false, .c = true },
);
// arr is [11]bool, indexed by @intFromEnum

## Complete Example: Permission System

```zig
const std = @import("std");

const Permission = enum {
    read,
    write,
    execute,
    admin,
};

const Permissions = std.enums.EnumSet(Permission);

const User = struct {
    name: []const u8,
    perms: Permissions,
};

fn canAccess(user: User, required: Permissions) bool {
    // User must have all required permissions
    return required.subsetOf(user.perms);
}

pub fn main() void {
    const admin = User{
        .name = "admin",
        .perms = Permissions.initFull(),
    };

    const reader = User{
        .name = "reader",
        .perms = Permissions.initOne(.read),
    };

    const write_required = Permissions.initMany(&.{ .read, .write });

    std.debug.print("admin can write: {}\n", .{canAccess(admin, write_required)});   // true
    std.debug.print("reader can write: {}\n", .{canAccess(reader, write_required)}); // false
}

## Complete Example: State Machine Transitions

```zig
const std = @import("std");

const State = enum { idle, running, paused, stopped };
const Event = enum { start, pause, resume, stop };

const TransitionMap = std.enums.EnumMap(Event, State);
const StateTransitions = std.enums.EnumArray(State, TransitionMap);

const transitions = StateTransitions.init(.{
    .idle = TransitionMap.init(.{ .start = .running, .stop = .stopped }),
    .running = TransitionMap.init(.{ .pause = .paused, .stop = .stopped }),
    .paused = TransitionMap.init(.{ .resume = .running, .stop = .stopped }),
    .stopped = TransitionMap{},  // no transitions from stopped
});

fn nextState(current: State, event: Event) ?State {
    return transitions.get(current).get(event);
}

pub fn main() void {
    var state = State.idle;
    state = nextState(state, .start) orelse state;  // -> running
    state = nextState(state, .pause) orelse state;  // -> paused
    state = nextState(state, .resume) orelse state; // -> running
    std.debug.print("Final state: {}\n", .{state});
}

## Notes

- `EnumSet`: Bit-backed, use for presence tracking
- `EnumMap`: Sparse, only stores present values
- `EnumArray`: Dense, all values always present
- All are fixed-size, zero-allocation, copyable by value
- Use `std.StaticBitSet` for non-enum integer sets
- Works with non-exhaustive enums (explicit fields only)
# std.Treap

A self-balancing binary search tree using randomized priorities. Combines BST ordering with heap-based balancing for expected O(log n) operations.

## When to Use

- Need ordered key storage with fast lookup/insert/delete
- Require in-order iteration
- Need min/max access
- Predecessor/successor queries

## Initialization

```zig
const std = @import("std");

// Define treap with key type and comparator
const MyTreap = std.Treap(u64, std.math.order);

var treap: MyTreap = .{};

## Node Structure

Nodes are user-managed (intrusive design):

```zig
var nodes: [100]MyTreap.Node = undefined;

// Node fields (managed by treap):
// - key: Key
// - priority: usize (random, for balancing)
// - parent: ?*Node
// - children: [2]?*Node

## Insert via Entry API

```zig
// Get entry for a key (like a "slot" in the treap)
var entry = treap.getEntryFor(key);

if (entry.node == null) {
    // Key not present, insert new node
    entry.set(&nodes[i]);
}

## Lookup

```zig
// Find by key
var entry = treap.getEntryFor(key);
if (entry.node) |node| {
    // found, node.key == key
}

// Get entry for existing node (O(1) if you have the node)
var entry = treap.getEntryForExisting(node);

## Remove

```zig
var entry = treap.getEntryFor(key);
entry.set(null);  // removes the node

// Or if you have the node:
var entry = treap.getEntryForExisting(node);
entry.set(null);

## Replace

```zig
var entry = treap.getEntryForExisting(old_node);
entry.set(&new_node);  // replaces old with new (same key)

## Min/Max Access

```zig
// Get smallest key
if (treap.getMin()) |min_node| {
    std.debug.print("min key: {}\n", .{min_node.key});
}

// Get largest key
if (treap.getMax()) |max_node| {
    std.debug.print("max key: {}\n", .{max_node.key});
}

## Predecessor/Successor

```zig
// Next larger key
if (node.next()) |successor| {
    // successor.key > node.key
}

// Previous smaller key
if (node.prev()) |predecessor| {
    // predecessor.key < node.key
}

## In-Order Iteration

```zig
// Iterate keys in sorted order (smallest to largest)
var iter = treap.inorderIterator();
while (iter.next()) |node| {
    std.debug.print("key: {}\n", .{node.key});
}

## Custom Comparator

```zig
fn compareStrings(a: []const u8, b: []const u8) std.math.Order {
    return std.mem.order(u8, a, b);
}

const StringTreap = std.Treap([]const u8, compareStrings);

## Complete Example

```zig
const std = @import("std");
const Treap = std.Treap(u64, std.math.order);

pub fn main() !void {
    var treap: Treap = .{};
    var nodes: [10]Treap.Node = undefined;

    // Insert keys 0-9
    for (0..10) |i| {
        var entry = treap.getEntryFor(@intCast(i));
        entry.set(&nodes[i]);
    }

    // Find key 5
    var entry = treap.getEntryFor(5);
    if (entry.node) |node| {
        std.debug.print("found: {}\n", .{node.key});

        // Get neighbors
        if (node.prev()) |p| std.debug.print("prev: {}\n", .{p.key});
        if (node.next()) |n| std.debug.print("next: {}\n", .{n.key});
    }

    // Iterate in order
    var iter = treap.inorderIterator();
    while (iter.next()) |node| {
        std.debug.print("{} ", .{node.key});
    }
    // Output: 0 1 2 3 4 5 6 7 8 9

    // Remove key 5
    entry.set(null);
}

## Notes

- No allocator needed (nodes are user-managed)
- Balancing uses randomized priorities (xorshift PRNG)
- `node.priority == 0` indicates node is not in treap
- Entry API allows atomic check-and-modify patterns


## std.BitStack

A stack of u1 values implemented using ArrayList(u8). Used for tracking nested states (e.g., JSON parser state).

```zig
const std = @import("std");

var stack = std.BitStack.init(allocator);
defer stack.deinit();

try stack.push(1);
try stack.push(0);
const top = stack.peek();  // returns u1
const popped = stack.pop();  // returns u1
```

Standalone functions for working with a fixed-size buffer (no allocation):
```zig
var buf: [64]u8 = undefined;
var bit_len: usize = 0;

std.BitStack.pushWithStateAssumeCapacity(&buf, &bit_len, 1);
const val = std.BitStack.peekWithState(&buf, bit_len);
const popped = std.BitStack.popWithState(&buf, &bit_len);
```
