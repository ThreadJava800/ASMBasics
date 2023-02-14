.model tiny
.code

org 100h

locals @@

Start:
	mov ax, 05b3h	
	mov dx, 05c4h
	
	mov bx, 0b800h
	mov es, bx
	mov bx, 80d * 10d + 20d
	
	mov cx, 30d
	mov di, 5d

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
; Destroys:	CL, SI, DI
;-------------------------------------------------------------
DrawRect	proc		

@@MainCycle:	cmp di, 00h
		je @@Exit

		mov es:[bx], dx		

@@ContinueMain:	mov si, cx		
		sub di, 1		; i--
@@SecondCycle:	
		cmp si, 00h
		jmp @@DrawH
		
		cmp si, cx
		jmp @@DrawH
 		
		
@@Continue:	cmp si, 00h		; if j == 0: goto MainCycle
		je @@MainCycle		
		
		sub si, 1		; j--
		jmp @@SecondCycle

@@DrawV:	mov es:[bx], dx
		jmp @@ContinueMain

@@DrawH:	mov es:[bx + di * 80d + si], ax
		jmp @@Continue
	
@@Exit:		ret
		endp

end	Start