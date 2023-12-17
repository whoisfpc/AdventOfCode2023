package day12

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"


main :: proc() {
    part2()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day12.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    char_record := make([dynamic]rune)
    defer delete(char_record)
    num_record := make([dynamic]int)
    defer delete(num_record)


    total := 0
    max_num_count := 0
    max_char_count := 0
    for line in strings.split_lines_iterator(&it) {
        clear(&char_record)
        clear(&num_record)
        sp := strings.split(line, " ")
        defer delete(sp)
        for c in sp[0] {
            append(&char_record, c)
        }
        for n in strings.split_iterator(&sp[1], ",") {
            num, _ := strconv.parse_int(n)
            append(&num_record, num)
        }
        arrangement := calc_arrangement(char_record[:], num_record[:])
        total += arrangement
        fmt.println(arrangement)
    }

    fmt.println("total is", total)
}

part2 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day12.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    char_record := make([dynamic]rune)
    defer delete(char_record)
    num_record := make([dynamic]int)
    defer delete(num_record)


    total := 0
    max_num_count := 0
    max_char_count := 0
    for line in strings.split_lines_iterator(&it) {
        clear(&char_record)
        clear(&num_record)
        sp := strings.split(line, " ")
        defer delete(sp)
        for i in 0..<5 {
            for c in sp[0] {
                append(&char_record, c)
            }
            if i != 4 do append(&char_record, '?')
        }
        for i in 0..<5 {
            num_str := sp[1]
            for n in strings.split_iterator(&num_str, ",") {
                num, _ := strconv.parse_int(n)
                append(&num_record, num)
            }
        }
        arrangement := calc_arrangement(char_record[:], num_record[:])
        total += arrangement
        fmt.println(arrangement)
    }

    fmt.println("total is", total)
}

calc_arrangement :: proc(chars: []rune, nums: []int) -> int {
    n := len(nums)
    m := len(chars)
    dp := make([dynamic][dynamic]int)
    for i in 0..<n {
        a := make([dynamic]int, m)
        append(&dp, a)
    }
    defer {
        
        for p in dp {
            //fmt.println(p)
            delete(p)
        }
        delete(dp)
    }

    for j in 0..<m {
        v := check_damage(chars[0:j+1], nums[0])
        dp[0][j] = v
    }

    for i in 1..<n {
        d := nums[i]
        for j in 0..<m {
            dp[i][j] = 0
            if j < d - 1 {
                // do nothing
                continue
            } 
            k_init := j - d - 1
            for k := j; k >= 0; k -= 1 {
                if k > k_init {
                    if k > j-d {
                        if chars[k] != '#' && chars[k] != '?' {
                            break
                        }
                    } else if chars[k] != '.' && chars[k] != '?' {
                        break
                    }
                } else {
                    dp[i][j] += dp[i-1][k]
                    if chars[k] != '.' && chars[k] != '?' {
                        break
                    }
                }
            }
        }
    }

    total := 0
    for j in 0..<m {
        v := check_damage(chars[j+1:], 0)
        total += dp[n-1][j] * v
    }

    return total
}

check_damage :: proc(chars: []rune, tail_count: int) -> int {
    if len(chars) < tail_count {
        return 0
    }

    s := len(chars) - tail_count

    for c, i in chars {
        if i < s {
            if c != '.' && c != '?' {
                return 0
            }
        } else {
            if c != '#' && c != '?' {
                return 0
            }
        } 
    }
    return 1
}