.model tiny

.code

org 100h

Start:      mov ax, 1111h
            mov bx, 2222h
            mov cx, 3333h
            mov dx, 5555h

@@Test:     in al, 60h
            cmp al, 01h
            jne Start          

            ret

end Start