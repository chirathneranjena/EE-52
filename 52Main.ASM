
;;;					Chirath Neranjena Thouppuarachchi
;;;					EE / CS 52

NAME  MP3
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    52 Main	                             ;
;                         Main File for the Mp3 Player	                     ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program is the main function of the Mp3 Player
;		    It include the Initialization of the chip select,
;			sets the interrupt vector table, and installs the
;			timer event handler and the illegal even handler.
;		        It also contains the elapsed time function returning 
;		    	the time an mp3 has been playing.
;		    WARNING!: The program is an infinite Loop	                    		 
;
; Input:            Keys from the Keypad, Mp3 data from hard drive.
; Output:           Time, Track, Status, Artist and Title Details on the LCD screen
;		    Mp3 bits to the mp3 decoder board.	
;
; User Interface:   Keypad.
; Error Handling:   None.
;
; Algorithms:       Start
;		  	Inititalize Hardware
;			Call Main Function to play mp3 (written by Glen George 2002)
;			Sit in an Infinite Loop
;		    End.
;
; Data Structures:  None.
;
; Revision History:
;
;     6/15/02  Chirath Neranjena 	Final Demo Version


CGROUP  GROUP   CODE
DGROUP	GROUP	DATA

; local include files

$INCLUDE(51MAIN.INC)

; External Functions to be Called
EXTRN   InitDisplay     :NEAR
EXTRN	SetInterface	:NEAR
EXTRN	MP3InterruptHandler	:NEAR
EXTRN   Scan            :NEAR
EXTRN   Main            :NEAR
EXTRN   InitIDE         :NEAR

CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS:CGROUP, DS:DGROUP, SS:DGROUP


START:  

Init:
        MOV     AX, STACK               ;initialize the stack pointer
        MOV     SS, AX
        MOV     SP, OFFSET(TopOfStack)

        MOV     AX, DATA                ;initialize the data segment
        MOV     DS, AX


        CALL    InitCS                  ;initialize the 80188 chip selects
                                        ;   assumes LCS and UCS already setup

        CALL    ClrIRQVectors           ;clear (initialize) interrupt vector table

                                        ;initialize the variables for the timer event handler


        CALL    InstallHandler          ;install the event handler
                                        ;   ALWAYS install handlers before
                                        ;   allowing the hardware to interrupt.

        CALL    InitTimer               ;initialize the internal timer

        CALL    InitDisplay		; Initialize the LCD Display

        CALL    InitIDE			; Initialize and Get Hard Drive Parameters

        STI				; Enable Interrupts

        CALL    Main			; Hand over control to the the Main Function

       
Forever:
  
        JMP	Forever                 ;sit in an infinite loop, nothing to
                                        ;   do in the background routine

        HLT                             ;never executed (hopefully)



; TimerEventHandler
;
; Description:      This procedure is the event handler for the timer 0
;                   interrupt.  It generated interrupts for keypad functions
;		    and for the Elapsed timer functions.	
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  TimeElapsed
; Shared Variables: None.
; Global Variables: None
; Input:            None.
; Output:           Undated TimeElapsed Variable
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      5 words
;
; Revision     :    Chirath Neranjena  May 21, 2002
;		    
;		    	
;

TimerEventHandler       PROC    NEAR

        PUSHF

        PUSH    AX                      ;save the registers
        PUSH    BX                      ;Event Handlers should NEVER change
        PUSH    DX                      ;   any register values

        PUSH    ES
        PUSH    SI


	INC	TimeElapsed		; Update the TimeElapsed variable
        CALL    Scan			; Check if there is a Keypress and do appropriate function

EndTimerEventHandler:                   ;done taking care of the timer

        MOV     DX, INTCtrlrEOI         ;send the EOI to the interrupt controller
        MOV     AX, Timer0EOI
        OUT     DX, AL


        POP     SI
        POP     ES

        POP     DX                      ;restore the registers
        POP     BX
        POP     AX

        POPF

        IRET                            ;and return (Event Handlers end with IRET not RET)


TimerEventHandler       ENDP




; InitCS
;
; Description:      Initialize the Peripheral Chip Selects on the 80188.
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  AX, DX for holding port addresses and their values
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    May 2002

InitCS  PROC    NEAR


        MOV     DX, PACSreg     ;setup to write to PACS register
        MOV     AX, PACSval
        OUT     DX, AL          ;write PACSval to PACS (base at 0, 3 wait states)

        MOV     DX, MMCSreg	; set up write to MMCS register
        MOV     AX, MMCSval	; Write MMCSVal to MMCS (base at 8000, 0 wait states)
        OUT     DX, AX		;


        MOV     DX, MPCSreg     ;setup to write to MPCS register
        MOV     AX, MPCSval
        OUT     DX, AL          ;write MPCSval to MPCS (I/O space, 3 wait states)

        

        RET                     ;done so return


InitCS   ENDP




; InitTimer
;
; Description:      Initialize the 80188 Timers.
;    		    Timer 0 is set to generate interrupts at a frequancy 1000Hz
;			User by Keypad and elapsed time Functions
;                   
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  AX, DX - for holding Port addresses and their Values
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    May/June 2002

InitTimer       PROC    NEAR

                                ;initialize Timer #0 for 1 ms interrupts

        MOV     DX, Tmr0Count   ;initialize the count register to 0
        XOR     AX, AX
        OUT     DX, AL

        MOV     DX, Tmr0MaxCntA      ; Set timer count to 2304 = 1ms on 
        MOV     AX, COUNTS_PER_MS_0  ;    18.32 Mhz clock   
        OUT     DX, AL

        MOV     DX, Tmr0Ctrl    ;setup the control register, interrupts on
        MOV     AX, Tmr0CtrlVal 
        OUT     DX, AL

                                ;initialize interrupt controller for timers
        MOV     DX, INTCtrlrCtrl;setup the interrupt control register
        MOV     AX, INTCtrlrCVal
        OUT     DX, AL

        MOV     DX, INTCtrlrEOI ;send a non-specific EOI (to clear out controller)
        MOV     AX, NonSpecEOI
        OUT     DX, AL


        RET                     ;done so return


InitTimer       ENDP


; InstallHandler
;
; Description:      Install the event handler for the timer interrupts,
;		    and Mp3 Interrupts.
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  Registers AX, ES
;
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   flags, AX, ES
; Stack Depth:      0 Words
;
; Author:           Chirath Neranjena
; Last Modified:    June 2002

InstallHandler  PROC    NEAR


        XOR     AX, AX          ;clear ES (interrupt vectors are in segment 0)
        MOV     ES, AX
                                ;store the vector
        MOV     ES: WORD PTR (4 * Tmr0Vec), OFFSET(TimerEventHandler)	; Set up hadler for timer
        MOV     ES: WORD PTR (4 * Tmr0Vec + 2), SEG(TimerEventHandler)
	
	MOV	ES: WORD PTR (4 * SerialVec), OFFSET(MP3InterruptHandler) ; Set up handler for Mp3	
	MOV	ES: WORD PTR (4 * SerialVec + 2), SEG(MP3InterruptHandler)
    
        RET			;all done, return


InstallHandler  ENDP




; ClrIRQVectors
;
; Description:      This functions installs the IllegalEventHandler for all
;                   interrupt vectors in the interrupt vector table.  Note
;                   that all 256 vectors are initialized so the code must be
;                   located above 400H.  The initialization skips the first
;                   RESERVED_VECS vectors.
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  CX    - vector counter.
;                   ES:SI - pointer to vector table.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   flags, AX, CX, SI, ES
; Stack Depth:      1 word
;
; Author:           Chirath Neranjena
; Last Modified:    June 2002

ClrIRQVectors   PROC    NEAR


InitClrVectorLoop:              ;setup to store the same handler 256 times

        XOR     AX, AX          ;clear ES (interrupt vectors are in segment 0)
        MOV     ES, AX
        MOV     SI, 4 * RESERVED_VECS   ;initialize SI to skip RESERVED_VECS (4 bytes each)

        MOV     CX, 256 - RESERVED_VECS ;up to 256 vectors to initialize


ClrVectorLoop:                  ;loop clearing each vector
                                ;store the vector
        MOV     ES: WORD PTR [SI], OFFSET(IllegalEventHandler)
        MOV     ES: WORD PTR [SI + 2], SEG(IllegalEventHandler)

        ADD     SI, 4           ;update pointer to next vector

        LOOP    ClrVectorLoop   ;loop until have cleared all vectors
        ;JMP    EndClrIRQVectors;and all done


EndClrIRQVectors:               ;all done, return
        RET


ClrIRQVectors   ENDP




; IllegalEventHandler
;
; Description:      This procedure is the event handler for illegal
;                   (uninitialized) interrupts.  It does nothing - it just
;                   returns after sending a non-specific EOI and Returns.
;
; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  AX, DX for holding register addresses and values for EOI.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    June 2002

IllegalEventHandler     PROC    NEAR

        NOP                             ;do nothing (can set breakpoint here)

        PUSH    AX                      ;save the registers
        PUSH    DX

        MOV     DX, INTCtrlrEOI         ;send a non-sepecific EOI to the
        MOV     AX, NonSpecEOI          ;   interrupt controller to clear out
        OUT     DX, AL                  ;   the interrupt that got us here

        POP     DX                      ;restore the registers
        POP     AX

        IRET                            ;and return


IllegalEventHandler     ENDP


; elsped_time
;
; Description:      This procedure return the number of milliseconds that has passed
;                   since last been called. Used a variable that is updated each time	
;                   with the timer event handler.
;
; Arguments:        None.
; Return Value:     Time Elapsed since last called in AX
;
; Local Variables:  AX, TimeElapsed
; Shared Variables: TimeElapsed
; Global Variables: None.
;
; Input:            None.
; Output:           TimeElapsed
;
; Error Handling:   None.
;
; Algorithms:       start
;			set return value to elapsed time	
;		    	set elspsed time = 0
;		    return
;
; Data Structures:  None.
;
; Registers Used:   None
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    June 2002


elapsed_time	PROC	NEAR
		PUBLIC	elapsed_time

	MOV	AX, TimeElapsed		; set return value in AX
	MOV	TimeElapsed, 0		; set elapsed time as 0

        RET				; done

elapsed_time	ENDP

CODE ENDS

;the data segment

DATA    SEGMENT PUBLIC  'DATA'

TimeElapsed	DW	0		; for counting no of milliseconds passed
	

DATA    ENDS


;the stack

STACK           SEGMENT STACK  'STACK'

                DB      80 DUP ('Stack ')       ;240 words

TopOfStack      LABEL   WORD

STACK           ENDS



        END     START
