package day04

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"


main :: proc() {
    part1and2()
}

part1and2 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day04.txt")
    if !ok {
        return
    }
    defer delete(data)
    
    win_nums := make([dynamic]int)
    have_nums := make([dynamic]int)
    defer delete(win_nums)
    defer delete(have_nums)
    
    total := 0
    it := string(data)
    line_count := strings.count(it, "\n") + 1
    cards := make([dynamic]int, 0, line_count)
    for i in 0..<line_count {
        append(&cards, 1)
    }

    defer delete(cards)

    idx := 0
    for line in strings.split_lines_iterator(&it) {
        points := 0
        matchs := 0
        clear(&win_nums)
        clear(&have_nums)
        colon_idx := strings.index_rune(line, ':')
        numbers_line := line[colon_idx + 1:]
        win_and_have := strings.split(numbers_line, "|")
        defer delete(win_and_have)
        for s in strings.split_iterator(&win_and_have[0], " ") {
            if s != "" {
                n, _ := strconv.parse_int(s)
                append(&win_nums, n)
            }
        }
        for s in strings.split_iterator(&win_and_have[1], " ") {
            if s != "" {
                n, _ := strconv.parse_int(s)
                append(&have_nums, n)
                if slice.contains(win_nums[:], n) {
                   points = 1 if points == 0 else points * 2
                   matchs += 1
                }
            }
        }
        if matchs > 0 {
            for i in idx+1..=idx+matchs {
                if i < line_count do cards[i] += cards[idx]
            }
        }
        total += points
        idx += 1
    }
    fmt.println(total)
    fmt.println(math.sum(cards[:]))
}