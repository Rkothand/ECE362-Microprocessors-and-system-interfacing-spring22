.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.global login
login: .asciz "rkothand"

.align 2
.global main
main:
    bl   autotest // Uncomment this ONLY when you're not manually invoking below.
    movs r0, #1
    movs r1, #2
    movs r2, #4
    movs r3, #8
    bl   example // invoke the example subroutine
    nop

    movs r0, #13
	rsbs r0, r0, #0
    movs r1, #69 //r1=69
    movs r2, #15 //r2=15
    movs r3, #14 //r3=14


    bl   step31 // invoke Step 3.1
    nop



    movs r0, #16

	movs r1, #80 //r2=-80
    rsbs r2,r1, #0


    movs r1, #95 //r1=95

    movs r3, #36 //r3=36

    bl   step32 // invoke Step 3.2
    nop

    movs r0, #40 // replace these values with examples from the prelab
    rsbs r1, r0, #0 //r1=-40

    movs r0, #95 // replace these values with examples from the prelab
    rsbs r2, r0, #0 //r2=-95



    movs r3, #38 // replace these values with examples from the prelab
    rsbs r3, r3, #0 //r3=-38

    movs r0, #91 // replace these values with examples from the prelab
    rsbs r0, r0, #0 //r2=-91




    bl   step33 // invoke Step 3.3
    nop

    movs r0, #56 // replace these values with examples from the prelab
    rsbs r1, r0, #0 //r1=-56

    movs r0, #28 // replace these values with examples from the prelab
    rsbs r2, r0, #0 //r2=-28
	movs r3, #7 // replace these values with examples from the prelab
    rsbs r3, r3, #0 //r3=-7

    movs r0, #56 // replace these values with examples from the prelab
    rsbs r0, r0, #0 //r2=-56



    bl   step41 // invoke Step 4.1
    nop

    // replace these values with examples from the prelab

    movs r0, #13 //r0=13
    movs r1, #68 //r1=68
    bl   step42 // invoke Step 4.2
    nop

    movs r0, #0 // unused as an input operand
    movs r1, #16
    movs r2, #2
    movs r3, #3
    bl   step51 // invoke Step 5.1
    nop

	movs r0, #5
    bl   step52 // invoke Step 5.2
    nop


    bl   setup_portc
loop:
    bl   toggle_leds
    ldr  r0, =500000000
wait:
    subs r0,#83
    bgt  wait
    b    loop

// The main function never returns.
// It ends with the endless loop, above.

// Subroutine for example in Step 3.0
.global example
example:
                    adds r1, r0, r1 // now, r1 = r0 + r1
                adds r1, r1, r2 // now, r1 = r0 + r1 + r2
                adds r1, r1, r3 // finally, r1 = r0 + r1 + r2 + r3
                movs r0, r1     // put the result into r0

    bx   lr

// Subroutine for Step 3.1
.global step31
step31:

	//rsbs r0,r0, #0 //r0 =-13

    subs r3, r0 //r3-r0
    adds r1, r2 //r1 +r2
    muls r1, r3 //(r3-r0) * (r1 +r2)
    movs r0, r1
    bx   lr

// Subroutine for Step 3.2
.global step32
step32:
    subs r1, r2 //r1+-r2
    subs r3, r0 //r3 +r0
    muls r1, r3 //(r1+-r2) * (r3 +r0)
    movs r0, r1
    bx   lr

// Subroutine for Step 3.3
.global step33
step33:
	muls r1, r2 //r1*r2
    subs r3, r0 //r3-r0
    muls r1, r3 //((r1 + -r2) * (r3 - r0))
    movs r0, r1 //r0 = ((r1 + -r2) * (r3 - r0))
    bx   lr

// Subroutine for Step 4.1
.global step41
step41:
   	orrs r1, r2 //r1|r2
    ands r3, r0 //r3&r0
    eors r1, r3 //(r1|r2)^(r3&r0)
    movs r0, r1
    bx   lr

// Subroutine for Step 4.2
.global step42
step42:
    movs r2, #0xdd
    movs r3, #80 //0x50
    bics r1, r2 //r1 &~0xdd
    ands r0, r3 //r0 & 0x50
	adds r0,r1 //r0 = (r0 & 0x50)+(r1 &~0xdd)
    bx   lr

// Subroutine for Step 5.1
.global step51
step51:
    lsls r3, r1
    lsrs r3, r2
    movs r0, r3
    bx   lr

// Subroutine for Step 5.2
.global step52
step52:
    movs r1, #0x1
	bics r0, r1
	movs r1, #3
	lsls r0, r1
	movs r1, #5
	orrs r0, r1
    bx   lr

// Step 6: Type in the .equ constant initializations below
.equ RCC,          0x40021000
.equ AHBENR,       0x14
.equ GPIOCEN,      0x00080000
.equ GPIOC,        0x48000800
.equ MODER,        0x00
.equ ODR,          0x14
.equ ENABLE6_TO_9, 0x55000
.equ PINS6_TO_9,   0x3c0


.global setup_portc
setup_portc:
	//enable the rcc clock for the GPIOC peripheral
    ldr r0, =RCC
    ldr r1, [r0,#AHBENR]
    ldr r2, =GPIOCEN
    orrs r1, r2
    str r1, [r0, #AHBENR]

    //set pins 6 through 9 to be outputs
    ldr r0, =GPIOC
    ldr r1, [r0, #MODER]
    ldr r2, =ENABLE6_TO_9
    orrs r1, r2
    str r1, [r0, #MODER]
    bx   lr

.global toggle_leds
toggle_leds:
    // Type in the code here.
    //read and toggle all four pins
    ldr r0, =GPIOC
    ldr r1,[r0, #ODR]
    ldr r2, =PINS6_TO_9
    eors r1,r2
    str r1, [r0, #ODR]

    bx   lr
