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

    stops := make([dynamic]int, len(lines[0]))
    defer delete(stops)

    n := len(lines)
    total := 0
    
    for line, i in lines {
        for c, j in line {
            if c == '#' {
                stops[j] = i + 1
            } else if c == 'O' {
                total += n - stops[j]
                stops[j] += 1
            }
        }
    }

    fmt.println(total)
}
