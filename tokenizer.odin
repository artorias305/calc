package main

TokenType :: enum {
	Number,
	Operator,
	L_Paren,
	R_Paren,
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

			if idx < len(input) && input[idx] == '.' {
				idx += 1
				for idx < len(input) && input[idx] >= '0' && input[idx] <= '9' {
					idx += 1
				}
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
		case '*':
			idx += 1
			append(&tokens, new_token(.Operator, "*"))
		case '/':
			idx += 1
			append(&tokens, new_token(.Operator, "/"))
		case '%':
			idx += 1
			append(&tokens, new_token(.Operator, "%"))
		case '^':
			idx += 1
			append(&tokens, new_token(.Operator, "^"))
		case '(', ')':
			tok := new_token(.L_Paren, "(") if char == '(' else new_token(.R_Paren, ")")
			idx += 1
			append(&tokens, tok)
		case:
			delete(tokens)
			return nil, .Invalid_Token
		}
	}

	return tokens, .None
}
