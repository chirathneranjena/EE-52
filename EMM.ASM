$title ('EMM.ASM -- Expanded Memory Manager driver')
$debug

	name	EMM

; C calling conventions:
;       extern int EMM_get_status();
;       extern int EMM_get_pg_frame(unsigned int *);
;       extern int EMM_get_unalloc_pg_count(int *, int *);
;       extern int EMM_alloc_pgs(int, int *);
;       extern int EMM_map_handle_pg(int, int, int);
;       extern int EMM_dealloc_pgs(int);

PUBLIC  EMM_get_status
PUBLIC  EMM_get_pg_frame
PUBLIC  EMM_get_unalloc_pg_count
PUBLIC  EMM_alloc_pgs
PUBLIC  EMM_map_handle_pg
PUBLIC  EMM_dealloc_pgs

EMM_INTR	equ	67H
DOS_INTR	equ	21H
DOS_GET_INTVEC	equ	35H

GET_STATUS      equ     40H
GET_PG_FRAME	equ	41H
GET_UNALLOC_PG	equ	42H
ALLOC_PGS	equ	43H
MAP_PGS		equ	44H
DEALLOC_PGS	equ	45H

TRUE		equ	1
FALSE		equ	0
DEVNAME_LEN	equ	8
OFFSET_DEVNAME	equ	10
AH_ONLY         equ     0FF00H

CGROUP	group	CODE

assume	CS: CGROUP

CODE	segment

; EMM_get_status: procedure word external;
; Returns zero if the EMM driver is installed, non-zero if it is not.

EMM_get_status	proc	near
	push	DS			; Standard preamble
	push	BP			;
	mov	BP, SP			;

	mov	AH, DOS_GET_INTVEC	; DOS "get interrupt vector" function
	mov	AL, EMM_INTR		; EMM interrupt vector
	int	DOS_INTR		; Call DOS

	mov     AH, GET_STATUS          ; EMM "get_status" function
	int     EMM_INTR                ; Check for EMM memory manager
	and     AX, AH_ONLY             ; Mask for upper 8 bits = status

	pop	BP			; Standard postamble
	pop	DS			;   restores BP and DS
	ret	0			; Parameters not discarded
EMM_get_status	endp

EMM_get_pg_frame	proc	near
	push	DS			; Standard preamble
	push	BP			;
	mov	BP, SP			;

        mov     AH, GET_PG_FRAME        ; EMM "get page frame" function
        int     EMM_INTR                ; Call the EMM
        and     AX, AH_ONLY             ; Mask for upper 8 bits = status
        mov     SI, [BP + 6]            ; Pointer to caller variable
        mov     [SI], BX                ; Return value from EMM call

	pop	BP			; Standard postamble
	pop	DS			;   restores BP and DS
	ret	0			; Parameters not discarded
EMM_get_pg_frame	endp

EMM_get_unalloc_pg_count	proc	near
	push	DS			; Standard preamble
	push	BP			;
	mov	BP, SP			;

	mov     AH, GET_UNALLOC_PG      ; EMM "get unallocated count" function
	int     EMM_INTR                ; Call EMM
	and     AX, AH_ONLY             ; Mask for upper 8 bits = status
	mov     SI, [BP + 6]            ; Unallocated pages
	mov     [SI], BX                ;
	mov     SI, [BP + 8]            ; Total pages
	mov     [SI], DX                ;

	pop	BP			; Standard postamble
	pop	DS			;   restores BP and DS
	ret	0			; Parameters not discarded
EMM_get_unalloc_pg_count	endp

EMM_alloc_pgs	proc	near
	push	DS			; Standard preamble
	push	BP			;
	mov	BP, SP			;

	mov     AH, ALLOC_PGS           ; EMM "allocate pages" function
	mov     BX, [BP + 6]            ; Number of pages to allocate
	int     EMM_INTR                ; Call EMM
	and     AX, AH_ONLY             ; Mask for upper 8 bits = status
	mov     SI, [BP + 8]            ; Pointer to handle int
	mov     [SI], DX                ; Store handle

	pop	BP			; Standard postamble
	pop	DS			;   restores BP and DS
	ret	0			; Parameters not discarded
EMM_alloc_pgs	endp

EMM_map_handle_pg	proc	near
	push	DS			; Standard preamble
	push	BP			;
	mov	BP, SP			;

	mov     DX, [BP + 6]            ; Handle
	mov     BX, [BP + 8]            ; Logical page
	mov     AL, [BP + 10]           ; Physical page
	mov     AH, MAP_PGS             ; EMM "map handle" function
	int     EMM_INTR                ; Call EMM
	and     AX, AH_ONLY             ; Mask for upper 8 bits = status

	pop	BP			; Standard postamble
	pop	DS			;   restores BP and DS
	ret	0			; Parameters not discarded
EMM_map_handle_pg	endp

EMM_dealloc_pgs	proc	near
	push	DS			; Standard preamble
	push	BP			;
	mov	BP, SP			;

	mov     AH, DEALLOC_PGS         ; EMM "deallocate" function
	mov     DX, [BP + 6]            ; Page to deallocate
	int     EMM_INTR                ; Call EMM
	and     AX, AH_ONLY             ; Mask for upper 8 bits = status

	pop	BP			; Standard postamble
	pop	DS			;   restores BP and DS
	ret	0			; Parameters not discarded
EMM_dealloc_pgs	endp

CODE	ends

	end
