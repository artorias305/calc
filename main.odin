package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	buf := make([]byte, 2048)
	defer delete(buf)

	for {
		fmt.print("> ")
		total_read := os.read(os.stdin, buf[:]) or_break

		input := string(buf[:total_read])
		input = strings.trim_space(input)

		tokens, err := tokenize(input)
		if err != nil {
			fmt.fprintf(os.stderr, "invalid token detected\n")
			continue
		}

		parser := Parser{tokens = tokens, pos = 0}
		root := parse(&parser)
		result := evaluate(root)

		fmt.printf("%f\n", result)

		delete(tokens)
	}
}
