svc_handler
; TODO: handle SVC calls
PUSH {LR}
PUSH {R14}
PUSH {R0}
MRS  R0, CPSR                       ;Enables interrupts while in SVC
BIC  R0, R0, #&C0                   ;Not sure if this is ok currently
MSR  CPSR_c, R0
POP {R0}


LDR R14, [LR, #-4]                  ; Read the caller svc instruction into R14
BIC R14, R14, #&FF000000            ; Clear the opcode (24 bit can now be read)

svc_entry
PUSH {R3}
LDR R3, SVC_MAX
CMP R14, R3                   ; Check SVC < SVC_MAX
POP {R3}
BHI SVC_unknown
SUB R14, R14, #&100                 ; Normalise base of SVCs

ADD R14, PC, R14, LSL #2            ; Calculate SVC jump point in the table
LDR PC, [R14]                   ; Perform Jump


; Jump table
DEFW SVC_0  ; halt
DEFW SVC_1  ; printchar
DEFW SVC_2  ; printstr
DEFW SVC_3  ; timer
DEFW SVC_4  ; button data
DEFW SVC_5  ; set cursorposx
DEFW SVC_6  ; set cursorposy
DEFW SVC_7  ; query_keyboard
DEFW SVC_8  ; query_key
DEFW SVC_9  ; create_thread
DEFW SVC_10 ; end_thread

SVC_0
B halt

SVC_1
BL printchar
B SVC_exit

SVC_2
BL printstr
B SVC_exit

SVC_3
PUSH {R0}
LDR R0, addr_timer
LDR R0, [R0]
POP {R0}        ;TODO: Fix?
B SVC_exit

SVC_4
B SVC_exit

SVC_5
BL set_cursorposx
B SVC_exit

SVC_6
BL set_cursorposy
B SVC_exit

SVC_7
BL query_keyboard
B SVC_exit

SVC_8
BL query_key
B SVC_exit

SVC_9
BL create_thread
B SVC_exit

SVC_10
BL end_thread
B SVC_exit

SVC_exit
PUSH {R0}
MRS R0, CPSR
BIC R0, R0, #&C0
MSR CPSR_c, R0
POP {R0}
POP {R14}
POP {LR}
MOVS PC, LR                        ; Return to usercode, change mode

SVC_unknown
B halt
