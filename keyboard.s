[BITS 16]
[ORG 0x7c00]

start:
   cli
   xor ax, ax
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov sp, 0x7C00
   sti

get_key:
   mov ah, 0
   int 0x16
   
   mov cl, 0x10
   mov dx, ax
   mov ax, 0x0E0D
   int 0x10
   
loop:
   sub cl, 4

   mov bx, dx
   shr bx, cl
   and bx, 0xF
   mov al, [hexchar + bx]
   mov ah, 0x0E
   int 0x10
   
   cmp cl, 0
   je get_key
   jmp loop

hexchar db '0123456789ABCDEF'
times 510 - ($ - $$) db 0
dw 0xAA55