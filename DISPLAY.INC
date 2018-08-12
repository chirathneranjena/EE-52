;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  Display.INC                               ;
;                              	   Mp3 Player                                ;
;                          Include File for Display.Asm                      ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the Mp3 Player Display File
; program 
;
; Revision History:
; 	
; May 2002	Chirath Thouppuarachchi		Creation
;



; Display port values
DisplaySetPort		EQU	00h		; display command port	
DisplayshowPort		EQU	01h		; display data port
BusyFlagPort            EQU     02h		; display check busy flag port


; Row up and down values
MovtoNextRow		EQU	0A8h		; value to move to the second row of the
						;  the display
MoveBack		EQU	00h		; value to move back to the top row

BusyFlag                EQU     10000000b	; value of the busy flag

; Initialization codes for the display
InitCode1		EQU	00111000b	; sets data length and display lines	
InitCode2		EQU	00001000b	; sets display on	
InitCode3		EQU	00000001b	; clear the display
InitCode4		EQU	00000110b	; set cursor move direction, stop display shift
InitCode5               EQU     00001101b	; display on, cursor on, blink on

ClearDisplayCode        EQU     00000001b	; command to clear the display
	
ASCIINoStart		EQU	030H		; ASCII value for '0' hence the start
						;  ASCII number for digits
						; ASCII Value = ASCIINoStart + digit

; Status representations of various status passed.
statusplay		EQU	0
statusffw		EQU	1
statusRev		EQU	2
statusIdle		EQU	3
statusIllegal		EQU	4


; General Definitions
True			EQU	1		; 
False			EQU	0



