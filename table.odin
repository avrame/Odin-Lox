package odinlox

import "core:strings"

TABLE_MAX_LOAD :: 0.75

Table :: struct {
	count:    int,
	capacity: int,
	entries:  []Entry,
}

Entry :: struct {
	key:   ^ObjString,
	value: Value,
}

initTable :: proc(table: ^Table) {
	table.count = 0
	table.capacity = 0
	table.entries = nil
}

freeTable :: proc(table: ^Table) {
	delete(table.entries)
}

tableGet :: proc(table: ^Table, key: ^ObjString) -> (Value, bool) {
	if table.count == 0 {return {}, false}

	entry: ^Entry = findEntry(table.entries, table.capacity, key)
	if entry.key == nil {return {}, false}

	return entry.value, true
}

tableSet :: proc(table: ^Table, key: ^ObjString, value: Value) -> bool {
	if f32(table.count + 1) > f32(table.capacity) * TABLE_MAX_LOAD {
		capacity := growCapacity(table.capacity)
		adjustCapacity(table, capacity)
	}

	entry: ^Entry = findEntry(table.entries, table.capacity, key)
	isNewKey: bool = entry.key == nil
	if isNewKey && IS_NIL(entry.value) {table.count += 1}

	entry.key = key
	entry.value = value
	return isNewKey
}

tableDelete :: proc(table: ^Table, key: ^ObjString) -> bool {
	if table.count == 0 {return false}

	// Find the entry.
	entry := findEntry(table.entries, table.capacity, key)
	if entry.key == nil {return false}

	// Place a tombstone in the entry.key
	entry.key = nil
	entry.value = BOOL_VAL(true)
	return true
}

tableAddAll :: proc(from: ^Table, to: ^Table) {
	for i in 0 ..< from.capacity {
		entry: ^Entry = &from.entries[i]
		if entry.key != nil {
			tableSet(to, entry.key, entry.value)
		}
	}
}

tableFindString :: proc(table: ^Table, str: string, hash: u32) -> ^ObjString {
	if table.count == 0 {return nil}

	index := hash % u32(table.capacity)
	for {
		entry := &table.entries[index]
		if entry.key == nil {
			// Stop if we find an empty non-tombstone entry.
			if IS_NIL(entry.value) {return nil}
		} else if len(entry.key.str) == len(str) &&
		   entry.key.hash == hash &&
		   strings.compare(entry.key.str, str) == 0 {
			// We found it.
			return entry.key
		}
		index = (index + 1) % u32(table.capacity)
	}
}

findEntry :: proc(entries: []Entry, capacity: int, key: ^ObjString) -> ^Entry {
	index := key.hash % u32(capacity - 1)
	tombstone: ^Entry = nil
	for {
		entry := &entries[index]
		if entry.key == nil {
			if IS_NIL(entry.value) {
				// Empty entry.
				return tombstone != nil ? tombstone : entry
			} else {
				// We found a tombstone.
				if tombstone == nil {tombstone = entry}
			}
		} else if entry.key == key {
			// We found the key.
			return entry
		}
		index = (index + 1) % cast(u32)capacity
	}
}

growCapacity :: proc(capacity: int) -> int {
	return 8 if capacity < 8 else capacity * 2
}

adjustCapacity :: proc(table: ^Table, capacity: int) {
	entries := make([]Entry, capacity)
	for i in 0 ..< capacity {
		entries[i].key = nil
		entries[i].value = NIL_VAL()
	}

	table.count = 0
	for i in 0 ..< table.capacity {
		entry: ^Entry = &table.entries[i]
		if entry.key == nil {continue}

		dest: ^Entry = findEntry(entries, capacity, entry.key)
		dest.key = entry.key
		dest.value = entry.value
		table.count += 1
	}

	delete(table.entries)
	table.entries = entries
	table.capacity = capacity
}
