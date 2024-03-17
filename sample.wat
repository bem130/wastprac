;; 2024 Bem130
(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

    (memory 1)
    (export "memory" (memory 0))

    (func $main (export "_start")
        (call $printInt64 (i64.const 3141592653589793238))
    )
    (func $printInt64 (param $num i64) (local $nd i64) (local $abs i64) ;; i64の値をプリントする
        (local.set $abs (call $i64_abs (local.get $num)))
        (block $exit
            (loop $loop
                (local.set $nd (i64.add (local.get $nd) (i64.const 1)))
                (br_if $exit (i64.le_u (local.get $abs) (call $i64_power (i64.const 10) (local.get $nd))))
                (br $loop)
            )
        )
        (if ;; "-" を付ける
            (i64.lt_s (local.get $num) (i64.const 0)) ;; 符号check
            (then
                (local.set $nd (i64.add (local.get $nd) (i64.const 1)))
            )
        )
        (call $i64_to_Str (local.get $num) (local.get $nd) (i64.const 16))
        (call $print (i32.wrap_i64 (local.get $nd)) (i32.const 16))
    )

    (func $i64_to_Str (param $num i64) (param $nd i64) (param $ptr i64) (local $i i64) (local $abs i64)
        (local.set $i (i64.const 1))
        (local.set $nd (i64.add (local.get $nd) (i64.const 1)))
        (local.set $abs (call $i64_abs (local.get $num)))
        (block $exit
            (loop $loop
                (br_if $exit (i64.le_u (local.get $nd) (local.get $i)))
                (call $i64_store1Byte
                    (i64.sub (i64.add (local.get $ptr) (local.get $nd)) (i64.add (local.get $i) (i64.const 1))) ;; adr
                    (i64.add 
                        (i64.div_u
                            (i64.sub
                                (i64.rem_u (local.get $abs) (call $i64_power (i64.const 10) (local.get $i)))
                                (i64.rem_u (local.get $abs) (call $i64_power (i64.const 10) (i64.sub (local.get $i) (i64.const 1))))
                            )
                            (call $i64_power (i64.const 10) (i64.sub (local.get $i) (i64.const 1)))
                        )
                        (i64.const 48)
                    )
                )
                (local.set $i (i64.add (local.get $i) (i64.const 1)))
                (br $loop)
            )
        )
        (if ;; "-" を付ける
            (i64.lt_s (local.get $num) (i64.const 0)) ;; 符号check
            (then
                (call $i64_store1Byte (i64.add (local.get $ptr) (i64.const 0)) (i64.const 0x2D))
            )
        )
    )
    (func $i64_power (export "pow") (param $base i64) (param $exp i64) (result i64) (local $i i64) (local $tmp i64)
        (local.set $i (i64.const 0))
        (local.set $tmp (i64.const 1))
        (block $exit
            (loop $loop
                (br_if $exit (i64.le_s (local.get $exp) (local.get $i)))
                (local.set $tmp (i64.mul (local.get $tmp) (local.get $base)))
                (local.set $i (i64.add (local.get $i) (i64.const 1)))
                (br $loop)
            )
        )
        (local.get $tmp)
    )
    (func $i64_abs (export "i64abs") (param $num i64) (result i64) (local $tmp i64)
        (if
            (i64.lt_s (local.get $num) (i64.const 0)) ;; 符号check
            (then (local.set $tmp (i64.xor (i64.const 0xFFFFFFFFFFFFFFFF) (i64.sub (local.get $num) (i64.const 1)))))
            (else (local.set $tmp (local.get $num)))
        )
        (local.get $tmp)
    )
    (func $i64_store1Byte (param $ptr i64) (param $val i64)
        (call $i32_store1Byte (i32.wrap_i64 (local.get $ptr)) (i32.wrap_i64 (local.get $val)))
    )
    (func $i32_store1Byte (param $ptr i32) (param $val i32) (local $tmp i32)
        (local.set $tmp (i32.load (local.get $ptr)))
        (i32.store
            (local.get $ptr)
            (i32.or
                (i32.and (local.get $tmp) (i32.const 0xFFFFFF00))
                (i32.and (local.get $val) (i32.const 0x000000FF))
            )
        )
    )
    (func $print (export "print") (param $len i32) (param $ptr i32)
        (i32.store (i32.const 4) (local.get $len))
        (i32.store (i32.const 0) (local.get $ptr))
        (call $fd_write (i32.const 1) (i32.const 0) (i32.const 1) (i32.const 8))
        drop
    )
)