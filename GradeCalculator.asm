IO**************************************************************
.ORIG X3000
AND R0, R0, #0 ;CLEAR
AND R1, R1, #0 ;CLEAR
AND R2, R2, #0 ;CLEAR
AND R3, R3, #0 ;CLEAR
AND R4, R4, #0 ;CLEAR

;LEA R0, INPUT
;PUTS                     ;DISPLAY INPUT
JSR DISPLAY
DOITAGAIN GETC

ADD R3,R1,R0            ;GET USER INPUT - ASK IF IN OR GETC
ADD R3,R0,#-15          ;-48 FOR ASCII CONVERSION 
ADD R3,R0,#-15
ADD R3,R0,#-15
ADD R3,R0,#-3

BRz DONE                
ST R0,R2,0
ADD R2,R2,#-1
BR DOITAGAIN

;NEED TO CONVERT BACK TO ASCII
JSR NDISPLAY                ;WILL OUTPUT END DISPLAY. 



DISPLAY LEA R0,INPUT  ;JSR DISPLAY MENU
PUTS
DISPL .STRINGZ "PLEASE INPUT A POSITIVE INTEGER" ; Prints display
DISPL2 .STRINGZ "\N WELCOME TO MIN/MAX/AVG CALCULATOR!"; PRINT DISPLAY 2

NDISPLAY LEA R0,INPUT
NDISPL .STRINZ "THIS IS YOUR AVERAGE RESULT"
NDISPL2 .STRINGZ "THE LETTER GRADE YOU RECEIVED IS: \N"


INPUT .BLKW 5 


;MINIMUM CALCULATOR**********************************************

CALMIN  ST R1, CALMINRESTORER1; SAVE REGISTERS
ST R2, CALMINRESTORER2
ST R3, CALMINRESTORER3
ST R4, CALMINRESTORER4
ST R5, CALMINRESTORER5

LDI R1, HEAD ;Set Head value as minimum
LD R2, STACKSIZE   ;Set R2 as STACKSIZE
ADD R2, R2, #-1   ;R2 = STACKSIZE - 1 (iterate through stack except first element)
LEA R3, HEAD      ;Set R3 as index
ADD R3, R3, #1    ; Increment index by 1

MINLOOP LDR R4, R3, x0 ;Load stack value at index
NOT R4, R4
ADD R4, R4, #1  ;2'S COMPLEMENT : R4 = -STACKELEMENT
ADD R5, R1, R4  ; R5 = MIN - STACKELEMENT
BRnz MINSKIP
NOT R4, R4
ADD R4, R4, #1 ;2'S COMPLEMENT : R4 = STACKELEMENT
ADD R1, R4, x0 ; MIN = STACKELEMENT
MINSKIP ADD R3, R3, #1 ; INCREMENT INDEX
ADD R2, R2, #-1 ; DECREMENT COUNTER
BRp MINLOOP
ST R1, MIN; STORE R1 TO MIN ADDRESS

LD R1, CALMINRESTORER1; RESTORE REGISTERS
LD R2, CALMINRESTORER2
LD R3, CALMINRESTORER3
LD R4, CALMINRESTORER4
LD R5, CALMINRESTORER5
RET

MIN .FILL x0
CALMINRESTORER1 .FILL x0
CALMINRESTORER2 .FILL x0
CALMINRESTORER3 .FILL x0
CALMINRESTORER4 .FILL x0
CALMINRESTORER5 .FILL x0

;MAXINUM CALCULATOR**********************************************

CALMAX ST R1, CALMAXRESTORER1; SAVE REGISTERS
ST R2, CALMAXRESTORER2
ST R3, CALMAXRESTORER3
ST R4, CALMAXRESTORER4
ST R5, CALMAXRESTORER5
LDI R1, HEAD ;Set Head value as MAX
LD R2, STACKSIZE   ;Set R2 as STACKSIZE
ADD R2, R2, #-1   ;R2 = STACKSIZE - 1 (iterate through stack except first element)
LEA R3, HEAD      ;Set R3 as index
ADD R3, R3, #1    ; Increment index by 1

MAXLOOP LDR R4, R3, x0 ;Load stack value at index
NOT R4, R4
ADD R4, R4, #1  ;2'S COMPLEMENT : R4 = -STACKELEMENT
ADD R5, R1, R4  ; R5 = MAX - STACKELEMENT
BRpz MAXSKIP
NOT R4, R4
ADD R4, R4, #1 ;2'S COMPLEMENT : R4 = STACKELEMENT
ADD R1, R4, x0 ; MAX = STACKELEMENT
MAXSKIP ADD R3, R3, #1; INCREMENT INDEX
ADD R2, R2, #-1 ; DECREMENT COUNTER
BRp MAXLOOP
ST R1, MAX; STORE R1 TO MIN ADDRESS

LD R1, CALMAXRESTORER1; RESTORE REGISTERS
LD R2, CALMAXRESTORER2
LD R3, CALMAXRESTORER3
LD R4, CALMAXRESTORER4
LD R5, CALMAXRESTORER5
RET

MAX .FILL x0
CALMAXRESTORER1 .FILL x0
CALMAXRESTORER2 .FILL x0
CALMAXRESTORER3 .FILL x0
CALMAXRESTORER4 .FILL x0
CALMAXRESTORER5 .FILL x0

;AVERAGE CALCULATOR************************************************************
CALAVG ST R1, CALAVGRESTORER1; SAVE REGISTERS
ST R2, CALAVGRESTORER2
ST R3, CALAVGRESTORER3
ST R4, CALAVGRESTORER4
ST R5, CALAVGRESTORER5
ST R7, CALAVGRESTORER7 ; SAVE RETURN ADDRESS, SINCE WE ARE USING NESTED SUBROUTINE
AND R1, R1, x0 ; CLEAR R1, USE AS ACCUMULATOR
LEA R2, HEAD          ; USE R2 FOR INDEX
LD R3, STACKSIZE ; LOAD STACKSIZE FOR COUNTER
ACCLOOP
LDR R4, R2, x0 ; LOAD STACKELEMENT AT INDEX
ADD R1, R1, R4 ; ACC = ACC + STACKELEMENT
ADD R2, R2, #1 ; INCREMENT INDEX
ADD R3, R3, #-1 ; DECREMENT COUNTER
BRp ACCLOOP
LD R2, STACKSIZE ; REUSE R2 TO LOAD STACKSIZE
ST R1, N; STORE R1 (SUM) INTO NUMERATOR
ST R2, D; STORE R2 (STACKSIZE) INTO DENOMINATOR
JSR DIV
LD R1, QUOTIENT; REUSE R1 TO LOAD QUOTIENT
ST R1, AVGINT; STORE INTEGER PART OF AVERAGE TO AVGINT
LD R1, REMAINDER; LOAD REMAINDER INTO R1
LD R3, HUNDRED ; LOAD 100 INTO R3
ST R1, Y ; STORE AVG REMAINDER INTO MULTIPLICAND
ST R3, X ; STORE HUNDRED TO MULTIPLIER
JSR MULT
LD R1, XTIMESY ; REUSE R1 TO STORE AVG REMAINDER TIMES 100
ST R1, N ; STORE R1 (AVG REMAINDER * 100) INTO NUMERATOR
ST R2, D ; STORE R2 (STACKSIZE) INTO DENOMINATOR
JSR DIV
LD R1, QUOTIENT ; REUSE R1 TO LOAD QUOTIENT (DECIMAL PART OF AVG)
LD R3, REMAINDER ; REUSE R3 TO LOAD SECOND REMAINDER
AND R4, R4, x0 ; CLEAR R4
ADD R4, R4, #2 ; R4 = 2
ST R2, N ; STORE STACKSIZE INTO NUMERATOR
ST R4, D ; STORE 2 INTO DENOMINATOR
JSR DIV
LD R4, REMAINDER ; REUSE R4 TO HOLD REMAINDER OF STACKSIZE / 2
LD R5, QUOTIENT ; REUSE R5 TO HOLD STACKSIZE / 2
ADD R4, R4, #0 ; R4 = R4 + 0
BRz STACKEVEN ; DETERMINE STACK PARITY TO DETERMINE ROUNDING CUT
ADD R2, R2, #-1 ; R2 = STACKSIZE - 1
AND R4, R4, #0 ; CLEAR R4
ADD R4, R4, #2 ; R4 = 2
ST R2, N ; STORE STACKSIZE = 1 INTO NUMERATOR
ST R4, D ; STORE 2 INTO DENOMINATOR
JSR DIV
LD R4, QUOTIENT; R4 = (STACKSIZE - 1) / 2 = ROUNDING CUT
BR AVGSKIP
STACKEVEN ADD R4, R5, #-1 ; R4 = (STACKSIZE / 2) - 1 = ROUNDING CUT
AVGSKIP NOT R4, R4
ADD R4, R4, #1 ; R4 = MINUS ROUNDING CUT
ADD R2, R3, R4 ; R2 = SECOND REMAINDER - ROUNDING CUT
BRnz ROUNDSKIP
ADD R1, R1, #1 ; R1 = AVGDEC + 1 (ROUND UP DECIMAL PART OF AVERAGE)
ROUNDSKIP ST R1, AVGDEC ; STORE AVGDEC
LD R1, CALAVGRESTORER1 ; RESTORE REGISTERS
LD R2, CALAVGRESTORER2
LD R3, CALAVGRESTORER3
LD R4, CALAVGRESTORER4
LD R5, CALAVGRESTORER5
LD R7, CALAVGRESTORER7 ; RESTORE RETURN ADDRESS
RET

AVGINT .FILL x0
AVGDEC .FILL x0
CALAVGRESTORER1 .FILL x0
CALAVGRESTORER2 .FILL x0
CALAVGRESTORER3 .FILL x0
CALAVGRESTORER4 .FILL x0
CALAVGRESTORER5 .FILL x0
CALAVGRESTORER7 .FILL x0




;NOTE ON MULT AND DIV: THERE SHOULD BE ERROR CHECKING FOR NEGATIVES AND FOR DIVISION BY ZERO
;THIS WILL BE DONE IN INPUT FUNCTIONS, HOWEVER, SO MULT AND DIV SUBROUTINES SHOULD BE FINE

;MULTIPLICATION*******************************************************
;BITSHIFT MULTIPLICATION
;ASSUME R1 = X IS MULTIPLIER AND R2 = Y IS MULTIPLICAND. ALTERNATIVE IS MEMORY LOCATIONS
MULT ST R1, MULTRESTORER1 ; SAVE REGISTER
ST R2, MULTRESTORER2
ST R3, MULTRESTORER3
ST R4, MULTRESTORER4
ST R5, MULTRESTORER5
LD R1, X; LOAD X
LD R2, Y; LOAD Y
AND R3, R3, x0 ; CLEAR R3
ADD R3, R3, x1 ; SET R3 AS BIT THAT WE ARE MULTIPLYING AT
AND R4, R4, x0 ; CLEAR R4, SET R4 AS ACCUMULATOR
AND R5, R5, x0 ; CLEAR R5
ADD R5, R5, #15 ; SET R5 AS COUNTER

MULTLOOP AND R6, R2, R3; CHECK IF BIT IS EQUAL TO ZERO
BRz MULTISZERO
ADD R4, R4, R1; ADD MULTIPLIED x0
MULTISZERO ADD R3, R3, R3 ; R3 = 2 * R3, MULTIPLY BIT BY BINARY 10
ADD R1, R1, R1; R1 = 2 * R1, MULTIPLY X BY BINARY 10
ADD R5, R5, #-1 ; DECREMENT COUNTER
BRp MULTLOOP
ST R4, XTIMESY; RETURN RESULT
LD R1, MULTRESTORER1 ; RESTORE REGISTERS
LD R2, MULTRESTORER2
LD R3, MULTRESTORER3
LD R4, MULTRESTORER4
LD R5, MULTRESTORER5
RET

X .FILL x0
Y .FILL x0
XTIMESY .FILL x0
MULTRESTORE1 .FILL x0
MULTRESTORE2 .FILL x0
MULTRESTORE3 .FILL x0
MULTRESTORE4 .FILL x0
MULTRESTORE5 .FILL x0

;DIVISION********************************************************************
;NOT BITSHIFT
;ASSUME R1 = N FOR NUMERATOR AND R2 = D FOR DENOMINATOR
; R1 WILL OUTPUT REMAINDER, R3 WILL OUTPUT QUOTIENT
;NOTE: BRANCHING COULD BE OPTIMIZED

DIV ST R1, DIVRESTORER1 ; SAVE REGISTERS
ST R2, DIVRESTORER2
ST R3, DIVRESTORER3
LD R1, N ; LOAD N
LD R2, D ; LOAD D
AND R3, R3, #0 ; CLEAR R3, SET AS ACCUMULATOR/QUOTIENT
NOT R2, R2
ADD R2, R2, #1; 2S COMPLEMENT : R2 = -D
DIVLOOP ADD R1, R1, R2 ; R = R - D
BRzn BREAKDIV ; IF REMAINDER IS ZERO OR NEGATIVE, BREAK LOOP
ADD R3, R3, #1; INCREMENT QUOTIENT
BR DIVLOOP
BREAKDIV ADD R1, R1, #0 ; R1 = R + 0
BRn ADDREMAINDER
ADD R3, R3, #1 ; ADD 1 TO Q, SINCE WE SKIP THIS INSTRUCTION WHEN WE BREAK LOOP
BR DIVSKIP
ADDREMAINDER NOT R2, R2
ADD R2, R2, #1 ; 2S COMPLEMENT : R2 = DENOMINATOR
ADD R1, R1, R2 ; R1 = R + D (MAKE SURE REMAINDER IS POSITIVE)
DIVSKIP ST R3, QUOTIENT ; STORE R3 TO QUOTIENT
ST R1, REMAINDER; STORE R1 TO REMAINDER
LD R1, DIVRESTORER1
LD R2, DIVRESTORER2
LD R3, DIVRESTORER3
RET

N .FILL x0
D .FILL x0
QUOTIENT .FILL x0
REMAINDER .FILL x0
DIVRESTORER1 .FILL x0
DIVRESTORER2 .FILL x0
DIVRESTORER3 .FILL x0

