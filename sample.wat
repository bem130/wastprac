(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

    (memory 1)
    (export "memory" (memory 0))
    (data (i32.const 16) "\E3\81\8200010000")

    (func $main (export "_start")
        (i32.store (i32.const 0) (i32.const 16))
        (i32.store (i32.const 4) (i32.const 7))

        (call $fd_write
            (i32.const 1)
            (i32.const 0)
            (i32.const 1)
            (i32.const 8)
        )
        drop
        (i32.store (i32.const 0) (i32.const 18))
        (call $fd_write
            (i32.const 1)
            (i32.const 0)
            (i32.const 1)
            (i32.const 8)
        )
        drop
    )
)