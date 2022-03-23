queue_pop_with_io
; OUT R0 - Item popped
; This function implements a less general form or queue
; This function should loop over the items in the queue and pop the first item which is not waiting for IO

; More specifically it should do this by looking up the PC saved in the main thread and finding which index
; that PC is in the register map. It should then check if the index is in the IO queue
; If the index is not in the queue, I can pull this item from the queue and then normalise the queue
; If the index is in the queue I move to the next item in the main thread queue
; In the event that I can't find anything to currently do I will move to an Idle thread


; When the IO queue is empty it should have the same effect as running queue_pop
PUSH {LR}
PUSH {R1 - R12}




ADRL R1, addr_thread_queue_start
MOV R11, R1
ADRL R12, addr_thread_IO_queue_start
BL queue_utilisation ; R0 now contains length of queue
MOV R3, R0
MOV R0, #0           ; R0 counts up to R3

queue_pop_with_io_loop
MOV R1, R11
BL queue_index
; R2 contains candidate PC
; determine wether PC is waiting on IO or not
BL convert_pc_to_index
; R2 contains PC
; R3 contains index of PC's threads
MOV R1, R12
BL queue_find
CMP R0, #-1
BEQ move_to_pop




ADD R0, R0, #1
CMP R0, R3
BEQ jobless
B queue_pop_with_io_loop

jobless
B halt

move_to_pop
MOV R1, R11
MOV R0, R2
BL queue_find
; R0 contains the index of PC I want to pop
; R2 contains the PC
; Need to update the queue to remove this item.
MOV R5, #WORD_SIZE_BYTES
MUL R5, R5, R0
ADD R6, R11, R5
ADD R7, R6, #WORD_SIZE_BYTES


move_to_pop_loop
MOV R9, #MAX_THREADS
SUB R9, R9, R0
SUB R9, R9, #1
CMP R9, #0                ; quit condition is MAX_THREADS - index of PC - 1 = 0
BEQ move_to_pop_done

LDR R8, [R7], #WORD_SIZE_BYTES
STR R8, [R6], #WORD_SIZE_BYTES
ADD R0, R0, #1
B move_to_pop_loop
move_to_pop_done
MOV R7, #-1 ; write a -1 to the last byte incase queue was full
STR R7, [R6]

;neet to update the counter
SUB R1, R1, #WORD_SIZE_BYTES
LDR R3, [R1]
SUB R3, R3, #1
STR R3, [R1]
MOV R0, R2


POP  {R1 - R12}
POP  {LR}
MOV PC, LR






convert_pc_to_index
; IN  R2 - PC of thread
; OUT R3 - index of PC in thread_queue_register_map
PUSH {LR}
PUSH {R4 - R12}
ADRL R6, thread_queue_register_map
MOV R7, #0
MOV R4, #0

search_block_io_loop
LDR R5, [R6, R7]
CMP R5, R2
BEQ found


ADD R7, R7, #WORD_SIZE_BYTES
ADD R4, R4, #1
CMP R4, #MAX_THREADS
BEQ halt ; should never occur
B search_block_io_loop
found
MOV R3, R4

POP {R4 - R12}
POP {LR}
MOV PC, LR
