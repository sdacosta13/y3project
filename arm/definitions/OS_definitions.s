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
SVC_MAX DEFW &10B
; stacks are defined here
cursorposx          DEFW 0
cursorposy          DEFW 0
addr_LCD            DEFW 0xAC00_0000
addr_LCD_end        DEFW 0xAC03_83FF
addr_timer          DEFW 0xF1001010
addr_keyboard       DEFW 0xF1002004
addr_keyboard_req   DEFW 0xF1002000
addr_keyboard_dir   DEFW 0xF1002008
addr_interrupts      DEFW 0xF2000000
addr_interrupts_mask DEFW 0xF2000001
addr_timer_compare   DEFW 0xF1001014
addr_timer_enable    DEFW 0xF100100C ;bit 0 = 1 means timer enabled
charwidth       EQU 24
LCD_linediff    EQU 7680
lcd_char_length EQU 40
lcd_char_height EQU 30

ALIGN
MAX_THREADS EQU 4
THREAD_STACK_SIZE_BYTES EQU &2000
THREAD_STACK_SIZE_WORDS EQU THREAD_STACK_SIZE_BYTES / 4
; Define the space for address queues
; Queues are defined as a Word of data followed by X words
thread
thread_queue_items DEFW 0
addr_thread_queue_start DEFS MAX_THREADS * 4
;addr_thread_queue_end

thread_queue_IO_items DEFW 0
addr_thread_IO_queue_start DEFS MAX_THREADS * 4
;addr_thread_IO_queue_end



; Note, when naming these address I discovered the max length of a label is 32 characters


thread_queue_register_map DEFS MAX_THREADS * 4
thread_queue_registers DEFS MAX_THREADS * 4 * 17 ; declares 17 words for each thread
thread_queue_registers_end                       ; these register are not wiped in reset_handler.s


thread_IO_queue_register_map DEFS MAX_THREADS * 4
thread_IO_queue_registers DEFS MAX_THREADS * 4 * 17 ; declares 17 words for each thread
;thread_IO_queue_registers_end

ALIGN
stack_user DEFS &2000
stackend_user
stacks_in_use DEFS 4 * MAX_THREADS
stack_threads DEFS THREAD_STACK_SIZE_BYTES * MAX_THREADS
stackend_threads

stack_svc DEFS &1000
stackend_svc

stack_IRQ DEFS &1000
stackend_IRQ

stack_FIQ DEFS &1000
stackend_FIQ
; Examples
; thread_queue_register_map + 0x00 : PC (Thread 0)
; thread_queue_register_map + 0x04 : PC (Thread 1)
; thread_queue_register_map + 0x08 : PC (Thread 2)
; thread_queue_register_map + 0x0C : PC (Thread 3)
; thread_queue_registers + 0x00: CPSR (Thread 0)
; thread_queue_registers + 0x04: SP  (Thread 0)
; thread_queue_registers + 0x08: LR  (Thread 0)
; thread_queue_registers + 0x0C: R0  (Thread 0)
; thread_queue_registers + 0x10: R1  (Thread 0)
; thread_queue_registers + 0x14: R2  (Thread 0)
; thread_queue_registers + 0x18: R3  (Thread 0)
; thread_queue_registers + 0x1C: R4  (Thread 0)
; thread_queue_registers + 0x20: R5  (Thread 0)
; thread_queue_registers + 0x24: R6  (Thread 0)
; thread_queue_registers + 0x28: R7  (Thread 0)
; thread_queue_registers + 0x2C: R8  (Thread 0)
; thread_queue_registers + 0x30: R9  (Thread 0)
; thread_queue_registers + 0x34: R10  (Thread 0)
; thread_queue_registers + 0x38: R11  (Thread 0)
; thread_queue_registers + 0x3C: R12  (Thread 0)
; thread_queue_registers + 0x40: PC   (Thread 0)
