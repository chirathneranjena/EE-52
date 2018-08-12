;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                               MP3Inf.INC                                   ;
;                              	Mp3 Player                                   ;
;                          Include File for Mp3.Asm                          ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the Mp3 Player Mp3 File
; program 
;
; Revision History:
; 	
; May 2002	Chirath Thouppuarachchi		Creation


; register addresses
Int2CtrlReg	EQU	0FF3CH		; Interrupt2 controller register address
IntCtrlEOI	EQU	0FF22H		; EOI register address
IRQReg		EQU	0FF2Eh		; Address of the interrupt request register

; Register Values
Int2CtrlVal     EQU     00017H          ; Unmask Int2, prority 3
Int2StpVal      EQU     00018H		; Mask Int 2 Value

Int2EOI		EQU	0000EH		; Interrupt 2 EOI
NonSpecEOI	EQU	08000H		; Non specific EOI

ChkVal		EQU	01000000b	; Value to check if Interrupt 2 is still on	
StartBit	EQU	0		; the start bit

MP3Port		EQU	100h		; Port connected to the mp3 decorder
		          
; General Definitions
TRUE		EQU	1
FALSE		EQU	0

