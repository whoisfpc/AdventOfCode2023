package day16

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:container/queue"

Dir :: enum {
    Up,
    Left,
    Down,
    Right,
}

Dir_Set :: bit_set[Dir]

Dir_Vec := [Dir][2]int {
	.Up = {  -1, 0 },
	.Left = { 0,  -1 },
	.Down = {  +1, 0 },
	.Right = { 0, +1 },
}

Beam :: struct {
    x, y: int,
    dir: Dir,
}


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day16.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    grid : [dynamic][dynamic]rune
    flags : [dynamic][dynamic]Dir_Set
    defer {
        for g in grid do delete(g)
        delete(grid)
        for f in flags do delete(f)
        delete(flags)
    }
    
    for line in strings.split_lines_iterator(&it) {
        grid_line : [dynamic]rune
        flags_line : [dynamic]Dir_Set
        for c in line {
            append(&grid_line, c)
            x : Dir_Set
            append(&flags_line, x)
        }
        append(&grid, grid_line)
        append(&flags, flags_line)
    }

    beam := Beam{0,0,.Right}
    run_beam(grid, flags, beam)

    total := 0
    for line in flags {
        for f in line {
            if card(f) > 0 do total += 1
        }
    }

    fmt.println(total)
}

run_beam :: proc(grid: [dynamic][dynamic]rune, flags : [dynamic][dynamic]Dir_Set, beam: Beam) {
    q : queue.Queue(Beam)
    queue.init(&q)
    queue.push(&q, beam)
    defer queue.destroy(&q)

    n := len(grid)
    m := len(grid[0])

    for {
        b, ok := queue.pop_back_safe(&q)
        if !ok do break
        
        dir :Dir = b.dir
        if dir in flags[b.x][b.y] {
            continue
        }
        flags[b.x][b.y] += {dir}
        c := grid[b.x][b.y]
        //fmt.println(b, c)

        switch c {
            case '\\':
                reflect : Dir
                switch dir {
                    case .Up: reflect = .Left
                    case .Left: reflect = .Up
                    case .Down: reflect = .Right
                    case .Right: reflect = .Down
                }
                add_beam(&q, b.x, b.y, n, m, reflect)
            case '/':
                reflect : Dir
                switch dir {
                    case .Up: reflect = .Right
                    case .Left: reflect = .Down
                    case .Down: reflect = .Left
                    case .Right: reflect = .Up
                }
                add_beam(&q, b.x, b.y, n, m, reflect)
            case '-':
                if dir == .Up || dir == .Down {
                    add_beam(&q, b.x, b.y, n, m, Dir.Left)
                    add_beam(&q, b.x, b.y, n, m, Dir.Right)
                } else {
                    add_beam(&q, b.x, b.y, n, m, dir)
                }
            case '|':
                if dir == .Left || dir == .Right {
                    add_beam(&q, b.x, b.y, n, m, Dir.Up)
                    add_beam(&q, b.x, b.y, n, m, Dir.Down)
                } else {
                    add_beam(&q, b.x, b.y, n, m, dir)
                }
            case '.':
                add_beam(&q, b.x, b.y, n, m, dir)
        }
    }
}

add_beam :: proc(q : ^queue.Queue(Beam), x, y: int, n, m: int, dir: Dir) {
    x := x + Dir_Vec[dir].x
    y := y + Dir_Vec[dir].y
    if in_bround(x, y, n, m) {
        queue.push(q, Beam{x, y, dir})
    }
}

in_bround :: proc(x, y: int, n, m: int) -> bool {
    return x >= 0 && x < n && y >= 0 && y < m
}
