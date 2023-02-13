.model tiny
.code

org 100h

locals @@

Start:
	mov bx, 0b800h
	mov es, bx
	mov bx, 160d * 5d + 80d
	mov cx, 0542h
	call PutChar

	ret			; exit(0)



;-----------------------------------------------------------
; Print binary of value
;-----------------------------------------------------------
; Entry: 	AX = value to convert to 
; Exit:		None
; Expects:  	ES -> videomem (b800h)
; Destroys: 	AX
;-----------------------------------------------------------
ToBin	proc
	
	ret
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

	mov es:[bx], cx			; put symbol to videomem

	ret
	endp


end	Start