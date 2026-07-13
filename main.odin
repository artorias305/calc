package main

import "core:os"
import "core:fmt"

main :: proc() {
	buf := make([]byte, 2048)
	for {
		fmt.print("> ")
		total_read := os.read(os.stdin, buf[:]) or_break
	}
}
