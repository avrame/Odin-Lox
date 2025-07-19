package odinlox

import "core:fmt"
import "core:log"
import "core:mem"

DEBUG_STACK_TRACE :: true
STACK_MAX :: 256

VM :: struct {
	chunk:     ^Chunk,
	ip:        ^u8,
	stack:     [STACK_MAX]Value,
	stack_top: ^Value,
	strings:   Table,
	objects:   ^Obj,
}

InterpretResult :: enum {
	OK,
	COMPILE_ERROR,
	RUNTIME_ERROR,
}

vm: VM

resetStack :: proc() {
	vm.stack_top = &vm.stack[0]
}

getLineAtInstruction :: proc(instruction_idx: int) -> (int, bool) {
	instruction_count := 0
	for line in vm.chunk.lines {
		instruction_count += line.count
		if instruction_count >= instruction_idx {
			return line.line_num, true
		}
	}
	return 0, false
}

runtimeError :: proc(format: string, args: ..any) {
	fmt.printfln(format, ..args)

	instruction_idx := mem.ptr_sub(vm.ip, &vm.chunk.code[0]) - 1
	line_num, ok := getLineAtInstruction(instruction_idx)
	if !ok {
		fmt.printfln("I couldn't find the line number for the runtime error!")
		return
	}
	fmt.printfln("[line %v] in script", line_num)

	resetStack()
}

initVM :: proc() {
	resetStack()
	vm.objects = nil
	initTable(&vm.strings)
}

freeVM :: proc() {
	freeTable(&vm.strings)
	freeObjects()
}

push :: proc(value: Value) {
	vm.stack_top^ = value
	vm.stack_top = mem.ptr_offset(vm.stack_top, 1)
}

pop :: proc() -> Value {
	vm.stack_top = mem.ptr_offset(vm.stack_top, -1)
	return vm.stack_top^
}

peek :: proc(distance: i32) -> Value {
	return mem.ptr_offset(vm.stack_top, -1 - distance)^
}

isFalsey :: proc(value: Value) -> bool {
	return IS_NIL(value) || (IS_BOOL(value) && !AS_BOOL(value))
}

concatenate :: proc() {
	b := cast(^ObjString)AS_OBJ(pop())
	a := cast(^ObjString)AS_OBJ(pop())

	length := len(a.str) + len(b.str)
	chars := make([]byte, length)
	i := 0
	i = +copy(chars[i:], a.str)
	copy(chars[i:], b.str)

	result := takeString(string(chars))
	push(OBJ_VAL(result))
}

readByte :: proc() -> u8 {
	byte_code := vm.ip^
	vm.ip = mem.ptr_offset(vm.ip, 1)
	return byte_code
}

readConstant :: proc() -> Value {
	return vm.chunk.constants[readByte()]
}

checkNumbers :: proc() -> InterpretResult {
	if !IS_NUMBER(peek(0)) || !IS_NUMBER(peek(1)) {
		runtimeError("Operands must be numbers.")
		return .RUNTIME_ERROR
	}
	return nil
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
		case .NIL:
			push(NIL_VAL())
		case .TRUE:
			push(BOOL_VAL(true))
		case .FALSE:
			push(BOOL_VAL(false))
		case .EQUAL:
			b: Value = pop()
			a: Value = pop()
			push(BOOL_VAL(valuesEqual(a, b)))
		case .GREATER:
			checkNumbers() or_return
			b: f64 = AS_NUMBER(pop())
			a: f64 = AS_NUMBER(pop())
			push(BOOL_VAL(a > b))
		case .LESS:
			checkNumbers() or_return
			b: f64 = AS_NUMBER(pop())
			a: f64 = AS_NUMBER(pop())
			push(BOOL_VAL(a < b))
		case .ADD:
			v1 := peek(0)
			v2 := peek(1)
			if IS_OBJ(v1) &&
			   AS_OBJ(v1).type == .STRING &&
			   IS_OBJ(v2) &&
			   AS_OBJ(v2).type == .STRING {
				concatenate()
			} else if IS_NUMBER(peek(0)) && IS_NUMBER(peek(1)) {
				b := AS_NUMBER(pop())
				a := AS_NUMBER(pop())
				push(NUMBER_VAL(a + b))
			} else {
				runtimeError("Operands must be two numbers or two strings.")
				return .RUNTIME_ERROR
			}
		case .SUBTRACT:
			checkNumbers() or_return
			b: f64 = AS_NUMBER(pop())
			a: f64 = AS_NUMBER(pop())
			push(NUMBER_VAL(a - b))
		case .MULTIPLY:
			checkNumbers() or_return
			b: f64 = AS_NUMBER(pop())
			a: f64 = AS_NUMBER(pop())
			push(NUMBER_VAL(a * b))
		case .DIVIDE:
			checkNumbers() or_return
			b: f64 = AS_NUMBER(pop())
			a: f64 = AS_NUMBER(pop())
			push(NUMBER_VAL(a / b))
		case .NOT:
			push(BOOL_VAL(isFalsey(pop())))
		case .NEGATE:
			if !IS_NUMBER(peek(0)) {
				runtimeError("Operand must be a number.")
				return .RUNTIME_ERROR
			}
			push(NUMBER_VAL(-AS_NUMBER(pop())))
		case .RETURN:
			printValue(pop())
			fmt.println("")
			return .OK
		}
	}
}

interpret :: proc(source: ^string) -> InterpretResult {
	chunk: Chunk
	initChunk(&chunk)

	if !compile(source, &chunk) {
		freeChunk(&chunk)
		return .COMPILE_ERROR
	}

	vm.chunk = &chunk
	vm.ip = &vm.chunk.code[0]

	result: InterpretResult = run()

	freeChunk(&chunk)
	return result
}
