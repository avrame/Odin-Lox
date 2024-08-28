package odinlox

main :: proc() {
    chunk : Chunk

    constant : int = addConstant(&chunk, 1.2)
    writeChunk(&chunk, cast(u8)OpCode.CONSTANT, 1)
    writeChunk(&chunk, cast(u8)constant, 1)

    constant2 : int = addConstant(&chunk, 3.1415)
    writeChunk(&chunk, cast(u8)OpCode.CONSTANT, 2)
    writeChunk(&chunk, cast(u8)constant2, 2)

    constant3 : int = addConstant(&chunk, 1.618)
    writeChunk(&chunk, cast(u8)OpCode.CONSTANT, 2)
    writeChunk(&chunk, cast(u8)constant3, 2)

    writeChunk(&chunk, cast(u8)OpCode.RETURN, 3)

    disassembleCode(&chunk, "test code")
}