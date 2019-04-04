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

%macro Four_cache_lines 0
cache_line
cache_line
cache_line
cache_line
%endmacro

%macro One_KB_of_nops 0
Four_cache_lines
Four_cache_lines
Four_cache_lines
Four_cache_lines
%endmacro

GLOBAL foo

ALIGN 256
foo:
# start some irrelevant work
One_KB_of_nops
# finish some irrelevant work

# load that goes to DRAM
mov     rax, QWORD [rdi + rsi]
# introduce dependency chain
mov     rax, QWORD [rdi + rax]

xor rax, rax
ret
ud2
