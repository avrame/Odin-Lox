package odinlox

import "core:fmt"

ValueType :: enum {
	BOOL,
	NIL,
	NUMBER,
}

ValueUnion :: union {
	bool,
	f64,
}

Value :: struct {
	type: ValueType,
	as:   ValueUnion,
}

ValueArray :: [dynamic]Value

isBool :: proc(value: Value) -> bool {
	return value.type == .BOOL
}

isNil :: proc(value: Value) -> bool {
	return value.type == .NIL
}

isNumber :: proc(value: Value) -> bool {
	return value.type == .NUMBER
}

asBool :: proc(value: Value) -> bool {
	return value.as.(bool)
}

asNumber :: proc(value: Value) -> f64 {
	return value.as.(f64)
}

printValue :: proc(value: Value) {
	switch value.type {
	case .BOOL:
		fmt.printf(asBool(value) ? "true" : "false")
	case .NIL:
		fmt.printf("nil")
	case .NUMBER:
		fmt.printf("%g", asNumber(value))
	}
}

valuesEqual :: proc(a: Value, b: Value) -> bool {
	if a.type != b.type {return false}
	switch a.type {
	case .BOOL:
		return asBool(a) == asBool(b)
	case .NIL:
		return true
	case .NUMBER:
		return asNumber(a) == asNumber(b)
	case:
		return false // Unreachable
	}
}

boolVal :: proc(value: bool) -> Value {
	return Value{.BOOL, value}
}

nilVal :: proc() -> Value {
	return Value{.NIL, 0}
}

numberVal :: proc(value: f64) -> Value {
	return Value{.NUMBER, value}
}
