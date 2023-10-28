.model small
.data
    alarm db "ALARM: $"
    x db " x$"

.code
main proc
    mov ax, @data
    mov ds, ax

display_time:
    
    mov ah, 06h
    mov al, 0
    mov bh, 0
    mov ch, 0
    mov cl, 0
    mov dh, 0
    mov dl, 0
    int 10h
    
    ; Position cursor at the beginning (0,0)
    mov ah, 02h      ; AH = 02H: Set Cursor Position
    mov bh, 0        ; Page number (0)
    mov dh, 0        ; Row (0)
    mov dl, 62       ; Column (0)
    int 10h

    mov ah, 09h
    lea dx, alarm
    int 21h

    hour:
    mov ah, 2ch      ; AH = 2CH: Get System Time
    int 21h
    mov al, ch       ; Hour is in CH
    aam
    mov bx, ax
    call disp

    mov dl, ':'
    mov ah, 02h
    int 21h

    minutes:
    mov ah, 2ch      ; AH = 2CH: Get System Time
    int 21h
    mov al, cl       ; Minutes is in CL
    aam
    mov bx, ax
    call disp

    mov dl, ':'
    mov ah, 02h
    int 21h

    seconds:
    mov Ah, 2ch      ; AH = 2CH: Get System Time
    int 21h
    mov al, dh       ; Seconds is in DH
    aam
    mov bx, ax
    call disp

    mov ah, 09h
    lea dx, x
    int 21h

    ; Delay to control the refresh rate
    mov cx, 65535
    
    mov ah, 01h
    int 16h

    cmp al, '-'     ; Check if "-" is pressed
    je hide_message
    ;jmp turn_display_on
    
    call clear_keyboard_buffer
    
delay_loop:
    dec cx
    jnz delay_loop

    jmp display_time

hide_message:
    ; Clear the keyboard buffer after hiding the message
    call clear_keyboard_buffer
    
    ; Clear the screen
    mov ah, 06h
    mov al, 0
    mov bh, 0
    mov ch, 0
    mov cl, 0
    mov dh, 1
    mov dl, 89
    int 10h
    
    ; Check for any keypress
    mov ah, 01h
    int 16h
    cmp al, '-'
    je hide_message
    jmp turn_display_on ; If any key (except '-') is pressed, turn the display back on
    
    jmp display_time
    
turn_display_on:
    ; Clear the keyboard buffer after turning the display back on
    call clear_keyboard_buffer
    
    jmp display_time
    
clear_keyboard_buffer:
    mov ah, 01h
    int 16h
    jz buffer_cleared ; If ZF (Zero Flag) is set, the buffer is empty

    mov ah, 00h
    int 16h           ; Read and discard the key

    jmp clear_keyboard_buffer

buffer_cleared:
    ret

disp proc
    mov dl, bh        ; Since the values are in BX, BH Part
    add dl, 30h       ; ASCII Adjustment
    mov ah, 02h       ; AH = 02H: Print Character
    int 21h
    mov dl, bl        ; BL Part
    add dl, 30h       ; ASCII Adjustment
    mov ah, 02h       ; AH = 02H: Print Character
    int 21h
    ret

disp endp
end main