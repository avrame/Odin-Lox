package odinlox

import "core:fmt"

disassembleChunk :: proc(chunk: ^Chunk, name: string) {
	fmt.printfln("== %v ==", name)

	for offset: int = 0; offset < len(chunk^.code); {
		offset = disassembleInstruction(chunk, offset)
	}
}

disassembleInstruction :: proc(chunk: ^Chunk, offset: int) -> int {
	fmt.printf("%4d ", offset)

	// if offset > 0 && chunk.lines[offset] == chunk.lines[offset - 1] {
	//   fmt.printf("  | ");
	// } else {
	//   fmt.printf("%v ", chunk.lines[offset])
	// }
	line_num := getLine(chunk, offset)
	fmt.printf("%v ", line_num)

	instruction: OpCode = cast(OpCode)chunk^.code[offset]
	switch instruction {
	case .CONSTANT:
		return constantInstruction("OP_CONSTANT", chunk, offset)
	case .NIL:
		return simpleInstruction("OP_NIL", offset)
	case .TRUE:
		return simpleInstruction("OP_TRUE", offset)
	case .FALSE:
		return simpleInstruction("OP_FALSE", offset)
	case .EQUAL:
		return simpleInstruction("OP_EQUAL", offset)
	case .GREATER:
		return simpleInstruction("OP_GREATER", offset)
	case .LESS:
		return simpleInstruction("OP_LESS", offset)
	case .ADD:
		return simpleInstruction("OP_ADD", offset)
	case .SUBTRACT:
		return simpleInstruction("OP_SUBTRACT", offset)
	case .MULTIPLY:
		return simpleInstruction("OP_MULTIPLY", offset)
	case .DIVIDE:
		return simpleInstruction("OP_DIVIDE", offset)
	case .NOT:
		return simpleInstruction("OP_NOT", offset)
	case .NEGATE:
		return simpleInstruction("OP_NEGATE", offset)
	case .RETURN:
		return simpleInstruction("OP_RETURN", offset)
	case:
		fmt.printfln("Unknown opcode %d", instruction)
		return offset + 1
	}
}

constantInstruction :: proc(name: string, chunk: ^Chunk, offset: int) -> int {
	constant_idx: u8 = chunk.code[offset + 1]
	fmt.printf("%v %v '", name, constant_idx)
	printValue(chunk.constants[constant_idx])
	fmt.printfln("'")
	return offset + 2
}

simpleInstruction :: proc(name: string, offset: int) -> int {
	fmt.printfln("%v", name)
	return offset + 1
}
