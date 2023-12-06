package day03

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    part1and2()
}

Digit :: struct {
    value: int,
    min_i :int,
    min_j :int,
    max_i :int,
    max_j :int,
}

part1and2 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day03.txt")
    if !ok {
        return
    }
    defer delete(data)

    it := string(data)
    lines := strings.split_lines(it)
    defer delete(lines)
    
    row := len(lines)
    column := len(lines[0])
    
    m := make([dynamic][dynamic]byte, 0, row)
    defer {
        for n in m {
            delete(n)
        }
        delete(m)
    }
    
    for line, idx in lines {
        n := make([dynamic]byte, 0, column)
        append(&n, ..transmute([]u8)line)
        append(&m, n)
    }

    digits := make([dynamic]Digit)
    defer delete(digits)

    for i in 0..<row {
        combine_digit := false
        digit_value : int
        start_idx : int
        for j in 0..<column {
            c := m[i][j]

            switch c {
                case '0'..='9':
                    d := int(c) - int('0')
                    if combine_digit {
                        digit_value = digit_value * 10 + d
                    } else {
                        combine_digit = true
                        digit_value = d
                        start_idx = j
                    }
                case:
                    if combine_digit {
                        combine_digit = false
                        digit := Digit {
                            value = digit_value,
                            min_i = i - 1,
                            min_j = start_idx - 1,
                            max_i = i + 1,
                            max_j = j,
                        }
                        append(&digits, digit)
                    }
            }
            if j == column - 1 && combine_digit {
                digit := Digit {
                    value = digit_value,
                    min_i = i - 1,
                    min_j = start_idx - 1,
                    max_i = i + 1,
                    max_j = j + 1,
                }
                append(&digits, digit)
            }
        }
    }
    
    {
        total := 0
        for &digit in digits {
            check_pass := false
            check_loop: for i in digit.min_i..=digit.max_i {
                for j in digit.min_j..=digit.max_j {
                    if i >= 0 && i < row && j >= 0 && j < column {
                        c := m[i][j]

                        switch c {
                            case '0'..='9', '.':
                            case:
                                check_pass = true
                                break check_loop
                            }
                    }
                }
            }

            if check_pass {
                total += digit.value
            }
        }

        fmt.println("part 1 is", total)
    }

    {
        gears := make([dynamic]bool, len(digits))
        defer delete(gears)
        total := 0
        for &a, i in digits {
            if !gears[i] {
                gear_loop: for &b, j in digits {
                    if i != j && check_aabb(&a, &b) {
                        for x in a.min_i..=a.max_i {
                            for y in a.min_j..=a.max_j {
                                if x >= 0 && x < row && y >= 0 && y < column {
                                    c := m[x][y]
                                    if c == byte('*') && check_inside_aabb(&a, x, y) && check_inside_aabb(&b, x, y) {
                                        //fmt.println(a.value, "*", b.value)
                                        total += a.value * b.value
                                        gears[i] = true
                                        gears[j] = true
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        fmt.println("part 2 is", total)
    }
}

check_aabb :: proc(a, b: ^Digit) -> bool {
    result :=
        a.min_i <= b.max_i &&
        a.max_i >= b.min_i &&
        a.min_j <= b.max_j &&
        a.max_j >= b.min_j

    return result
}

check_inside_aabb :: proc(a : ^Digit, i, j : int) -> bool {
    result :=
        i >= a.min_i &&
        i <= a.max_i &&
        j >= a.min_j &&
        j <= a.max_j
    
        return result
}