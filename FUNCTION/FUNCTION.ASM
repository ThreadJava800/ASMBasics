.model tiny
.code

org 100h

locals @@

Start:
	mov bx, 0b800h
	mov es, bx
	mov bx, 160d * 5d + 80d ; middle of 5 line
	mov si, 1000d
	call ToDec

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
	
	mov dx, 100h		; dx = 256d
	jmp @@NewByte

@@Print1:
	mov es:[bx], 0531h	; put 0 to videomem
	add bx, 2		; bx += 2
	jmp @@Next

@@Print0:
	mov es:[bx], 0530h	; put 0 to videomem
	add bx, 2		; bx += 2
	jmp @@Next	

@@NewByte:
	mov cx, ax		; cx = ax
	and cx, dx		; cx && dx

	cmp cx, 0h		; if cx == 0: print(0) else: print(1)
	je  @@Print0
	jmp @@Print1	

@@Next:	
	cmp dx, 1h		; if dx == 1: return
	je @@Exit

	shr dx, 1		; dx >> 1
	jmp @@NewByte

@@Exit:	ret
	endp


;-----------------------------------------------------------
; Print dec of value
;-----------------------------------------------------------
; Entry: 	SI = value to convert to
;		BX = coordinates to print on string 
; Exit:		None
; Expects:  	ES -> videomem (b800h)
; Destroys: 	AX, BX, CX, DX, DI
;-----------------------------------------------------------
ToDec	proc
	
	mov dx, 0100h		; dx = 256d
	mov cx, si		; cx = si
	mov di, 00h		; di = 0	

@@ParseNewBit:
	and cx, dx
	cmp cx, 00h
	je @@SkipMul

	add di, dx
	

@@SkipMul:
	cmp dx, 01h
	je @@Print

	shr dx, 1
	mov cx, si
	jmp @@ParseNewBit		

@@Print:
	add bx, 10
	mov ax, di
	mov di, 5
	
@@PrintSymb:
	mov cl, 10d		; cl = 10
	div cl			; al = ax / 10, ah = ax % 10
		
	mov dh, 05h
	mov dl, ah
	add dl, 30h

	mov es:[bx], dx  
	mov ah, 00h
	
	sub bx, 2
	sub di, 1

	cmp di, 0
	je @@Exit

	jmp @@PrintSymb

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
