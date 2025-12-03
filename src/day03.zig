const std = @import("std");
const print = std.debug.print;

const joltageLen = 12; // 2 for part one, 12 for part two
const data = @embedFile("data/day03.txt");
// const data =
//     \\987654321111111
//     \\811111111111119
//     \\234234234234278
//     \\818181911112111
// ;

fn charToInt(char: u8) !u8 {
    return try std.fmt.parseInt(u8, &[_]u8{char}, 10);
}

pub fn main() !void {
    var lines = std.mem.splitScalar(u8, data, '\n');

    var result: u64 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var joltageChars: [joltageLen]?u8 = .{null} ** joltageLen;
        for (line, 0..) |digitChar, d| {
            var alreadyChanged = false;
            for (&joltageChars, 0..) |*joltageChar, j| {
                if (alreadyChanged) {
                    // a previous digit of the joltage was changed:
                    // set all subsequent digits to null so they get the next
                    // available value
                    joltageChar.* = null;
                    continue;
                }

                if (d > line.len - joltageLen + j) {
                    // remaining digits in the line are less than the
                    // remaining joltage digits:
                    // then we can't change the current joltage digit,
                    // otherwise there won't be enough digits left in the line
                    // for subsequent digits
                    continue;
                }

                if (joltageChar.* == null or digitChar > joltageChar.*.?) {
                    // change the joltage digit to the line digit if either:
                    // 1. we haven't saved anything for the current digit yet,
                    //    either because we're at the start of the line, or
                    //    a previous digit was changed
                    // 2. the line digit is greater than the digit we've
                    //    saved
                    // NOTE: comparing as chars rather than ints here, which
                    // should be fine since input is guaranteed to be numbers
                    joltageChar.* = digitChar;
                    alreadyChanged = true;
                }
            }
        }

        var joltageInt: u64 = 0;
        for (joltageChars, 0..) |j, i| {
            const digitInt = try charToInt(j.?);
            const pow10 = std.math.pow(u64, 10, joltageLen - i - 1);
            joltageInt += digitInt * pow10;
        }

        result += joltageInt;
    }
    print("{}\n", .{result});
}
