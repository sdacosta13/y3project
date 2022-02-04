query_keyboard
; Reads first key found into R3
; If not key is found R3 <- 0
PUSH {R4 - R11}
ADRL R4, addr_keyboard_map_start
MOV R10, R4
ADRL R5, addr_keyboard_map_end
ADD R5, R5, #4 ; for making loop easier

continueKeyScan
LDR R6, [R4], #4
CMP R6, #0
BNE keyseen
CMP R4, R5
BNE continueKeyScan
MOV R3, #0

query_keyboard_end
POP {R4 - R11}
MOV PC, LR

keyseen             ; fires there is a key in the map active
MOV R7, #1
MOV R9, #1
B keyseenloopstart1

keyseenloopstart2
ADD R9, R9, #1
ADD R7, R7, R7
keyseenloopstart1
AND R8, R7, R6
CMP R8, R7
BEQ keyfound
B keyseenloopstart2 ; while loop as positive number is seen

keyfound            ; fires once the location can be determined
SUB R4, R4, #4      ; decrement due to post increment
SUB R10, R4, R10    ; work out which byte ascii code is in
MOV R11, #8
MUL R10, R10, R11
ADD R10, R10, R9
ADD R3, R10, #31   ; ascii code = (byte addressed - keymap base) * 8 + bit accessed + ascii offset - 1
B query_keyboard_end


query_key
; Checks the ASCII code in R3 against they keymap
; if (key pressed) R3 <- 1
; else             R3 <- 0
PUSH {R4 - R11}

POP {R4 - R11}
MOV PC, LR
