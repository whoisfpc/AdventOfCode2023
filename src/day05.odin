package day05

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"

Pair :: struct {
    dest : int,
    source : int,
    length : int,
}


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day05.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    locations := make([dynamic]int)
    defer delete(locations)
    translater := make([dynamic]Pair)
    defer delete(translater)

    line_idx := 0
    for line in strings.split_lines_iterator(&it) {
        if line_idx == 0 {
            line_clone := strings.clone(line)
            origin_line := line_clone
            defer delete(origin_line)
            for seed in strings.split_iterator(&line_clone, " ") {
                num, ok := strconv.parse_int(seed)
                if ok do append(&locations, num)
            }
        } else if line_idx > 1{
            if strings.contains(line, "map:") {
                clear(&translater)
            } else if line == "" {
                //fmt.println(translater)
                //fmt.println("empty line")
                translate_locations(&locations, &translater)
            } else {
                num_strs := strings.split(line, " ")
                defer delete(num_strs)
                dest, _ := strconv.parse_int(num_strs[0])
                source, _ := strconv.parse_int(num_strs[1])
                length, _ := strconv.parse_int(num_strs[2])
                append(&translater, Pair{dest, source, length})
            }
        }
        line_idx += 1
    }
    translate_locations(&locations, &translater)
    fmt.println(slice.min(locations[:]))
    //fmt.println(locations[:])
}

translate_locations :: proc(locations: ^[dynamic]int, translater : ^[dynamic]Pair) {
    for location, i in locations {
        locations[i] = find_dest(location, translater)
    }
}

find_dest :: proc(location: int, translater : ^[dynamic]Pair) -> int {
    for pair in translater {
        if location >= pair.source && location < pair.source + pair.length {
            return location - pair.source + pair.dest
        }
    }
    return location
}