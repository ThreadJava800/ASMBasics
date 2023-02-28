.model tiny
.code

org 100h

locals @@

Start:      mov bx, 0b800h
            mov es, bx
            mov bx, 160d * 5d + 80d         ; setting position on screen

@@Cycle:    mov ah, 4eh                     ; setting color for print
            in al, 60h                      ; getting value from keyboard port (read only)
            mov es:[bx], ax                 ; print what's inside
                                            ; it's not ascii, but scan code!
            cmp al, 1                       ; if key == ESC: exit()
            jne @@Cycle

@@Exit:     ret

end         Start