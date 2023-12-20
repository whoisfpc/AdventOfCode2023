package day15

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day15.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)
    
    total := 0
    for s in strings.split_iterator(&it, ",") {
        total += hash(s)
        // fmt.println(s, hash(s))
    }

    fmt.println(total)
}

hash :: proc(s: string) -> int {
    v := 0
    for c in s {
        v += int(c)
        v *= 17
        v %= 256
    }
    return v
}
