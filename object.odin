package odinlox

import "core:fmt"
import "core:strings"

Obj :: struct {
	type: ObjType,
}

ObjString :: struct {
	using obj: Obj,
	str:       string,
}

ObjType :: enum {
	STRING,
}

objType :: proc(value: Value) -> ObjType {
	return AS_OBJ(value).type
}

isObjType :: proc(value: Value, type: ObjType) -> bool {
	return IS_OBJ(value) && AS_OBJ(value).type == type
}

printObject :: proc(object: ^Obj) {
	switch object.type {
	case .STRING:
		fmt.printf("%v", (cast(^ObjString)object).str)
	}
}

isString :: proc(value: Value) -> bool {
	return isObjType(value, ObjType.STRING)
}

copyString :: proc(str: string) -> ^ObjString {
	s := strings.clone(str)
	return allocateString(s)
}

allocateString :: proc(str: string) -> ^ObjString {
	lstring := allocateObject(ObjString, .STRING)
	lstring.str = str

	push(OBJ_VAL(lstring))
	pop()

	return lstring
}

takeString :: proc(str: string) -> ^ObjString {
	return allocateString(str)
}

allocateObject :: proc($T: typeid, type: ObjType) -> ^T {
	object := new(T)
	object.type = type
	return object
}
