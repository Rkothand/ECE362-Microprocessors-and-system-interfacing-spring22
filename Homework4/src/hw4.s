.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.global login
login: .string "xyz"
hello_str: .string "Hello, %s!\n"
.balign  2
.global hello
hello:
	push {lr}
	bl serial_init
	ldr r0,=hello_str
	ldr r1, =login
	bl printf
	pop  {pc}

showsub2_str: .string "%d * %d = %d\n"
.balign  2
.global showstr2
showsub2:
	push {lr}
	movs r1, r0
	movs r2, r1
	ldr r0, =showsub2_str
	movs r3, r1
	subs r3, r2
	bl printf
	pop  {pc}

// Add the rest of your subroutines below

showsub3_str: .string "%d * %d = %d\n"
.balign  2
.global showstr3
showsub3:
	push {lr}
	movs r1, r0
	movs r2, r1
	ldr r0, =showsub2_str
	movs r3, r1
	subs r3, r2
	bl printf
	pop  {pc}
