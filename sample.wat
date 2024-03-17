;; 2024 Bem130
(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

    (memory 1)
    (export "memory" (memory 0))

    (func $main (export "_start")
        (call $printInt32 (i32.const 314159265))
    )
    
    (func $printInt32 (param $num i32) (local $nd i32) (local $abs i32) ;; i32の値をプリントする
        (local.set $abs (call $i32_abs (local.get $num)))
        (block $exit
            (loop $loop
                (local.set $nd (i32.add (local.get $nd) (i32.const 1)))
                (br_if $exit (i32.le_u (local.get $abs) (call $i32_power (i32.const 10) (local.get $nd))))
                (br $loop)
            )
        )
        (if ;; "-" を付ける
            (i32.lt_s (local.get $num) (i32.const 0)) ;; 符号check
            (then
                (local.set $nd (i32.add (local.get $nd) (i32.const 1)))
            )
        )
        (call $i32_to_Str (local.get $num) (local.get $nd) (i32.const 16))
        (call $print (local.get $nd) (i32.const 16))
    )

    (func $i32_to_Str (param $num i32) (param $nd i32) (param $ptr i32) (local $i i32) (local $abs i32)
        (local.set $i (i32.const 1))
        (local.set $nd (i32.add (local.get $nd) (i32.const 1)))
        (local.set $abs (call $i32_abs (local.get $num)))
        (block $exit
            (loop $loop
                (br_if $exit (i32.le_u (local.get $nd) (local.get $i)))
                (call $store1Byte
                    (i32.sub (i32.add (local.get $ptr) (local.get $nd)) (i32.add (local.get $i) (i32.const 1))) ;; adr
                    (i32.add 
                        (i32.div_u
                            (i32.sub
                                (i32.rem_u (local.get $abs) (call $i32_power (i32.const 10) (local.get $i)))
                                (i32.rem_u (local.get $abs) (call $i32_power (i32.const 10) (i32.sub (local.get $i) (i32.const 1))))
                            )
                            (call $i32_power (i32.const 10) (i32.sub (local.get $i) (i32.const 1)))
                        )
                        (i32.const 48)
                    )
                )
                (local.set $i (i32.add (local.get $i) (i32.const 1)))
                (br $loop)
            )
        )
        (if ;; "-" を付ける
            (i32.lt_s (local.get $num) (i32.const 0)) ;; 符号check
            (then
                (call $store1Byte (i32.add (local.get $ptr) (i32.const 0)) (i32.const 0x2D))
            )
        )
    )
    (func $i32_power (export "pow") (param $base i32) (param $exp i32) (result i32) (local $i i32) (local $tmp i32)
        (local.set $i (i32.const 0))
        (local.set $tmp (i32.const 1))
        (block $exit
            (loop $loop
                (br_if $exit (i32.le_s (local.get $exp) (local.get $i)))
                (local.set $tmp (i32.mul (local.get $tmp) (local.get $base)))
                (local.set $i (i32.add (local.get $i) (i32.const 1)))
                (br $loop)
            )
        )
        (local.get $tmp)
    )
    (func $i32_abs (export "i32abs") (param $num i32) (result i32) (local $tmp i32)
        (if
            (i32.lt_s (local.get $num) (i32.const 0)) ;; 符号check
            (then (local.set $tmp (i32.xor (i32.const 0xFFFFFFFF) (i32.sub (local.get $num) (i32.const 1)))))
            (else (local.set $tmp (local.get $num)))
        )
        (local.get $tmp)
    )
    (func $store1Byte (param $ptr i32) (param $val i32) (local $tmp i32)
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