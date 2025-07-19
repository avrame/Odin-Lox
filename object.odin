package odinlox

import "core:fmt"
import "core:strings"

Obj :: struct {
	type: ObjType,
	next: ^Obj,
}

ObjString :: struct {
	using obj: Obj,
	str:       string,
	hash:      u32,
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
	hash: u32 = hashString(str)
	interned: ^ObjString = tableFindString(&vm.strings, str, hash)
	if interned != nil {return interned}
	s := strings.clone(str)
	return allocateString(s, hash)
}

allocateString :: proc(str: string, hash: u32) -> ^ObjString {
	lox_string := allocateObject(ObjString, .STRING)
	lox_string.str = str
	lox_string.hash = hash
	tableSet(&vm.strings, lox_string, NIL_VAL())

	push(OBJ_VAL(lox_string))
	pop()

	return lox_string
}

hashString :: proc(key: string) -> u32 {
	hash: u32 = 2166136261
	length := len(key)
	for i := 0; i < length; i += 1 {
		hash ~= cast(u32)key[i]
		hash *= 16777619
	}
	return hash
}

takeString :: proc(str: string) -> ^ObjString {
	hash: u32 = hashString(str)
	interned: ^ObjString = tableFindString(&vm.strings, str, hash)

	if interned != nil {
		delete(str)
		return interned
	}

	return allocateString(str, hash)
}

allocateObject :: proc($T: typeid, type: ObjType) -> ^T {
	object := new(T)
	object.type = type

	// Insert this new object into the head of the vm's objects linked list
	object.next = vm.objects
	vm.objects = object

	return object
}
