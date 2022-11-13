.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.data
.balign 4

.global arr
arr: .word 13, 11, 22, 20,  6, 18, 23, 16,  13, 6, 15, 9,  24, 19, 15, 21

.global value
value: .word 0

.global str
str: .string "HeLLo, 01234 WoRLD! 56789++"



.text
.global intsub
intsub:
PUSH {R4-R7,LR}
movs r0, #0 //r0 = i

for1:
movs r1, #1
ands r1,r0
cmp r1, #1
bne else1

if1:
ldr r2, =value
ldr r3, [r2] // value

ldr r2, =arr
movs r5, #4
muls r5, r0
ldr r4, [r2,r5] //r4 = arr[i]

movs r5, #3
muls r4, r5 //r4 = 3 * arr[i]

adds r3, r4 //r3 = value + 3 * arr[i]

ldr r2, =value
str r3, [r2] //value += 3 * arr[i];

b endif1

else1:
ldr r2, =value
ldr r3, [r2] // value

ldr r2, =arr
movs r5, #1
adds r5, r0
movs r6, #4
muls r5, r6 //r5 = i+1

ldr r4, [r2,r5] //r4 =arr[i+1]
movs r5, #15
ands r4, r5 //r4= 15 & arr[i+1]


movs r5, r0
movs r6, #4
muls r5, r6 //r5 = i

ldr r7, [r2,r5] //r7 =arr[i+1]

movs r6, #31 //r6 =31

ands r7, r6 //r7 = 31 & arr[i]

adds r4, r7 //r4= (15 & arr[i+1])+(31 & arr[i])

adds r3, r4 //r3 = value + (15 & arr[i+1])+(31 & arr[i])

ldr r2, =value
str r3, [r2] //value += (15 & arr[i+1])+(31 & arr[i])

endif1:
adds r0, #1
cmp r0, #15
blt for1

POP {R4-R7,PC}




.global charsub
charsub:
//PUSH {R4-R7,LR}
movs r0, #0 //r0=x

for2:
movs r1,r0
/*
movs r1, 4
muls r1, r0
*/
ldr r2, =str
ldrb r3, [r2, r1] //str[x]

cmp r3, #65
blt endif2 //str[x] >= 'A'

cmp r3, #90
bgt endif2 //str[x] <= 'Z'

if2:
adds r3, #32//r3 = str[x] + 0x20
movs r1,r0
/*
movs r1, 4
muls r1, r0
*/

ldr r2, =str
strb r3, [r2, r1]//str[x] = str[x] + 0x20


endif2:
adds r0, #1 //x++

movs r1,r0
/*
movs r1, 4
muls r1, r0
*/
ldr r2, =str
ldrb r3, [r2, r1] //str[x]


cmp r3, #0 //str[x] != '\0
bne for2




//POP {R4-R7,PC}
bx lr



.global login
login: .string "rkothand" // Make sure you put your login here.
.balign 2

.global main
main:
    bl autotest
    bl intsub
    bl charsub
    bkpt

