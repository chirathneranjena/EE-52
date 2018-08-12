
NAME Key

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    Key                                     ;
;                              Keypad Routines                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      Functions involved with the keypad. Includes
;			key_available - Sets the zero flags appropriately if a key is pressed
;		        getkey - Returns a key that has been pressed 				
;
; Input:            None.
; Output:           KeyAvailable, KeyValue (AX)
;
; User Interface:   requires the user to press keys in keypad
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;	Chirath Neranjena 	21, Feb 2002	Creation



CGROUP  GROUP   CODE
DGROUP	GROUP	DATA

$INCLUDE(KEY.INC)


CODE SEGMENT PUBLIC 'CODE'

        ASSUME  CS: CGROUP, DS: DGROUP,	SS: DGROUP


; Scan
;
; Description:      Keypad Scaning routines
;
; Arguments:        None.
; Return Value:     NewKey, NewKeyRow
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: KeyStatus - 0 - No key, 1 - Key pressed, 2 - Key Debpunced
;		    KeyRow    - row in keypad pressed
;		    Key	      - Key in keypad row being pressed		
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Algorithms:       Scan row in Key pad.
;                   If a key is pressed then debounce it
;                   Else go back to no key status    
; Data Structures:  None.
;
; Registers Used:   AX, BX
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB. 21 2002

SCAN		PROC	NEAR
		PUBLIC	SCAN

CheckKeyStatus:
	
        MOV     AL, KeyStatus
        CMP     AL, KeyPressedState     ; Check Key Status
	JL	NoKey			;   IF There is no Key Check for a Keypress
	JE	KeyPressed		;   IF there is a keypress debounce it	
	JG	KeyDebounced		;   IF the key has been debounced then hold.	

NoKey:

	CALL	ScanRow			;   Scan row on keypad
        CMP     AL, NoKeyValue          ;   IF There is a Key THEN
	JNE	NewKeyPress		;     do stuff for new keypress
        MOV     AX, KeyRow
        ADD     AX, 1
        MOV     KeyRow, AX              ;   IF NOT go to the next row
        CMP     AX, KeyPadRows          ;     See if row exceeds row on kepad
        JG      ResetKeyRow             ;       then adjust
        JLE     EndScan                 ;    Otherwise we are done

ResetKeyRow:

        MOV     KeyRow, 0               ; Reset the Row being scanned
	JMP	EndScan			; Finish, go to the end

NewKeyPress:

	MOV	KeyStatus, KeyPressedState ; Set Key Status = Key Pressed
	MOV	Key, AL			; Store pressed key
	MOV	KeyDebounceTime, 0	; Reset KeyDebounceTime
	JMP	EndScan			; All done

KeyPressed:

	CALL	ScanRow			;  Scan row on keypad
        CMP     AL, NoKeyValue          ;  Check if the Key is still being pressed
	JE	KeyReleased		;      If not then reset
	CMP	AL, Key			;  Check if the same key
	JNE	KeyReleased		;	If not then reset
					;  Otherwise
        MOV     AX, KeyDebounceTime         ;    Increment debounce time
        ADD     AX, 1
        MOV     KeyDebounceTime, AX

        MOV     AX, DebounceTime
        MOV     BX, KeyDebounceTime
        CMP     AX, BX                          ; If Debounce complete
	JGE	KeyJustDebounced		;   Set variables
	JMP	EndScan				; Otherwise Finish

KeyJustDebounced:

	MOV	KeyStatus, KeyDebouncedState		; Key has debounced
	MOV	KeyAvailable, True	; Set KeyAvailable = true
        MOV     BL, Key
        MOV     NewKey, BL              ; Store the Key pressed
        MOV     BX, KeyRow
        MOV     NewKeyRow, BX           ; Also store the row number of the Key
	JMP	EndScan			; Alright done

KeyDebounced:

	CALL	ScanRow			; Scan row in Keypad
        CMP     AL, NoKeyValue          ; Check if the key is still been pressed
	JE	KeyReleased		;   If not then reset
	CMP	AL, Key			; Check if same Key
	JNE	KeyReleased		;   If not then reset
	JMP	EndScan			;  Otherwise go to finish

KeyReleased:
	
	MOV	KeyStatus, NoKeyState		; No more key press
        MOV     KeyAvailable, NoKeyState        ; KeyAvailable = false
	JMP	EndScan				; Done

EndScan:

	RET

Scan		ENDP


; ScanRow
;
; Description - Scans the keypad for a keypress
;
; Arguments:        None.
; Return Value:     Pressed Key value
;
; Local Variables:  None
;
; Shared Variables: None.
; Global Variables: KeyRow		
;
; Input:            None.
; Output:           AL
;
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Registers Used:   DX, AL
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB. 21 2002

ScanRow		PROC	NEAR
                PUBLIC  ScanRow

	MOV	DX, KeyPadPort
        ADD     DX, KeyRow                  	;   Go to the required row in Keypad

	IN	AL, DX				; Get the key
point:

	RET					; get back

ScanRow		ENDP
	

; Key_available
;
; Description:      Sets the zeroflag if no key is available
;			Resets the zeroflag if key is available
; Arguments:        None.
; Return Value:     Key available - True/False in AX
;
; Local Variables:  AX
;                  
; Shared Variables: None.
; Global Variables: KeyAvailable  - indicates whether a key is available
;                  
;
; Input:            None.
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX
; Stack Depth:      0 words
;
; Author:           Chirath Neranjena
; Last Modified:    FEB 20, 2002





key_available	PROC	NEAR
                PUBLIC  Key_available


        

        MOV     AL, KeyAvailable	
        CMP     AL, False               ; Check KeyAvailable and set the flag
	JE	ReturnFalse		; then branch of return different return values
	JNE	ReturnTrue

ReturnFalse:

        MOV     AX, False		; return false
	JMP EndKeyAvailable

ReturnTrue:

        MOV     AX, True		; return true
	JMP	EndKeyAvailable

EndKeyAvailable:                              

        
        RET				; done

Key_available	ENDP



; GetKey
;
; Description:      Sits in a loop until a key has been pressed and then returns the Key pressed in AL
;

; Arguments:        None.
; Return Value:     None.
;
; Local Variables:  BX, DX 
; Shared Variables: None.
; Global Variables: None
;
; Input:            None.
; Output:           AL Key Code
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Registers Used:   AX, BX, CX
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    21 FEB 2002

getKey		PROC	NEAR
		PUBLIC	GetKey

	PUSH	BX
	PUSH	CX


LoopWhileNoKey:

        CALL    key_available           ; While Zero flag = 0 
        JZ      LoopWhileNoKey          ;   Check for Key using IsAkey
                                        ; ENDWHILE

	MOV	AX, 0			; clear AX and CX 
	MOV	CX, 0
	MOV	AX, NewKeyRow		; Load Row of the keypad of the key pressed
	MOV	CX, KeyPermutations	; Load the number of permutations due to the
					;   number of keys on that row
	MUL	CX			; Calculate the Offset for the key on key table using
	ADD	AL, NewKey		; Offset on table = Key Row * no of permutation + key value

			
	MOV	BX, OFFSET KeyTable	; get the key code for the key press from the table
	XLAT	CS:KeyTable		
        
	MOV     Keyavailable, NoKeyState         ; Done with key, now no key

EndGetKey:        

	POP	CX
	POP	BX			; Restore the registers

	RET

GetKey	ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								      ;	
; Key Code Table carrying the Key Codes for keypresses on the keypad  ;
;								      ;	
;								      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



KeyTable	LABEL	BYTE
		PUBLIC	KeyTable

	DB	00		
	DB	00		
	DB	00		
	DB	00		
	DB	00		
	DB	02		
        DB      00 
	DB	00		
	
	DB	00		
	DB	00		
	DB	00		
        DB      04       
	DB	00		
	DB	05		
	DB	06		
	DB	00	

	DB	00		
	DB	00		
	DB	00		
	DB	07		
	DB	00	
	DB	08	
	DB	00		
	DB	00		

	DB	00		
	DB	00		
	DB	00	
        DB      00       
	DB	00		
        DB      11       
	DB	00		
	DB	00	



CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'


Key             DB      ?		; temparary hold which key has been pressed	
KeyStatus	DB	0		; store status of the keypress
KeyRow          DW      0		; row on the keypad of the pressed key
KeyDebounceTime DW      ?		; variable for holding the time for which the key had
					;   been debouncing


NewKey          DB      ?		; Holds the value of a new key being pressed
		PUBLIC	NewKey

NewKeyRow       DW      ?		; row of the key just pressed
		PUBLIC	NewKeyRow

KeyAvailable    DB      0		; stores whether a key has been pressed or not
		PUBLIC	KeyAvailable


DATA    ENDS


        END
