;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  52Main.INC                                ;
;                              	   Mp3 Player                                ;
;                          Include File for 52Main.Asm                       ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the Robo Crane Main File
; program 
;
; Revision History:
; 	
; May 2002	Chirath Thouppuarachchi		Creation
;


; Timer Defintions

; Addresses
Tmr0Ctrl        EQU     0FF56H          ;address of Timer 0 Control Register
Tmr0MaxCntA     EQU     0FF52H          ;address of Timer 0 Max Count A Register
Tmr0Count       EQU     0FF50H          ;address of Timer 0 Count Register
Tmr2Ctrl        EQU     0FF66H          ;address of Timer 2 Control Register
Tmr2MaxCnt      EQU     0FF62H          ;address of Timer 2 Max Count A Register
Tmr2Count       EQU     0FF60H          ;address of Timer 2 Count Register

Tmr1Ctrl        EQU     0FF5EH		; address of Timer 1 Control Register
Tmr1Count       EQU     0FF58H		; address of Timer 1 Count Register
Tmr1MaxCntA     EQU     0FF5AH		; address of Timer 1 Max Count A Register

; Control Register Values
Tmr0CtrlVal     EQU     0E001H          ;value to write to Timer 0 Control Register
					;1---------------  enable timer
					;-1--------------  write to control
					;--1-------------  enable interrupts
					;------------00--  do not count timer 2 outs
					;--------------0-  single counter mode
					;---------------1  continuous mode
Tmr2CtrlVal     EQU     0C001H          ;value to write to Timer 2 Control Register
					;1---------------  enable timer
					;-1--------------  write to control
                                        ;--0-------------  set interrupts on
					;---------------1  continuous mode


Tmr1CtrlVal     EQU     0E009H		;value to write to Timer 0 Control Registe
					;1---------------  enable timer
					;-1--------------  write to control
					;--1-------------  enable interrupts
					;------------10--  count timer 2 outs
					;--------------0-  single counter mode
					;---------------1  continuous mode

; Interrupt Vectors
Tmr0Vec         EQU     8               ;interrupt vector for Timer 0
Tmr2Vec		EQU	19		;interrupt vector for Timer 2	
Tmr1Vec         EQU     18		;interrupt vector for Timer 1

SerialVec	EQU	14		; Interrupt Vector for Interrupt 2

; Interrupt Controller Definitions

; Addresses
INTCtrlrCtrl    EQU     0FF32H          ;address of interrupt controller for timer
INTCtrlrEOI     EQU     0FF22H          ;address of interrupt controller EOI register

; Register Values
INTCtrlrCVal    EQU     00001H          ;set priority for timers to 1 and enable
Timer0EOI       EQU     00008H          ;Timer EOI command (same for all timers)
NonSpecEOI      EQU     08000H          ;Non-specific EOI command


; Chip Select Unit Definitions

; Addresses
PACSreg         EQU     0FFA4H          ;address of PACS register
MPCSreg         EQU     0FFA8H          ;address of MPCS register
MMCSreg         EQU     0FFA6H		;address of MMCS register

; Control Register Values
PACSval         EQU     00003H          ;PCS base at 0, 3 wait states
MPCSval         EQU     04083H          ;PCS in I/O space, use PCS5/6, 3 wait states
MMCSval         EQU     08000H		; MMCS Value (Base at 8000 and 0 wait states)



; Timing Definitions

COUNTS_PER_MS_0 EQU     2304            ;number of timer counts per 1 ms for timer 1
COUNTS_PER_MS_2 EQU     2304		; number of timer counts per 1 ms for timer 2


True		EQU	1		; True and False Values
False		EQU	0

; General Definitions

RESERVED_VECS   EQU     4		;vectors reserved for debugger