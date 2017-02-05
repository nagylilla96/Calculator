if 1 
	include MACROS.MAC
endif

data segment para public 'data'
	text1 db "1. Addition"
	lgtext1 equ $-text1
	text2 db "2. Subtraction"
	lgtext2 equ $-text2
	text3 db "3. Multiplication"
	lgtext3 equ $-text3
	text4 db "4. Division"
	lgtext4 equ $-text4
	text5 db "5. Square"
	lgtext5 equ $-text5
	text6 db "6. Squareroot"
	lgtext6 equ $-text6
	errortxt db "The introduced number is not correct"
	lgerror equ $-errortxt
	ui1 db 2
	value dw 0
	value1 dw 0	
	value2 dw 0
	float db 15 dup(?)
	lgfloat dw 0
	number dw 1
	negat db 0
	real db 0
	realpart db 15 dup(?)
	fractpart db 15 dup(?)
	basenumber dw 0
	i dw 0
data ends

code segment para public 'code'
	
start proc far
assume cs:code, ds:data
	PUSH DS
	XOR AX,AX
	PUSH AX
	MOV AX, DATA
	MOV DS, AX
	finit 
	mov	AX, 0004h
	;int 10h
	;mov	AX, 0C03h
	;xor	BX, BX
	;mov	CX, 0064h	; 50 in hex
	;mov	DX, 0064h	; 100 in hex
	int 10h

	write text1, lgtext1
	call newline
	write text2, lgtext2
	call newline
	write text3, lgtext3
	call newline
	write text4, lgtext4
	call newline
	write text5, lgtext5
	call newline
	write text6, lgtext6
	call newline
	mov si, 0
	
read:
	mov ah, 7
	int 21h
	mov dl, al
	mov ah,2
	int 21h
	mov ui1[si], al
	cmp si, 1
	je condition
	inc si
	cmp si, 2
	jl read
	
condition:
	cmp al, 13
	je check1
	jne error
	
check1:
	cmp ui1[0], 31h
	je addition
	jne readfloat
	
	
error: 
	mov dl, 10 ;new line
	mov ah, 2
	int 21h	
	mov si, 0
	mov value2, lgerror	
errorloop:
	mov dl, errortxt[si]
	mov ah, 2
	int 21h
	add si, 1
	cmp si, value2
	jl errorloop
	
addition:
	nop
	
	mov dl, 10 ;new line
	mov ah, 2
	int 21h	
	mov si, 0	
	
readfloat:
	mov ah, 7
	int 21h
	mov dl, al
	mov ah,2
	int 21h
	cmp al, 13
	je workfloat ;if a carriage return appears, we want to work with the float	
	mov float[si], al	
	inc si
	inc lgfloat
	cmp si, 15 ;if the input is bigger than 15 characters, it gives the error of incorrect number
	jg error
	cmp al, 13
	jne readfloat	
	
	;fld
	
workfloat:
	cmp float[0], 2Dh
	je negative
	jne positive
	
	
isinteger:
	mov si, 0
	mov di, 0
finddot: 
	cmp float[si], 2Eh
	je isreal
	cmp si, 0
	je deleteminus	
	mov cl, float[si]
	mov realpart[di], cl	
	mov di, si
	
contdot:
	inc si
	cmp si, lgfloat
	jg isnotreal
	jng finddot
isreal:
	mov real, 1
	mov di, 0
	inc si
fractloop:
	mov cl, float[si]
	mov fractpart[di], cl
	cmp si, lgfloat
	je delay5
	inc si
	inc di
	jmp fractloop
	jmp delay5
	
deleteminus:
	mov di, si
	cmp negat, 1
	je changesi
	jmp contdot	
	inc si
changesi:	
	jmp contdot
	
isnotreal:
	mov real, 0
	
negative:
	mov negat, 1
	jmp isinteger
positive:
	mov negat, 0
	jmp	isinteger
	
delay5:
	nop
	inc value
	mov value1, 0
moredelay1: 
	nop
	inc value1
	cmp value1, 2500
	jl moredelay1
	cmp value, 2500
	jl delay5
	
	fwait
	
	ret
	
start endp
code ends
end start