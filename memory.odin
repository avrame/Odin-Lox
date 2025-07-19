package odinlox

freeObjects :: proc() {
	object: ^Obj = vm.objects
	for object != nil {
		next: ^Obj = object.next
		freeObject(object)
		object = next
	}
}

freeObject :: proc(object: ^Obj) {
	switch object.type {
	case .STRING:
		lstring := cast(^ObjString)object
		delete(lstring.str)
		free(lstring)
	}
}
