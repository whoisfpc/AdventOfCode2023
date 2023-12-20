package day14

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"


main :: proc() {
    part2()
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

part2 :: proc() {
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

    loads := make([dynamic]int)
    defer delete(loads)
    pattern_map := make(map[string]int)
    defer {
        for k, v in pattern_map {
            delete(k)
        }
        delete(pattern_map)
    }

    last_pattern : string
    last_cycle := 0
    CYCLES :: 1000000000
    for i in 0..<CYCLES {
        tile_north(rocks)
        tile_west(rocks)
        tile_south(rocks)
        tile_east(rocks)

        pattern := rocks_to_string(rocks)
        if pattern in pattern_map {
            last_pattern = pattern
            last_cycle = i
            break
        }
        append(&loads, calc_load(rocks))
        pattern_map[pattern] = i
    }
    
    offset := pattern_map[last_pattern]
    repetition := last_cycle - offset
    fmt.println(last_cycle, offset, repetition)
    idx := (CYCLES - 1 - offset) % repetition + 1 + offset
    fmt.println(loads[idx - 1])
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

rocks_to_string :: proc(rocks: [dynamic][dynamic]rune) -> string {
    sb := strings.builder_make()
    defer strings.builder_destroy(&sb)
    for line, i in rocks {
        for c, j in line {
            if c == 'O' {
                strings.write_int(&sb, i)
                strings.write_rune(&sb, ',')
                strings.write_int(&sb, j)
                strings.write_rune(&sb, ',')
            }
        }
    }
    return strings.clone(strings.to_string(sb))
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

tile_west :: proc(rocks: [dynamic][dynamic]rune) {
    stops := make([dynamic]int, len(rocks))
    defer delete(stops)

    for line, i in rocks {
        for c, j in line {
            if c == '#' {
                stops[i] = j + 1
            } else if c == 'O' {
                if stops[i] != j {
                    rocks[i][stops[i]] = 'O'
                    rocks[i][j] = '.'
                }
                stops[i] += 1
            }
        }
    }
}

tile_south :: proc(rocks: [dynamic][dynamic]rune) {
    stops := make([dynamic]int, len(rocks[0]))
    n := len(rocks)
    for _, i in stops {
        stops[i] = n-1
    }
    defer delete(stops)

    #reverse for line, i in rocks {
        for c, j in line {
            if c == '#' {
                stops[j] = i - 1
            } else if c == 'O' {
                if stops[j] != i {
                    rocks[stops[j]][j] = 'O'
                    rocks[i][j] = '.'
                }
                stops[j] -= 1
            }
        }
    }
}

tile_east :: proc(rocks: [dynamic][dynamic]rune) {
    stops := make([dynamic]int, len(rocks))
    m := len(rocks[0])
    for _, i in stops {
        stops[i] = m-1
    }
    defer delete(stops)

    for line, i in rocks {
        #reverse for c, j in line {
            if c == '#' {
                stops[i] = j - 1
            } else if c == 'O' {
                if stops[i] != j {
                    rocks[i][stops[i]] = 'O'
                    rocks[i][j] = '.'
                }
                stops[i] -= 1
            }
        }
    }
}
