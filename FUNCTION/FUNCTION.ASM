.model tiny
.code

org 100h

locals @@

Start:
	mov bx, 0b800h
	mov es, bx
	mov bx, 160d * 5d + 80d
	mov ax, 150d
	call ToBin

	ret			; exit(0)



;-----------------------------------------------------------
; Print binary of value
;-----------------------------------------------------------
; Entry: 	AX = value to convert to
;		BX = coordinates to print on string 
; Exit:		None
; Expects:  	ES -> videomem (b800h)
; Destroys: 	BX, CX, DL
;-----------------------------------------------------------
ToBin	proc
	
	mov dx, 100h
	jmp @@NewByte

@@Print1:
	mov es:[bx], 0531h
	add bx, 2
	jmp @@Next

@@Print0:
	mov es:[bx], 0530h
	add bx, 2
	jmp @@Next	

@@NewByte:
	mov cx, ax
	and cx, dx

	cmp cx, 0h
	je  @@Print0
	jmp @@Print1	

@@Next:	
	cmp dx, 1h
	je @@Exit

	shr dx, 1		; dx >> 1
	jmp @@NewByte

@@Exit:	ret
	endp
	
;-----------------------------------------------------------
; Put symbol with given ascii to videomem
;-----------------------------------------------------------
; Entry:	BX = coordinates where to print symbol
;		CX = symbol itself
; Exit:		None
; Expects:	ES -> videomem (b800h)
; Destroys:	None
;-----------------------------------------------------------
PutChar proc

	mov es:[bx], cx		; put symbol to videomem

	ret
	endp


end	Start