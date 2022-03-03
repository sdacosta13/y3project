hard_reset
; Resets the proccessor to a known state, is also run at boot
MOV R0, #0
MOV R1, #0
MOV R2, #0
MOV R3, #0
MOV R4, #0
MOV R5, #0
MOV R6, #0
MOV R7, #0
MOV R8, #0
MOV R9, #0
MOV R10, #0
MOV R11, #0
MOV R12, #0

; setup IO
STR R0, cursorposx
STR R0, cursorposy
MOV R0, #&FF
LDR R1, addr_LCD
LDR R2, addr_LCD_end

screenblankloop
STRB R0, [R1], #1
CMP R2, R1
BNE screenblankloop


;setup timer
MOV R0, #0
LDR R1, addr_timer_compare
STR R0, [R1]
LDR R1, addr_timer_enable
LDR R0, [R1]
BIC R0, R0, #&03
ORR R0, R0, #&01
STR R0, [R1]
ADRL SP, stackend_svc

; clear queues
ADRL R1, addr_thread_queue_start
BL clear_queue
ADRL R1, addr_thread_IO_queue_start
BL clear_queue

; wipe old register PCs
; for regular threads
ADRL R1, thread_queue_register_map
MOV R2, #-1 ; write unusual value to PC location to indicate garbage
MOV R3, #0

thread_register_wipe_loop_1
STR R2, [R1], #4
ADD R3, R3, #1
CMP R3, #MAX_THREADS
BNE thread_register_wipe_loop_1


; wipe previous actual registers
; for regular threads
ADRL R1, thread_queue_registers
ADRL R2, thread_queue_registers_end
MOV  R3, #0
thread_register_wipe_loop_2
STR R3, [R1], #4
CMP R1, R2
BNE thread_register_wipe_loop_2


;for IO threads
ADRL R1, thread_IO_queue_register_map
MOV R2, #-1
MOV R3, #0

thread_IO_register_wipe_loop
STR R2, [R1], #4
ADD R3, R3, #1
CMP R3, #MAX_THREADS
BNE thread_IO_register_wipe_loop



;setup interrupts
LDR  R1, addr_interrupts_mask
LDRB R0, [R1]
BIC  R0, R0, #&C1
ORR  R0, R0, #&C1
STRB R0, [R1]

;wipe debounce map
ADRL R1, addr_keyboard_map_start
ADRL R2, addr_keyboard_map_end
MOV  R3, #0
debounce_wipe_loop
STRB R3, [R1], #1
CMP R1, R2
BNE debounce_wipe_loop
LDR R1, addr_keyboard_req
MOV R2, #1
STRB R2, [R1]

MRS  R0, CPSR
BIC  R0, R0, #&C0             ;set bit 6,7 to 0 to enable FIQ and IRQ
BIC  R0, R0, #&1F
ORR  R0, R0, #&12
MSR  CPSR_c, R0               ;switch to IRQ
ADRL SP, stackend_IRQ

MRS  R0, CPSR
BIC  R0, R0, #&1F
ORR  R0, R0, #&11
MSR  CPSR_c, R0               ;switch to FIQ
ADRL SP, stackend_FIQ


MRS  R0, CPSR
BIC  R0, R0, #&1F
ORR  R0, R0, #&10
MSR  CPSR_c, R0               ;switch to user
ADRL SP, stackend_user



MOV R0, #0
MOV R1, #0
MOV R2, #0

B usercode
; End of hard_reset
addr_interrupts      DEFW 0xF2000000
addr_interrupts_mask DEFW 0xF2000001
addr_timer_compare   DEFW 0xF1001014
addr_timer_enable    DEFW 0xF100100C ;bit 0 = 1 means timer enabled
