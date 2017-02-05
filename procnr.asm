if 1 
	include MACROS.MAC
endif

data segment para 'data'
	lgfract db ?
	lgreal db ?
	one dd 1.0
	ten dd 10.0
	result dd 0
data ends

code segment para 'code'
public processnr
	assume cs:code, ds:data
	processnr proc far
	push ds
	mov lgfract, ch
	mov lgreal, cl
	mov cx, 0
	mov cl, lgreal
	mov si, cx
	dec si
	fld one
	fld one
	fld result
processreal:
	mov bx, 0	
	checknr realpart[si]
	sub realpart[si], 30h
	mov bl, realpart[si]
	mov floatnumber, bx
	fild floatnumber
	fmul ST(0), ST(3)
	fld ten
	fmulp ST(4)
	fadd 
	dec si
	loop processreal
	mov si, 0
	mov cl, lgfract
	fld result
	fld ten
	fdivp ST(3), ST(0)
processfloat:
	mov bx, 0
	checknr fractpart[si]
	sub fractpart[si], 30h
	mov bl, fractpart[si]
	mov floatnumber, bx
	fild floatnumber
	fmul ST(0), ST(3)
	fld ten
	fdivp ST(4), ST(0)
	fadd
	inc si
	loop processfloat
	fadd
	ffree st(2)
	ffree st(1)
	retf
processnr endp
code ends
end processnr