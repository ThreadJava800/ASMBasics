.model tiny

.code

org 100h

Start:      mov ax, 05h
            mov bx, 100h
            mov cx, 1000h
            mov dx, 15h

@@Test:     jmp @@Test            

            ret

end Start