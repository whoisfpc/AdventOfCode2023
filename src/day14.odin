package day14

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day14.txt")
    if !ok {
        return
    }
    defer delete(data)
    lines := strings.split_lines(string(data))
    defer delete(lines)

    rocks := make([dynamic][dynamic]rune)
    defer {
        for p in rocks do delete(p)
        delete(rocks)
    }

    for line, i in lines {
        p := make([dynamic]rune)
        for c, j in line {
            append(&p, c)
        }
        append(&rocks, p)
    }

    tile_north(rocks)
    
    total := calc_load(rocks)
    fmt.println(total)
}

calc_load :: proc(rocks: [dynamic][dynamic]rune) -> int {
    total := 0
    n := len(rocks)
    
    for line, i in rocks {
        for c, j in line {
            if c == 'O' {
                total += n - i
            }
        }
    }

    return total
}

tile_north :: proc(rocks: [dynamic][dynamic]rune) {
    stops := make([dynamic]int, len(rocks[0]))
    defer delete(stops)

    for line, i in rocks {
        for c, j in line {
            if c == '#' {
                stops[j] = i + 1
            } else if c == 'O' {
                if stops[j] != i {
                    rocks[stops[j]][j] = 'O'
                    rocks[i][j] = '.'
                }
                stops[j] += 1
            }
        }
    }
}
