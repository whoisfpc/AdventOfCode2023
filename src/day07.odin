package day07

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

HandPair :: struct {
    cards: string,
    strength: int,
    bid: int,
}


main :: proc() {
    part1()
}

part1 :: proc() {
    data, ok := os.read_entire_file_from_filename("inputs/day07.txt")
    if !ok {
        return
    }
    defer delete(data)
    it := string(data)

    hand_pairs := make([dynamic]HandPair)
    defer delete(hand_pairs)

    idx := 0
    for line in strings.split_lines_iterator(&it) {
        hand_bid_str := strings.split(line, " ")
        defer delete(hand_bid_str)

        cards := hand_bid_str[0]
        strength := get_hand_strength(cards)
        bid, _ := strconv.parse_int(hand_bid_str[1])
        append(&hand_pairs, HandPair{cards, strength, bid})
        idx += 1
    }

    
    slice.sort_by(hand_pairs[:], less_hand)
    
    //fmt.println(hand_pairs)

    total := 0
    for pair, i in hand_pairs {
        total += (i + 1) * pair.bid
    }

    fmt.println(total)
}

less_hand :: proc(a, b: HandPair) -> bool {
    if a.strength != b.strength {
        return a.strength < b.strength
    }

    for i in 0..<5 {
        idx_a := card_to_idx(rune(a.cards[i]))
        idx_b := card_to_idx(rune(b.cards[i]))
        if idx_a != idx_b {
            return idx_a < idx_b
        }
    }

    return true
}

card_to_idx :: proc(card: rune) -> int {
    switch card {
        case '2': return 0
        case '3': return 1
        case '4': return 2
        case '5': return 3
        case '6': return 4
        case '7': return 5
        case '8': return 6
        case '9': return 7
        case 'T': return 8
        case 'J': return 9
        case 'Q': return 10
        case 'K': return 11
        case 'A': return 12
    }
    return -1
}

get_hand_strength :: proc(hand: string) -> int {
    assert(len(hand) == 5, "hand length is must be 5!")
    
    slots : [13]int
    for card in hand {
        idx := card_to_idx(card)
        slots[idx] += 1
    }

    if slice.contains(slots[:], 5) {
        return 6
    } else if slice.contains(slots[:], 4) {
        return 5
    } else if slice.contains(slots[:], 3) {
        if slice.contains(slots[:], 2) {
            return 4
        } else {
            return 3
        }
    } else if slice.contains(slots[:], 2) {
        i, _ := slice.linear_search(slots[:], 2)
        slots[i] = 0
        if slice.contains(slots[:], 2) {
            return 2
        } else {
            return 1
        }
    }
    
    return 0
}