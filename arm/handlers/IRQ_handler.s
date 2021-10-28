IRQ_handler
; TODO handle interrupts
PUSH {R0 - R12}
LDR R0, addr_keyboard
LDRB R0, [R0]

POP {R0 - R12}
SUBS PC, LR, #4 ;return to usercode
