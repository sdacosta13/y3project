usercode
INCLUDE queue_testing.s









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
