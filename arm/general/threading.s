INCLUDE context_switch.s
create_thread
; IN R0 - Address of thread
; Note, a new thread will not have any cleared registers
PUSH {LR}
PUSH {R1 - R12}
ADRL R1, addr_thread_queue_start
MOV R2, R0
MOV R5, #0
BL queue_push
ADRL R1, thread_queue_register_map
ADRL R3, thread_queue_registers
free_thread_search_loop
LDR R4, [R1], #4
CMP R4, #-1
ADDNE R5, R5, #1
BEQ free_thread_found
CMP R1, R3
BEQ halt
B free_thread_search_loop


free_thread_found
STR R2, [R1, #-4]
; Setup return registers
ADRL R6, thread_queue_registers
MOV R7, #4 * 17
MUL R5, R5, R7
ADD R6, R6, R5
MRS R7, CPSR
STR R7, [R6]
ADD R6, R6, #16*4
STR R2, [R6]

POP {R1 - R12}
POP {LR}
MOV PC, LR

end_thread
PUSH {LR}
PUSH {R0 - R12}

POP {R0 - R12}
POP {LR}
MOV PC, LR
