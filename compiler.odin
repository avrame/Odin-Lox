package odinlox

import "core:fmt"
import "core:unicode/utf8"

compile :: proc(source: ^string) {
	initScanner(source)
	line: int = -1
	for {
		token: Token = scanToken()
		if token.line != line {
			fmt.printf("%4d ", token.line)
			line = token.line
		} else {
			fmt.printf("   | ")
		}
		fmt.printfln("%s '%s'", token.type, token.source)

		if token.type == .EOF {break}
	}
}
