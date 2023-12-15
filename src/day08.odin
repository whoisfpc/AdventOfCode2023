package day08

import "core:fmt"
import "core:os"
import "core:strings"

Node :: struct {
    label: string,
    left: string,
    right: string
}


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day08.txt")
    if !ok {
        return
    }
    defer delete(data)
    
    idx := 0
    it := string(data)

    cmds : string
    nodes := make(map[string]Node)
    cur_node : Node
    defer delete(nodes)
    
    for line in strings.split_lines_iterator(&it) {
        defer idx += 1

        if idx == 0 {
            cmds = line
        } else if idx > 1 {
            label := line[0:3]
            node := Node {label, line[7:10], line[12:15]}
            if label == "AAA" {
                cur_node = node
            }
            nodes[label] = node
        }
    }

    //fmt.println(nodes)

    cmd_len := len(cmds)
    cmd_count := 0
    for cur_node.label != "ZZZ" {
        cmd_idx := cmd_count % cmd_len
        cmd_count += 1

        if rune(cmds[cmd_idx]) == 'L' {
            cur_node = nodes[cur_node.left]
            //fmt.println("go left", cur_node)
        } else {
            cur_node = nodes[cur_node.right]
            //fmt.println("go right", cur_node)
        }

        //if cmd_count >  do break
    }

    fmt.println(cmd_count)
}
