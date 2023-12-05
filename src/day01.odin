package day01

import "core:fmt"
import "core:os"
import "core:strings"


main :: proc() {
    part1()
    part2()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day01.txt")
    if !ok {
        return
    }
    defer delete(data)
    
    total := 0
    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        first, last := 0, 0
        is_first := true
        for c in line {
            switch c {
                case '0'..='9':
                    d := int(c) - int('0')
                    if is_first {
                        is_first = false
                        first, last = d, d
                    } else {
                        last = d
                    }
            }
        }
        total += first * 10 + last
    }
    fmt.println(total)
}

part2 :: proc() {
    trie_root := trie_init()
    defer trie_destroy(trie_root)

    trie_add_word(trie_root, "one", 1)
    trie_add_word(trie_root, "two", 2)
    trie_add_word(trie_root, "three", 3)
    trie_add_word(trie_root, "four", 4)
    trie_add_word(trie_root, "five", 5)
    trie_add_word(trie_root, "six", 6)
    trie_add_word(trie_root, "seven", 7)
    trie_add_word(trie_root, "eight", 8)
    trie_add_word(trie_root, "nine", 9)

    // s := "five"
    // ss := s[0:3]
    // t: = type_info_of(type_of(ss))
    // fmt.println(t, ss)
    // return

    data, ok := os.read_entire_file_from_filename("inputs/day01.txt")
    if !ok {
        return
    }
    defer delete(data)
    
    total := 0
    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        first, last := 0, 0
        is_first := true
        length := len(line)
        for i in 0..<length {
            c := rune(line[i])
            switch c {
                case '0'..='9':
                    d := int(c) - int('0')
                    if is_first {
                        is_first = false
                        first, last = d, d
                    } else {
                        last = d
                    }
                case:
                    d, ok := trie_find_digit(trie_root, line[i:])
                    if ok {
                        if is_first {
                            is_first = false
                            first, last = d, d
                        } else {
                            last = d
                        }
                    }
            }
        }
        total += first * 10 + last
    }
    fmt.println(total)
}

ALPHABET_SIZE :: 26

Trie_Node :: struct {
    next: [ALPHABET_SIZE]^Trie_Node,
    is_digit: bool,
    digit: int,
    char: rune
}

trie_init :: proc() -> ^Trie_Node {
    root := new(Trie_Node)
    root.is_digit = false
    return root
}

trie_destroy :: proc(node: ^Trie_Node) {
    for n in node.next {
        if n != nil {
            trie_destroy(n)
        }
    }
    free(node)
}

trie_add_word :: proc(root: ^Trie_Node, word: string, digit: int) {
    node := root
    for c in word {
        idx := int(c) - int('a')
        if node.next[idx] != nil {
            node = node.next[idx]
        } else {
            new_node := new(Trie_Node)
            new_node.char = c
            node.next[idx] = new_node
            node = node.next[idx]
        }
    }
    if node == root {
        return
    }
    node.is_digit = true
    node.digit = digit
}

trie_find_next :: proc(node: ^Trie_Node, c : rune) {
    // TODO
}

trie_find_digit :: proc(root: ^Trie_Node, word: string) -> (int, bool) {
    node := root
    for c in word {
        idx := int(c) - int('a')
        if node.is_digit {
            break
        } else if idx >= 0 && idx < ALPHABET_SIZE {
            if node.next[idx] != nil {
                node = node.next[idx]
            } else {
                return 0, false
            }
        }
        else {
            return 0, false
        }
    }
    if node.is_digit {
        return node.digit, true
    } else {
        return 0, false
    }
}