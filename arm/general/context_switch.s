save_registers


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



context_switch_halt
MOV R0, R0
B context_switch_halt
