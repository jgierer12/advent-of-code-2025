const std = @import("std");
const print = std.debug.print;

const data = @embedFile("data/day04.txt");
// const data =
//     \\..@@.@@@@.
//     \\@@@.@.@.@@
//     \\@@@@@.@.@@
//     \\@.@@@@..@.
//     \\@@.@@@@.@@
//     \\.@@@@@@@.@
//     \\.@.@.@.@@@
//     \\@.@@@.@@@@
//     \\.@@@@@@@@.
//     \\@.@.@@@.@.
// ;

// number of columns in map = index of first line break
const cols = std.mem.indexOfScalar(u8, data, '\n').?;

// calculate index when moving from index i by dx and dy
// eg. dx = 1 dy = -1 is north-east
// returns null if result is out of bounds
fn adjectentIndex(i: usize, dx: i2, dy: i2) ?usize {
    const signedI: isize = @intCast(i);
    const signedCols: isize = @intCast(cols);
    const result = signedI + (dy * (signedCols + 1)) + dx;

    if (result < 0 or result >= data.len) {
        return null;
    } else {
        return @intCast(result);
    }
}

// recursively remove accessible rolls of paper from map
// returns accumulated amount of removed rolls
fn removeRolls(map: [data.len]u8, acc: u16) u16 {
    var newMap = map;
    var removed: u16 = 0;
    for (map, 0..) |char, i| {
        if (char != '@') {
            continue;
        }

        const adjacent = [_]?usize{
            adjectentIndex(i, -1, -1), // nw
            adjectentIndex(i, 0, -1), // n
            adjectentIndex(i, 1, -1), // ne
            adjectentIndex(i, -1, 0), // w
            adjectentIndex(i, 1, 0), // e
            adjectentIndex(i, -1, 1), // sw
            adjectentIndex(i, 0, 1), // s
            adjectentIndex(i, 1, 1), //se
        };

        var occupied: u4 = 0;
        for (adjacent) |a| {
            if (a != null and map[a.?] == '@') {
                occupied += 1;
            }
        }

        if (occupied < 4) {
            removed += 1;
            newMap[i] = '.';
        }
    }

    if (removed == 0) return acc;

    return removeRolls(newMap, acc + removed);
}

pub fn main() !void {
    const result = removeRolls(data[0..data.len].*, 0);
    print("{}\n", .{result});
}
