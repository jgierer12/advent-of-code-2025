const std = @import("std");
const print = std.debug.print;

const data = @embedFile("data/day01.txt");

const Direction = enum {
    L,
    R,

    fn parse(char: u8) error{InvalidDirection}!Direction {
        return switch (char) {
            'L' => .L,
            'R' => .R,
            else => return error.InvalidDirection,
        };
    }
};

const Instruction = struct {
    direction: Direction,
    amount: u16,

    fn parse(str: []const u8) error{ InvalidDirection, InvalidCharacter, Overflow }!Instruction {
        const direction = try Direction.parse(str[0]);
        const amount = try std.fmt.parseInt(u16, str[1..], 10);

        return Instruction{ .direction = direction, .amount = amount };
    }
};

const Dial = struct {
    position: i16,

    fn rotateOnce(self: *Dial, direction: Direction) void {
        self.position = switch (direction) {
            .L => @mod(self.position - 1, 100),
            .R => @mod(self.position + 1, 100),
        };
    }

    fn rotate(self: *Dial, instruction: Instruction) u16 {
        var zeroes: u16 = 0;

        var i: u16 = 0;
        while (i < instruction.amount) : (i += 1) {
            self.rotateOnce(instruction.direction);
            if (self.position == 0) {
                zeroes += 1;
            }
        }

        return zeroes;
    }
};

pub fn main() !void {
    var lines = std.mem.splitScalar(u8, data, '\n');

    var dial = Dial{ .position = 50 };
    var zeroes: u16 = 0;

    var lineNumber: u16 = 1;
    while (lines.next()) |line| : (lineNumber += 1) {
        if (line.len == 0) continue;

        const instruction = Instruction.parse(line) catch |err| {
            print("Line {}: {s}\n", .{ lineNumber, line });
            return err;
        };

        zeroes += dial.rotate(instruction);
    }

    print("{}\n", .{zeroes});
}
