const std = @import("std");

const Block = struct {
    id: ?usize = null,
    length: u8,
};

const AllowFragments = enum { allow_fragments, disallow_fragments };

const Fs = std.DoublyLinkedList(Block);

fn relocateBlock(
    pool: *std.heap.MemoryPool(Fs.Node),
    fs: *Fs,
    start: ?*Fs.Node,
    j: ?*Fs.Node,
    fragments: AllowFragments,
) !void {
    var i = start;
    while (i != j) : (i = i.?.next) {
        if (i.?.data.id != null) {
            // noop
        } else if (i.?.data.length == j.?.data.length) {
            std.mem.swap(Block, &i.?.data, &j.?.data);
            return;
        } else if (i.?.data.length > j.?.data.length) {
            const d = i.?.data.length - j.?.data.length;
            i.?.data = j.?.data;
            j.?.data.id = null;
            const node = try pool.create();
            node.* = .{ .data = .{ .length = d } };
            fs.insertAfter(i.?, node);
            return;
        } else if (i.?.data.length < j.?.data.length and fragments == .allow_fragments) {
            const d = j.?.data.length - i.?.data.length;
            i.?.data.id = j.?.data.id;
            j.?.data.length = d;
            const node = try pool.create();
            node.* = .{ .data = .{ .length = i.?.data.length } };
            fs.insertAfter(j.?, node);
        }
    }
}

fn compactFs(
    pool: *std.heap.MemoryPool(Fs.Node),
    fs: *Fs,
    fragments: AllowFragments,
) !void {
    var i = fs.first;
    var j = fs.last;
    while (i != j) {
        if (i.?.data.id != null) {
            i = i.?.next;
        } else if (j.?.data.id == null) {
            j = j.?.prev;
        } else {
            try relocateBlock(pool, fs, i, j, fragments);
            j = j.?.prev;
        }
    }
}

fn checksum(fs: Fs) usize {
    var result: usize = 0;
    var l: usize = 0;
    var i = fs.first;
    while (i) |node| {
        var k: usize = 0;
        while (k < node.data.length) : (k += 1) {
            if (node.data.id) |id| {
                result += l * id;
            }
            l += 1;
        }
        i = node.next;
    }
    return result;
}

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa_state.deinit() == .ok);
    const gpa = gpa_state.allocator();

    const text = try std.io.getStdIn().readToEndAlloc(gpa, std.math.maxInt(usize));
    defer gpa.free(text);
    const line = std.mem.trimRight(u8, text, "\r\n");
    var pool = std.heap.MemoryPool(Fs.Node).init(gpa);
    defer pool.deinit();
    var fs = std.DoublyLinkedList(Block){};
    var fs2 = std.DoublyLinkedList(Block){};
    for (line, 0..) |ch, i| {
        const node = try pool.create();
        node.* = .{
            .data = .{
                .id = if (i % 2 == 0) i / 2 else null,
                .length = ch - '0',
            },
        };
        const node2 = try pool.create();
        node2.* = node.*;
        fs.append(node);
        fs2.append(node2);
    }
    try compactFs(&pool, &fs, .allow_fragments);
    try compactFs(&pool, &fs2, .disallow_fragments);

    const part1 = checksum(fs);
    const part2 = checksum(fs2);
    try std.io.getStdOut().writer().print(
        \\Part 1: {d}
        \\Part 2: {d}
        \\
    , .{ part1, part2 });
}
