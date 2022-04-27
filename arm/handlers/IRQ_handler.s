IRQ_handler
; TODO handle interrupts
PUSH {R0 - R12}
LDR  R1, addr_interrupts
LDRB R1, [R1]
CMP R1, #0
BEQ keyboard_interrupt
AND R1, R1, #&01
CMP R1, #&01
BEQ timer_interrupt
B halt

timer_interrupt
;Subtract 1 from the timer compare
;This essentially resets the timer compare
;Without this the interrupt seen at f200_0000 addressed by byte will never clear
;this IRQ_assert is RO
;timer details at page 12 in the lab manual
LDR R1, addr_timer_compare
LDR R2, [R1]
SUB R2, R2, #1
CMP R2, #0
MOVLT R2, #&FF
STR R2, [R1]
; Save state
B save_registers
; Run Sheduler

B IRQ_quit

keyboard_interrupt
LDR R1, addr_keyboard_req
MOV R2, #1
STR R2, [R1] ; Call for data
LDR R0, addr_keyboard
LDRB R0, [R0]
SUB R0, R0, #32
LDR R1, addr_keyboard_dir
LDRB R1, [R1]



; Divide R0 by 8
MOV R3, #0

continueDivisionLoop
SUB R0, R0, #8
CMP R0, #0
BLT exitDivision
ADD R3, R3, #1
B continueDivisionLoop


exitDivision
ADD R0, R0, #8 ; at this point R0: Remainder R3: Result
ADRL R4, addr_keyboard_map_start
ADD R4, R4, R3
LDRB R7, [R4] ; Get the key byte into R4
MOV R5, #1
MOV R6, #0
ADD R5, R6, R5, LSL R0 ; Get Mask

CMP R1, #0
BEQ unpushed
BNE pushed

unpushed
BIC R7, R7, R5
STRB R7, [R4]
B IRQ_quit

pushed
ORR R7, R7, R5
STRB R7, [R4]
keyboard_thread_handling
;return to keyboard context here

MOV R2, #1
STR R2, entering_from_IO
B save_registers



IRQ_quit
POP {R0 - R12}
SUBS PC, LR, #4 ;return to usercode









;
