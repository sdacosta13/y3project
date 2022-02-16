svc_0  EQU &100 ; halt
svc_1  EQU &101 ; print char
svc_2  EQU &102 ; print string
svc_3  EQU &103 ; get timer
svc_4  EQU &104 ; button data
svc_5  EQU &105 ; set cursorposx
svc_6  EQU &106 ; set cursorposy
svc_7  EQU &107 ; query_keyboard
svc_8  EQU &108 ; query_key
svc_9  EQU &109 ; create_thread
svc_10 EQU &10A ; end_thread
SVC_MAX DEFW &10A
; stacks are defined here
cursorposx          DEFW 0
cursorposy          DEFW 0
addr_LCD            DEFW 0xAC00_0000
addr_LCD_end        DEFW 0xAC03_83FF
addr_timer          DEFW 0xF1001010
addr_keyboard       DEFW 0xF1002004
addr_keyboard_req   DEFW 0xF1002000
addr_keyboard_dir   DEFW 0xF1002008
charwidth       EQU 24
LCD_linediff    EQU 7680
lcd_char_length EQU 40
lcd_char_height EQU 30

ALIGN
MAX_THREADS EQU 16
; Define the space for address queues
; Queues are defined as a Word of data followed by X words

thread_queue_items DEFW 0
addr_thread_queue_start DEFS MAX_THREADS * 4
addr_thread_queue_end

thread_queue_IO_items DEFW 0
addr_thread_IO_queue_start DEFS MAX_THREADS * 4
addr_thread_IO_queue_end

ALIGN


stack_user DEFS &2000
stackend_user

stack_svc DEFS &1000
stackend_svc

stack_IRQ DEFS &1000
stackend_IRQ

stack_FIQ DEFS &1000
stackend_FIQ
