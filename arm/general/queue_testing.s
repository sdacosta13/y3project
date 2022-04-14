; Unit testing for queue implementation
ADRL R1, addr_thread_queue_start
MOV R0, #1
MOV R2, #0

queue_loop_1
BL queue_push
ADD R2, R2, #1
ADD R0, R0, #1
CMP R1, #-1
BEQ fail
CMP R2, #16
BLNE queue_loop_1

BL queue_push ; Check no overflow
CMP R1, #-1
BLNE fail

ADRL R1, addr_thread_queue_start
MOV R2, #0
MOV R3, #1
queue_loop_2
BL queue_pop
CMP R3, R0
BLNE fail
ADD R3, R3, #1
ADD R2, R2, #1
CMP R2, #16
BNE queue_loop_2

BL queue_pop
CMP R1, #-1
BLNE fail



pass
MOV R0, R0
B pass

fail
MOV R0, R0
B fail ; failure
