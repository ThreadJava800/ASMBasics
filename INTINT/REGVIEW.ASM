.286                                    ; so shr(4) do not takes 4 commands
.model tiny

.data
    status: dw 0                        ; whether on or off

.code

org 100h

locals @@

Start:      ; KEYBOARD SETUP ;
            cli
            xor bx, bx
            mov es, bx
            mov bx, 9 * 4

            mov ax, es:[bx]
            mov [oldIntAd], ax
            mov ax, es:[bx + 2]
            mov [oldIntSeg], ax             ; saving all data about old interruption

            mov es:[bx], offset NewInt
            mov ax, cs
            mov es:[bx + 2], ax
            sti                             ; setting our 09h interruption

            ; CHRONOMETER SETUP ;
            cli
            xor bx, bx
            mov es, bx
            mov bx, 8 * 4

            mov ax, es:[bx]
            mov [oldIntAd08], ax
            mov ax, es:[bx + 2]
            mov [oldIntSeg08], ax             ; saving all data about old interruption

            mov es:[bx], offset NewInt08h
            mov ax, cs
            mov es:[bx + 2], ax
            sti                             ; setting our 08h interruption

            ; SAVING PROGRAM IN MEMORY ;
            mov ax, 3100h                   ; code for exiting program leaving it in memory
            mov dx, offset ProgEnd          ; amount of memory to keep resident
            shr dx, 4                       ; dx /= 16 (as paragraph == 16 byte)
            inc dx                          ; trunc(dx)
            int 21h

            ret


NewInt      proc
            push ax bx cx dx si di bp sp es ; saving registers

            call CodeFromPort
            cmp cl, 1Dh                     ; ctrl
            je @@OnOff
            jmp @@Else                      ; if ctrl pressed read next

@@OnOff:    lea di, cs:status
            mov cl, cs:[di]                 ; di = status

            cmp cl, 00h                     ; if isOff: switchOn               
            je @@SwOn                       ; else: SwitchOff

@@SwOff:    mov cl, 00h
            mov cs:[di], cl                 ; set status = 0

            jmp @@Exit

@@SwOn:     mov cl, 01h
            mov cs:[di], cl                 ; set status = 1

            jmp @@Exit


@@Else:     mov bx, 0b800h
            mov es, bx
            mov bx, 160d * 5d + 80d         ; setting position on screen
 
            mov ah, 4eh                     ; setting color for print
            mov al, cl                      ; space
            mov es:[bx], ax


@@Exit:     pop es sp bp di si dx cx bx ax  ; register back

            pushf                           ; putting flags to stack for int call immitation
            db 09ah                         ; call far
oldIntAd    dw 0
oldIntSeg   dw 0

            iret                            ; return from interruption 
                                            ; (iret does popf automatically)
            endp


NewInt08h       proc

                push ax bx cx dx si di bp sp es

                lea di, cs:status
                mov cl, cs:[di]                 ; di = status
                cmp cl, 00h 
                je @@Exit

                call DisplayRegs

@@Exit:         pop es sp bp di si dx cx bx ax  ; register back

                pushf                           ; putting flags to stack for int call immitation
                db 09ah                         ; call far
oldIntAd08      dw 0
oldIntSeg08     dw 0

                iret                            ; return from interruption 
                                              ; (iret does popf automatically)
                endp


;------------------------------------------------------------------------------
; Gets scan code from 61st port and puts it to register
;------------------------------------------------------------------------------
; Entry:        None
; Exit:         CL - read symbol
; Expects:      None
; Destroys:     AL, CL
;------------------------------------------------------------------------------
CodeFromPort    proc
                in al, 60h
                mov cl, al

                in al, 61h                      ; get data from 61 port

                or al, 80h                      ; setting first bit = 1
                out 61h, al
                and al, not 80h
                out 61h, al                     ; blinking

                mov al, 20h
                out 20h, al                     ; sending verification to int controller

                ret
                endp
;-------------------------------------------------------------------------------

ShowReg macro name, value
        mov cx, name
        mov di, bx
        mov ah, 05h
        mov al, ch 
        stosw
        mov al, cl 
        stosw

        add bx, 12d


        mov si, [value]
        call ToHex
        add bx, 160d - 10d * 2d 

        endm

;-------------------------------------------------------------------------------
; Draws rectangle and shows all registers in screen
;-------------------------------------------------------------------------------
; Entry:        None
; Exit:         None
; Expects:      None
; Destroys:     BX, ES
;-------------------------------------------------------------------------------
DisplayRegs     proc
                push bp                 ; saving old base pointer
                push di                 ; status var address
                mov bp, sp

                mov bx, 0b800h
                mov es, bx
                mov bx, 02h             ; point to left higher point

                ; DRAWING FRAME ;
                mov di, offset symbols
                mov cx, 14d
                mov dx, 11d
                call DrawRect

                mov bx, 160d + 4d

                ShowReg "AX" bp+11
                ShowReg "BX" bp+10
                ShowReg "CX" bp+9
                ShowReg "DX" bp+8
                ShowReg "SI" bp+7
                ShowReg "DI" bp+6
                ShowReg "BP" bp+5
                ShowReg "SP" bp+4
                ShowReg "ES" bp+3

                pop di
                pop bp
                ret
                endp

include SMLIB.ASM

ProgEnd:
end         Start