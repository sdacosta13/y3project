svc_0 EQU &100 ; halt
svc_1 EQU &101 ; print char
svc_2 EQU &102 ; print string
svc_3 EQU &103 ; get timer
svc_4 EQU &104 ; button data
svc_5 EQU &105 ; set cursorposx
svc_6 EQU &106 ; set cursorposy
SVC_MAX DEFW &106
; stacks are defined here
cursorposx DEFW 0
cursorposy DEFW 0
addr_LCD            DEFW 0xAC00_0000
addr_LCD_end        DEFW 0xAC03_83FF
addr_timer          DEFW 0xF1001010
addr_keyboard       DEFW 0xF1003000
charwidth       EQU 24
LCD_linediff    EQU 7680
lcd_char_length EQU 40
lcd_char_height EQU 30
ALIGN


stack_user DEFS &2000
stackend_user

stack_svc DEFS &1000
stackend_svc

stack_IRQ DEFS &1000
stackend_IRQ

stack_FIQ DEFS &1000
stackend_FIQ
