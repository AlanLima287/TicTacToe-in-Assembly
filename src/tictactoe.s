[BITS 16]
[ORG 0x7C00]

start:
   cli
   xor ax, ax
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov sp, 0x7C00
   sti

   xor dx, dx
   mov ah, 0x02
   int 0x10

   mov ax, 0x0A00
   mov bh, 0x00
   mov cx, 0x07D0
   int 0x10

   mov si, board
   call print

   xor ax, ax
   mov [ptr_cursor], ax
   mov [ptr_O_marks], ax
   mov [ptr_X_marks], ax
   
   mov al, 0x4F
   mov [ptr_player], al
   jmp put_cursor
get_arrow_key:
   mov ah, 0
   int 0x16
   
   mov dx, [ptr_cursor]
   cmp ax, 0x4B00
   je case_LEFT
   cmp ax, 0x4800
   je case_UP
   cmp ax, 0x4D00
   je case_RIGHT
   cmp ax, 0x5000
   je case_DOWN
   cmp al, 0x20
   je put_mark
   jmp get_arrow_key

case_LEFT:
   sub dl, 2
   jmp fix_overflow_col
case_UP:
   sub dh, 1
   jmp fix_overflow_row
case_RIGHT:
   add dl, 2
   jmp fix_overflow_col
case_DOWN:
   add dh, 1
   jmp fix_overflow_row

put_mark:
   mov cl, dl
   shr cl, 1
   add cl, dh
   add cl, dh
   add cl, dh

   mov bx, 1
   shl bx, cl

   test bx, [ptr_O_marks]
   jnz get_arrow_key
   test bx, [ptr_X_marks]
   jnz get_arrow_key

   mov al, [ptr_player]
   xor al, 0x17
   mov [ptr_player], al

   cmp al, 0x4F
   jne handle_X_mark

handle_O_mark:
   or bx, [ptr_O_marks]
   mov [ptr_O_marks], bx
   jmp print_mark
handle_X_mark:
   or bx, [ptr_X_marks]
   mov [ptr_X_marks], bx
   jmp print_mark
fix_overflow_row:
   and dh, 0x3
   cmp dh, 0x3
   jne put_cursor
   
   mov dh, 0
   jmp put_cursor
fix_overflow_col:
   and dl, 0x7
   cmp dl, 0x6
   jne put_cursor
   
   mov dl, 0
   jmp put_cursor

print_mark:
   mov al, [ptr_player]
   mov ah, 0x0E
   int 0x10

   mov ax, bx
   not ax

   xor bx, bx
.tests:
   test ax, [win_boards + bx]
   jz win_exit
   
   add bx, 2
   cmp bx, 0x10
   jne .tests

   mov bx, [ptr_O_marks]
   or bx, [ptr_X_marks]
   cmp bx, 0x01FF
   je tie_exit

put_cursor:
   mov [ptr_cursor], dx
   mov bx, 0x0000
   mov ax, 0x0200
   int 0x10

   jmp get_arrow_key

win_exit:
   mov bh, 0x00
   mov ah, 0x02
   mov dx, 0x0400
   int 0x10

   mov al, [ptr_player]
   mov ah, 0x0E
   int 0x10
   
   mov si, win_message
   call print
   jmp exit

tie_exit:
   mov bh, 0x00
   mov ah, 0x02
   mov dx, 0x0400
   int 0x10

   mov si, tie_message
   call print

   ;jmp exit
exit:
   mov ah, 0
   int 0x16

   cmp ax, 0x011B
   jne start

   mov ax, 0x5307
   mov bx, 0x0001
   mov cx, 0x0003
   int 0x15

   cli
   hlt

print:
   push bp
   mov bp, sp

.loop:
   lodsb
   cmp al, 0
   je .func
   
   mov ah, 0x0E
   int 0x10
   jmp .loop

.func:
   mov sp, bp
   pop bp
   ret

ptr_O_marks dw 0x0000
ptr_X_marks dw 0x0000
ptr_cursor dw 0x0000
ptr_player db 0x4F
board db " | | ", 0xA, 0xD, " | | ", 0xA, 0xD, " | | ", 0
win_boards dw 0x0007, 0x0038, 0x01C0, 0x0049, 0x0092, 0x0124, 0x0111, 0x0054
win_message db " won!!!", 0
tie_message db "It was a tie!", 0
times 510 - ($ - $$) db 0
dw 0xAA55