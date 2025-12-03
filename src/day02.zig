const std = @import("std");
const print = std.debug.print;

const data = @embedFile("data/day02.txt");
// const data = "9-9,11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

fn isValid(num: u64) !bool {
    // convert number into string
    const maxDigits = comptime std.math.log10_int(@as(u64, std.math.maxInt(u64)));
    var buf: [maxDigits]u8 = undefined;
    const digits = try std.fmt.bufPrint(&buf, "{}", .{num});

    // loop through all possibly repeating sections
    sections: for (0..digits.len / 2) |i| {
        const sectionLen = i + 1;

        // it cannot be repeated if the lengths aren't evenly divisible
        if (digits.len % sectionLen != 0) continue :sections;

        // loop through subsequent sections
        const section1 = digits[0..sectionLen];
        for (1..digits.len / sectionLen) |j| {
            const section2 = digits[sectionLen * j .. sectionLen * (j + 1)];

            // if subsequent section is not equal, the repetition is broken
            if (!std.mem.eql(u8, section1, section2)) continue :sections;
        }

        // if we reached this point, all sections were equal; there is
        // a repetition which makes the number invalid
        return false;
    }

    // if we reached this point, there were no repetitions which makes the
    // number valid
    return true;
}

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
};

pub fn main() !void {
    var ranges = std.mem.splitScalar(u8, std.mem.trim(u8, data, "\n"), ',');

    var result: u64 = 0;

    while (ranges.next()) |rangeStr| {
        const range = Range.parse(rangeStr) catch |err| {
            print("{s}\n", .{rangeStr});
            return err;
        };

        for (range.first..range.last + 1) |num| {
            if (!try isValid(num)) result += num;
        }
    }

    print("{}\n", .{result});
}
