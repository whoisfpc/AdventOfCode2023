package day05

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"

Pair :: struct {
    dest : int,
    source : int,
    length : int,
}

Flow :: struct {
    source: int,
    length: int,
}


main :: proc() {
    part2()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day05.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    locations := make([dynamic]int)
    defer delete(locations)
    translater := make([dynamic]Pair)
    defer delete(translater)

    line_idx := 0
    for line in strings.split_lines_iterator(&it) {
        if line_idx == 0 {
            line_clone := strings.clone(line)
            origin_line := line_clone
            defer delete(origin_line)
            for seed in strings.split_iterator(&line_clone, " ") {
                num, ok := strconv.parse_int(seed)
                if ok do append(&locations, num)
            }
        } else if line_idx > 1{
            if strings.contains(line, "map:") {
                clear(&translater)
            } else if line == "" {
                //fmt.println(translater)
                //fmt.println("empty line")
                translate_locations(&locations, &translater)
            } else {
                num_strs := strings.split(line, " ")
                defer delete(num_strs)
                dest, _ := strconv.parse_int(num_strs[0])
                source, _ := strconv.parse_int(num_strs[1])
                length, _ := strconv.parse_int(num_strs[2])
                append(&translater, Pair{dest, source, length})
            }
        }
        line_idx += 1
    }
    translate_locations(&locations, &translater)
    fmt.println(slice.min(locations[:]))
    //fmt.println(locations[:])
}

part2 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day05.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    flows := make([dynamic]Flow)
    defer delete(flows)
    translater := make([dynamic]Pair)
    defer delete(translater)

    line_idx := 0
    for line in strings.split_lines_iterator(&it) {
        if line_idx == 0 {
            seeds := strings.split(line, " ")
            //defer delete(seeds)
            for i := 1; i < len(seeds); i += 2 {
                num, _ := strconv.parse_int(seeds[i])
                length, _ := strconv.parse_int(seeds[i + 1])
                append(&flows, Flow {num, length})
            }
        } else if line_idx > 1{
            if strings.contains(line, "map:") {
                clear(&translater)
            } else if line == "" {
                //slice.sort_by(translater[:], less_translate)
                // fmt.println(translater)
                // fmt.println(flows, "->")
                translate_flows(&flows, &translater)
                // fmt.println(flows)
                // fmt.println()
                //break
            } else {
                num_strs := strings.split(line, " ")
                defer delete(num_strs)
                dest, _ := strconv.parse_int(num_strs[0])
                source, _ := strconv.parse_int(num_strs[1])
                length, _ := strconv.parse_int(num_strs[2])
                append(&translater, Pair{dest, source, length})
            }
        }
        line_idx += 1
    }
    //slice.sort_by(translater[:], less_translate)
    translate_flows(&flows, &translater)
    min_flow := flows[0].source
    for flow in flows {
        if flow.source < min_flow do min_flow = flow.source
    }
    fmt.println("min_flow:", min_flow)
}

less_translate :: proc(i, j: Pair) -> bool {
     return i.source < j.source
}

translate_flows :: proc(flows: ^[dynamic]Flow, translater : ^[dynamic]Pair) {
    slice.sort_by(translater[:], less_translate)
    up_flows := make([dynamic]Flow, len(flows), cap(flows), flows.allocator)
    defer delete(up_flows)
    copy(up_flows[:], flows[:])
    clear(flows)
    for len(up_flows) > 0 {
        f := up_flows[0]
        f_s := f.source
        f_e := f.source + f.length - 1
        ordered_remove(&up_flows, 0)

        has_trans := false
        for pair in translater {
            start := pair.source
            end := pair.source + pair.length - 1
            used_case := -1
            switch {
            case f_e < start:
                used_case = 0
                append(flows, Flow{f_s, f_e - f_s + 1})
                has_trans = true
            case end < f_s:
                used_case = 1
                // do nothing
            case f_s < start && f_e <= end:
                used_case = 2
                append(flows, Flow{f_s, start - f_s})
                append(flows, Flow{pair.dest, f_e - start + 1})
                has_trans = true
            case f_s < start && end < f_e:
                used_case = 3
                append(flows, Flow{f_s, start - f_s})
                append(flows, Flow{pair.dest, pair.length})
                append(&up_flows, Flow{end+1, f_e - end}) // continue to up_flows
                has_trans = true
            case start <= f_s && f_e <= end:
                used_case = 4
                append(flows, Flow{pair.dest + f_s - start, f.length})
                has_trans = true
            case start <= f_s && end < f_e:
                used_case = 5
                append(flows, Flow{pair.dest + f_s - start, end - f_s + 1})
                append(&up_flows, Flow{end+1, f_e - end}) // continue to up_flows
                has_trans = true
            }
            
            //fmt.println("meow", used_case, ":", f_s, f_e, start, end)

            if used_case == -1 do panic("wtf!!!!")
            if has_trans do break
        }

        if !has_trans {
            append(flows, Flow{f_s, f_e - f_s + 1})
            has_trans = true
        }
    }

    // fmt.println("flows: ", flows^)
    // fmt.println()
}

translate_locations :: proc(locations: ^[dynamic]int, translater : ^[dynamic]Pair) {
    for location, i in locations {
        locations[i] = find_dest(location, translater)
    }
}

find_dest :: proc(location: int, translater : ^[dynamic]Pair) -> int {
    for pair in translater {
        if location >= pair.source && location < pair.source + pair.length {
            return location - pair.source + pair.dest
        }
    }
    return location
}