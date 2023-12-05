package day02

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day02.txt")
    if !ok {
        return
    }
    defer delete(data)
    
    total := 0
    it := string(data)
    line_idx := 0
    for line in strings.split_lines_iterator(&it) {
        line_idx += 1
        colon_idx := strings.index_rune(line, ':')
        cube_sets := line[colon_idx + 1:]
        valid_game := true
        set_loop: for set in strings.split_iterator(&cube_sets, ";") {
            set_clone := strings.clone(set)
            for cube in strings.split_iterator(&set_clone, ",") {
                cube := strings.trim(cube, " ")
                cube_pair := strings.split(cube, " ")
                defer delete(cube_pair)
                num := strconv.atoi(cube_pair[0])
                color := cube_pair[1]
                //fmt.println(cube_pair, num, color)
                switch color {
                    case "red":
                        if num > 12 {
                            valid_game = false
                            break set_loop
                        }
                    case "green":
                        if num > 13 {
                            valid_game = false
                            break set_loop
                        }
                    case "blue":
                        if num > 14 {
                            valid_game = false
                            break set_loop
                        }
                }
            }
        }
        if valid_game do total += line_idx
    }
    fmt.println(total)
}
