save_registers

SUB LR, LR, #4 ; accouint for pipelining
; write LR to queue
ADRL R1, addr_thread_queue_start
MOV R0, LR    ; MOV LR, to parameter register
BL queue_push
MOV LR, R0    ; Restore LR

;MOVE R0-R12 to save location
ADRL R0, thread_queue_register_map
MOV R1, #0

free_thread_loop  ; Needs work, assumes free thread will be found
LDR R2, [R0, R1]
CMP R2, #-1
ADDNE R1, R1, #4
BNE free_thread_loop
STR LR, [R0, R1]  ; Write LR to index
ADD R1, R1, #4
ADRL R0, thread_queue_registers
MOV R2, #16
MUL R1, R1, R2     ; Offset = previous offset * 16
ADD R0, R0, R1     ; R0 points to the top of the stack

MOV R3, #0
register_store_loop
LDR R4, [SP], #4
STR R4, [R0, #-4]!
ADD R3, R3, #1
CMP R3, #13
BNE register_store_loop

; A this point 13 registers are stored
STR SP, [R0, #-4]!
STR LR, [R0, #-4]! ; Not sure if this is handled properly
STR LR, [R0, #-4]!
B sheduler
sheduler
ADRL R1, addr_thread_queue_start
BL queue_pop
; R0 contians the PC of the thread to switch to
B restore_registers






restore_registers
; takes R1 as thread ident

ADRL R0, thread_queue_register_map
MOV R2, #0
; find PC in table
restore_registers_loop_1
LDR R3, [R0], #4
CMP R3, R1
ADDNE R2, R2, #1
BNE restore_registers_loop_1

; clear table index
SUB R0, R0, #4
MOV R5, #-1
STR R5, [R0]


; calc address of stored registers
ADD R2, R2, #1
ADRL R0, thread_queue_registers
MOV R3, #MAX_THREADS * 4 * 16
MUL R2, R2, R3
ADD R0, R0, R2  ; R0 = base_address + ((index+1) * 16 words)
; restore registers
MOV SP, R0
POP {R0 - R15}


































;
