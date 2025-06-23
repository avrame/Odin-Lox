package odinlox

import "core:fmt"

OpCode :: enum u8 {
	CONSTANT,
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE,
	NEGATE,
	RETURN,
}

Line :: struct {
	line_num: int,
	count:    int,
}

Chunk :: struct {
	code:      [dynamic]u8,
	constants: ValueArray,
	lines:     [dynamic]Line,
}

initChunk :: proc(c: ^Chunk) {
	c.code = make([dynamic]u8)
	c.constants = make(ValueArray)
	c.lines = make([dynamic]Line)
}

freeChunk :: proc(c: ^Chunk) {
	delete(c.code)
	delete(c.constants)
}

writeChunk :: proc(c: ^Chunk, byte: u8, line: int) {
	append(&c.code, byte)
	last_line_idx := len(&c.lines) - 1
	if last_line_idx >= 0 {
		last_line := &c.lines[last_line_idx]
		if last_line.line_num == line {
			last_line.count += 1
			return
		}
	}
	append(&c.lines, Line{line, 1})
}

addConstant :: proc(c: ^Chunk, value: Value) -> int {
	append(&c.constants, value)
	return len(&c.constants) - 1
}

getLine :: proc(c: ^Chunk, offset: int) -> int {
	line_count := offset
	idx := 0
	line: ^Line
	for {
		line = &c.lines[idx]
		line_count -= line.count
		if line_count >= 0 {
			idx += 1
		} else {
			break
		}
	}
	return line.line_num
}
