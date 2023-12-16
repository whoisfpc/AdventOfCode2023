package day10

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

// Tile :: enum {
//     Start,
//     NorthSouth,
//     EastWest,
//     NorthEast,
//     NorthWest,
//     SouthWest,
//     SouthEest,
//     Ground
// }

From_Dir :: enum {
    North,
    South,
    West,
    East
}

Node :: struct {
    i, j: int, // current i and j
    from: From_Dir, // from where
    step_count: int,
}


main :: proc() {
    part2()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day10.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    tiles := make([dynamic][dynamic]rune)
    defer {
        for tile_line in tiles {
            delete(tile_line)
        }
        delete(tiles)
    }

    start_i, start_j : int

    line_idx := 0
    for line in strings.split_lines_iterator(&it) {
        defer line_idx += 1
        tile_line := make([dynamic]rune)
        for c, j in line {
            if c == 'S' {
                start_i, start_j = line_idx, j
            }
            append(&tile_line, rune(c))
        }
        append(&tiles, tile_line)
    }

    n := len(tiles)
    m := len(tiles[0])

    steps := make([dynamic][dynamic]int)
    defer {
        for step_line in steps {
            delete(step_line)
        }
        delete(steps)
    }
    for i in 0..<n {
        step_line := make([dynamic]int, m)
        for j in 0..<m do step_line[j] = -1
        append(&steps, step_line)
    }

    steps[start_i][start_j] = 0

    step_queue := make([dynamic]Node)
    defer delete(step_queue)
    append(&step_queue, Node {start_i - 1, start_j, From_Dir.South, 1})
    append(&step_queue, Node {start_i + 1, start_j, From_Dir.North, 1})
    append(&step_queue, Node {start_i, start_j - 1, From_Dir.East, 1})
    append(&step_queue, Node {start_i, start_j + 1, From_Dir.West, 1})

    max_step := 0
    for len(step_queue) > 0 {
        node := step_queue[0]
        ordered_remove(&step_queue, 0)
        i, j := node.i, node.j
        
        if i < 0 || i >= n do continue
        if j < 0 || j >= m do continue
        if steps[i][j] != -1 do continue
        
        new_node, pass := to_next_pipe(tiles, node)
        if pass {
            //fmt.println("check", node, "pass")
            //fmt.println("append", new_node)
            steps[i][j] = node.step_count
            max_step = max(max_step, node.step_count)
            append(&step_queue, new_node)
        } else {
            //fmt.println("check", node, "not pass")
        }
    }

    // for s in steps {
    //     fmt.println(s[:])
    // }
    fmt.println(max_step)
}

part2 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day10.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    tiles := make([dynamic][dynamic]rune)
    defer {
        for tile_line in tiles {
            delete(tile_line)
        }
        delete(tiles)
    }

    start_i, start_j : int

    line_idx := 0
    for line in strings.split_lines_iterator(&it) {
        defer line_idx += 1
        tile_line := make([dynamic]rune)
        for c, j in line {
            if c == 'S' {
                start_i, start_j = line_idx, j
            }
            append(&tile_line, rune(c))
        }
        append(&tiles, tile_line)
    }

    n := len(tiles)
    m := len(tiles[0])

    steps := make([dynamic][dynamic]int)
    defer {
        for step_line in steps {
            delete(step_line)
        }
        delete(steps)
    }
    for i in 0..<n {
        step_line := make([dynamic]int, m)
        for j in 0..<m do step_line[j] = -1
        append(&steps, step_line)
    }

    steps[start_i][start_j] = 0

    step_queue := make([dynamic]Node)
    defer delete(step_queue)
    append(&step_queue, Node {start_i - 1, start_j, From_Dir.South, 1})
    append(&step_queue, Node {start_i + 1, start_j, From_Dir.North, 1})
    append(&step_queue, Node {start_i, start_j - 1, From_Dir.East, 1})
    append(&step_queue, Node {start_i, start_j + 1, From_Dir.West, 1})

    s_north, s_south, s_west, s_east : bool

    step_idx := 0
    for len(step_queue) > 0 {
        node := step_queue[0]
        ordered_remove(&step_queue, 0)
        i, j := node.i, node.j
        
        if i < 0 || i >= n do continue
        if j < 0 || j >= m do continue
        if steps[i][j] != -1 do continue
        
        new_node, pass := to_next_pipe(tiles, node)
        if pass {
            steps[i][j] = node.step_count
            append(&step_queue, new_node)
        }
        
        if step_idx == 0 do s_north = pass
        if step_idx == 1 do s_south = pass
        if step_idx == 2 do s_west = pass
        if step_idx == 3 do s_east = pass
        step_idx += 1
    }

    tile_under_start := '@' // hack

    if s_south && s_north do tile_under_start = '|'
    if s_south && s_east do tile_under_start = 'F'
    if s_south && s_west do tile_under_start = '7'
    if s_north && s_east do tile_under_start = 'L'
    if s_north && s_west do tile_under_start = 'J'

    fmt.println("tile_under_start", tile_under_start)

    tiles[start_i][start_j] = tile_under_start

    inside_tile_count := 0

    for step_line, i in steps {
        inside := false
        last_corner := '.'
        for s, j in step_line {
            if steps[i][j] >= 0 {
                // main loop pipe tile
                t := tiles[i][j]
                switch t {
                    case '|': inside = !inside
                    case '-': // do nothing
                    case 'L': last_corner = 'L'
                    case 'J':
                        if last_corner == 'F' {
                            inside = !inside
                            last_corner := '.'
                        }
                    case '7':
                        if last_corner == 'L' {
                            inside = !inside
                            last_corner := '.'
                        }
                    case 'F': last_corner = 'F'
                    case: panic("some error hanpped!")
                }
            } else {
                if inside {
                    inside_tile_count += 1
                    tiles[i][j] = 'I'
                } else {
                    tiles[i][j] = 'O'
                }
            }
        }
    }

    // for t in tiles {
    //     fmt.println(t[:])
    // }
    fmt.println(inside_tile_count)
}

to_next_pipe :: proc(tiles: [dynamic][dynamic]rune, node: Node) -> (Node, bool) {
    tile := tiles[node.i][node.j]
    //fmt.println("check", tile, node.i, node.j, node.from)
    
    from: From_Dir
    ok := false
    switch node.from {
        case .North:
            if tile == '|' {
                from = .North
                ok = true
            } else if tile == 'L' {
                from = .West
                ok = true
            } else if tile == 'J' {
                from = .East
                ok = true
            }
        case .South:
            if tile == '|' {
                from = .South
                ok = true
            } else if tile == '7' {
                from = .East
                ok = true
            } else if tile == 'F' {
                from = .West
                ok = true
            }
        case .East:
            if tile == '-' {
                from = .East
                ok = true
            } else if tile == 'F' {
                from = .North
                ok = true
            } else if tile == 'L' {
                from = .South
                ok = true
            }
        case .West:
            if tile == '-' {
                from = .West
                ok = true
            } else if tile == '7' {
                from = .North
                ok = true
            } else if tile == 'J' {
                from = .South
                ok = true
            }
    }

    if !ok do return Node{}, false

    ni, nj: int
    new_node : Node

    switch from {
        case .North:
            ni, nj = 1, 0
        case .South:
            ni, nj = -1, 0
        case .East:
            ni, nj = 0, -1
        case .West:
            ni, nj = 0, 1
    }

    new_node.i = node.i + ni
    new_node.j = node.j + nj
    new_node.from = from
    new_node.step_count = node.step_count + 1

    return new_node, true
}