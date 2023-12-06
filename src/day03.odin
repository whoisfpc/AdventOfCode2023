package day03

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    part1()
}

Digit :: struct {
    value: int,
    start_idx: int,
    end_idx: int,
    row: int,
}

part1 :: proc() {
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
                            start_idx = start_idx,
                            end_idx = j - 1,
                            row = i,
                        }
                        append(&digits, digit)
                    }
            }
            if j == column - 1 && combine_digit {
                digit := Digit {
                    value = digit_value,
                    start_idx = start_idx,
                    end_idx = j,
                    row = i,
                }
                append(&digits, digit)
            }
        }
    }
    
    total := 0
    for &digit in digits {
        left_up_i := digit.row - 1
        left_up_j := digit.start_idx - 1
        right_bottom_i := digit.row + 1
        right_bottom_j := digit.end_idx + 1

        check_pass := false
        check_loop: for i in left_up_i..=right_bottom_i {
            for j in left_up_j..=right_bottom_j {
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

    fmt.println("total is", total)
}