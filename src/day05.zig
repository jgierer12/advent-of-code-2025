const std = @import("std");
const print = std.debug.print;

const data = @embedFile("data/day05.txt");
// const data =
//     \\3-5
//     \\10-14
//     \\16-20
//     \\12-18
//     \\
//     \\1
//     \\5
//     \\8
//     \\11
//     \\17
//     \\32
// ;

const Range = struct {
    first: u64,
    last: u64,

    fn parse(range: []const u8) !Range {
        const dashIndex = std.mem.indexOf(u8, range, "-").?;
        return Range{
            .first = try std.fmt.parseInt(u64, range[0..dashIndex], 10),
            .last = try std.fmt.parseInt(u64, range[dashIndex + 1 ..], 10),
        };
    }

    // compare fn for std.mem.sort
    // first argument is a context object, which we don't need
    fn compare(_: void, lhs: Range, rhs: Range) bool {
        return lhs.first < rhs.first;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const alloc = gpa.allocator();

    var lines = std.mem.splitScalar(u8, data, '\n');

    var ranges: std.ArrayList(Range) = .empty;
    defer ranges.deinit(alloc);

    while (lines.next()) |line| {
        // breaks after ranges block
        if (line.len == 0) break;

        try ranges.append(alloc, try Range.parse(line));
    }

    std.mem.sortUnstable(Range, ranges.items, {}, Range.compare);

    var result: u64 = 0;
    var max: u64 = 0;
    for (ranges.items) |r| {
        // -| (saturating subtraction) turns any negative result (underflow)
        // into 0, which is exactly what is needed here
        result += r.last + 1 -| @max(r.first, max);
        max = @max(max, r.last + 1);
    }

    print("{}\n", .{result});
}
