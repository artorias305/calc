package main

import "core:math"
import "core:strconv"

// These will be leaves
Number_Node :: struct {
	value: f64,
}

Operator :: enum {
	Add,
	Sub,
	Mul,
	Div,
	Mod,
	Pow,
}

// binary node will be evaluated into a value
Binary_Node :: struct {
	op:    Operator,
	left:  ^AST_Node,
	right: ^AST_Node,
}

AST_Node :: union {
	Number_Node,
	Binary_Node,
}

Parser :: struct {
	pos:    int,
	tokens: [dynamic]Token,
}

parse :: proc(p: ^Parser) -> ^AST_Node {
	p.pos = 0
	return parse_expr(p)
}

parse_expr :: proc(p: ^Parser) -> ^AST_Node {
	left := parse_term(p)

	for p.pos < len(p.tokens) &&
	    p.tokens[p.pos].type == .Operator &&
	    (p.tokens[p.pos].literal == "+" || p.tokens[p.pos].literal == "-") {
		literal := p.tokens[p.pos].literal
		p.pos += 1
		right := parse_term(p)

		op: Operator = .Add if literal == "+" else .Sub
		node := new(AST_Node, context.temp_allocator)
		node^ = Binary_Node{op, left, right}
		left = node
	}

	return left
}

parse_term :: proc(p: ^Parser) -> ^AST_Node {
	left := parse_primary(p)

	for p.pos < len(p.tokens) &&
	    p.tokens[p.pos].type == .Operator &&
	    (p.tokens[p.pos].literal == "*" ||
			    p.tokens[p.pos].literal == "/" ||
			    p.tokens[p.pos].literal == "%" ||
			    p.tokens[p.pos].literal == "^") {
		literal := p.tokens[p.pos].literal
		p.pos += 1
		right := parse_primary(p)

		op: Operator
		if literal == "*" do op = .Mul
		if literal == "/" do op = .Div
		if literal == "%" do op = .Mod
		if literal == "^" do op = .Pow

		node := new(AST_Node, context.temp_allocator)
		node^ = Binary_Node{op, left, right}
		left = node
	}

	return left
}

parse_primary :: proc(p: ^Parser) -> ^AST_Node {
	if p.tokens[p.pos].type == .Number {
		value := strconv.parse_f64(p.tokens[p.pos].literal) or_else 0
		p.pos += 1

		node := new(AST_Node, context.temp_allocator)
		node^ = Number_Node{value}
		return node
	}

	if p.tokens[p.pos].type == .L_Paren {
		p.pos += 1
		result := parse_expr(p)
		p.pos += 1
		return result
	}

	panic("unexpected token in parse_primary")
}

evaluate :: proc(node: ^AST_Node) -> f64 {
	switch n in node {
	case Number_Node:
		return n.value
	case Binary_Node:
		left := evaluate(n.left)
		right := evaluate(n.right)

		if n.op == .Add {
			return left + right
		}

		if n.op == .Sub {
			return left - right
		}

		if n.op == .Mul {
			return left * right
		}

		if n.op == .Div {
			if right == 0 do panic("Division by zero")
			return left / right
		}
		if n.op == .Mod {
			if right == 0 do panic("Division by zero")
			return math.mod_f64(left, right)
		}
		if n.op == .Pow {
			return math.pow(left, right)
		}

		return 0
	}

	return 0
}
