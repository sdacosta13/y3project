; reads position from R2


set_cursorposx ; 0 <= R2 < 40
CMP R2, #lcd_char_length
BGE halt
CMP R2, #0
BLE halt
STR R2, cursorposx
MOV PC, LR


set_cursorposy ; 0 <= R2 < 30
CMP R2, #lcd_char_height
BGE halt
CMP R2, #0
BLE halt
STR R2, cursorposy
MOV PC, LR
