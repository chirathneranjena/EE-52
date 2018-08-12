
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                     DMA.INC                                ;
;                              	   Mp3 Player                                ;
;                          Include File for DMA.Asm                       ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the definitions for the Robo Crane DMA File
; program 
;
; Revision History:
; 	
; June 2002	Chirath Thouppuarachchi		Creation
;

; DMA Register addresses
DMASRL		EQU	0FFC0H		; Lower Source address register
DMASRH		EQU	0FFC2H		; Upper Source address register
DMADRH		EQU	0FFC6H		; Upper Destination address register
DMADRL          EQU     0FFC4H		; Lower Destination address register
DMATxCnt	EQU	0FFC8H		; DMA transfer count register
DMACntrlReg     EQU     0FFCAH		; DMA control register

; DMA register values and Masks

DMACntrlVal     EQU     0B600H		; DMA control register value (unarmed value)
					;  1------------- Dma Destination memory
					;  -0------------ Destination Decrement
					;  --1----------- Destination Increment
					;  ---1---------- Source Memory
					;  ----0--------- Source Decrement
					;  -----1-------- Source Increment
					;  ------1------- Terminal Count
					;  -------0------ No interrupt
					;  --------00---- Unsynchronized Transfer
					;  ----------0--- No priority
					;  -----------0000 No Internal DMA, No Change
					  		  No Arming and No word Transfer	

DMAArmMask      EQU     00006H		;  -----------0110 Change bit on, DMA start bit on

; IDE Register addresses

IDEBaseAddress  EQU     8000H		; Base address for the IDE

IDECntrlReg     EQU     0E000H		; IDE control register
IDEStatus       EQU     0E000H		; IDE status register / same address as control
IDEDataReg      EQU     0000H		; IDE data register
IDEHeadReg      EQU     0C000H		; IDE Head Register
IDECylRegL      EQU     8000H		; IDE Low Cylindar register
IDECylRegH      EQU     0a000H		; IDE upper Cylindar register
IDESectorReg    EQU     6000H		; IDE Sector register
IDESectorCntREG EQU     4000H		; IDE Sector count register
IDEErrorReg     EQU     2000H		; IDE error register
IDEAltStatusReg EQU     6000H		; IDE Alternate Status Register


IDEDeviceMask   EQU     0A0H		; IDE device mask to indicate CHS access to hard drive

; IDE control values
IDECommandRead  EQU     0021H		; IDE control register command to read
IDECommand      EQU     0ECH		; IDE control register command to let
					;  access to IDE Hard drive specs
; IDE Check values
IDEDataReqVal   EQU     08H		; Data Request check mask
IDEBusyVal      EQU     80H		; Busy indicate bit check mask
IDEDataReadyVal EQU     040H		; Data ready check mask

IDEIndexOffset  EQU     0		; Index offset for data request for the Hard drive


IDEBlockSize    EQU     512

; DMA address for IDE data register
IDE_DMAValLow   EQU     0000H		; IDE data register lower value
IDE_DMAValHigh  EQU     0008H		; IDE data register upper value.

 






