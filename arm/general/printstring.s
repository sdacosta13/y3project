printstr
; R0 - Address of first char of target string
; R1 - Address of RGB data
PUSH {LR}
PUSH {R0-R12}

MOV R4, R0
printloop
LDRB R0, [R4], #1        ; Get ascii code to printstr
CMP R0, #0
BEQ printstr_exit
BL printchar
B printloop


printstr_exit
POP {R0-R12}
POP {LR}
MOV PC, LR
