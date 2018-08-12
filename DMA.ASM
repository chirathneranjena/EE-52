
NAME DMA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                DMA.ASM	                             ;
;                         IDE and DMA for Mp3 Player	                     ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This File contains Code for handling IDE data transfer via
;			IDE to memory for the mp3 player
;			InitIDE - Sets up parameters to access IDE device
;			IDEbusyCheck - Waits until IDE is ready to accept next command
;			IDEDataReadyCheck - Waits untill IDE is ready for data access
;			getblocks - gets a block of data from the IDE hard drive
;					and stores in memory
;
; Input:            IDE and Memory address and legths of data transfer
; Output:           None
;		   
; User Interface:   None
; Error Handling:   None.
;
; Algorithms:       None
; Data Structures:  None.
;
; Revision History:
;
;     June 2002  Chirath Neranjena 	Creation


CGROUP 	GROUP 	CODE
DGROUP	GROUP	DATA

$INCLUDE (DMA.INC)

CODE SEGMENT PUBLIC 'CODE'

  ASSUME	CS: CGROUP,	DS: DGROUP,  SS: DGROUP

; InitIDE
;
; Description:      Gets parameters to access data from the hard drive.
;			heads per cylindar
;			tracks per sector
;
; Arguments:        None
; Return Value:     None
;
; Local Variables:  AL, DX, 
; Shared Variables: HeadsPerCylindar, TracksPerSector
;
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
; Registers Used:   AX, BX, DX, ES
; Stack Depth:      4 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002



InitIDE     PROC    NEAR
            PUBLIC  InitIDE

        PUSH    AX			; save registers
        PUSH    BX
        PUSH    DX
        PUSH    ES

        PUSH    IDEBaseAddress		; put the value of the base memory address
        POP     ES			;  to access the hard drive to ES	

        MOV     DX, DMACntrlReg		; Set up  the DMa control register
        MOV     AX, DMACntrlVal		; memory to memory unsynchronous transfer
        OUT     DX, AX

	CALL    IDEBusyCheck		; Wait untill IDE is ready again

GetIDEId:
	MOV	BX, IDECntrlReg		; set BX to have the address of the 
					;  hard drive control register
        MOV     WORD PTR ES:[BX], IDECommand	; Send command to access hard drive 
        					;   parameters

        CALL    IDEBusyCheck		; Check for IDE busy again		

GetIDEInfor:

        MOV     BX, IDEDataReg		; Set BX to have the hard drive data register
        MOV     AX, ES:[BX]		; dump values until heads per cylindar data
        MOV     AX, ES:[BX]
        MOV     AX, ES:[BX]
        MOV     AX, ES:[BX]
        MOV     HeadsPerCylindar, AX	; save heads per cylindar
        MOV     AX, ES:[BX]		; again keep dumping values
        MOV     AX, ES:[BX]
        MOV     AX, ES:[BX]
        MOV     SectorsPerTrack, AX	; save sectors per track

EndIDEInit:

        POP     ES			; restore registers
        POP     DX
        POP     BX
        POP     AX

        RET				; return

InitIDE     ENDP

; IDEBusyCheck
;
; Description:      Gets the Value of the status register from IDE hard drive
;			and check if it indicated busy. If busy it keeps checking
;			until not busy.
;
; Arguments:        None
; Return Value:     None
;
; Local Variables:  AX, BX
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
; Registers Used:   AX, BX
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    June 2002


IDEBusyCheck    PROC    NEAR


        PUSH    AX		; save registers
        PUSH    BX

WaitTillnotBusy:


        MOV     BX, IDECntrlReg		; store IDE status register address in BX
        MOV     AX, ES:[BX]		; get value from the status register
        AND	AL, IDEBusyVal	
        CMP     AL, IDEBusyVal		; check with busy value
        JE      WaitTillnotBusy		; if busy then keep checking

        POP     BX			; restore register
        POP     AX
        
        RET				; return

IDEDBusyCheck    ENDP

; IDEDataReadyCheck
;
; Description:      Gets the Value of the status register from IDE hard drive
;			and check if it indicated data ready. If not it keeps checking
;			until not busy.
;
; Arguments:        None
; Return Value:     None
;
; Local Variables:  AX, BX
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
; Registers Used:   AX, BX
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    MAY. 11 2002

IDEDataReadyCheck       PROC    NEAR

        PUSH    AX		; save register
	PUSH	BX
IDEDataReady:

        
        MOV     BX, IDECntrlReg		; store IDE status register address in BX
        MOV     AX, ES:[BX]		; get value from the status register
        AND     AL, IDEDataReadyVal	; check if the bit pattern indicated data ready
        CMP     AL, IDEDataReadyVal	; If not data ready
        JNE     IDEDataReady		'    then keep checking. Else exit
	
	POP	BX			; restore registers
        POP     AX

        RET				; return / done

IDEDataReadyCheck       ENDP


; getblocks
;
; Description:      Tranfers MP3 data from IDE to memory by initiating DMA transfer
;
; Arguments:        IDE LBA address, Memory Address, Blocks of Data to transfer
; Return Value:     No of Block Transfered
;
; Local Variables:  AX, BX, CX, DX, ES, SI, 
;
; Shared Variables: HeadsPerCylindar, SectorsPerTrack
; Global Variables: None
;
; Input:            None
; Output:           None
;
; Error Handling:   None.
;
; Algorithms:       start
;			get arguments
;			convert LBA address to CHS address
;			convert and setup DMA physical address
;			Repeat
;				Initiate DMA transfer
;			Until all blocks are sent			
; Data Structures:  None.
;
; Registers Used:   AX, BX, CX, DX, ES, SI, BP,
; Stack Depth:      2 words
;
; Author:           Chirath Neranjena
; Last Modified:    June 2002


get_blocks      PROC    NEAR
                PUBLIC  get_blocks

        PUSH	BP		; save BP and ES register
	PUSH    ES
	
        PUSH    IDEBaseAddress	; set ES to hold the IDE base memory address
        POP     ES

	MOV	BP, SP		; store SP value in BP 
        MOV     NoOfBuffers, 0	; set No of Buffer that has been transfered to be zero
        CALL    IDEBusyCheck	; now check if IDE is busy

GetBlockData:

        MOV     AX, [BP+6]	; get upper LBA address	
        MOV     DX, [BP+8]	; get lower LBA address

ConvertToCHS:

        ADD     AX, IDEIndexOffset 	; Add the Index Offset to upper address if there is one
        DIV     SectorsPerTrack		; divide by the number of sectors per track
        MOV     CX, DX			;   then CX has quotient
        INC     CX			;   Increment CX by one and hence the no. of sectors
        MOV     DX, 0			;   set DX to be zero
        DIV     HeadsPerCylindar        ; divide remainder by number of heads per cylindar
        				; then AX has cylindars, DX has Heads

        
        CALL    IDEBusyCheck		; wait until IDE is ready


WriteCHS:				; write CHS data to registers on Hard drive
					; to access data at that location

        MOV     BX, IDECylRegL		; Write Lower Cylindar Value to  
        MOV     ES:[BX], AX		;  Lower Cylindar register of IDE

        MOV     BX, IDECylRegH		; Write upper Cylindar value
        XCHG    AH, AL
        MOV     ES:[BX], AX

        MOV     BX, IDESectorReg	; Write Sector number
        MOV     ES:[BX], CX

        MOV     BX, IDEHeadReg		; Write number of heads
        OR      DX, IDEDeviceMask
        MOV     ES:[BX], DX

        MOV     BX, IDESectorCntReg	; Write no of blocks of data needed
        MOV     AX, [BP+10]		;  by getting this value from the stack
        MOV     ES:[BX], AX


        MOV     BX, IDECntrlReg		; send the command to read data from the hard drive	
        MOV     WORD PTR ES:[BX], IdeCommandRead	; to command register

SetDMA:

        MOV     AX, [BP+14]		; Get Offset of memory location

        ROL     AX, 4			; rotate it left by 4
        MOV     BX, AX			; save this value in BX					
        AND     AX, 0FFF0H		; Get the middle first 3 nibles of this value

        ADD     AX, [BP+12]		; and add that to the offset

        ADC     BX, 0			; If there's carry then add it to BX

        AND     BX, 000FH		; Finally get the last nibble of the BX 

        MOV     DX, DMADRL		; set the DMA registers with values obtained
        OUT     DX, AL			;  first the Lower value in AX

        MOV     DX, DMADRH		; then the upper vaue in BX
        MOV     AX, BX
        OUT     DX, AX

        

IDEDataWait:

	 CALL 	IDEBusyCheck		; Wait untill IDE is ready

IDEDataReqCheck:

        MOV     BX, IdeCntrlReg		; Get value from the IDE status register
        MOV     AX, ES:[BX]		;  Check if it has a data request
        AND     AL, IDEDataReqVal	;    if so initialize DMA		
        CMP     AL, IDEDataReqVal	;    else exit the function
        JNE     EndGetBlocks

        MOV     DX, DMASRL		; Set the source address for DMA transfer
        MOV     AX, IDE_DMAValLow	;   This would be the data register of 
        OUT     DX, AX			;   of the IDE Hard drive

        MOV     DX, DMASRH		; first the low value and then the high value  
        MOV     AX, IDE_DMAValHigh
        OUT     DX, AX

DMATransferInit:

        CALL    DMATransferBlock	; Call function that initiates DMA transfer
        INC     NoOfBuffers		;  Increment the number of buffer transfered in thie 
        JMP     IDEDataWait		;  secession
        				;  Go back to the Top and wait till IDE is not busy

EndGetBlocks:				

        MOV     AX, NoOfBuffers		; set return value to be the number of block transfered

        POP     ES			; restore registers
        POP     BP

        RET				; done

get_blocks       ENDP

; DMATransferBlock
;
; Description:      Transfers a block of data (specified by IDEBlockSize in bytes)
;			between hard drive and memory
; Arguments:        None
; Return Value:     None
;
; Local Variables:  AX, DX
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

DMATransferBlock        PROC    NEAR
                        PUBLIC  DMATransferBlock

        PUSH    AX			; Save registers
        PUSH    DX	


        MOV     AX, IDEBlockSize	; Get the No of bytes required to transfer
        MOV     DX, DMATxCnt		;  and put this into the Sector count register
        OUT     DX, AX
	
        MOV     DX, DMACntrlReg		; Get current value from the DMA control register
        IN      AX, DX			
        OR      AX, DMAArmMask		; Mask it to initate DMA transfer
        OUT     DX, AX			; DMA GO !

EndDMATransfer:

        POP     DX			; restore registers
        POP     AX

        RET				; DMA done, return

DMATransferBlock        ENDP



CODE	ENDS

DATA    SEGMENT PUBLIC  'DATA'

NoOfBuffers     DW      ?

HeadsPerCylindar        DW      ?	; holds the number of heads per cylindar of the hard drive         
SectorsPerTrack         DW      ?	; holds the number of sectors per track

DATA    ENDS


        END	
