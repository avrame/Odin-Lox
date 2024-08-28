package odinlox

import "core:fmt"

disassembleCode :: proc(chunk : ^Chunk, name : string) {
    fmt.printfln("== %v ==", name)

    for offset: int = 0; offset < len(chunk^.code); {
        offset = disassembleInstruction(chunk, offset);
    }
}

disassembleInstruction :: proc(chunk : ^Chunk, offset : int) -> int {
    fmt.printf("%4d ", offset)

    // if offset > 0 && chunk.lines[offset] == chunk.lines[offset - 1] {
    //   fmt.printf("  | ");
    // } else {
    //   fmt.printf("%v ", chunk.lines[offset])
    // }
    line_num := getLine(chunk, offset)
    fmt.printf("%v ", line_num)

    instruction : OpCode = cast(OpCode)chunk^.code[offset]
    switch instruction {
        case .CONSTANT:
            return constantInstruction("OP_CONSTANT", chunk, offset)
        case .RETURN:
            return simpleInstruction("OP_RETURN", offset)
        case:
            fmt.printfln("Unknown opcode %d", instruction)
            return offset + 1
    }
}

constantInstruction :: proc(name : string, chunk : ^Chunk, offset : int) -> int {
    constant_idx : u8 = chunk.code[offset + 1]
    fmt.printf("%v %v '", name, constant_idx)
    printValue(chunk.constants[constant_idx])
    fmt.printfln("'")
    return offset + 2
}

simpleInstruction :: proc(name : string, offset : int) -> int {
    fmt.printfln("%v", name)
    return offset + 1
}