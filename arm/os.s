ORIGIN &00000000
B hard_reset                          ; +0   (00)
B undefined_instruction_handler       ; +4   (04)
B svc_handler                         ; +8   (08)
B prefetch_abort_handler              ; +12  (0C)
B data_abort_handler                  ; +16  (10)
NOP                                   ; +20  (14)
B IRQ_handler                         ; +24  (18)
B FIQ_handler                         ; +28  (1C)

halt ; should be jumped to, to stop the proccessor
MOV R0, R0
B halt

; Import handlers
INCLUDE handlers/reset_handler.s
INCLUDE handlers/instruction_handler.s
INCLUDE handlers/prefetch_abort_handler.s
INCLUDE handlers/data_abort_handler.s
INCLUDE handlers/IRQ_handler.s
INCLUDE handlers/FIQ_handler.s
INCLUDE handlers/svc_handler.s

; Import definitions
INCLUDE general/printchar.s
INCLUDE general/printstring.s
INCLUDE general/cursorcontrol.s
INCLUDE general/key_querys.s
INCLUDE general/threading.s
INCLUDE general/queue.s
INCLUDE definitions/keyboard_map.s
INCLUDE definitions/character_definitions.s
INCLUDE definitions/general_definitions.s
INCLUDE definitions/OS_definitions.s


ALIGN
INCLUDE general/usercode.s
