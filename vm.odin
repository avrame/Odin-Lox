package odinlox

import "core:fmt"
import "core:mem"

DEBUG_STACK_TRACE :: true
STACK_MAX :: 256

VM :: struct {
	chunk: ^Chunk,
	ip:    int,
	stack: [STACK_MAX]Value,
	stack_top: ^Value,
}

InterpretResult :: enum {
	INTERPRET_OK,
	INTERPRET_COMPILE_ERROR,
	INTERPRET_RUNTIME_ERROR,
}

vm: VM

resetStack :: proc() {
	vm.stack_top = &vm.stack[0]
}

initVM :: proc() {
	resetStack()
}

freeVM :: proc() {

}

push :: proc(value: Value) {
	vm.stack_top^ = value
	vm.stack_top = mem.ptr_offset(vm.stack_top, 1)
}

pop :: proc() -> Value {
	vm.stack_top = mem.ptr_offset(vm.stack_top, -1)
	return vm.stack_top^
}

negate :: proc() {
	temp: ^Value = mem.ptr_offset(vm.stack_top, -1)
	temp^ = -temp^
}

readByte :: proc() -> u8 {
	b := vm.chunk.code[vm.ip]
	vm.ip += 1
	return b
}

readConstant :: proc() -> Value {
	return vm.chunk.constants[readByte()]
}

run :: proc() -> InterpretResult {
	for {
		when DEBUG_STACK_TRACE {
			fmt.printf("          ")
			for slot: ^Value = &vm.stack[0]; slot < vm.stack_top; slot = mem.ptr_offset(slot, 1) {
				fmt.printf("[ ")
				printValue(slot^)
				fmt.printf(" ]")
			}
			fmt.println("")
		}
		instruction := cast(OpCode)readByte()
		switch cast(OpCode)instruction {
		case .CONSTANT:
			constant: Value = readConstant()
			push(constant)
		case .ADD:
			b: Value = pop()
			a: Value = pop()
			push(a + b)
		case .SUBTRACT:
			b: Value = pop()
			a: Value = pop()
			push(a - b)
		case .MULTIPLY:
			b: Value = pop()
			a: Value = pop()
			push(a * b)
		case .DIVIDE:
			b: Value = pop()
			a: Value = pop()
			push(a / b)
		case .NEGATE:
			negate()
		case .RETURN:
			printValue(pop())
			fmt.println("")
			return .INTERPRET_OK
		}
	}
}

interpret :: proc(chunk: ^Chunk) -> InterpretResult {
	vm.chunk = chunk
	vm.ip = 0
	return run()
}
