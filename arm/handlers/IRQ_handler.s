IRQ_handler
; TODO handle interrupts
PUSH {R0 - R12}
LDR R0, addr_keyboard
LDRB R0, [R0]
SUB R0, R0, #32 ; move by table offset
ADRL R1, addr_keyboard_map_start
MOV R2, #0
ADD R1, R1, R0, ASR #3  ; Integer divide ascii code by 8 and add to address base

divloop         ; R0 % 8 operation
SUB R0, R0, #8
CMP R0, #0
BGE divloop
ADD R0, R0, #8
MOV R3, #1
ADD R0, R2, R3, LSL R0    ; R0 <- 0 + 1 * (2^R0) sets up mask

LDR R4, addr_keyboard_dir
LDR R4, [R4]

CMP R4, #0
BNE setKey
B   unsetKey


setKey
LDRB R2, [R1]
BIC R2, R2, R0
ORR R2, R2, R0
STRB R2, [R1]
B nextIRQ1
unsetKey
LDRB R2, [R1]
BIC R2, R2, R0
STRB R2, [R1]
B nextIRQ1


nextIRQ1
POP {R0 - R12}
SUBS PC, LR, #4 ;return to usercode
