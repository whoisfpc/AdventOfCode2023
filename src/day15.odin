package day15

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

HashEntry :: struct {
    label: string,
    focal: int,
}


main :: proc() {
    part2()
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
        fmt.println(s, hash(s))
    }

    fmt.println(total)
}

part2 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day15.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    hashmap : [256][dynamic]HashEntry
    defer {
        for e in hashmap do delete(e)
    }
    
    for s in strings.split_iterator(&it, ",") {
        if equal_idx := strings.index_rune(s, '='); equal_idx != -1 {
            label := s[:equal_idx]
            focal, _ := strconv.parse_int(s[equal_idx+1:])
            h := hash(label)
            set_entry(&hashmap, HashEntry{label, focal}, h)
        } else {
            dash_idx := strings.index_rune(s, '-')
            label := s[:dash_idx]
            h := hash(label)
            remove_entry(&hashmap, label, h)
        }
    }

    total := 0
    for p, i in hashmap {
        for e, j in p {
            total += (i+1) * (j+1) * e.focal
        }
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

set_entry :: proc(hashmap: ^[256][dynamic]HashEntry, entry: HashEntry, hash: int) {
    for &e, i in hashmap[hash] {
        if e.label == entry.label {
            e.focal = entry.focal
            return
        }
    }

    append(&hashmap[hash], entry)
}

remove_entry ::proc(hashmap: ^[256][dynamic]HashEntry, label: string, hash: int) {
    idx := -1
    for e, i in hashmap[hash] {
        if e.label == label {
            idx = i
            break
        }
    }

    if idx != -1 {
        ordered_remove(&hashmap[hash], idx)
    }
}

