package day01

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day01.txt")
    if !ok {
        return
    }
    defer delete(data)
    
    total := 0
    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        first, last := 0, 0
        is_first := true
        for c in line {
            switch c {
                case '0'..='9':
                    d := int(c) - int('0')
                    if is_first {
                        is_first = false
                        first, last = d, d
                    } else {
                        last = d
                    }
            }
        }
        total += first * 10 + last
    }
    fmt.println(total)
}