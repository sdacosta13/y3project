create_thread
PUSH {LR}
PUSH {R0 - R14}

POP {R0 - R14}
POP {LR}
MOV PC, LR

end_thread
PUSH {LR}
PUSH {R0 - R14}

POP {R0 - R14}
POP {LR}
MOV PC, LR
