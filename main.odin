package odinlox

main :: proc() {
	initVM()

	chunk: Chunk

	// constant1: int = addConstant(&chunk, 1.2)
	// writeChunk(&chunk, cast(u8)OpCode.CONSTANT, 1)
	// writeChunk(&chunk, cast(u8)constant1, 1)

	// constant2: int = addConstant(&chunk, 3.4)
	// writeChunk(&chunk, cast(u8)OpCode.CONSTANT, 1)
	// writeChunk(&chunk, cast(u8)constant2, 1)

	// writeChunk(&chunk, cast(u8)OpCode.ADD, 1)
	
	// constant3: int = addConstant(&chunk, 5.6)
	// writeChunk(&chunk, cast(u8)OpCode.CONSTANT, 2)
	// writeChunk(&chunk, cast(u8)constant3, 2)

	// writeChunk(&chunk, cast(u8)OpCode.DIVIDE, 3)
	// writeChunk(&chunk, cast(u8)OpCode.NEGATE, 3)
	// writeChunk(&chunk, cast(u8)OpCode.RETURN, 3)

	constant1: int = addConstant(&chunk, 2)
	writeChunk(&chunk, cast(u8)OpCode.CONSTANT, 1)
	writeChunk(&chunk, cast(u8)constant1, 1)
	writeChunk(&chunk, cast(u8)OpCode.NEGATE, 1)

	constant2: int = addConstant(&chunk, 3)
	writeChunk(&chunk, cast(u8)OpCode.CONSTANT, 1)
	writeChunk(&chunk, cast(u8)constant2, 1)

	writeChunk(&chunk, cast(u8)OpCode.MULTIPLY, 1)

	constant3: int = addConstant(&chunk, 1)
	writeChunk(&chunk, cast(u8)OpCode.CONSTANT, 1)
	writeChunk(&chunk, cast(u8)constant3, 1)

	writeChunk(&chunk, cast(u8)OpCode.ADD, 1)
	writeChunk(&chunk, cast(u8)OpCode.RETURN, 1)

	disassembleChunk(&chunk, "test chunk")
	interpret(&chunk)
	freeVM()
	freeChunk(&chunk)
}
