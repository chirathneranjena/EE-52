
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

NAME    MP3

CGROUP  GROUP   CODE
DGROUP	GROUP	DATA

$INCLUDE(MP3INF.INC)


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DGROUP,	SS:DGROUP


; SetInterface
;
; Description:      Set up interrupt 2 of the 80188 processor to acknowledge interrupts from
;			the mp3 decoder	
;
; Arguments:        None.
; Return Value:     None
;
; Local Variables:  AX, DX
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            None.
; Output:           None
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
; Last Modified:    June 2002


SetInterface	PROC	NEAR
		PUBLIC	SetInterface


        PUSH    AX			; save registers
        PUSH    DX                

	MOV	DX, Int2CtrlReg		; setup Interrupt 2 to acknowledge interrupts
	MOV	AX, Int2CtrlVal		;  set it to highest priority
	OUT	DX, AX

	MOV	DX, IntCtrlEOI		; send a non-specific EOI (to clear out controller)
	MOV	AX, NonSpecEOI		
	OUT	DX, AX


        POP     DX			; restore registers
        POP     AX

        RET				; go back

SetInterface	ENDP

; audio_play
;
; Description:     Gets the segment and the offset of the first mp3 buffer to play along with
;			with it's length		
;
; Arguments:        Mp3 Buffer Segment, Buffer Offset and Length
; Return Value:     None
;
; Local Variables:  AX, BX, CX, DX, Mp3CurrentBufferSEG, Mp3CurrentBufferOFF
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   BX, CX, DX, BP
; Stack Depth:      1 words
;
; Author:           Chirath Neranjena
; Last Modified:    June 2002


audio_play	PROC	NEAR
		PUBLIC	audio_play

	PUSH	BP		; Store BP value
	MOV	BP, SP		; Get the Stack Pointer value

	MOV	BX, [BP+6]	; Get the Segment of Buffer
	MOV	CX, [BP+4]	; Get the Offset of the Buffer	
	MOV	DX, [BP+8]	; And finally get the length


audio_GetNewBuffer:

        MOV     MP3CurrentBufferSEG, BX		; Transfer Value of Segment to the variable
        MOV     MP3CurrentBufferOFF, CX		; Transfer the value of the Offset

	MOV	MP3Amount, DX			; Transfer the value of the Length

	JMP	audio_EndUpdate			


audio_EndUpdate:

        CALL    SetInterface			; Start Mp3 Output
	POP	BP				; restore the BP register
	RET					; return

audio_play		ENDP


; update
;
; Description:      Checks if a new buffer is needed and if so gets the segment, offset
;			and length of the buffer returning true. Else it returns false.
;
; Arguments:        Mp3 Buffer Segment, Buffer Offset and Length
; Return Value:     True/False
;
; Local Variables:  AX, BX, CX, DX, BP, SP, Mp3NewBufferSEG, Mp3NewBufferOFF
;
; Shared Variables: None
; Global Variables: None
;
; Input:            None
; Output:           None
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
; Last Modified:    June 2002

update		PROC	NEAR
		PUBLIC	Update

	PUSH	BP			; save the BP register
	MOV	BP, SP			; transfer the 

	MOV	BX, [BP+6]		; get the segment from stack
	MOV	CX, [BP+4]		; get the offset
	MOV	DX, [BP+8]		; get the length

	CMP	BufferDone, True	; check if done with the buffer
	JE	GetNewBuffer		;  if then get the new buffer
	JNE	KeepOldBuffer		;  else return false and exit

GetNewBuffer:

	MOV	MP3NewBufferSEG, BX	; set the new buffer segment value 	
	MOV	MP3NewBufferOFF, CX	; set the new buffer offset value

	MOV	MP3NewAmount, DX	; set the new buffer legth 	

	MOV	AX, TRUE		; set AX to return true
        MOV     BufferDone, FALSE	; a new buffer is now available so set this to false
        JMP     EndUpdate		

KeepOldBuffer:

	MOV	AX, FALSE		; set AX to return false
	JMP	EndUpdate

EndUpdate:

	POP	BP			; restore registers
	RET				; done

Update		ENDP
	
; Mp3InterruptHandler
;
; Description:      This procedure is the Interrupt handler for the Mp3 decorder
;                   interrupts. It takes bytes from the mp3 music buffer and
;		    transfers them a bit at a time to the decorder.	
;		    
; Arguments:        None
; Return Value:     None.
;
; Local Variables:  Mp3NewBufferSEG, Mp3NewBufferOFF
; Shared Variables: None.
; Global Variables: None
; Input:            None.
; Output:           Mp3 Bits to the decoder
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX, BX, CX, DX, ES, SI
; Stack Depth:      7 words
;
; Revision     :    Chirath Neranjena  May 21, 2002
;		    
;		    	
;

MP3InterruptHandler	PROC	NEAR
			PUBLIC  MP3InterruptHandler


        PUSHF				; save flags 

	PUSH	AX			; Save registers
        PUSH    BX
        PUSH    CX
	PUSH	DX

	PUSH	ES
	PUSH	SI
					; Get all memory variables into registers
					; to save access time

	MOV	ES, MP3CurrentBufferSEG	; Current Buffer Segment in ES
        MOV     SI, MP3CurrentBufferOFF	; Current Buffer Offset in SI	
        MOV     BX, Mp3Port		; BX has the Mp3Port value
        MOV     CX, MP3Amount		; CX will have the Mp3 Length


StartSendingMP3:


GetByte:

	
        CMP     CX, 0			; First check if the buffer in empty
	JLE	NewBuffer		;  If empty the get new buffer
					;  otherwise keep playing.
KeepPlaying:

	MOV	AL, ES:[SI]		; get a byte from the buffer
        INC     SI			; increment the offset to get the next byte next time
        DEC     CX			; decrease the length of the buffer by a byte
        ;JMP	SendByte

SendByte:

        MOV     DX, BX			; set DX to have the Mp3 Port

	OUT	DX, AL			; send the first bit
	SHL	AX, 1

	OUT	DX, AL			; send the 2nd bit
	SHL	AX, 1

	OUT	DX, AL			; 3rd
	SHL	AX, 1

	OUT	DX, AL			; 4th
	SHL	AX, 1

	OUT	DX, AL			; 5th
	SHL	AX, 1

	OUT	DX, AL			; 6th
	SHL	AX, 1

	OUT	DX, AL			; 7th
	SHL	AX, 1
		
	OUT	DX, AL			; finally the 8th
	


CheckInterrupt:

	MOV	DX, IRQReg		; check the interrupt control register
	IN	AX, DX			; to see if decoder is still
	AND	AX, ChkVal		; interrupting
	CMP	AX, ChkVal
	JE	StartSendingMp3		; If it is then go to top and bit bang second byte
        JNE     Mp3Done			; other wise exit

NewBuffer:
					; get values for the new buffer

        MOV     SI, MP3NewBufferOFF	; get segement value
						
        MOV     ES, MP3NewBufferSEG	; get offset

        MOV     CX, MP3NewAmount	; and new length	

        MOV     BufferDone, TRUE	; flag we need another buffer soon

        JMP     StartSendingMp3		; back to the top

Mp3Done:

        MOV     MP3CurrentBufferSEG, ES	; restore back the values in the registers
        MOV     MP3CurrentBufferOFF, SI	; in memory variable for use next time
        MOV     MP3Amount, CX

	MOV	DX, IntCtrlEOI		; Send EOI to end the interrupt
	MOV	AX, Int2EOI	
	OUT	DX, AX

	
	POP	SI
	POP	ES

	POP	DX			; restore registers
        POP     CX
        POP     BX
	POP	AX

        POPF				; restore the flags

        IRET				; return from the interrupt handler

MP3InterruptHandler	ENDP

; audio_halt
;
; Description:      Sets the interrupt 2 control register to stop acknowledging
;			interrupts fromt the mp3 decoder and hence stop
;			audio play.
;
; Arguments:        None
; Return Value:     None
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: None
;
; Input:            None.
; Output:           None
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
; Last Modified:    June 2002
.


audio_halt	PROC	NEAR
		PUBLIC	audio_halt


        PUSH    AX			; save registers
        PUSH    DX

	MOV	DX, Int2CtrlReg		; Setup Interrupt 2 to stop acknowledging interrupts
        MOV     AX, Int2StpVal		;  (send stop acknowledge value to control register)
	OUT	DX, AX

	MOV	DX, IntCtrlEOI		; send a non-specific EOI (to clear out controller)
	MOV	AX, NonSpecEOI		
	OUT	DX, AX

        POP     DX			; restore registers
        POP     AX


	
        RET				; done !



audio_halt	ENDP



CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'


Mp3Byte			DB	?		 ; temporary variable for storing an mp3 byte
						 ;    from the buffer
MP3Amount		DW	?		;  the length of the buffer currently in use
MP3NewAmount		DW	?		;  the legth of the buffer to be used immediately


MP3NewBufferSEG		DW	?		; segment of the current buffer
MP3NewBufferOFF		DW	?		; offset of the current buffer

MP3CurrentBufferSEG	DW	?		; segment of the buffer to come
Mp3CurrentBufferOFF	DW	?		; offset of the buffer	to come

BufferDone		DB	?		; stores if a new buffer is needed

DATA    ENDS


        END
