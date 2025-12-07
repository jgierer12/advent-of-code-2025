const std = @import("std");
const print = std.debug.print;

const data = @embedFile("data/day07.txt");
// const data =
//     \\.......S.......
//     \\...............
//     \\.......^.......
//     \\...............
//     \\......^.^......
//     \\...............
//     \\.....^.^.^.....
//     \\...............
//     \\....^.^...^....
//     \\...............
//     \\...^.^...^.^...
//     \\...............
//     \\..^...^.....^..
//     \\...............
//     \\.^.^.^.^.^...^.
//     \\...............
// ;

const MAX_COLS = 141;

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    const lineLen = lines.peek().?.len;

    if (MAX_COLS < lineLen) return error.MaxColsTooSmall;

    // for each column, stores how many timelines currently go through it
    var timelinesByColumn: [MAX_COLS]u64 = @splat(0);

    while (lines.next()) |line| {
        for (line, 0..) |char, i| {
            switch (char) {
                'S' => {
                    timelinesByColumn[i] = 1;
                    break;
                },
                '^' => {
                    const amount = timelinesByColumn[i];
                    timelinesByColumn[i] = 0;

                    if (i > 0) {
                        timelinesByColumn[i - 1] += amount;
                    }
                    if (i < lineLen - 1) {
                        timelinesByColumn[i + 1] += amount;
                    }
                },
                else => {},
            }
        }
    }

    var timelines: u64 = 0;
    for (timelinesByColumn) |n| {
        timelines += n;
    }

    print("{}\n", .{timelines});
}
