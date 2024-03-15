(module
  (func $add (param i32 i32) (result i32)
    get_local 0
    get_local 1
    i32.add
  )
  (func $main (param) (result i32)
    i32.const 5
    i32.const -2
    call $add
  )
  (export "_start" (func $main))
)