package day02

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day09.txt")
    if !ok {
        return
    }
    defer delete(data)
    
    total := 0
    it := string(data)
    values := make([dynamic]int)
    defer delete(values)
    
    for line in strings.split_lines_iterator(&it) {
        vs := strings.split(line, " ")
        defer delete(vs)
        clear(&values)
        for v in vs {
            value, _ := strconv.parse_int(v)
            append(&values, value)
        }
        p := predicate(values[:], 0)
        //fmt.println("p is", p)
        total += p
    }
    fmt.println(total)
}

predicate :: proc(seq: []int, meow: int) -> int {
    //fmt.println(seq[:])
    //if meow > 5 do return 0
    if slice.all_of(seq, 0) {
        return 0
    }

    length := len(seq)
    next_seq := make([dynamic]int, 0, length)
    defer delete(next_seq)

    for i in 0..<length-1 {
        append(&next_seq, seq[i + 1] - seq[i])
    }

    v := predicate(next_seq[:], meow + 1)
    return seq[length-1] + v
}
