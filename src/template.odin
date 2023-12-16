package template

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/template.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)
    
    for line in strings.split_lines_iterator(&it) {
        
    }
}
