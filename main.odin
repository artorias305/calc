package main

import "core:fmt"
import "core:os"
import "core:strings"

TokenType :: enum {
	Number,
	Operator,
}

Token :: struct {
	type:    TokenType,
	literal: string,
}

new_token :: proc(type: TokenType, literal: string) -> Token {
	return Token{type, literal}
}

Tokenize_Error :: enum {
	None = 0,
	Invalid_Token,
}

@(require_results)
tokenize :: proc(
	input: string,
	allocator := context.allocator,
) -> (
	[dynamic]Token,
	Tokenize_Error,
) {
	tokens := make([dynamic]Token, allocator)

	idx := 0

	for idx < len(input) {
		char := input[idx]

		switch char {
		case '0' ..= '9':
			start := idx
			for idx < len(input) && input[idx] >= '0' && input[idx] <= '9' {
				idx += 1
			}

			number_string := input[start:idx]
			append(&tokens, new_token(.Number, number_string))

			continue
		case ' ':
			idx += 1
			continue
		case '+':
			idx += 1
			append(&tokens, new_token(.Operator, "+"))
		case '-':
			idx += 1
			append(&tokens, new_token(.Operator, "-"))
		case:
			delete(tokens)
			return nil, .Invalid_Token
		}
	}

	return tokens, .None
}

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

		fmt.printf("%v\n", tokens)

		delete(tokens)
	}
}
