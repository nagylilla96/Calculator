if 1 
	include MACROS.MAC
endif

;;TODO comment it!!!
;;TODO check why it enters an infinite loop when you enter / instead of . -- done 
;;TODO add some response when user enters a number because it's not obvious! (ex: add operation chosen or smth like that)

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
	ui1 db 2 ;;menu option number
	value dw 0 ;;used for delay
	value1 dw 0 ;;used for delay
	float db 15 dup(?)
	lgfloat dw 0
	number dw 1
	negat db 0
	real db 0
	realpart db 15 dup(?)
	lgreal db 0
	fractpart db 15 dup(?)
	lgfract db 0
	floatnumber dw 0
	one dd 1.0
	ten dd 10.0
	result dd 0
	addi db 0
	subt db 0
	mult db 0
	divi db 0
	squa db 0
	squar db 0
data ends

extrn newline:far
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
	jne labelerror
	
check1:
	cmp ui1[0], 31h
	je addition
	cmp ui1[0], 32h
	je subtraction
	cmp ui1[0], 33h
	je multiplication
	cmp ui1[0], 34h
	je todiv	
	cmp ui1[0], 35h
	je tosquare
	cmp ui1[0], 36h
	je tosquareroot
labelerror:
	jmp error

todiv:
	jmp division
tosquare:
	jmp square
tosquareroot:
	jmp squareroot
addition:
	mov addi, 1
	write text1, lgtext1
	jmp startread
subtraction:
	mov subt, 1
	write text2, lgtext2
	jmp startread
multiplication:
	mov mult, 1
	write text3, lgtext3
	jmp startread
division:
	mov divi, 1
	write text4, lgtext4
	jmp startread
square:
	mov squa, 1
	write text5, lgtext5
	jmp startread
squareroot:
	mov squar, 1
	write text6, lgtext6
	jmp startread
	
error: 
	call newline
	write errortxt, lgerror	
	jmp delay5
	
startread:
	call newline
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
	cmp si, 10 ;if the input is bigger than 10 characters (max unsigned nr repr. on 32 bits is  4,294,967,295), it gives the error of incorrect number
	jg error
	cmp al, 13
	jne readfloat		
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
	cmp negat, 1
	je deleteminus
contfind:
	mov cl, float[si]
	mov realpart[di], cl	
	inc lgreal	
contdot:
	inc si
	inc di
	cmp si, lgfloat
	jg isnotreal
	jng finddot
isreal:
	mov real, 1
	mov di, 0
	inc si
fractloop:
	mov cl, float[si]
	cmp si, lgfloat
	je processnr
	mov fractpart[di], cl
	inc lgfract	
	inc si
	inc di
	jmp fractloop
	jmp processnr	
deleteminus:	
	cmp di, 0
	jne contfind
	mov di, si	
	inc si	
	jmp contfind
isnotreal:
	dec lgreal
	mov real, 0
	mov fractpart[0], 30h ;; we need this, othewise: divide by zero
	mov lgfract, 1
	jmp processnr	
negative:
	mov negat, 1
	jmp isinteger
positive:
	mov negat, 0
	jmp	isinteger
	
	cmp negat,1
	je decrease
	jne nodecrease
decrease:
	dec lgreal
nodecrease:
	finit
	mov cx, 0
	
processnr:
	mov cl, lgreal
	mov si, cx
	dec si
	fld one
	fld one
	fld result
	processreal realpart
	jmp nextlabel
error1:
	call newline
	write errortxt, lgerror
	jmp delay5
nextlabel:
	mov si, 0
	mov cl, lgfract
	fld result
	fld ten
	fdivp ST(3), ST(0)
	processfloat fractpart
contproc:
	fadd
	
beforedelay:
	cmp negat, 1
	je invert
	jne noinvert
invert:
	fchs
noinvert:
	ffree st(2)
	ffree st(1)
	fld st(0)
	frndint
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
	
	;fwait
	
	ret
	
start endp
code ends
end start