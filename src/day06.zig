const std = @import("std");
const print = std.debug.print;

// WARNING: make sure each line has exactly the same length!
// auto-format removing trailing spaces can mess things up
const data = @embedFile("data/day06.txt");

const Operation = enum {
    Add,
    Mul,

    fn parse(char: u8) ?Operation {
        return switch (char) {
            '+' => .Add,
            '*' => .Mul,
            else => null,
        };
    }

    fn exec(self: Operation, comptime T: type, a: ?T, b: ?T) error{Overflow}!T {
        std.debug.assert(a != null or b != null);
        return switch (self) {
            .Add => std.math.add(T, a orelse 0, b orelse 0),
            .Mul => std.math.mul(T, a orelse 1, b orelse 1),
        };
    }
};

fn isDigit(char: u8) bool {
    return char >= '0' and char <= '9';
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const alloc = gpa.allocator();

    const lineLen = std.mem.indexOfScalar(u8, data, '\n').? + 1;
    const lineCount = data.len / lineLen;

    // accumulated final result (sum of all section results)
    var result: u64 = 0;

    // operator for current section
    var op: ?Operation = null;

    // accumulated result for current section
    var acc: ?u64 = null;

    // accumulated digit characters of current number
    var numStr: std.ArrayList(u8) = .empty;

    // outer loop reads colums left to right
    for (0..lineLen) |col| {
        // inner loop reads characters in column top to bottom
        for (0..lineCount) |line| {
            const char = data[col + (line * lineLen)];

            if (Operation.parse(char)) |newOp| {
                op = newOp;
            } else if (isDigit(char)) {
                try numStr.append(alloc, char);
            } // else it's whitespace and can be ignored
        }

        // after we're done reading a column:

        if (numStr.items.len > 0) {
            // parse number, add to section result, and prepare for a new column
            const num = try std.fmt.parseInt(u64, numStr.items, 10);
            acc = try op.?.exec(u64, acc, num);

            numStr.deinit(alloc);
            numStr = .empty;
        } else {
            // no number in this column, which means it's a section separator
            // so we add the section result to final result and prepare for
            // a new section
            result += acc.?;
            op = null;
            acc = null;
        }
    }

    print("{}\n", .{result});
}
