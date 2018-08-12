DisplaySetPort		EQU	00h
DisplayshowPort		EQU	01h
BusyFlagPort            EQU     02h

BusyFlag                EQU     10000000b

InitCode1		EQU	00111000b
InitCode2		EQU	00001000b
InitCode3		EQU	00000001b
InitCode4		EQU	00000110b
InitCode5		EQU	00001111b

ClearDisplayCode        EQU     00000001b

ASCIINoStart		EQU	030H

statusplay		EQU	0
statusffw		EQU	1
statusRev		EQU	2
statusIdle		EQU	3
statusIllegal		EQU	4


IDE_BLOCK_SIZE		EQU	512
