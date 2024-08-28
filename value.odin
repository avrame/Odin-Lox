package odinlox

import "core:fmt"

Value :: distinct f64

ValueArray :: [dynamic]Value

printValue :: proc(value: Value) {
    fmt.printf("%v", value)
}