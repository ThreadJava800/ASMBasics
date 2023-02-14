.model tiny
.code

org 100h

locals @@

Start:
	mov ax, 0501h	
	mov dx, 0502h
	
	mov bx, 0b800h
	mov es, bx
	mov bx, 160d * 15d + 40d
	
	mov cx, 30d
	mov di, 10d

	call DrawRect	

	ret

;-------------------------------------------------------------
; Draws rectangle on screen with given borders
;-------------------------------------------------------------
; Entry:	AX - horizontal border
;		DX - vertical   border
;		BX - left highest point
;		CX - horizontal size
;		DI - vertical   size
; Exit:		None
; Expects:	ES -> videomem (0b800h)
; Destroys:	BP, SI
;-------------------------------------------------------------
DrawRect	proc		
		
		mov si, di		; i = di
		jmp @@MainCycle			

@@IterateI:	sub si, 1		; i--
	
		sub bx, cx		; start vertically
		sub bx, cx
		add bx, 160d		; new line

@@MainCycle:	mov bp, cx		; j = cx

		sub bx, 2		; bx -= 2 (then i += 2 to print)
		
		cmp si, 00h
		jne @@DrawV

@@ContinueMain:	add bx, 2		; bx += 2 (watch previous comment)
		cmp si, 00h
		je @@Exit 		; if i == 0: exit(0)

@@SecondCycle:	cmp bp, 00h
		je @@DrawRightV		; print left border (WORKS!)

		cmp si, di
		je @@DrawH		; draw highest border

		cmp si, 01h
		je @@DrawH		; draw lowest border

@@ContinueSecond:
		cmp bp, 00h
		je @@IterateI		; if j == 0: i++

		sub bp, 1		; else: j--
		add bx, 2		; bx += 2
		jmp @@SecondCycle

@@DrawH:	mov es:[bx], ax
		jmp @@ContinueSecond

@@DrawV:	mov es:[bx], dx	
		jmp @@ContinueMain

@@DrawRightV:	mov es:[bx], dx
		jmp @@ContinueSecond

@@Exit:		ret
		endp

end	Start