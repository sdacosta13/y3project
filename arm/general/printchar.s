printchar  ; character to be printed held in R0 in ASCII
           ; Address of 6 bytes representing character and background RGB held in R1
PUSH {LR}
PUSH {R0-R12}

MOV R4, R0
CMP R4, #127
BGE unknown_character
CMP R4, #7
BLE unknown_character
CMP R4, #13
BLE control_handler
CMP R4, #32
BLT unknown_character ; if this fails, R4, contains a legal character

ADRL R0, font_32
SUB  R4, R4, #32
MOV  R5, #7
MUL  R4, R4, R5
ADD  R0, R0, R4
B character_write

control_handler
LDR  R6, cursorposx
LDR  R7, cursorposy
SUB R4, R4, #8
ADD R5, PC, R4, LSL #2
LDR PC, [R5]

DEFW BS_handler
DEFW HT_handler
DEFW LF_handler
DEFW VT_handler
DEFW FF_handler
DEFW CR_handler

BS_handler
SUB R6, R6, #1
CMP R6, #0
BGE control_exit
MOV R6, #0
SUB R7, R7, #1
CMP R7, #0
MOVLT R7, #0
B control_exit

HT_handler
ADD R6, R6, #1
CMP R6, #lcd_char_length
BNE control_exit
MOV R6, #0
ADD R7, R7, #1
CMP R7, #lcd_char_height
MOVEQ R7, #0
B control_exit

LF_handler
ADD R7, R7, #1
CMP R7, #lcd_char_height
MOVEQ R7, #0
B control_exit

VT_handler
SUB R7, R7, #1
CMP R7, #0
MOVLT R7, #0
B control_exit

FF_handler
MOV R10, #&FF
LDR R8, addr_LCD
LDR R9, addr_LCD_end
screenblankloop2
STRB R10, [R8], #1
CMP R8, R9
BNE screenblankloop2
B control_exit

CR_handler
ADD R7, R7, #1
CMP R7, #lcd_char_height
MOVEQ R7, #0
MOV R6, #0
B control_exit

control_exit
STR R6, cursorposx
STR R7, cursorposy
POP {R0-R12}
POP {LR}
MOV PC, LR


character_write
LDR R4, cursorposx                   ; Calculate the correct address to write to
MOV R5, #charwidth
MUL R4, R4, R5
LDR R5, cursorposy
MOV R6, #LCD_linediff
MUL R5, R5, R6
ADD R4, R4, R5
LDR R5, addr_LCD
ADD R4, R4, R5                       ; R4 now holds the top left address for the char to write to
MOV R5, #-1                          ; R5 counts the width of the char (1-7 inc)
MOV R6, #0                           ; R6 counts the height of the char (1-8 inc)
MOV R7, #1                           ; R7 is the value to compare too
MOV R8, #0                           ; R8 contains the font data i am querying
B post_address_fetch

font_line_return
CMP R5, #-1
BEQ post_address_fetch

LDRB R8, [R0, R5]
post_address_fetch
AND R9, R8, R7
CMP R9, R7
BEQ pixel_font
BNE pixel_background

pixel_write_return
ADD R6, R6, #1                       ; perform height increments
ADD R7, R7, R7
ADD R4, R4, #LCD_width
CMP R6, #8
BNE font_line_return

MOV R6, #0                           ; reset R6 and R7
MOV R7, #1
ADD R5, R5, #1                       ; perform width increments
CMP R5, #7
SUB R4, R4, #LCD_linediff
;ADD R4, R4, #LCD_width
ADD R4, R4, #3
BNE font_line_return

LDR R4, cursorposx
LDR R5, cursorposy
ADD R4, R4, #1
CMP R4, #lcd_char_length
MOVGE R4, #0
ADDGE R5, R5, #1
CMP R5, #lcd_char_height
MOVGE R4, #0
MOVGE R5, #0
STR R4, cursorposx
STR R5, cursorposy

POP {R0-R12}
POP {LR}
MOV PC, LR


pixel_font
LDRB R10, [R1], #1                   ; Load the R byte to R10, increment address to point to G byte
STRB R10, [R4], #1
LDRB R10, [R1], #1                   ; Load the G byte to R10, increment address to point to B byte
STRB R10, [R4], #1
LDRB R10, [R1], #-2                  ; Load the B byte to R10, point address at R byte
STRB R10, [R4], #-2                  ; routine ends pointing at the pixel just coloured
B pixel_write_return

pixel_background
ADD  R1, R1, #3
LDRB R10, [R1], #1                   ; Load the R byte to R10, increment address to point to G byte
STRB R10, [R4], #1
LDRB R10, [R1], #1                   ; Load the G byte to R10, increment address to point to B byte
STRB R10, [R4], #1
LDRB R10, [R1], #-2                  ; Load the B byte to R10, point address at R byte
STRB R10, [R4], #-2                  ; routine ends pointing at the pixel just coloured
SUB  R1, R1, #3
B pixel_write_return

unknown_character                    ; TODO: Add some sort of error handler?
B halt
