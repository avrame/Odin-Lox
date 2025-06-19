package odinlox

import "core:fmt"
import "core:io"
import "core:mem"
import "core:unicode/utf8"

Scanner :: struct {
	buffer:  ^string,
	start:   int,
	current: int,
	line:    int,
}

Token :: struct {
	type:   TokenType,
	source: string,
	line:   int,
}

TokenType :: enum {
	// Single-character tokens.
	LEFT_PAREN,
	RIGHT_PAREN,
	LEFT_BRACE,
	RIGHT_BRACE,
	COMMA,
	DOT,
	MINUS,
	PLUS,
	SEMICOLON,
	SLASH,
	STAR,

	// One or two character tokens.
	BANG,
	BANG_EQUAL,
	EQUAL,
	EQUAL_EQUAL,
	GREATER,
	GREATER_EQUAL,
	LESS,
	LESS_EQUAL,

	// Literals
	IDENTIFIER,
	STRING,
	NUMBER,

	// Keywords
	AND,
	CLASS,
	ELSE,
	FALSE,
	FOR,
	FUN,
	IF,
	NIL,
	OR,
	PRINT,
	RETURN,
	SUPER,
	THIS,
	TRUE,
	VAR,
	WHILE,
	ERROR,
	EOF,
}

scanner: Scanner

initScanner :: proc(source: ^string) {
	scanner.buffer = source
	scanner.start = 0
	scanner.current = 0
	scanner.line = 1
}

isAlpha :: proc(c: rune) -> bool {
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
}

isDigit :: proc(c: rune) -> bool {
	return c >= '0' && c <= '9'
}

isAtEnd :: proc() -> bool {
	return scanner.current >= len(scanner.buffer)
}

@(private = "file")
advance :: proc() -> rune {
	rune: rune = utf8.rune_at(scanner.buffer^, scanner.current)
	scanner.current += 1
	return rune
}

@(private = "file")
peek :: proc() -> rune {
	return utf8.rune_at(scanner.buffer^, scanner.current)
}

peekNext :: proc() -> (rune, io.Error) {
	if isAtEnd() { return ' ', io.Error.EOF }
	return utf8.rune_at(scanner.buffer^, scanner.current + 1), nil
}

@(private = "file")
match :: proc(expected: rune) -> bool {
	if isAtEnd() { return false }
	if utf8.rune_at(scanner.buffer^, scanner.current) != expected {return false}
	scanner.current += 1
	return true
}

makeToken :: proc(type: TokenType) -> Token {
	return Token {
		type = type,
		source = scanner.buffer[scanner.start:scanner.current],
		line = scanner.line,
	}
}

errorToken :: proc(message: string) -> Token {
	return Token{type = .ERROR, line = scanner.line, source = message}
}

skipWhitespace :: proc() {
	for {
		c: rune = peek()
		switch c {
		case ' ', '\r', '\t':
			advance()
			break
		case '\n':
			scanner.line += 1
			advance()
			break
		case '/':
			nextChar, err := peekNext()
			if err != nil {
				if nextChar == '/' {
					// A comment goes until the end of the line.
					for peek() != '\n' && !isAtEnd() { advance() }
				}
			}
			return
		case: // any other character
			return
		}
	}
}

checkKeyword :: proc(start: int, length: int, rest: string, type: TokenType) -> TokenType {
	if scanner.current - scanner.start == start + length && scanner.buffer[scanner.start+start:scanner.start+start+length] == rest {
		return type
	}
	return .IDENTIFIER
}

identifierType :: proc() -> TokenType {
	switch scanner.buffer[scanner.start] {
		case 'a': return checkKeyword(1, 2, "nd", .AND)
		case 'c': return checkKeyword(1, 4, "lass", .CLASS)
		case 'e': return checkKeyword(1, 3, "lse", .ELSE)
		case 'f': {
			if scanner.current - scanner.start > 1 {
				switch scanner.buffer[scanner.start+1] {
				case 'a': return checkKeyword(2, 3, "lse", .FALSE)
				case 'o': return checkKeyword(2, 1, "r", .FOR)
				case 'u': return checkKeyword(2, 4, "n", .FUN)
				}
			}
		}
		case 'i': return checkKeyword(1, 1, "f", .IF)
		case 'n': return checkKeyword(1, 2, "il", .NIL)
		case 'o': return checkKeyword(1, 1, "r", .OR)
		case 'p': return checkKeyword(1, 4, "rint", .PRINT)
		case 'r': return checkKeyword(1, 5, "eturn", .RETURN)
		case 's': return checkKeyword(1, 4, "uper", .SUPER)
		case 't': {
			if scanner.current - scanner.start > 1 {
				switch scanner.buffer[scanner.start+1] {
				case 'h': return checkKeyword(2, 2, "is", .THIS)
				case 'r': return checkKeyword(2, 2, "ue", .TRUE)
				}
			}
		}
		case 'v': return checkKeyword(1, 2, "ar", .VAR)
		case 'w': return checkKeyword(1, 4, "hile", .WHILE)
	}
	return .IDENTIFIER
}

scanIdentifier :: proc() -> Token {
	for isAlpha(peek()) || isDigit(peek()) { advance() }
	return makeToken(identifierType())
}

scanNumber :: proc() -> Token {
	for isDigit(peek()) || peek() == '_' { advance() }
	nextChar, _ := peekNext()
	if peek() == '.' && isDigit(nextChar) {
		// Consume the "."
		advance()
		for isDigit(peek()) { advance() }
	}
	return makeToken(.NUMBER)
}

scanString :: proc() -> Token {
	for peek() != '"' && !isAtEnd() {
		if peek() == '\n' {
			scanner.line += 1
		}
		advance()
	}
	if isAtEnd() {
		return errorToken("Unterminated string.")
	}
	// closing the quote.
	advance()
	return makeToken(.STRING)
}

scanToken :: proc() -> Token {
	skipWhitespace()
	scanner.start = scanner.current

	if isAtEnd() {return makeToken(.EOF)}

	c: rune = advance()

	if isAlpha(c) { return scanIdentifier() }
	if isDigit(c) { return scanNumber() }

	switch c {
	case '(':
		return makeToken(.LEFT_PAREN)
	case ')':
		return makeToken(.RIGHT_PAREN)
	case '{':
		return makeToken(.LEFT_BRACE)
	case '}':
		return makeToken(.RIGHT_BRACE)
	case ';':
		return makeToken(.SEMICOLON)
	case ',':
		return makeToken(.COMMA)
	case '.':
		return makeToken(.DOT)
	case '-':
		return makeToken(.MINUS)
	case '+':
		return makeToken(.PLUS)
	case '/':
		return makeToken(.SLASH)
	case '*':
		return makeToken(.STAR)
	case '!':
		return makeToken(match('=') ? .BANG_EQUAL : .BANG)
	case '=':
		return makeToken(match('=') ? .EQUAL_EQUAL : .EQUAL)
	case '<':
		return makeToken(match('=') ? .LESS_EQUAL : .LESS)
	case '>':
		return makeToken(match('=') ? .GREATER_EQUAL : .GREATER)
	case '"': return scanString()
	}

	unexpected_char := "Unexpected character."
	return errorToken(unexpected_char)
}
