;originate from x3000
.ORIG X3000
AND R0, R0, #0    ;clear all registers 
AND R1, R1, #0    
AND R2, R2, #0    
AND R3, R3, #0    
AND R4, R4, #0    
JSR STACK         ;prepare grade stack
JSR DIGITSTACK    ;prepare digit stack
JSR MAIN          ;load main subroutine
HALT              ;halt program

;INTRO

;**INITIALIZE THE DIGIT STACK**
;This will hold 3 digits in ascii form. Used in conversion.
DIGITSTACK
  AND R0, R0, #0
  ST R0, DIGITSIZE
  LD R0, DIGITBOTTOM
  ST R0, DIGITTOP
  LD R0, DIGITCAPACITY
  RET

DIGITBOTTOM .FILL x4200   ;base of the stack
DIGITSIZE .BLKW #1      
DIGITTOP .BLKW #1         ;will keep pointing to the top of the stack;originally pointing to x4000
DIGITCAPACITY .FILL #3    ;only three elements are allowed in the stack;must 

;**DIGIT SUBROUTINE**

DIGITPUSH
      ST R1, DIGITSAVER1
      ST R2, DIGITSAVER2
      LD R1, DIGITSIZE
      LD R2, DIGITTOP   ;load STACKTOP pointer to R2
      ADD R2, R2, #-1   ;MUST ADD -1 AS PUSHING 
      STR R0, R2, #0    ;PUSH element
      ST R2, DIGITTOP   ;UPDATE TOP OF THE STACK
      ADD R1, R1, #1    
      ST R1, DIGITSIZE  ;ADD ONE TO STACKSIZE TO INCREMENT THE size
      LD R1, DIGITSAVER1
      LD R2, DIGITSAVER2
      RET
DIGITSAVER1  .FILL x0  ;SAVE REGISTER 1
DIGITSAVER2  .FILL x0  ;SAVE REGISTER 2



;**DIGIT POP ROUTINE**

DIGITPOP
      ST R1, DIGITPOPSAVER1
      ST R2, DIGITPOPSAVER2
      AND R5, R5, #0
      LD R1, DIGITSIZE  ;LOAD STACKSIZE TO R1
      BRz ISDIGITEMPTY  ;IF STACKSIZE = 0, CAN NO LONGER POP, CONT TO ISEMPTY SUBROUTINE
      LD R2, DIGITTOP
      LDR R0, R2, #0    ;POP ELEMENT ;USING LDR SINCE WE USED STR IN PUSH SUBROUTINE
      ADD R2, R2, #1    ;MUST ADD 1 AS POPPING
      ST R2, DIGITTOP
      ADD R1, R1, #-1   ;DELETE ONE FROM THE STACKSIZE
      ST R1, DIGITSIZE  ;UPDATE size
      ADD R5, R5, #1
ISDIGITEMPTY ;SUBROUTINE FOR IF STACK IS EMPTY;NO MORE ELEMENTS CAN BE POPPED
      LD R1, DIGITPOPSAVER1
      LD R2, DIGITPOPSAVER2
      RET
DIGITPOPSAVER1 .FILL x0      ;SAVE REGISTER 1
DIGITPOPSAVER2 .FILL x0      ;SAVE REGISTER 2

;pointers for digitpop function
MAINYPTR .FILL Y
MAINXPTR .FILL X
MAINXTIMESYPTR .FILL XTIMESY
MAINMINPTR .FILL MIN
MAINMAXPTR .FILL MAX
MAINAVGINTPTR .FILL AVGINT
MAINAVGDECPTR .FILL AVGDEC
MAINNPTR .FILL N
MAINDPTR .FILL D
MAINQUOTIENTPTR .FILL QUOTIENT
MAINREMAINDERPTR .FILL REMAINDER
MAINSTACKCAPACITYPTR .FILL STACKCAPACITY

DISPL .STRINGZ "INPUT THREE POSITIVE INTEGERS OF AN ASSIGNMENT GRADE\n" ; Prints display
DISPL3 .STRINGZ "EX: ENTER 97 AS '097'\n"
DISPL2 .STRINGZ "WELCOME TO MIN/MAX/AVG CALCULATOR!\n"; PRINT DISPLAY 2


;**MAIN**

MAIN ST R7, CONVERTADDRESS          ;Save return addressave return addess
LDI R1, MAINSTACKCAPACITYPTR
OUTERLOOP                           ;outerloop. First get all grade assignments and store them into stack
  AND R6, R6, #0
  ADD R6, R6, #3
	LEA R0, DISPL	;LOAD
	PUTS		              ;Print first display - Displaying instructions
	AND R0, R0, #0 	      ;clear R0
  LEA R0, DISPL3        
  PUTS                  ;Print display 3
  AND R0, R0, #0
	LEA R0, DISPL2	       	
	PUTS		              ;Print display 2
	AND R0, R0, #0	      ;Clear R0
    DOITAGAIN IN        ;Loop for input : up to 3 times for each digit
    JSR DIGITPUSH		    ;Push onto digit stack
    ADD R6, R6, #-1
    BRp DOITAGAIN             
  JSR DIGITPOP          ;Pop first digit
  JSR DECIMAL	          ;Convert ASCII to decimal
  AND R4, R4, x0        ;Initialize accumulator R4 to 0
  ADD R4, R4, R0        ;Add first digit to R4
  JSR DIGITPOP          ;Pop second digit
  JSR DECIMAL		        ;Convert ASCII to decimal
  STI R0, MAINYPTR
  AND R5, R5, x0
  ADD R5, R5, #10
  STI R5, MAINXPTR
  JSR MULT                ;Multiply second digit by 10
  LDI R0, MAINXTIMESYPTR
  ADD R4, R4, R0          ;Add (2nd digit times 10) to R4
  JSR DIGITPOP            ;Pop third digit
  JSR DECIMAL	            ;Convert ASCII to decimal
  STI R0, MAINYPTR
  AND R5, R5, x0          ;initialize to R5 and then add 15, six times
  ADD R5, R5, #15
  ADD R5, R5, #15
  ADD R5, R5, #15
  ADD R5, R5, #15
  ADD R5, R5, #15
  ADD R5, R5, #15
  ADD R5, R5, #10
  STI R5, MAINXPTR
  JSR MULT                ;Multiply third digit by 100
  LDI R0, MAINXTIMESYPTR
  ADD R4, R4, R0          ;Add (3rd digit times 100) to R4
  ADD R0, R4, #0
  JSR PUSH                ;Copy R4 into R0, then push to grade stack
  AND R0, R0, x0          ;Clear R0
  ADD R1, R1, #-1         ;Decrement R1
  BRp OUTERLOOP
  JSR CALMIN		          ;Call minimum subroutine	. All grades have been pushed into the stack now
  JSR CALMAX		          ;Call maximum subroutine
  JSR CALAVG		          ;Call average subroutine
  LDI R2, MAINMINPTR
  ST R2, VALUE            ;store value in R2
  JSR CONVERTASCII        ;convert MIN to ascii
  LEA R0, MINDISPL        ;Display MIN sentence
  PUTS
  JSR DIGITPOP            ;pop out each digit of MIN and display it to the user
  OUT
  JSR DIGITPOP
  OUT
  JSR DIGITPOP
  OUT
  AND R0, R0, #0
  LDI R2, MAINMAXPTR
  ST R2, VALUE             ;store MAX value in R2
  JSR CONVERTASCII         ;convert MAX value to ascii
  LEA R0, MAXDISPL         ;Display MAX sentence
  PUTS 
  JSR DIGITPOP             ;pop out each digit of MAX value from digit stack and display it to user
  OUT
  JSR DIGITPOP
  OUT
  JSR DIGITPOP
  OUT
  AND R0, R0, #0
  LDI R3, MAINAVGINTPTR
  ST R3, VALUE 
  JSR CONVERTASCII          ;convert avgint value to ascii
  LEA R0, AVGDISPL		      ;Display avg sentence
  PUTS
  JSR DIGITPOP              ;pop out each digit of avgint value from digit stack
  OUT
  JSR DIGITPOP
  OUT
  JSR DIGITPOP
  OUT
  LD R0, DECIMALCHAR        ;print out "." after avgint
  OUT                       ;OUT decimal character
  LDI R3, MAINAVGDECPTR
  ST R3, VALUE
  JSR CONVERTASCII          ;Convert avgdec part into ascii
  JSR DIGITPOP              ; Skip 1st digit (We want to display only two digits)
  JSR DIGITPOP              ; Print other two digits
  OUT
  JSR DIGITPOP
  OUT
  AND R0,R0,#0
  JSR LETTERGRADEBRANCH     ;Determine letter grade
  LD R7, CONVERTADDRESS     ;Restore return address
  RET

  ;initialize variables
  CONVERTADDRESS .FILL x0
  MINDISPL .STRINGZ "\THE MIN GRADE IS : \n"
  MAXDISPL .STRINGZ "\nTHE MAX GRADE IS : \n"
  AVGDISPL .STRINGZ "\nTHE AVERGAGE GRADE IS : \n"

;**CONVERTING BACK TO ASCII**
;Converting a grade value into 3 asccii digits in the digit stack
CONVERTASCII ST R0, CONVERTASCIIRESTORER0    
  ST R1, CONVERTASCIIRESTORER1               ;Save registers
  ST R2, CONVERTASCIIRESTORER2
  ST R7, CONVERTASCIIRESTORER7
  LD R1, VALUE                               ;load generic value to R1
  STI R1, MIDNPTR
  AND R2, R2, #0
  ADD R2, R2, #10
  STI R2, MIDDPTR
  JSR DIV                                    ;Divide Value by 10
  LDI R1, MIDQUOTIENTPTR
  LDI R0, MIDREMAINDERPTR
  JSR ASCII
  JSR DIGITPUSH                             ;ASCII convert and push remainder into digit stack
  STI R1, MIDNPTR
  STI R2, MIDDPTR
  JSR DIV                                   ;Divide previous quotient by 10
  LDI R1, MIDQUOTIENTPTR
  LDI R0, MIDREMAINDERPTR
  JSR ASCII
  JSR DIGITPUSH                             ;ASCII convert and push remainder into digit stack
  STI R1, MIDNPTR
  STI R2, MIDDPTR
  JSR DIV                                   ;Divie previous quotient by 10
  LDI R0, MIDREMAINDERPTR                   ;ASCII convert and push remainder into digit stack
  JSR ASCII
  JSR DIGITPUSH
  LD R0, CONVERTASCIIRESTORER0
  LD R1, CONVERTASCIIRESTORER1
  LD R2, CONVERTASCIIRESTORER2
  LD R7, CONVERTASCIIRESTORER7              ;restore registers, including return address
  RET

  VALUE .FILL x0
  CONVERTASCIIRESTORER0 .FILL x0
  CONVERTASCIIRESTORER1 .FILL x0
  CONVERTASCIIRESTORER2 .FILL x0
  CONVERTASCIIRESTORER7 .FILL x0

;initialize variables 
MIDYPTR .FILL Y
MIDXPTR .FILL X
MIDXTIMESYPTR .FILL XTIMESY
MIDMINPTR .FILL MIN
MIDMAXPTR .FILL MAX
MIDAVGINTPTR .FILL AVGINT
MIDAVGDECPTR .FILL AVGDEC
MIDNPTR .FILL N
MIDDPTR .FILL D
MIDQUOTIENTPTR .FILL QUOTIENT
MIDREMAINDERPTR .FILL REMAINDER

;**LETTER GRADE**
  
LETTERGRADEBRANCH ST R0, LETTERGRADEBRANCHRESTORER0 ;save registers, including return address
  ST R1, LETTERGRADEBRANCHRESTORER1
  ST R2, LETTERGRADEBRANCHRESTORER2
  ST R7, LETTERGRADEBRANCHRESTORER7
  LDI R2, MIDAVGINTPTR 
  ADD R1, R2, #-15
  ADD R1, R1, #-15
  ADD R1, R1, #-15
  ADD R1 ,R1, #-15
  ADD R1, R1, #-15
  ADD R1 ,R1, #-15        ;subtract avgint - 90
  BRn NEXT                ;if avg < 90, go to next comparison
  LEA R0, LETTERGRADEA
  PUTS
  BR SKIP                 ;if avgint > 90, display line and skip to end
  NEXT
  ADD R1, R2, #-15        ;subtract avgint - 80 
  ADD R1, R1, #-15        ;if avgint < 80 go to next comparison
  ADD R1, R1, #-15
  ADD R1, R1, #-15
  ADD R1, R1, #-15
  ADD R1, R1, #-5
  BRn NEXT2
  LEA R0, LETTERGRADEB
  PUTS
  BR SKIP
  NEXT2
  ADD R1, R2, #-15
  ADD R1, R1, #-15
  ADD R1, R1, #-15
  ADD R1, R1, #-15
  ADD R1, R1, #-10        ;subtract avgint - 70
  BRn NEXT3               ;if avgint < 70, go to next comparison
  LEA R0, LETTERGRADEC
  PUTS
  BR SKIP                 ;if avgint > 70, display line and skip to end
  NEXT3
  ADD R1, R2, #-15
  ADD R1, R1, #-15
  ADD R1, R1, #-15
  ADD R1, R1, #-15        ;subtract avgint - 60
  BRn NEXT4               ;if avgint < 60, go print "F"
  LEA R0, LETTERGRADED
  PUTS
  BR SKIP                 ;if avgint > 60, display line and skip to end
  NEXT4
  LEA R0, LETTERGRADEF
  PUTS
  SKIP LD R0, LETTERGRADEBRANCHRESTORER0
  LD R1, LETTERGRADEBRANCHRESTORER1
  LD R2, LETTERGRADEBRANCHRESTORER2
  LD R7, LETTERGRADEBRANCHRESTORER7   ;restore registers
  RET

LETTERGRADEBRANCHRESTORER0 .FILL x0
LETTERGRADEBRANCHRESTORER1 .FILL x0
LETTERGRADEBRANCHRESTORER2 .FILL x0
LETTERGRADEBRANCHRESTORER7 .FILL x0

DECIMALCHAR .FILL X2E                 ;ASCII value for decimal character



LETTERGRADEA .STRINGZ "\nThe LETTER GRADE IS: A \n"
LETTERGRADEB .STRINGZ "\nThe LETTER GRADE IS: B \n"
LETTERGRADEC .STRINGZ "\nThe LETTER GRADE IS: C \n"
LETTERGRADED .STRINGZ "\nThe LETTER GRADE IS: D \n"
LETTERGRADEF .STRINGZ "\nThe LETTER GRADE IS: F \n"

;CONVERT ASCII CHARACTER TO NUMBER
DECIMAL ADD R0,R0,#-15 
ADD R0,R0,#-15  ; subtracting 48 to convert to decimal
ADD R0,R0,#-15
ADD R0,R0,#-3
RET

;CONVERT SINGLE NUMBER TO ASCII CHARACTER
ASCII ADD R0,R0,#15 
ADD R0,R0,#15 ; add 48 to convert back to ascii
ADD R0,R0,#15
ADD R0,R0,#3
RET



;GRADE STACK
;Contains all of the grades in variable size array
;**INITIALIZE STACK SUBROUTINE**
STACK

      AND R0, R0, #0        ;clear register R0
      ST R0, STACKSIZE      ;store all variables in R0
      LD R0, STACKBOTTOM
      ST R0, STACKTOP
      LD R0, STACKCAPACITY
      RET

STACKBOTTOM .FILL x4400     ;base of the stack
STACKSIZE .BLKW #1          ;initialize the variable to hold the size of the stack
STACKTOP .BLKW #1           ;will keep pointing to the top of the stack;originally pointing to x4000
STACKCAPACITY .FILL #5      ;only five elements are allowed in the stack

;initialize the push subroutine 
PUSH
      ST R1, SAVER1
      ST R2, SAVER2
      LD R1, STACKSIZE
      LD R2, STACKCAPACITY
      NOT R2, R2            ;compare the size with the capacity by subtracting them
      ADD R2, R2, #1
      ADD R2, R1, R2
      BRz ISFULL            ;if the stack is full move on to the ISFULL 
      ;if stack is not full then continue to add an element onto the stack
      LD R2, STACKTOP       ;LOAD STACKTOP POINTER TO R2
      ADD R2, R2, #-1       ;Must add -1 as pushing 
      STR R0, R2, #0        ;PUSH element;will change
      ST R2, STACKTOP       ;Update top of stack
      ADD R1, R1, #1    
      ST R1, STACKSIZE      ;Add one to stacksize to increment the size 
;ISFULL subroutine will stop adding to the stack if STACKCAPACITY is reached
ISFULL 
      LD R1, SAVER1
      LD R2, SAVER2
      RET
SAVER1  .FILL x0             ;Save register 1
SAVER2  .FILL x0             ;Save register 2
STACKFULLMESSAGE .STRINGZ "STACK IS FULL. CAN NO LONGER ADD ELEMENTS\n" ;error message

;initialize pop subroutine
POP
      ST R1, POPSAVER1
      ST R2, POPSAVER2       
      LD R1, STACKSIZE       ;LOAD STACKSIZE TO R1
      BRz ISEMPTY            ;IF STACKSIZE = 0, CAN NO LONGER POP, CONT TO ISEMPTY SUBROUTINE
      LD R2, STACKTOP
      LDR R0, R2, #0         ;pop element using LDR since we used STR in push subtroutine
      ADD R2, R2, #1         ;must add 1 as popping
      ST R2, STACKTOP
      ADD R1, R1, #-1        ;delete one from the stacksize
      ST R1, STACKSIZE       ;UPDATE size ;ADD R5, R5, #1 ;SUBROUTINE FOR IF STACK IS EMPTY;NO MORE ELEMENTS CAN BE POPPED
ISEMPTY
      LD R1, POPSAVER1
      LD R2, POPSAVER2
      RET
POPSAVER1 .FILL x0           ;SAVE REGISTER 1
POPSAVER2 .FILL x0           ;SAVE REGISTER 2
STACKEMPTYMESSAGE .STRINGZ "STACK IS EMPTY. CAN NO LONGER REMOVE ELEMENTS\n"  ;error message

;**CALCULATE MINIMUM**

CALMIN  ST R1, CALMINRESTORER1; save registers
ST R2, CALMINRESTORER2
ST R3, CALMINRESTORER3
ST R4, CALMINRESTORER4
ST R5, CALMINRESTORER5

LDI R1, STACKTOP             ;Set Head of grade stack as minimum
LD R2, STACKSIZE             ;Set R2 as STACKSIZE
ADD R2, R2, #-1              ;R2 = STACKSIZE - 1 (iterate through stack except first element)
LD R3, STACKTOP              ;Set R3 as index
ADD R3, R3, #1               ;Increment index by 1

MINLOOP LDR R4, R3, x0       ;Load stack value at index
NOT R4, R4
ADD R4, R4, #1               ;2''s complement : R4 = -stackelement
ADD R5, R1, R4               ;R5 = min - stackelement
BRnz MINSKIP                 ;if min > element, set element as new min
NOT R4, R4
ADD R4, R4, #1               ;2's complement : R4 = stackelement
ADD R1, R4, x0               ;min = stackelement
MINSKIP ADD R3, R3, #1       ;increment index
ADD R2, R2, #-1              ;decrement counter
BRp MINLOOP
ST R1, MIN                   ;store R1 to MIN ADDRESS

LD R1, CALMINRESTORER1       ;restore registers
LD R2, CALMINRESTORER2
LD R3, CALMINRESTORER3
LD R4, CALMINRESTORER4
LD R5, CALMINRESTORER5
RET

;initialize variables
MIN .FILL x0
CALMINRESTORER1 .FILL x0
CALMINRESTORER2 .FILL x0
CALMINRESTORER3 .FILL x0
CALMINRESTORER4 .FILL x0
CALMINRESTORER5 .FILL x0

;**MAXINUM CALCULATOR**

CALMAX ST R1, CALMAXRESTORER1    ;save registers
ST R2, CALMAXRESTORER2
ST R3, CALMAXRESTORER3
ST R4, CALMAXRESTORER4
ST R5, CALMAXRESTORER5
LDI R1, STACKTOP                 ;Set Head value as MAX
LD R2, STACKSIZE                 ;Set R2 as STACKSIZE
ADD R2, R2, #-1                  ;R2 = STACKSIZE - 1 (iterate through stack except first element)
LD R3, STACKTOP                  ;Set R3 as index
ADD R3, R3, #1                   ;Increment index by 1

MAXLOOP LDR R4, R3, x0           ;Load stack value at index
NOT R4, R4
ADD R4, R4, #1                   ;2's complement : R4 = -stackelement
ADD R5, R1, R4                   ;R5 = max - stackelement
BRzp MAXSKIP                     ;if max < stackelement, set stackelement as new max
NOT R4, R4
ADD R4, R4, #1 		               ;2's complement : R4 = stackelement
ADD R1, R4, x0 		               ;max = element
MAXSKIP ADD R3, R3, #1		       ;increment index
ADD R2, R2, #-1 		             ;decrement counter
BRp MAXLOOP
ST R1, MAX			                 ;store R1 to MAX address

LD R1, CALMAXRESTORER1           ;Restore registers
LD R2, CALMAXRESTORER2
LD R3, CALMAXRESTORER3
LD R4, CALMAXRESTORER4
LD R5, CALMAXRESTORER5
RET

;initialize variables
MAX .FILL x0
CALMAXRESTORER1 .FILL x0
CALMAXRESTORER2 .FILL x0
CALMAXRESTORER3 .FILL x0
CALMAXRESTORER4 .FILL x0
CALMAXRESTORER5 .FILL x0

;**AVERAGE CALCULATOR**

CALAVG ST R1, CALAVGRESTORER1      ;save registers, including return address
ST R2, CALAVGRESTORER2
ST R3, CALAVGRESTORER3
ST R4, CALAVGRESTORER4
ST R5, CALAVGRESTORER5
ST R7, CALAVGRESTORER7              ;FIRST, sum up all of the grades in grade stack
AND R1, R1, x0                      ;clear R1, use as accumulator
LD R2, STACKTOP                     ;use R2 for index
LD R3, STACKSIZE                    ;load STACKSIZE for counter
ACCLOOP
LDR R4, R2, x0                      ;load STACKELEMENT at index
ADD R1, R1, R4                      ;ACC = ACC + STACKELEMENT
ADD R2, R2, #1                      ;increment index
ADD R3, R3, #-1                     ;decrement counter
BRp ACCLOOP
LD R2, STACKSIZE                    ;reuse R2 to load STACKSIZE
ST R1, N                            
ST R2, D                            
JSR DIV                             ;Divide total by stacksize
LD R1, QUOTIENT                     ;reuse R1 to load quotient
ST R1, AVGINT                       ;store integer part of AVERAGE to AVGINT
LD R1, REMAINDER                    
LD R3, HUNDRED                      
ST R1, Y                            
ST R3, X                            
JSR MULT                            ;Multiply remainder by 100
LD R1, XTIMESY                      ;reuse R1 to store AVG REMAINDER times 100
ST R1, N
ST R2, D                            
JSR DIV                             ;Divide (AVG REMAINDER * 100) / stacksize
LD R1, QUOTIENT                     ;reuse R1 to load QUOTIENT (DECIMAL PART OF AVG)
LD R3, REMAINDER                    ;reuse R3 TO load second REMAINDER
AND R4, R4, x0 ; CLEAR R4
ADD R4, R4, #2 ; R4 = 2
ST R2, N                            
ST R4, D                            
JSR DIV                             ;Divide stack size by 2
LD R4, REMAINDER                    ;reuse R4 to hold REMAINDER of STACKSIZE / 2
LD R5, QUOTIENT                     ;reuse R5 to hold STACKSIZE / 2
ADD R4, R4, #0                      ;R4 = R4 + 0
BRz STACKEVEN                       ;Use STACK PARITY to determine rounding cut
ADD R2, R2, #-1                     ;R2 = STACKSIZE - 1
AND R4, R4, #0                      ;clear R4
ADD R4, R4, #2                      ;R4 = 2
ST R2, N                            ;store STACKSIZE = 1 into NUMERATOR
ST R4, D                            ;store 2 into DENOMINATOR
JSR DIV
LD R4, QUOTIENT                     ;R4 = (STACKSIZE - 1) / 2 = ROUNDING CUT if stacksize is odd
BR AVGSKIP
STACKEVEN ADD R4, R5, #-1           ;R4 = (STACKSIZE / 2) - 1 = ROUNDING CUT if stacksize is even
AVGSKIP NOT R4, R4
ADD R4, R4, #1                      ;R4 = MINUS ROUNDING CUT
ADD R2, R3, R4                      ;R2 = SECOND REMAINDER - ROUNDING CUT
BRnz ROUNDSKIP                      ; If SECOND REMAINDER > ROUNDING CUT, round AVGDEC up
ADD R1, R1, #1                      ;R1 = AVGDEC + 1 (Round up decimal part of average)
ROUNDSKIP ST R1, AVGDEC             ;store AVGDEC
LD R1, CALAVGRESTORER1              ;restore REGISTERS
LD R2, CALAVGRESTORER2
LD R3, CALAVGRESTORER3
LD R4, CALAVGRESTORER4
LD R5, CALAVGRESTORER5
LD R7, CALAVGRESTORER7              ;restore return address
RET

;initialize variables
AVGINT .FILL x0
AVGDEC .FILL x0
HUNDRED .FILL #100
CALAVGRESTORER1 .FILL x0
CALAVGRESTORER2 .FILL x0
CALAVGRESTORER3 .FILL x0
CALAVGRESTORER4 .FILL x0
CALAVGRESTORER5 .FILL x0
CALAVGRESTORER7 .FILL x0



;**MULTIPLICATION**
;BITSHIFT MULTIPLICATION

MULT ST R1, MULTRESTORER1         ;save registers
ST R2, MULTRESTORER2
ST R3, MULTRESTORER3
ST R4, MULTRESTORER4
ST R5, MULTRESTORER5
LD R1, X                          ;load X
LD R2, Y                          ;load Y
AND R3, R3, x0                    ;clear R3
ADD R3, R3, x1                    ;set R3 as bit that we are multiplying at
AND R4, R4, x0                    ;clear R4, set R4 as ACCUMULATOR
AND R5, R5, x0                    ;clear R5
ADD R5, R5, #15                   ;set R5 as COUNTER

MULTLOOP AND R6, R2, R3           ;check if bit is equal to zero
BRz MULTISZERO
ADD R4, R4, R1                    ;add MULTIPLIED x0
MULTISZERO ADD R3, R3, R3         ;R3 = 2 * R3, Multiply bit by binary 10
ADD R1, R1, R1                    ;R1 = 2 * R1, multiply X by binary 10
ADD R5, R5, #-1                   ;decrement counter
BRp MULTLOOP
ST R4, XTIMESY                    ;return result
LD R1, MULTRESTORER1              ;restore registers
LD R2, MULTRESTORER2
LD R3, MULTRESTORER3
LD R4, MULTRESTORER4
LD R5, MULTRESTORER5
RET
;initialize variables
X .FILL x0
Y .FILL x0
XTIMESY .FILL x0
MULTRESTORER1 .FILL x0
MULTRESTORER2 .FILL x0
MULTRESTORER3 .FILL x0
MULTRESTORER4 .FILL x0
MULTRESTORER5 .FILL x0

;**DIVISION**
;NOT BITSHIFT

DIV ST R1, DIVRESTORER1             ;save registers
ST R2, DIVRESTORER2
ST R3, DIVRESTORER3
LD R1, N                            ;load N
LD R2, D                            ;load D
AND R3, R3, #0                      ;clear R3, set as ACCUMULATOR/QUOTIENT
NOT R2, R2
ADD R2, R2, #1                      ;2S complement : R2 = -D
DIVLOOP ADD R1, R1, R2              ;R = R - D
BRnz BREAKDIV                       ;if remainder is zero or negative, break loop
ADD R3, R3, #1                      ;increment QUOTIENT
BR DIVLOOP
BREAKDIV ADD R1, R1, #0             ;R1 = R + 0
BRn ADDREMAINDER
ADD R3, R3, #1                      ;add 1 to Q, since we skip this instruction when we break loop
BR DIVSKIP
ADDREMAINDER NOT R2, R2
ADD R2, R2, #1                      ;2S complement : R2 = denominator
ADD R1, R1, R2                      ;R1 = R + D (make sure remainder is positive)
DIVSKIP ST R3, QUOTIENT             ;store R3 TO quotient
ST R1, REMAINDER                    ;store r1 to remainder
LD R1, DIVRESTORER1
LD R2, DIVRESTORER2
LD R3, DIVRESTORER3
RET
;initialize variables
N .FILL x0
D .FILL x0
QUOTIENT .FILL x0
REMAINDER .FILL x0
DIVRESTORER1 .FILL x0
DIVRESTORER2 .FILL x0
DIVRESTORER3 .FILL x0

;end program
.END