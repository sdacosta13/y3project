usercode
MOV R0, #0
MOV R1, #1
MOV R2, #2
MOV R3, #3
MOV R4, #4
MOV R5, #5
MOV R6, #6
MOV R7, #7
MOV R8, #8
MOV R9, #9
MOV R10, #10
MOV R11, #11
MOV R12, #12

ADRL R0, thread2
BL create_thread


ADRL R1, colours
thread3
SVC svc_11
SVC svc_7
MOV R0, R3
SVC svc_1
B thread3






; ~ 0xDE24
thread2
ADD R3, R3, #1
B thread2









;ADRL R1, colours
;sam
;SVC svc_7
;CMP R3, #0
;BEQ sam
;MOV R0, R3
;SVC svc_1
;B sam

hi DEFB "Hello world!",0
test DEFB "test 2",0
colours
DEFB 0x00, 0x00, 0x00
DEFB 0xFF, 0xFF, 0xFF
