INCLUDE context_switch.s
create_thread
PUSH {LR}
PUSH {R0 - R12}

POP {R0 - R12}
POP {LR}
MOV PC, LR

end_thread
PUSH {LR}
PUSH {R0 - R12}

POP {R0 - R12}
POP {LR}
MOV PC, LR
