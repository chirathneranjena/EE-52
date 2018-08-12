;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 Key.INC                                    ;
;                              	 Mp3 Player                                  ;
;                          Include File for Key.Asm                          ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the Mp3 Player Key File
; program 
;
; Revision History:
; 	
; May 2002	Chirath Thouppuarachchi		Creation
;


;Key Status
NoKeystate		EQU	0
KeyPressedstate		EQU	1
KeyDebouncedstate	EQU	2


NoKeyValue		EQU	7 	; If no key is pressed, this is the return value

KeyPadRows	EQU	3		; no of rows in the key pad used - 1 (since row 1 = port 80)

DebounceTime    EQU     20              ; number of ms to debounce each key

KeypadPort	EQU	80h		; Port # of Keypad

KeyPermutations	EQU	8		; permutaions of possible combination of keypresses
					;  from keypad having 3 keys per row

; General Definitions
True		EQU	1
False		EQU	0

                            

