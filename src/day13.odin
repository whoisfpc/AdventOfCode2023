package day13

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day13.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)
    all_lines := strings.split_lines(it)
    defer delete(all_lines)

    patterns := make([dynamic][dynamic]rune)
    defer delete_2d_array(patterns)

    total := 0
    
    for line, i in all_lines {
        if line == "" {
            total += add_mirror_num(patterns)
            
            clear(&patterns)
        } else {
            p := make([dynamic]rune)
            for c in line {
                append(&p, c)
            }
            append(&patterns, p)
            if i == len(all_lines)-1 {
                total += add_mirror_num(patterns)
            
                clear(&patterns)
            }
        }
    }

    fmt.println(total)
}

add_mirror_num :: proc(patterns: [dynamic][dynamic]rune) -> int {
    mirror_col := get_mirror(patterns)
    // for p in patterns {
    //     fmt.println(p)
    // }
    // fmt.println()

    patterns_t := transpose(patterns)
    defer delete_2d_array(patterns_t)
    mirror_row := get_mirror(patterns_t)
    // for p in patterns_t {
    //     fmt.println(p)
    // }
    // fmt.println("mirror", mirror_col, mirror_row)

    total := 0
    if mirror_col > 0 do total += mirror_col
    if mirror_row > 0 do total += mirror_row * 100

    return total
}

delete_2d_array :: proc(patterns: [dynamic][dynamic]rune) {
    for p in patterns {
        delete(p)
    }
    delete(patterns)
}

transpose :: proc(patterns: [dynamic][dynamic]rune) -> [dynamic][dynamic]rune {
    patterns_t := make([dynamic][dynamic]rune)
    n := len(patterns)
    m := len(patterns[0])
    for j in 0..<m {
        p := make([dynamic]rune)
        for i in 0..<n {
            append(&p, patterns[i][j])
        }
        append(&patterns_t, p)
    }
    return patterns_t
}

get_mirror :: proc(patterns: [dynamic][dynamic]rune) -> int {

    m := len(patterns[0])
    for j in 0..<m-1 {
        pass := true
        check_mirror: for p in patterns {
            for i in 0..=j {
                k := j-i+1 + j
                if k >= m do continue
                if p[i] != p [k] {
                    pass = false
                    break check_mirror
                }
            }
        }
        if pass do return j+1
    }
    return -1
}
