INCLUDE context_switch.s
create_thread
; IN R0 - Address of thread
; Note, a new thread will not have any cleared registers
; The CPSR for this thread will be set from the current thread
; The Stack pointer will be allocated but all other registers are undefined
PUSH {LR}
PUSH {R1 - R12}
ADRL R1, addr_thread_queue_start
MOV R2, R0
MOV R5, #0
BL queue_push

;setup stack
ADRL R8, stacks_in_use
MOV R9, #-4

stack_search_loop
CMP R9, #4 * MAX_THREADS
BEQ halt
ADD R9, R9, #4
LDR R10, [R8, R9]
CMP R10, #-1
BNE stack_search_loop
MOV R10, #1
STR R10, [R8, R9]
ADD R9, R9, #4                       ; stacks are full descending so point to 'end of stack'
MOV R11, #THREAD_STACK_SIZE_WORDS    ; R9 Counts in words
MUL R9, R9, R11
ADRL R10, stack_threads
ADD R9, R9, R10




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
STR R7, [R6], #4
STR R9, [R6]
ADD R6, R6, #15*4
STR R2, [R6]



POP {R1 - R12}
POP {LR}
MOV PC, LR

end_thread
; IN - R12 usermode SP


; Needs to deallocate its stack pointer
; there is no protections against stacks overrunning into each other, so this operation is likely to
; have undefined behaviour in the event that a stack overrun occurs


; Compare the stack pointer against potential positions
; Assume there is no overflow as theres not much I can do about it
ADRL R0, stack_threads
ADD R1, R0, #THREAD_STACK_SIZE_BYTES
MOV R2, #0 ; Thread counter (counts in 4's)

check_next_thread_loop
CMP R2, #MAX_THREADS * 4
BEQ halt ; SP index not found

; check lower bound
CMP R12, R0
BLT halt ; SP Should never be lower then the lower bound.

; check upper bound
CMP R12, R1  ; If (SP <= Upper bound) the index has been found
BLE thread_index_found

; increment counter and bounds
ADD R2, R2, #4
ADD R0, R0, #THREAD_STACK_SIZE_BYTES
ADD R1, R1, #THREAD_STACK_SIZE_BYTES
B check_next_thread_loop

thread_index_found
ADRL R0, stacks_in_use
ADD R0, R0, R2
MOV R1, #-1
STR R1, [R0]

;exit thread by picking up another.
B sheduler



















;
