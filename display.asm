;--------------------------------------
; Declarations 
;--------------------------------------
; Interopt Declarations
numberMemLo DATA 30h
numberMemHi DATA 31h
displayMem DATA 32h

; Port Declarations
segmentSelectPort EQU P0
segmentShowPort EQU P1

; Declarations for Division
numberLo DATA 33h
numberHi DATA 34h
divLo DATA 35h
divHi DATA 36h
quotLo DATA 37h
quotHi DATA 38h
remLo DATA 33h
remHi DATA 34h

;--------------------------------------
; Display 
;--------------------------------------
clear_display:
    MOV segmentShowPort, #00h
    MOV segmentSelectPort, #00h
    RET

display_number:
    ; DIV 1000
    MOV numberHi, numberMemHi
    MOV numberLo, numberMemLo
    MOV divHi, #03h
    MOV divLo, #0E8h
    CALL div16x16

    MOV A, quotLo 
    ADD A, #80h
    MOV displayMem, A
    CALL display_digit

    ; DIV 100
    MOV A, remLo
    MOV B, #64h
    DIV AB
    ADD A, #40h
    MOV displayMem, A
    CALL display_digit

    ; DIV 10
    MOV A, B
    MOV B, #0Ah
    DIV AB
    ADD A, #20h
    MOV displayMem, A
    CALL display_digit
    
    ; REMAINING 
    MOV A, B
    ADD A, #10h
    MOV displayMem, A
    CALL display_digit 
    
    RET 

; Reads displayMem where 000[3 bits pos][4 bits for digit] and sets P1 and P0 corresponding
;   posBits: [3rd pos][2nd pos][1st pos][0th pos]
;   digitBits: just binary counting up 0-9
display_digit:
    ; get digit in dec
    MOV A, displayMem
    ANL A, #0Fh ; A = 0-9

    ; set P0(segments)
    MOV DPTR, #DEC_SEGMENT_MAP
    MOVC A, @A+DPTR
    MOV segmentSelectPort, A

    ; get pos and set P1(position)
    MOV A, displayMem
    SWAP A
    ANL A, #0Fh
    MOV segmentShowPort, A

    CALL clear_display
    RET

; Mapping Segmente auf P1
; A -> 7.bit
; B -> 6.bit
; C -> 5.bit
; D -> 4.bit
; E -> 3.bit
; F -> 2.bit
; G -> 1.bit
; P -> 0.bit
DEC_SEGMENT_MAP:
    DB 0xFC ; 0 -> A B C D E F           = 11111100
    DB 0x60 ; 1 ->   B C                 = 01100000
    DB 0xDA ; 2 -> A B   D E   G         = 11011010
    DB 0xF2 ; 3 -> A B C D     G         = 11110010
    DB 0x66 ; 4 ->   B C     F G         = 01100110
    DB 0xB6 ; 5 -> A   C D   F G         = 10110110
    DB 0xBE ; 6 -> A   C D E F G         = 10111110
    DB 0xE0 ; 7 -> A B C                 = 11100000
    DB 0xFE ; 8 -> A B C D E F G         = 11111110
    DB 0xF6 ; 9 -> A B C D   F G         = 11110110



;--------------------------------------
; 16x16 Division 
;--------------------------------------
div16x16:   
   ; Rem equ DIV
   MOV remLo, numberLo
   MOV remHi, numberHi

    ; Quot init 0
    MOV quotLo, #0
    MOV quotHi, #0

    CALL div_loop16x16
    RET

div_loop16x16:
    ; Prüfe ob Rest >= Divisor (16-Bit Vergleich)

    MOV A, remHi
    CLR C
    SUBB A, divHi
    JC div_done       ; Rest High < Divisor High → Rest < Divisor

    JZ check_low      ; Wenn equal, prüfe Low-Bytes

    ; Rest High > Divisor High → subtrahieren möglich
    JMP do_subtract

check_low:
    MOV A, remLo
    CLR C
    SUBB A, divLo
    JC div_done       ; Rest Low < Divisor Low → Rest < Divisor

    ; Rest >= Divisor → Subtraktion möglich

do_subtract:
    ; Subtrahiere Divisor von Rest
    MOV A, remLo
    CLR C
    SUBB A, divLo
    MOV remLo, A

    MOV A, remHi
    SUBB A, divHi
    MOV remHi, A

    ; Quotient erhöhen (16-Bit)
    MOV A, quotLo
    INC A
    MOV quotLo, A
    JNZ continue_loop
    ; Überlauf in Low-Byte → High-Byte erhöhen
    MOV A, quotHi
    INC A
    MOV quotHi, A

continue_loop:
    JMP div_loop16x16

div_done:
    RET


END
