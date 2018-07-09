%define nop8 db 0x0F, 0x1F, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00
%macro cache_line 0
nop8 
nop8 
nop8 
nop8 
nop8 
nop8 
nop8 
nop8
%endmacro

GLOBAL foo

ALIGN 256

foo:

; This number of nops was adjusted in a way to align hot loops in both cases at a 64 bytes boundary
; Hot loops should have the same alignment, otherwise comparison will not be equal.
cache_line
cache_line
cache_line
nop8 
nop8 
nop8 
nop8 
nop8 
nop8 
nop8
nop
nop

cmp rdi, 0
jnz .cold

.hot:
dec rsi
jnz .hot

.merge:

ret
ud2

.cold:

call err_handler
jmp .merge
ud2

err_handler:

cache_line
cache_line
cache_line
cache_line

ret
