; This file handles queue operations for queues of size MAX_THREADS
queue_push
; IN R0 - Item to push
; IN R1 - Pointer to queue (Corrupts to -1 if push fails)
PUSH {LR}
PUSH {R2 - R12}

; Check queue for space
SUB R2, R1, #4 ; Get address of counter
LDR R3, [R2]
CMP R3, #MAX_THREADS
BGE fail_push

; Perform push
ADD R4, R3, R3
ADD R4, R4, R4 ; R4 = item * 4
ADD R4, R1, R4 ; R4 = address + (item * 4)
STR R0, [R4]

; Update Counter
ADD R3, R3, #1
STR R3, [R2]
B queue_push_quit



fail_push
MOV R1, #-1
queue_push_quit
POP {R2 - R12}
POP {LR}
MOV PC, LR

queue_pop
; OUT R0 - Item popped
; IN  R1 - Pointer to queue (Corrupts to -1 if push fails)
PUSH {LR}
PUSH {R2 - R12}

; Check queue is non empty
SUB R2, R1, #4 ; Get address of counter
LDR R3, [R2]
CMP R3, #0
BEQ queue_pop_fail

; Move queue[0] to output
ADD R2, R2, #4
LDR R0, [R2]

; Perform MAX_THREADS-1 moves left
MOV R4, #MAX_THREADS-1
queue_shift_loop
LDR R5, [R2, #4]!
STR R5, [R2, #-4]!
ADD R2, R2, #4
SUB R4, R4, #1
CMP R4, #0
BNE queue_shift_loop

; Update counter
SUB R2, R1, #4
LDR R3, [R2]
SUB R3, R3, #1
STR R3, [R2]
B queue_pop_quit



queue_pop_fail
MOV R1, #-1
queue_pop_quit
POP {R2 - R12}
POP {LR}
MOV PC, LR

queue_utilisation
; OUT R0 - Counter Stat
; IN  R1 - Pointer to Queue
PUSH {LR}
PUSH {R1 - R12}

SUB R1, R1, #4
LDR R0, [R1]
ADD R1, R1, #4

POP {R1 - R12}
POP {LR}
MOV PC, LR

clear_queue
; IN R1 - Pointer to Queue
PUSH {LR}
PUSH {R0}
PUSH {R1 - R12}

; wipe body
MOV R0, #-1
MOV R2, #0 ; Counter
queue_wipe_loop
STR R0, [R1, R2]
ADD R2, R2, #4
CMP R2, #MAX_THREADS * 4
BNE queue_wipe_loop

; reset item
MOV R0, #0
SUB R1, R1, #4
STR R0, [R1]
ADD R1, R1, #4

POP  {R1 - R12}
POP  {R0}
POP  {LR}
MOV  PC, LR

queue_find
; IN/OUT R0 - target / Position of item or -1 if not found
; IN  R1 - Pointer to Queue
PUSH {LR}
PUSH {R1 - R12}

MOV R2, #0
MOV R4, #0

queue_find_loop
LDR R3, [R1, R2]
CMP R3, R0
MOVEQ R0, R4
BEQ queue_find_exit

ADD R2, R2, #WORD_SIZE_BYTES
ADD R4, R4, #1
CMP R2, #MAX_THREADS * WORD_SIZE_BYTES
BNE queue_find_loop

queue_not_found
MOV R0, #-1
queue_find_exit
POP {R1 - R12}
POP {LR}
MOV PC, LR


queue_index
; IN  R0 - index to check
; IN  R1 - Pointer to queue
; OUT R2 - item to return or -1 if invalid
PUSH {LR}
PUSH {R0 - R1}
PUSH {R3 - R12}

; check index is not out of bounds
SUB  R4, R1, #WORD_SIZE_BYTES ; get address of counter
LDR  R4, [R4]   ; get data
CMP R4, R0
MOVLT R0, #-1
BLT queue_find_exit ; fail if out of range
MOV R3, #WORD_SIZE_BYTES
MUL R3, R0, R3
ADD R1, R1, R3
LDR R2, [R1]



queue_index_exit
POP  {R3 - R12}
POP  {R0 - R1}
POP  {LR}
MOV PC, LR












;
