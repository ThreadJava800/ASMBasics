.model tiny

.data

	arguments:	dw 9 dup(0)

.code

org 100h

locals @@


Start:	
				mov bx, 0082h
				call ReadNumber			; ax -> line

				mov si, 160d 
				mul si					; ax *= 10
				mov di, ax 				; si = ax

				call ReadNumber
				add ax, ax
				add di, ax
				push di					; coordinates ready

				call ReadNumber
				push ax					; height

				call ReadNumber
				push ax					; length

				call ReadNumber			; type

				cmp ax, 01h
				je @@Parse1
				cmp ax, 02h
				je @@Parse2
				cmp ax, 03h
				je @@Parse3
				cmp ax, 04h
				je @@Parse4

; MODE = 1 ;
@@Parse1:		
				mov cx, 08h				; counter for loop
				lea di, arguments

				; READING ASCII ;
				mov byte ptr al, [bx]	; al = ascii code
				inc bl
				inc bl					; bl += 2

				mov ah, 05h
				mov [di], ax
				inc di
				inc di

@@Loop1:		mov [di], ax
				inc di
				inc di
				loop @@Loop1

				mov di, 0020h				; inside = space
				lea di, arguments

				jmp @@Call

; MODE = 2 ;
@@Parse2:		
				mov cx, 08h				; counter for loop

				; READING ASCII ;
				mov byte ptr al, [bx]	; al = ascii code
				inc bl
				inc bl					; bl += 2
				mov ah, 05h

@@Loop2:		push ax
				loop @@Loop1
				push 0020h				; inside = space

				jmp @@Call

; MODE = 3 ;
@@Parse3:		mov cx, 08h
@@Loop3:		push 052ah
				loop @@Loop3
				push 0020h				; inside = space		

				jmp @@Call

; MODE = 4 ;
@@Parse4:		mov cx, 09h

@@Loop4:		mov byte ptr al, [bx]	; al = ascii code
				inc bl
				inc bl					; bl += 2
				mov ah, 05h
				push ax					; ax = ascii to draw (color = 05h)

				loop @@Loop4		


@@Call:			pop cx
				pop dx

				mov bx, 0b800h
				mov es, bx				; es -> 0b800h
				pop bx

				call DrawRect
				int 20h					; exit(0)
				ret

;-----------------------------------------------------------
; Reads command line int arguments
;-----------------------------------------------------------
; Entry: 		BX = position in command line (starting 80h)
; Exit:			AX - read value
; Expects:  	None
; Destroys: 	AX, BX, CL, DX, SI
;-----------------------------------------------------------
ReadNumber		proc
				mov ax, 00h
				mov dx, 00h					; dx:ax = 0

@@Loop:			mov byte ptr cl, [bx]		; cl = arg symb
				cmp cl, 0Dh
				je @@Exit

				cmp cl, 20h
				je @@Exit					; if cl == ' ' or 0D: exit()

				mov si, 10d 
				mul si 						; ax *= 10

				add al, cl
				sub al, 30h					; ax += read ascii.toChar()

				inc bl						; bx++
				jmp @@Loop

@@Exit:			inc bl						; bx++
				ret
				endp


include ..\LIBA.ASM

end	Start