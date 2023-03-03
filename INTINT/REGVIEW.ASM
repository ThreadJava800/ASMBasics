.286                                    ; so shr(4) do not takes 4 commands
.model tiny

; DEFINING CONSTANTS ;
HOT_KEY      equ 2bh                         ; '\'
FRAME_HEIGHT equ 13d
FRAME_LENGTH equ 14d
; CONSTANTS END ;

.code

org 100h

locals @@

;----------------------------------------------------------------------------------
; Macro that saves old interruption and fills it with own
;----------------------------------------------------------------------------------
ReplInt macro oldIntAddr, oldIntSegment, newAddress
        mov ax, es:[bx]
        mov [oldIntAddr], ax
        mov ax, es:[bx + 2]
        mov [oldIntSegment], ax             ; saving all data about old interruption

        mov es:[bx], offset newAddress
        mov ax, cs
        mov es:[bx + 2], ax

        endm

Start:      ; KEYBOARD SETUP ;
            cli                                         ; disable interruptions
            xor bx, bx
            mov es, bx

            mov bx, 9 * 4                                ; 09 int (keyboard)
            ReplInt oldIntAd oldIntSeg NewInt

            ; CHRONOMETER SETUP ;
            mov bx, 8 * 4
            ReplInt oldIntAd08 oldIntSeg08 NewInt08h    ; 08 int (chronometer)
            sti                                         ; enable interruption

            ; SAVING PROGRAM IN MEMORY ;
            mov ax, 3100h                   ; code for exiting program leaving it in memory
            mov dx, offset ProgEnd          ; amount of memory to keep resident
            shr dx, 4                       ; dx /= 16 (as paragraph == 16 byte)
            inc dx                          ; trunc(dx)
            int 21h

            ; call VidToArr
            ; call ArrToVid

            ret

;------------------------------------------------------------------------------------
status: dw 0                        ; whether on or off
;------------------------------------------------------------------------------------
NewInt      proc
            push ax bx cx dx si di bp sp ds es ss ; saving regs

            call CodeFromPort
            cmp cl, HOT_KEY                 ; '\'
            je @@OnOff
            jmp @@Exit                      ; if '\' pressed read next

@@OnOff:    lea di, cs:status
            mov cl, cs:[di]                 ; di = status

            cmp cl, 00h                     ; if isOff: switchOn               
            je @@SwOn                       ; else: SwitchOff

@@SwOff:    mov cl, 00h
            mov cs:[di], cl                 ; set status = 0

            call ArrToVid

            jmp @@Exit

@@SwOn:     mov cl, 01h
            mov cs:[di], cl                 ; set status = 1

            call VidToArr

            jmp @@Exit


@@Exit:     mov al, 20h
            out 20h, al                     ; sending verification to int controller

            pop ss es ds sp bp di si dx cx bx ax  ; register back

            db 0eah                         ; call far
oldIntAd    dw 0
oldIntSeg   dw 0

            endp
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------
NewInt08h       proc

                push ax bx cx dx si di bp sp ds es ss

                lea di, cs:status
                mov cl, cs:[di]                 ; di = status
                cmp cl, 00h 
                je @@Exit

                call DisplayRegs

@@Exit:         pop ss es ds sp bp di si dx cx bx ax  ; register back

                db 0eah                         ; call far
oldIntAd08      dw 0
oldIntSeg08     dw 0

                endp
;------------------------------------------------------------------------------------

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

                ret
                endp


video: dw 13d * 14d dup (0)

;-------------------------------------------------------------------------------
; Saves videomem to array
;-------------------------------------------------------------------------------
; Entry:        None
; Exit:         video
; Expects:      ES -> videomem (0b800h)
; Destroys:     AX, BX, CX, DX, DI
;-------------------------------------------------------------------------------
VidToArr        proc

                mov bx, 0b800h
                mov es, bx

                xor bx, bx                      ; bx = 0
                xor ax, ax                      ; i = 0
                lea di, video

@@ReadRow:      inc ax
                mov cx, FRAME_LENGTH            ; j = frame.length

@@ReadLine:     mov dx, es:[bx]
                mov cs:[di], dx                 ; put val from arr to vidmem
                inc bx
                inc bx                          ; bx += 2

                inc di
                inc di                          ; di += 2

                loop @@ReadLine

                add bx, 160d - 2 * FRAME_LENGTH ; put bx to the beginning of new line

                cmp ax, FRAME_HEIGHT
                jne @@ReadRow

                ret
                endp

;-------------------------------------------------------------------------------
; Build videomem from array
;-------------------------------------------------------------------------------
; Entry:        video
; Exit:         videomem
; Expects:      ES -> videomem (0b800h)
; Destroys:     
;-------------------------------------------------------------------------------
ArrToVid        proc

                mov bx, 0b800h
                mov es, bx

                xor bx, bx                      ; bx = 0
                xor ax, ax                      ; ax = 0
                lea di, video

@@ReadRow:      inc ax
                mov cx, FRAME_LENGTH            ; j = frame.length

@@ReadLine:     mov dx, cs:[di]
                mov es:[bx], dx
                inc bx
                inc bx

                inc di
                inc di

                loop @@ReadLine

                add bx, 160d - 2 * FRAME_LENGTH

                cmp ax, FRAME_HEIGHT            ; put bx to the beginning of new line
                jne @@ReadRow

                ret
                endp

;-------------------------------------------------------------------------------
; Macros that prints registers on screen
;------------------------------------------------------------------------------
; Entry:        None
; Exit:         CL - read symbol
; Expects:      None
; Destroys:     AL, CL
;------------------------------------------------------------------------------
ShowReg macro name, value
        mov cx, name
        mov di, bx                  ; di = pos on screen
        mov ah, 05h                 ; text color
        mov al, ch                  ; al = first symbol
        stosw       
        mov al, cl                  ; al = second symbol
        stosw

        add bx, 6 * 2               ; moving bx for 6 to print hex value backwards

        mov si, [value]
        call ToHex
        add bx, 160d - 10d * 2d     ; moving to the start of line where to print next reg

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
                mov cx, FRAME_LENGTH
                mov dx, FRAME_HEIGHT
                call DrawRect

                mov bx, 160d + 4d       ; put bx to the begining of print tex

                ShowReg "AX" bp+26
                ShowReg "BX" bp+24
                ShowReg "CX" bp+22
                ShowReg "DX" bp+20
                ShowReg "SI" bp+18
                ShowReg "DI" bp+16
                ShowReg "BP" bp+14
                ShowReg "SP" bp+12
                ShowReg "DS" bp+10
                ShowReg "ES" bp+8
                ShowReg "SS" bp+6

                pop di
                pop bp
                ret
                endp

;--------------------------------------------------------

include SMLIB.ASM

;========================================================
ProgEnd:
;========================================================

end         Start

