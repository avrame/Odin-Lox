package odinlox

import "core:bufio"
import "core:fmt"
import "core:io"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

main :: proc() {
	initVM()

	args_count := len(os.args)

	if args_count == 1 {
		repl()
	} else if args_count == 2 {
		runFile(os.args[1])
	} else {
		fmt.printf("Usage: clox [path]\n")
		os.exit(64)
	}

	freeVM()
	os.exit(0)
}

repl :: proc() {
	line: [1024]u8
	reader: bufio.Reader
	bufio.reader_init_with_buf(&reader, io.to_reader(os.stream_from_handle(os.stdin)), line[:])
	for {
		fmt.printf("> ")
		line, err := bufio.reader_read_slice(&reader, '\n')
		if err != nil {
			fmt.println(err)
			break
		}
		source: string = string(line[:])
		interpret(&source)
	}
}

runFile :: proc(path: string) {
	source_bytes, ok := os.read_entire_file(path)
	defer delete(source_bytes)

	if !ok {
		fmt.printf("Could not open file \"%v\".\n", path)
		os.exit(74)
	}

	source: string = string(source_bytes[:])
	result: InterpretResult = interpret(&source)

	if result == .COMPILE_ERROR {os.exit(65)}
	if result == .RUNTIME_ERROR {os.exit(70)}
}
