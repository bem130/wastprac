(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

    (memory 1)
    (export "memory" (memory 0))
    (data (i32.const 16) "a\E3\81\82bcdefg")

    (func $main (export "_start")
        (call $print (i32.const 10) (i32.const 16))
    )
    
    (func $print (export "print") (param $len i32) (param $ptr i32)
        (i32.store (i32.const 4) (local.get $len))
        (i32.store (i32.const 0) (local.get $ptr))
        (call $fd_write (i32.const 1) (i32.const 0) (i32.const 1) (i32.const 8))
        drop
    )
)