
NAME Display

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                Display                                     ;
;                            Display Routines                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      Functions involved with the Display. Includes
;			InitDisplay - Initializes Display Settings
;			WaitonDisplay - Loop till display is next accessible
;		        Show - Outputs a character to the display
;			Update - Ouputs the data in the display buffers to the
;				 Display
;			ClearDisplay - Clears the Display


;			display_status  - functions required for displaying
;			display_track	- mp3 file information
;			display_time	
;			display_title
;			display_artist
;
; Input:            Time, Status, Track, Artist and Title
; Output:           Output on LCD display
;
; User Interface:   None
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  2 Arrays as Display buffer 1 and 2 for storing display characters
;
; Revision History:
;	Chirath Neranjena 	June 2002	Creation



CGROUP  GROUP   CODE
DGROUP	GROUP	DATA


$INCLUDE(DISPLAY.INC)


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DGROUP,	SS: DGROUP


; InitDisplay
;
; Description:      Display Initialization Routines and Welcome message for mp3 player
;
; Arguments:        None.
; Return Value:     None
;
; Local Variables:  AL, DX
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            None.
; Output:           Welcome message on the display.
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002

InitDisplay	PROC	NEAR
		PUBLIC	InitDisplay

	PUSH	AX			; save registers
	PUSH	DX

	MOV	DX, DisplaySetPort	; Initialization Code 1 
	MOV	AL, InitCode1
	OUT	DX, AL

        CALL    WaitonDisplay
	MOV	DX, DisplaySetPort	; Initialization Code 1 
	MOV	AL, InitCode2		; Initialization Code 2
	OUT	DX, AL

        CALL    WaitonDisplay
	MOV	DX, DisplaySetPort	; Initialization Code 1 
	MOV	AL, InitCode3		; Initialization Code 3
	OUT	DX, AL

        CALL    WaitonDisplay
	MOV	DX, DisplaySetPort	; Initialization Code 1 
	MOV	AL, InitCode4		; Initialization Code 4
        OUT     DX, AL
	
        CALL    WAitonDisplay
	MOV	DX, DisplaySetPort	; Initialization Code 1 
	MOV	AL, InitCode5		; Initialization Code 5
	OUT	DX, AL

        CALL    WaitonDisplay		; Wait until display is accessible
        MOV     AL, ClearDisplayCode	; now clear the display

        OUT     DX, AL
        CALL    WaitonDisplay		; wait again


        MOV     AX, ' '			; show the welcome screen
        CALL    Show
        MOV     AX, ' '
        CALL    Show
        MOV     AX, ' '
        CALL    Show
        MOV     AX, 'M'
        CALL    Show
        MOV     AX, 'p'
        CALL    Show
        MOV     AX, '3'
        CALL    Show
        MOV     AX, ' '			; '   Mp3  pLAya   '
        CALL    Show
        MOV     AX, 'p'
        CALL    Show
        MOV     AX, 'L'
        CALL    Show
        MOV     AX, 'A'
        CALL    Show
        MOV     AX, 'y'
        CALL    Show
        MOV     AX, 'A'
        CALL    Show

        MOV     AX, 0			; clear AX

DisplayLoop:				; Delay to keep the Welcome message on the screen	
        INC     AX	
        CMP     AX, 7FF0H		; for a little while	
        JLE     DisplayLoop

	POP	DX			; retore registers
	POP	AX

	RET				; all right, done

InitDisplay	ENDP

; WaitonDisplay
;
; Description:      Creates a delay until previous intruction to the
;                   display is completed. Display hardware requirement!
;
; Arguments:        None.
; Return Value:     None
;
; Local Variables:  AL, DX
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      None
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002


WaitonDisplay   PROC    NEAR
                PUBLIC  WaitonDisplay

        PUSH    AX			; save registers	
        PUSH    DX

LoopTillNotBusy:

        MOV     AX, 0			; clear AX
        MOV     DX, BusyFlagPort	; get address of display busy port
        IN      AL, DX			; get value from the port
        AND     AL, BusyFlag		; check if the value indicates busy
        CMP     AL, BusyFlag
        JE      LoopTillNotBusy		; if busy then check again untill not busy

        POP     DX			; restore registers
        POP     AX

        RET				; done, go back
WaitonDisplay   ENDP

; ClearDisplay
;
; Description:      Clears the Display
;
; Arguments:        None.
; Return Value:     None
;
; Local Variables:  AL, DX
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002

ClearDisplay    PROC    NEAR
                PUBLIC  ClearDisplay

        PUSH    AX		; save registers
        PUSH    DX

        CALL    WaitonDisplay	; wait till display is ready	

        MOV     DX, DisplaySetPort	; get the display port value to send command
        MOV     AL, ClearDisplayCode	; get the command to clear the display

        OUT     DX, AL			; send the command, clear the display

        POP     DX			; restore registers
        POP     AX

        RET				; done return

ClearDisplay    ENDP

; Show
;
; Description:      Displays a character on the display
;
; Arguments:        AX
; Return Value:     None
;
; Local Variables:  AL, DX
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            ASCII value of the character to be displayed
; Output:           LCD Display 
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   AX, DX
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002


Show		PROC	NEAR
		PUBLIC	Show

	PUSH	BX			; save registers
	PUSH	DX

	CALL	WaitonDisplay		; wait till display is ready	

        MOV     BX, OFFSET ConvertTable	; setup to convert ASCII to binary bit pattern
        XLAT    CS:ConvertTable		; convert ASCII to bit pattern

	MOV	DX, DisplayShowPort	; get the display port to send character data
	OUT	DX, AL			; send data / display character

	POP	DX			; restore registers
	POP	BX

	RET				; done
	
Show	ENDP

; UpdateDisplay
;
; Description:      Displays the stuff in the display buffers on the LCD display
;
; Arguments:        DisplayBuffer1, DisplayBuffer2
; Return Value:     None
;
; Local Variables:  AL, DX, DisplayOffset(scroll)
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            ASCII values of the characters to be displayed, DisplayOffset
; Output:           LCD Display 
;
; Error Handling:   None.
;
; Algorithms:       start
;			get segment and offset of first buffer
;			display characters one by one
;			now get the segment and offset values of the second buffer
;			start displaying at the value specified by DisplayOffset variable
;			display character one by one
;		    return	
;
; Data Structures:  Arrays, DisplayBuffer and DisplayBuffer2
;
; Registers Used:   AX, DX
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    June 2002

; Known Problems :  When the title is small, the title also acquires the artist's name and 
;			display it on the display's second row.


UpdateDisplay	PROC	NEAR
		PUBLIC	UpdateDisplay

	PUSH	ES				; save registers
	PUSH	SI


        CALL    ClearDisplay			; clear the display, get ready to display

	MOV	AX, SEG DisplayBuffer		; get the segment of the buffer
	MOV	ES, AX
	MOV	AX, OFFSET DisplayBuffer	; get the offset of the buffer	
	MOV	SI, AX

        MOV     AL, ':' 			; display a colon to indicate time
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 1st character / time
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 2nd character / time
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 3rd character	/ time
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 4th character	/ time
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 5th character	/ time
	CALL	Show
	INC	SI

        MOV     AX, ' '            		; display a space between time and track
        CALL    Show
	INC	SI

	MOV	AX, 'T'            		; display a T	indicate 'Track	'
	CALL	Show
	INC	SI

	MOV	AX, 'K'             		; display a K   
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 1st character / track
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 2nd character / track
	CALL	Show
	INC	SI

        MOV     AX, ' '          		; display a space between track and status
        CALL    Show
	INC	SI

	MOV	AX, ES:[SI]			; display 1st character / status
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 2nd character / status
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 3rd character / status
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 4th character / status1
	CALL	Show
	INC	SI

        CALL    WaitOnDisplay			; wait for display

        MOV     DX, DisplaySetPort		; set display to move to the next row
        MOV     AX, MovtoNextRow		; on the display
        OUT     DX, AX

	MOV	AX, SEG DisplayBuffer2		; now get the segement of the second buffer
	MOV	ES, AX
	MOV	AX, OFFSET DisplayBuffer2	; get the offset 
        ADD     AX, DisplayOffset		; add the value to the offset rom where to
        					; start displaying this buffer. (scroll feature)
	MOV	SI, AX				

        MOV     AX, ES:[SI]			; display 1st character / title
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 2nd character / title
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 3rd character / title
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 4th character / title
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 5th character / title
	CALL	Show
	INC	SI
	
	MOV	AX, ES:[SI]			; display 6th character / title
	CALL	Show
	INC	SI

        MOV     AX, ES:[SI]			; display 7th character / title
        CALL    Show
	INC	SI

	MOV	AX, ES:[SI]			; display 8th character / title
	CALL	Show
	INC	SI
	
	MOV	AX, ES:[SI]			; display 9th character / title
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 10th character / title
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 11th character / title
	CALL	Show
	INC	SI

        MOV     AX, ES:[SI]			; display 12th character / title
        CALL    Show
	INC	SI

	MOV	AX, ES:[SI]			; display 13th character / title
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 14th character / title
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 15th character / title
	CALL	Show
	INC	SI

	MOV	AX, ES:[SI]			; display 16th character / title
	CALL	Show
	INC	SI

	INC	DisplayOffset			; increment this value so that the next time
						; the display starts from one more position to
						; the left and hence scrolls							
	CMP	DisplayOffset, 60		; however if this value is 60
	JGE	ResetDisplayOffset		;   then reset it to 0
	JL	EndUpdateDisplay		;   otherwise keep scrolling

ResetDisplayOffset:

	MOV	DisplayOffset, 0		; reset the Offset
	
EndUpdateDisplay:

        MOV     DX, DisplaySetPort		; Go back to the fist ro on
        MOV     AL, MoveBack			; the display
        OUT     DX, AX

	POP	SI				; restore the registers
	POP	ES

	RET					; done, go back

UpdateDisplay	ENDP


; DisplayStatus
;
; Description:      Gets the status value form the arguments and writes the proper status to
;			to the display buffer to display
;
; Arguments:        Status
; Return Value:     None
;
; Local Variables:  AX, BX, BP, ES, SI DisplayBuffer
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   AX, BX, BP, SP, ES, SI
; Stack Depth:      3 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002

display_status	PROC	NEAR
		PUBLIC	display_status

	PUSH	BP			; Save the value in the Base Pointer
	MOV	BP, SP			; get the value of the current stack pointer
	MOV	AX, [BP+4]		; now get argument,  - status

	PUSH	ES			; save ES and SI so that we can use it to access
	PUSH	SI			;  te display buffer

	MOV	BX, SEG DisplayBuffer	; get the segement and offset values of the displaybuffer
	MOV	ES, BX			;  to ES and SI
	MOV	BX, OFFSET DisplayBuffer	

        ADD     BX, 12			; status is displayed 12 places to the right
        MOV	SI, BX			; so add 12 to the offset



	CMP	AX, statusplay		; check for the proper status and jump to 
	JE	DisplayPlay		;   the correct sub-routine handling the
	CMP	AX, statusffw		;   specific status
	JE	DisplayFFW
	CMP	AX, statusRev
	JE	DisplayRev
	CMP	AX, statusIdle
	JE	DisplayIdle
	JNE	DisplayIllegal

DisplayPlay:
	
        MOV     AX, 'p'			; store 'pLay' for status play in the buffer
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, 'L'
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, 'a'
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, 'y'
	MOV	ES:[SI], AX
	INC	SI


	JMP	ChangeDisplay		; go to end

DisplayFFW:

        MOV     AX, '>'			; store '>>>>' for fast forward in the buffer
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, '>'
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, '>'
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, '>'
	MOV	ES:[SI], AX
	INC	SI


	JMP	ChangeDisplay		; go to the end

DisplayRev:

        MOV     AX, '< '		; store '<<<<' for reverse in the buffer
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, '<'
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, '<'
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, '<'
	MOV	ES:[SI], AX
	INC	SI
        

	JMP	ChangeDisplay		; go to the end

DisplayIdle:

        MOV     AX, 'Z'			; store 'Zzz.' for Idle status / sleep mode :)
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, 'z'
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, 'z'
	MOV	ES:[SI], AX
	INC	SI
        MOV     AX, '.'
	MOV	ES:[SI], AX
	INC	SI

	JMP	ChangeDisplay		; go to the end

DisplayIllegal:

	MOV	AX, 'I'			; Oh-Oh	Illegal staus! so store 'ILG'
	MOV	ES:[SI], AX
	INC	SI
	MOV	AX, 'L'
	MOV	ES:[SI], AX
	INC	SI
	MOV	AX, 'G'
	MOV	ES:[SI], AX
	INC	SI

	JMP	ChangeDisplay		; go to the end

ChangeDisplay:

        ;CALL    ClearDisplay		; you can update the display now
        ;CALL    UpdateDisplay		; but not necessary bacause we can update it when
					; all status, track and time are done.
Enddisplaystatus:

	POP	SI			; restore the registers
	POP	ES
	POP	BP

	RET				; done

display_status	ENDP
	

; display_track
;
; Description:      Converts a binary passed on to the function from the stack into
;		    a string of ascii characters and stores it in the display buffer
;		    for displaying on the LCD display	
;
; Arguments:        track number
; Return Value:     None
;
; Local Variables:  TrackNo 
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            Track number in numerals 
; Output:           Track number in ASCII
;
; Error Handling:   None.
;
; Algorithms:       start
;			get track number
;			d=1000 	
;			repeat
;				n=track number / d	
;				convert n to ascii
;				store ascii value in the buffer
;				d = d /10
;			untill d=1
;
; Data Structures:  None.
;
; Registers Used:   AX, BX, CX, DX, ES, SI, BP
; Stack Depth:      6 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002


display_track	PROC	NEAR
		PUBLIC	display_track

       
	PUSH	BP		; save BP
	MOV	BP, SP		; get the stack pointer value

	MOV	AX, [BP + 4]	; get the track number form the stack
	MOV	TrackNo, AX	; store this value in the trackNo / release AX

	PUSH	BX		; save the bunch of registers
	PUSH	CX
	PUSH	DX
	PUSH	ES
	PUSH	SI


track_DecInit:

	MOV	BX, SEG DisplayBuffer		; get the segment and offset value of the display
	MOV	ES, BX				; buffer for access in the future
	MOV	BX, OFFSET DisplayBuffer
        ADD     BX, 7				; don't forget that track is displayed 7 places to
	MOV	SI, BX				;  right, so add 7 to offset

	MOV	BX, 0				; set registers to start converting
        MOV     CX, 1000			;  numeral to ascii value

track_StartDecTrace:

	MOV	AX, TrackNo			; get the TrackNo back to AX

	CMP	BX, False			; if no error and d <> 0 the keep
	JNE	track_StpDecTrace		; converting digits 
	CMP	CX, 0
	JLE	track_StpDecTrace

track_CheckDecDigit:

	MOV	DX, 0				; set DX for division
	DIV	CX				; divide track no by d
	CMP	AX, 10				; check if the digit is less that 10 
	JGE	track_DecDigitError		;  if not the report error
	JL	track_ShowDecNumber		;  else to the conversion

track_DecDigitError:

	MOV	BX, True			; set error = true
	JMP	track_StartDecTrace		; go back to the top

track_ShowDecNumber:

	ADD	AX, ASCIINoStart		; add the ASCII value from which numerals
	MOV	ES:[SI], AX			; start
	INC	SI				; then store in the buffer and increment the offset
						;  to store the next value
	JMP	track_CorrectIandPwr10		; chage the value of d and trackno


track_CorrectIandPwr10:

	MOV	AX, TrackNo			; get back trach no
	MOV	DX, 0				; set DX for division
	DIV	CX				; divide track no by d
	MOV	TrackNo, DX			; get the remainder and store it as track no


	MOV	AX, CX				; divide d (CX) by 10
	MOV	DX, 0				; and store this value back in d (CX)
	MOV	BX, 10
	DIV	BX
	MOV	CX, AX
	MOV 	BX, 0				; set error = false

	JMP	track_TraceNExtDec

track_TraceNextDec:

	JMP	track_StartDecTrace

track_StpDecTrace:


track_EndDisplayTime:


        ;CALL    ClearDisplay			; you can update the display now
        ;CALL    UpdateDisplay		; but not necessary bacause we can update it when
					; all status, track and time are done.
        
        POP	SI			; restore back all the saved registers 'phew'
	POP	ES
	POP	DX
	POP	CX
	POP	BX
	POP	BP

testpoint1:
	RET				; done get back

display_track  ENDP




; DisplayTime
;
; Description:      Converts a binary passed on to the function from the stack into
;		    a string of ascii characters and displays in memory.	
;
; Arguments:        Time 
; Return Value:     None
;
; Local Variables:  PassTime
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   AX, BX, CX, DX, Es, SI, BP
; Stack Depth:      4 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002


display_Time	PROC	NEAR
		PUBLIC	display_Time





	PUSH	BP		; save BP
	MOV	BP, SP		; get the stack pointer value

	MOV	AX, [BP + 4]	; get the track number form the stack
	
	MOV	PassTime, AX	; store this value in the time / release AX

	PUSH	BX		; save the bunch of registers
	PUSH	CX
	PUSH	DX
	
	PUSH	ES
	PUSH	SI

DecInit:


	MOV	BX, SEG DisplayBuffer		; get the segment and offset value of the display
	MOV	ES, BX				; buffer for access in the future
	MOV	BX, OFFSET DisplayBuffer
        ADD     BX, 7				; don't forget that track is displayed 7 places to
	MOV	SI, BX				;  right, so add 7 to offset

	MOV	BX, 0				; set registers to start converting
        MOV     CX, 1000			;  numeral to ascii value

StartDecTrace:


	MOV	AX, PassTime			; get the PassTime back to AX

	CMP	BX, False			; if no error and d <> 0 the keep
	JNE	track_StpDecTrace		; converting digits 
	CMP	CX, 0
	JLE	track_StpDecTrace


CheckDecDigit:



	MOV	DX, 0				; set DX for division
	DIV	CX				; divide track no by d
	CMP	AX, 10				; check if the digit is less that 10 
	JGE	DecDigitError			;  if not the report error
	JL	ShowDecNumber			;  else to the conversion

DecDigitError:


	MOV	BX, True			; set error = true
	JMP	StartDecTrace			; go back to the top

ShowDecNumber:


	ADD	AX, ASCIINoStart		; add the ASCII value from which numerals
	MOV	ES:[SI], AX			; start
	INC	SI				; then store in the buffer and increment the offset
						;  to store the next value
	
	CMP	CX, 10				; If there is only one digit remaining
	JE	PutDecimal			; then put the decimal
	JNE	CorrectIandPwr10		

PutDecimal:

        MOV     AX, '.'				; Put the decimal as the next character
	MOV	ES:[SI], AX			; in the display buffer
	INC	SI

	JMP	CorrectIandPwr10		; back to normal business


CorrectIandPwr10:



	MOV	AX, PassTime			; get back trach no
	MOV	DX, 0				; set DX for division
	DIV	CX				; divide track no by d
	MOV	PassTime, DX			; get the remainder and store it as track no


	MOV	AX, CX				; divide d (CX) by 10
	MOV	DX, 0				; and store this value back in d (CX)
	MOV	BX, 10
	DIV	BX
	MOV	CX, AX
	MOV 	BX, 0				; set error = false

	JMP	TraceNExtDec


TraceNextDec:

	JMP	StartDecTrace

StpDecTrace:


EndDisplayTime:

        CALL    UpdateDisplay			; call up update display, show the stuff

        POP     SI				; restore back the registers
        POP     ES

	POP	DX
	POP	CX
	POP	BX

        POP     BP

	RET				; done

Display_Time  ENDP


; display_title
;
; Description:      Takes the pointer to the string passed to the function and move the
;                   values of the string into the display buffer for display
;
; Arguments:        title *
; Return Value:     None
;
; Local Variables:  AX, DS, DI, ES, SI
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            Title 
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   AX, ES, SI, DS, DI, BP, SP
; Stack Depth:      None
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002


display_title   PROC    NEAR
                PUBLIC  display_Title



        PUSH    BP		; save value of BP
        MOV     BP, SP		; get the value of the stack pointer

        MOV     AX, [BP + 6]	; first get the segment of the passed title
	MOV	ES, AX		;	and put it in ES	
        MOV     BX, [BP + 4]	; then get the offset
	MOV	SI, BX		;	and store it in SI


	PUSH	DS		; save the values in DS and DI
	PUSH	DI

	MOV	AX, SEG DisplayBuffer2		; get the segment and offset values of the
	MOV	DS, AX				;   display buffer and store them in DS and DI
	MOV	AX, OFFSET DisplayBuffer2
	MOV	DI, AX

        MOV     AX, ' '			; First make sure that the first 16 characters
					;   of the second display buffer is not full of junk
        MOV     DS:[DI], AX		;   These characters should be made blank to make sure
	INC	DI			;   that the scrolling seem continuous
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
        MOV     AX, ' '
        MOV     DS:[DI], AX
	INC	DI
	
	MOV	AX, ES:[SI]		; get the characters for title one by one
	MOV	DS:[DI], AX		;     16 characters in total
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI


        MOV     AX, ' '				; leave a space		
	MOV	DS:[DI], AX
	INC	DI
        MOV     AX, '>' 			; put the two '>>' markers to separate
	MOV	DS:[DI], AX			;  the title and artist
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
        MOV     AX, ' '				; leave another space
	MOV	DS:[DI], AX
	
	
	POP	DI				; restore the registers
	POP	DS
        POP     BP

        RET					; get out of here

display_title   ENDP

; display_artist
;
; Description:      Takes the pointer to the string (artist) passed to the function and move the
;                   values of the string into the display buffer for display
;
; Arguments:        title *
; Return Value:     None
;
; Local Variables:  AX, DS, DI, ES, SI
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            Title 
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   AX, ES, SI, DS, DI, BP, SP
; Stack Depth:      None
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002



display_artist  PROC    NEAR
                PUBLIC  display_artist



        PUSH    BP			; save BP 
        MOV     BP, SP			; and transfer the value of SP to it

        MOV     AX, [BP + 6]		; get the segment of the artist
	MOV	ES, AX
        MOV     BX, [BP + 4]		; then the offset
	MOV	SI, BX


	PUSH	DS			; save DS, DI for use
	PUSH	DI

	MOV	AX, SEG DisplayBuffer2	; transfer the segment values of the displaybuffer
	MOV	DS, AX			;  to DS and DI
	MOV	AX, OFFSET DisplayBuffer2
	ADD	AX, 41			; add 41 to the offset 'cos the the artist should come	
	MOV	DI, AX			;  41 places to the right of the begining of the string


        MOV     AX, ES:[SI]		; start transfering the data a character at a time
        MOV     DS:[DI], AX		; all 16 of them
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
        INC     SI     
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
	MOV	AX, ES:[SI]
	MOV	DS:[DI], AX
	INC	DI
	INC	SI
        MOV     AX, ES:[SI]
        MOV     DS:[DI], AX
	INC	DI
	INC	SI


        MOV     AX, ' '			; fill the next 16 spaced of the buffer with spaces so the
	MOV	DS:[DI], AX		;  characters from a previous title/artist or random	
	INC	DI			;  junk is not displayed
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX
	INC	DI
	MOV	DS:[DI], AX


	MOV	DisplayOffset, 16	; then set the display offset to 16 and call uptade display
	CALL	UpdateDisplay		; this way the title will be shown before scrolling happens
					; when play is pressed


	POP	DI			; restore the registers
	POP	DS

	POP	BP

        RET				; done !
        
display_artist   ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								      ;	
; Segment Table carrying the LCD bit patterns for ASCIII Values       ;
;								      ;	
;								      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




ConvertTable	LABEL	BYTE
                PUBLIC  ConvertTable

        DB      32              ;0		; The ASCII values for which characters do not exist
        DB      32              ;1		; on the display are filled as they being spaces.
        DB      32              ;2
        DB      32              ;3
        DB      32              ;4
        DB      32              ;5
        DB      32              ;6
        DB      32              ;7
        DB      32              ;8 
        DB      32              ;9

        DB      32              ;10
        DB      32              ;11 
        DB      32              ;12 
        DB      32              ;13 
        DB      32              ;14 
        DB      32              ;15 
        DB      32              ;16 
        DB      32              ;17
        DB      32              ;18
        DB      32              ;19      

        DB      32              ;20
        DB      32              ;21      
        DB      32              ;22      
        DB      32              ;23      
        DB      32              ;24      
        DB      32              ;25      
        DB      32              ;26      
        DB      32              ;27 
        DB      32              ;28
        DB      32              ;29      

        DB      32              ;30
        DB      32              ;31      
        DB      00100000b       ;32      
        DB      00100001b       ;33      
        DB      00100010b       ;34      
        DB      00100011b       ;35      
        DB      00100100b       ;36      
        DB      00100101b       ;37 
        DB      00100110b       ;38
        DB      00100111b       ;39      

        DB      00101000b       ;40
        DB      00101001b       ;41
        DB      00101010b       ;42
        DB      00101011b       ;43
        DB      00101100b       ;44
        DB      00101101b       ;45
        DB      00101110b       ;46
        DB      00101111b       ;47
	DB	00110000b	;48
	DB	00110001b	;49

	DB	00110010b	;50
	DB	00110011b	;51
	DB	00110100b	;52
	DB	00110101b	;53
	DB	00110110b	;54
	DB	00110111b	;55
	DB	00111000b	;56
	DB	00111001b	;57
        DB      00111010b       ;58
        DB      00111011b       ;59

        DB      00111100b       ;60
        DB      00111101b       ;61
        DB      00111110b       ;62
        DB      00111111b       ;63
        DB      01000000b       ;64
	DB	01000001b	;65
	DB	01000010b	;66
	DB	01000011b	;67
	DB	01000100b	;68
	DB	01000101b	;69

	DB	01000110b	;70
	DB	01000111b	;71
	DB	01001000b	;72
	DB	01001001b	;73
	DB	01001010b	;74
	DB	01001011b	;75
	DB	01001100b	;76
	DB	01001101b	;77
	DB	01001110b	;78
	DB	01001111b	;79

	DB	01010000b	;80
	DB	01010001b	;81
	DB	01010010b	;82
	DB	01010011b	;83
	DB	01010100b	;84
	DB	01010101b	;85
	DB	01010110b	;86
	DB	01010111b	;87
	DB	01011000b	;88
	DB	01011001b	;89

	DB	01011010b	;90
        DB      01011011b       ;91
        DB      01011100b       ;92
        DB      01011101b       ;93
        DB      01011110b       ;94 
        DB      01011111b       ;95
        DB      01100000b       ;96
	DB	01100001b	;97
	DB	01100010b	;98
	DB	01100011b	;99

	DB	01100100b	;100
	DB	01100101b	;101
	DB	01100110b	;102
	DB	01100111b	;103
	DB	01101000b	;104
	DB	01101001b	;105
	DB	01101010b	;106
	DB	01101011b	;107
	DB	01101100b	;108
	DB	01101101b	;109

	DB	01101110b	;110
	DB	01101111b	;111
	DB	01110000b	;112
	DB	01110001b	;113
	DB	01110010b	;114
	DB	01110011b	;115
	DB	01110100b	;116
	DB	01110101b	;117
	DB	01110110b	;118
	DB	01110111b	;119

        DB      01111000b       ;120
        DB      01111001b       ;121
        DB      01111010b       ;122
        DB      01111011b       ;123
        DB      01111100b       ;124
        DB      01111101b       ;125
        DB      01111110b       ;126
        DB      01111111b       ;127
	DB	00		;128

CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'

TrackNo		DW	?		; temporary variable to store track number
PassTime	DW	?		; temporary variable to store time

DisplayBuffer   DB      16 DUP(0)	; array to store what to display on the first ro of
					;  the display
DisplayBuffer2  DB      76 DUP(0)	; array to store what to display on the 2nd row of 
					;  the LCD display. it is 76 bytes long due to scrolling 
					;  feature	

DisplayOffset	DW	?		; variable to remember from where in the 2nd display
					; buffer should we start displaying characters.
	
DATA    ENDS


        END
