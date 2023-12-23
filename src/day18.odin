package day18

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

Pos :: [2]int

Move_Dir := map[string]Pos {
	"U" = { -1,  0 }, // up
	"L" = {  0, -1 }, // left
	"D" = { +1,  0 }, // down
	"R" = {  0, +1 }, // right
}

main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day18.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    points: [dynamic]Pos
    defer delete(points)
    
    preimeter := 0
    pos := Pos{0, 0}
    append(&points, pos)
    
    for line in strings.split_lines_iterator(&it) {
        cmds := strings.split(line, " ")
        defer delete(cmds)

        delta : [2]int = Move_Dir[cmds[0]]

        dist, _ := strconv.parse_int(cmds[1])
        preimeter += dist
        pos += delta * {dist, dist}

        append(&points, pos)
    }

    // Pick's theorem: https://en.wikipedia.org/wiki/Pick%27s_theorem
    // A = i + b / 2 - 1
    // i = A - b / 2 + 1
    // b + i = A + b / 2 + 1

    total := area(points) + preimeter / 2 + 1
    fmt.println(total)
}

// https://en.wikipedia.org/wiki/Shoelace_formula
area :: proc(points: [dynamic]Pos) -> int {
    result := 0
    n := len(points)
    for i in 0..<n-1 {
        // swap x and y because we are x rows
        result += points[i].y * points[i+1].x - points[i].x * points[i+1].y
    }
    return result / 2
}
