package day01

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day06.txt")
    if !ok {
        return
    }
    defer delete(data)
    
    times := make([dynamic]int)
    defer delete(times)
    records := make([dynamic]int)
    defer delete(records)

    time_records := strings.split_lines(string(data))
    defer delete(time_records)
    
    time_str := strings.split(time_records[0],  " ")
    defer delete(time_str)
    for s in time_str {
        s := strings.trim(s, " ")
        num, ok := strconv.parse_int(s)
        if ok do append(&times, num)
    }

    records_str := strings.split(time_records[1],  " ")
    defer delete(records_str)
    for s in records_str {
        s := strings.trim(s, " ")
        num, ok := strconv.parse_int(s)
        if ok do append(&records, num)
    }

    total := 1
    for t, i in times {
        n := 0
        for j in 1..<t {
            if (t - j) * j > records[i] {
                n += 1
            }
        }
        total *= n
    }

    fmt.println(total)
}