package day11

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:intrinsics"

Pos :: distinct [2]int


main :: proc() {
    part2()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day11.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    universe := make([dynamic][dynamic]rune)
    defer {
        for u in universe do delete(u)
        delete(universe)
    }

    for line in strings.split_lines_iterator(&it) {
        uni_line := make([dynamic]rune)
        for c in line do append(&uni_line, c)
        append(&universe, uni_line)
    }

    n := len(universe)
    m := len(universe[0])

    empty_rows := make([dynamic]int)
    empty_columns := make([dynamic]int)
    defer delete(empty_rows)
    defer delete(empty_columns)

    for r, i in universe {
        if slice.all_of(r[:], '.') do append(&empty_rows, i)
    }

    for j in 0..<m {
        empty := true
        for i in 0..<n {
            if universe[i][j] != '.' {
                empty = false
                break
            }
        }

        if empty do append(&empty_columns, j)
    }

    //fmt.println(empty_rows, empty_columns)

    galaxies := make([dynamic]Pos)
    defer delete(galaxies)

    for r, i in universe {
        for c, j in r {
            if c == '#' do append(&galaxies, Pos{i, j})
        }
    }

    for g, i in galaxies {
        expand_rows := less_count(empty_rows[:], g.x)
        expand_columns := less_count(empty_columns[:], g.y)
        galaxies[i] = Pos{g.x + expand_rows, g.y + expand_columns}
    }

    total := 0
    g_count := len(galaxies)
    for i in 0..<g_count-1 {
        for j in i+1..<g_count {
            ga := galaxies[i]
            gb := galaxies[j]
            total += abs(gb.x - ga.x) + abs(gb.y - ga.y)
        }
    }

    fmt.println(total)
}

part2 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day11.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    universe := make([dynamic][dynamic]rune)
    defer {
        for u in universe do delete(u)
        delete(universe)
    }

    for line in strings.split_lines_iterator(&it) {
        uni_line := make([dynamic]rune)
        for c in line do append(&uni_line, c)
        append(&universe, uni_line)
    }

    n := len(universe)
    m := len(universe[0])

    empty_rows := make([dynamic]int)
    empty_columns := make([dynamic]int)
    defer delete(empty_rows)
    defer delete(empty_columns)

    for r, i in universe {
        if slice.all_of(r[:], '.') do append(&empty_rows, i)
    }

    for j in 0..<m {
        empty := true
        for i in 0..<n {
            if universe[i][j] != '.' {
                empty = false
                break
            }
        }

        if empty do append(&empty_columns, j)
    }

    //fmt.println(empty_rows, empty_columns)

    galaxies := make([dynamic]Pos)
    defer delete(galaxies)

    for r, i in universe {
        for c, j in r {
            if c == '#' do append(&galaxies, Pos{i, j})
        }
    }

    expand_amount :: 1000000

    for g, i in galaxies {
        expand_rows := less_count(empty_rows[:], g.x) * (expand_amount - 1)
        expand_columns := less_count(empty_columns[:], g.y) * (expand_amount - 1)
        galaxies[i] = Pos{g.x + expand_rows, g.y + expand_columns}
    }

    total := 0
    g_count := len(galaxies)
    for i in 0..<g_count-1 {
        for j in i+1..<g_count {
            ga := galaxies[i]
            gb := galaxies[j]
            total += abs(gb.x - ga.x) + abs(gb.y - ga.y)
        }
    }

    fmt.println(total)
}

less_count :: proc(s: $S/[]$T, value: T) -> (n: int) where intrinsics.type_is_comparable(T) {
	for v in s {
		if v < value {
			n += 1
		}
	}
	return
}
