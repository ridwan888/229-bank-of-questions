halfdiv:
    addi  $t0, $zero, -1
loop:
    beq   $a1, $zero, next
    srl   $a1, $a1, 1
    addi  $t0, $t0, 1
    j loop
next:                      # $t0 <- exponent of power of 2
    lhu   $t1, 0($a0)      # $t1 <- half-precision FP value
    sll   $t0, $t0, 10     # $t0 <- move power of 2 exponent to position
    sub   $t2, $t1, $t0    # subtract exponents
    shu   $t2, 0($a0)
    jr    $ra

