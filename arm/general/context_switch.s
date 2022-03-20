tempSP DEFW 0
tempR1 DEFW 0

save_registers

SUB LR, LR, #4 ; account for pipelining
ADRL R1, addr_thread_queue_start
MOV R0, LR

PUSH {LR} ; push current PC onto queue
BL queue_push
ADRL R1, thread_queue_register_map
BL get_free_position ;get the next free slot for saving
POP {LR}
STR LR, [R1] ; Put thread PC into map

; calculate base register positions
MOV R3, #4 * 17
MUL R0, R0, R3
ADRL R1, thread_queue_registers
ADD R1, R1, R0
; save user CPSR
MRS R2, SPSR
STR R2, [R1], #4
; save user SP, LR
STMIA R1!, {SP, LR}^
; make copies of SP and base address
STR R1, tempR1
POP{R0 - R12}
STR SP, tempSP
; get user registers back
; setup base registers for user register saving
LDR SP, tempR1
; perform save
STMIA SP!, {R0 - R12}^
; save thread PC
STR LR, [SP]
; get SP_irq back
LDR SP, tempSP
B sheduler

sheduler
; first step is to grab the oldest thread
ADRL R1, addr_thread_queue_start
BL queue_pop
MOV R1, R0
ADRL R0, thread_queue_register_map
; search for thread in register map
BL search_block
MOV R2, #-1
STR R2, [R0]
MOV R3, #4 * 17
MUL R1, R1, R3
ADRL R3, thread_queue_registers
ADD R3, R3, R1





; clear timer interrupt register to ensure the restore procedure occurs atomically
;LDR R0, addr_interrupts_mask
;LDRB R1, [R0]
;BIC R1, R1, #&01
;STRB R1, [R0]

; R3 contains base register
; first restore CPSR
; second restore SP LR
; third restore user registers, PC return to code
LDMIA R3!, {R4}
MSR SPSR_c, R4
LDMIA R3!, {SP, LR}^
LDMIA R3, {R0 - R12, PC}^




get_free_position
; IN R1 address of block (MAX_THREADS * 4)
; OUT R0 index number
; OUT R1 free address
PUSH{R2 - R5}
MOV R0, #0
get_free_not_found
CMP R0, #MAX_THREADS
BEQ halt
LDR R2, [R1], #4
CMP R2, #-1
ADDNE R0, R0, #1
BNE get_free_not_found
SUB R1, R1, #4

POP {R2 - R5}
MOV PC, LR


search_block
; IN R0 address of block
; IN R1 target
; OUT R0 updated address
; OUT R1 index
PUSH {R2 - R5}
MOV R2, #0
search_block_loop_1
CMP R2, #MAX_THREADS
BEQ halt
LDR R3, [R0], #4
CMP R3, R1
ADDNE R2, R2, #1
BNE search_block_loop_1
SUB R0, R0, #4
MOV R1, R2
POP {R2 - R5}
MOV PC, LR













;
