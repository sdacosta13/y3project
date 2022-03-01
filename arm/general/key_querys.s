query_keyboard
; Reads first key found into R3
; If not key is found R3 <- 0
PUSH {LR}
PUSH {R4 - R12}
ADRL R4, addr_keyboard_map_start ; R4: start of map
ADRL R5, addr_keyboard_map_end   ; R5: end of map
MOV  R6, #1                      ; R6: bit mask
MOV  R8, #2                      ; R8: multiplier
MOV  R11, #32                    ; R11: ascii character
                                 ; R7: byte data
                                 ; R9: working reg AND data
keyboard_byte_loop
MOV R6, #1
LDRB R7, [R4], #1
keyboard_bit_loop

;actual checks perfromed
AND R9, R7, R6
CMP R9, R6
MOVEQ R3, R11
BEQ quit


ADD R11, R11, #1
MUL R6, R6, R8
CMP R6, #256
BNE keyboard_bit_loop
CMP R4, R5
BNE keyboard_byte_loop
MOV R3, #0

quit
POP {R4 - R12}
POP {LR}
MOV PC, LR

query_key
; Check if R3 ascii character is in map
PUSH {LR}
POP {LR}
MOV PC, LR
