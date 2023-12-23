package day17

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import pq "core:container/priority_queue"

Dir :: enum {
    Up,
    Left,
    Down,
    Right,
}

Dir_Vec := [Dir][2]int {
	.Up    = { -1,  0 },
	.Left  = {  0, -1 },
	.Down  = { +1,  0 },
	.Right = {  0, +1 },
}

Dir_Turn := [Dir][2]Dir {
	.Up    = { .Left, .Right },
	.Left  = { .Up,   .Down  },
	.Down  = { .Left, .Right },
	.Right = { .Up,   .Down  },
}

DNode :: struct {
    cost: int,
    x, y: int,
    dir: Dir,
}

main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day17.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    heat_loss_map : [dynamic][dynamic]int
    defer {
        for p in heat_loss_map do delete(p)
        delete(heat_loss_map)
    }
    
    for line in strings.split_lines_iterator(&it) {
        p : [dynamic]int
        for c in line {
            append(&p, int(c - '0'))
        }
        append(&heat_loss_map, p)
    }

    find_dist(heat_loss_map)
}

find_dist :: proc(heat_loss_map : [dynamic][dynamic]int) {
    n, m := len(heat_loss_map), len(heat_loss_map[0])
    dist : [Dir][dynamic][dynamic]int
    defer {
        for d in Dir {
            for p in dist[d] do delete(p)
            delete(dist[d])
        }
    }

    for d in Dir {
        for i in 0..<n {
            p : [dynamic]int
            for j in 0..<m {
                append(&p, max(int))
            }
            append(&dist[d], p)
        }
    }

    dist[.Up][0][0] = 0
    dist[.Down][0][0] = 0
    dist[.Right][0][0] = 0
    dist[.Left][0][0] = 0

    q : pq.Priority_Queue(DNode)
    pq.init(&q, less_DNode, pq.default_swap_proc(DNode))
    defer pq.destroy(&q)

    pq.push(&q, DNode{0, 0, 0, .Right})
    pq.push(&q, DNode{0, 0, 0, .Down})

    for pq.len(q) > 0 {
        node := pq.pop(&q)
        cost, x,y, dir := node.cost, node.x, node.y, node.dir
        if cost > dist[dir][x][y] {
            continue
        }

        for _ in 0..<3 {
            x += Dir_Vec[dir].x
            y += Dir_Vec[dir].y

            if x < 0 || x >= n || y < 0 || y >= m {
                break
            }

            cost += heat_loss_map[x][y]

            for new_dir in Dir_Turn[dir] {
                if cost < dist[new_dir][x][y] {
                    dist[new_dir][x][y] = cost
                    pq.push(&q, DNode{cost, x, y, new_dir})
                }
            }
        }
    }

    min_cost := min(dist[.Up][n-1][m-1],
         dist[.Left][n-1][m-1], dist[.Right][n-1][m-1], dist[.Down][n-1][m-1])
    
    fmt.println(min_cost)
}

less_DNode :: proc(a, b: DNode) -> bool {
    return a.cost < b.cost
}