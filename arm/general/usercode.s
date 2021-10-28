usercode
ADRL R0, hi
ADRL R1, colours
SVC svc_2
SVC svc_2
SVC svc_2
SVC svc_2
SVC svc_2

halt2
B halt2

hi DEFB "Hello world!",0
test DEFB "test 2",0
colours
DEFB 0x00, 0x00, 0x00
DEFB 0xFF, 0xFF, 0xFF
