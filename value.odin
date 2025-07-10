package odinlox

import "core:fmt"

ValueType :: enum {
	BOOL,
	NIL,
	NUMBER,
	OBJ,
}

ValueUnion :: union {
	bool,
	f64,
	^Obj,
}

Value :: struct {
	type: ValueType,
	as:   ValueUnion,
}

ValueArray :: [dynamic]Value

IS_BOOL :: proc(value: Value) -> bool {
	return value.type == .BOOL
}

IS_NIL :: proc(value: Value) -> bool {
	return value.type == .NIL
}

IS_NUMBER :: proc(value: Value) -> bool {
	return value.type == .NUMBER
}

IS_OBJ :: proc(value: Value) -> bool {
	return value.type == .OBJ
}

AS_BOOL :: proc(value: Value) -> bool {
	return value.as.(bool)
}

AS_NUMBER :: proc(value: Value) -> f64 {
	return value.as.(f64)
}

AS_OBJ :: proc(value: Value) -> ^Obj {
	return value.as.(^Obj)
}

printValue :: proc(value: Value) {
	switch value.type {
	case .BOOL:
		fmt.printf(AS_BOOL(value) ? "true" : "false")
	case .NIL:
		fmt.printf("nil")
	case .NUMBER:
		fmt.printf("%g", AS_NUMBER(value))
	case .OBJ:
		printObject(AS_OBJ(value))
	}
}

valuesEqual :: proc(a: Value, b: Value) -> bool {
	if a.type != b.type {return false}
	switch a.type {
	case .BOOL:
		return AS_BOOL(a) == AS_BOOL(b)
	case .NIL:
		return true
	case .NUMBER:
		return AS_NUMBER(a) == AS_NUMBER(b)
	case .OBJ:
		return AS_OBJ(a) == AS_OBJ(b)
	case:
		return false // Unreachable
	}
}

BOOL_VAL :: proc(value: bool) -> Value {
	return Value{.BOOL, value}
}

NIL_VAL :: proc() -> Value {
	return Value{.NIL, 0}
}

NUMBER_VAL :: proc(value: f64) -> Value {
	return Value{.NUMBER, value}
}

OBJ_VAL :: proc(value: ^Obj) -> Value {
	return Value{.OBJ, value}
}
