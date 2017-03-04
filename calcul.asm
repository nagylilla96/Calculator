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
	divbyzerotxt db "Division by zero"
	lgdivbyzero equ $-divbyzerotxt
	ui1 db 2 ;;menu option number
	value dw 0 ;;used for delay
	value1 dw 0 ;;used for delay
	float db 15 dup(?) ;; the array used for the initial array of characters
	lgfloat dw 0 
	number dw 1
	negat db 0 ;; 1 if nr is negative
	real db 0 ;; 1 if nr has floating point
	realpart db 15 dup(?) ;; real part of the number
	lgreal dw 0
	fractpart db 15 dup(?) ;; fract part of the number
	answerreal db 10 dup(?) ;;real part of the answer
	lganswerreal dw 0
	answerfract db 5 dup(?) ;; fract part of the answer
	finalanswer db 15 dup(?) ;; the final answer
	newanswerreal db 10 dup(?)
	lgnewanswer dw 0
	lgfinalanswer dw 0
	lganswerfract dw 0
	lgfract dw 0
	floatnumber dw 0
	one dd 1.0
	ten dd 10.0
	result dd 0.0
	zero dd 0.0
	addi db 0 ;; these variables have 1 as value when the specified operation is selected 
	subt db 0
	mult db 0
	divi db 0
	squa db 0
	squar db 0
	ezer dw 1000
	szaz dw 100
	tiz dw 10
	dividend dd 1.0
	iterator db 1
	placeholder dd 0
	anotherfloat dw 0
	oldcw dw ?
	lgminusone dw ?
data ends

extrn newline:far
extrn delay:far
code segment para public 'code'
	
start proc far
assume cs:code, ds:data
	PUSH DS
	XOR AX,AX
	PUSH AX
	MOV AX, DATA
	MOV DS, AX
	finit 
	fstcw oldcw ;here i tried to load a control word to change the rounding method but i failed
	fwait
	mov ax, oldcw
	or oldcw, 0c00h
	;push ax
	fldcw oldcw
	mov	AX, 0004h
	int 10h
	;;printing the menu
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
	;;read the selected menu number
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
	;;check operation, if nr not ok, error shown
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
	;;specify operation
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
	;;print error message
error: 
	call newline
	write errortxt, lgerror	
	jmp delaay
	
compare:
	;;clear arrays completely (after first number was read)
	emptyarr float, lgfloat	
	emptyarr realpart, lgreal
	emptyarr fractpart, lgfract
	mov lgfloat, 0
	mov lgreal, 0
	mov lgfract, 0
	call newline
	mov si, 0
	cmp addi, 1
	je incadd
	jne skip
incadd:
	inc addi
	jmp startread
	;;increase the variable of operation, so next time it won't read another number
skip:
	cmp subt, 1
	je incsub
	jne skip1
incsub:
	inc subt
	jmp startread
skip1:
	cmp divi, 1
	je incdiv
	jne skip2
incdiv:
	inc divi
	jmp startread

skip2:
	cmp mult, 1
	je incmult
	jne startread
incmult:
	inc mult
	jmp startread
laberror:
	jmp error
startread:
	cmp lgfloat, 0
	call newline
	mov si, 0		
	;;read and process a float
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
	jg laberror
	cmp al, 13 ;; carriage return checked again
	jne readfloat		
workfloat:
	cmp float[0], 2Dh ;; if '-' char appears, number is negative, otherwise positive
	je negative
	jne positive		
isinteger:
	mov si, 0
	mov di, 0
finddot: 
	cmp float[si], 2Eh ;; if point is found, the number is real, not integer
	je isreal
	cmp negat, 1 ;;if number is negative, don't process '-' further on as part of the number
	je deleteminus
contfind:
	mov cl, float[si]
	mov realpart[di], cl	;;if nr is real, put the real part into realpart from float
	inc lgreal	
contdot:
	inc si
	inc di
	cmp si, lgfloat ;; while si is smaller than length of float
	jg isnotreal ;;if no dot found, not real
	jng finddot
isreal:
	mov real, 1 ;;else is real
	mov di, 0
	inc si
fractloop:
	mov cl, float[si] ;;we put fract part in fractpart from float and increase its length
	cmp si, lgfloat ;; check if si smaller than lgfloat (if not, number reading is done)
	jge contttt ;;changed from jg
	mov fractpart[di], cl
	inc lgfract	
	inc si
	inc di
	jmp fractloop
	jmp contttt	
deleteminus:	;;increase si, so minus is not processed further on
	cmp di, 0
	jne contfind
	mov di, si	
	inc si	
	jmp contfind
isnotreal:
	mov real, 0
	mov fractpart[0], 30h ;; we need this, othewise: divide by zero
	mov lgfract, 1
	jmp contttt	
negative:
	mov negat, 1
	jmp isinteger
positive:
	mov negat, 0
	jmp	isinteger
contttt:
	cmp real, 0 ;;if not real, decrease its length
	jne continue
	dec lgreal
continue:
	mov cx, 0
	jmp processnr
	
label2:
	jmp compare
	;;process number
processnr:
	mov cx, lgreal
	mov si, cx
	dec si
	fld one ;;push one to stack, process real part
	fld one
	fld result
	processreal realpart
	jmp nextlabel
error1: ;;if error is met, print error message
	call newline
	write errortxt, lgerror
	jmp delaay
label1:
	jmp label2
nextlabel:
	mov si, 0 ;; process float
	mov cx, lgfract
	fld result
	fld ten
	fdivp ST(3), ST(0)
	processfloat fractpart
contproc:
	fadd ;;add real part to fract part
	jmp beforedelay
label0:
	jmp label1
	
beforedelay:
	cmp negat, 1
	je invert
	jne noinvert
invert:
	fchs ;;if number is negative, invert it
noinvert:
	ffree st(2)
	ffree st(1)
	;;checks operation
	cmp addi, 1
	je label0
	cmp subt, 1
	je label0
	cmp mult, 1
	je label0
	cmp divi, 1
	je label0
	fld st(3)
	ffree st(4)
	cmp addi, 2
	je resultadd
	cmp subt, 2
	je resultsub
	cmp mult, 2
	je resultmul
	cmp divi, 2
	je resultdiv
	cmp squa, 1
	je resultsqu
	cmp squar, 1
	je resultsqr

resultadd:
	fadd ;;add the two numbers
	jmp reconvert
resultsub:
	fld st(1)
	ffree st(2)
	fsub ;;fubtract the two numbers
	jmp reconvert
resultmul:
	fmul ;;multiply the two numbers
	jmp reconvert
resultdiv:
	fld st(1)
	ffree st(2)	
	fdiv	;;fivide the two numbers
	jmp reconvert
resultsqu:	
	fld st(1)
	ffree st(2)
	fld st(0)
	fmul ;; multiply the number with itself
	jmp reconvert
resultsqr:
	fld st(1)
	ffree st(2)
	fsqrt ;; squareroot of the number
	jmp reconvert	
divbyzero: ;;if divide by zero, print error message
	call newline
	write divbyzerotxt, lgdivbyzero	
	;;reconvert from fpu to string
reconvert:
	fld st(0)
	fld st(0)
	fabs ;;modulo of number
	fdiv ;;divide then
	frndint
	fistp floatnumber
	cmp floatnumber, 0FFFFh ;; if 0FFFFh, it means it's -1, so negative
	je negres
	jne posres
negres:
	mov negat, 1
	fchs ;; invert it
	jmp cont
posres:
	mov negat, 0 ;;otherwise, it's positive
cont:
	fld ten
	fld ten
	mov lganswerreal, 0
	realproc ;;process the real number (it's inverted)
afterreal:
	mov lganswerreal, si
	mov si, lganswerfract
	mov cx, 5
	fld st(3)
	ffree st(4)
	ffree st(3)
	ffree st(2)
	ffree st(1)
	fld ten
	mov lganswerfract, 0
	fractproc ;;process fract number (it's in good order)
afterfract:
	mov lganswerfract, si
	cmp si, 0
	je aftercont
	dec si
	inc answerfract[si]
aftercont:	
	mov di, lganswerreal
	dec di
	mov si, lganswerreal
	mov cx, lganswerreal
	mov si, 0
	mov lgnewanswer, 0
	invreal ;;invert real number (and also do decrease operation to correct round errors)
	mov bx, lganswerreal
	mov lgnewanswer, bx
	mov cx, lgnewanswer
	mov si, 0
	mov di, 0
	cmp newanswerreal[0], 0
	jne afterskip
skipfirst:
	mov si, 1
afterskip:
	cmp negat, 1
	je addminus
	jne concatreal1
addminus:
	mov finalanswer[di], '-' ;; add minus if number is negative
	inc di
	inc lgfinalanswer
concatreal1:
	cmp lgnewanswer, 0
	je skipreal
	mov cx, lganswerreal
	catreal ;; add real to finalanswer
	jmp skipskip
skipreal:
	mov bl, 0
	mov finalanswer[di],bl
skipskip:
	mov si, 0
	cmp lganswerfract, 0
	je skippoint
	mov finalanswer[di], '.'
	inc di
	inc lgfinalanswer
	mov cx, lganswerfract
	catfract ;; add fract to final answer
	mov cx, lgfinalanswer
	mov si, cx
	dec si
	mov lgminusone, si
loopfinal:
;	cmp si, lgminusone
;	jne notlastcompare
;lastcompare:
;	cmp finalanswer[si], 36h
;	jge decrease1
;	jnge nodecrease1
;notlastcompare:
;	cmp finalanswer[si], 35h
;	jnge nodecrease1
;decrease1:
;	dec finalanswer[si - 1]
;nodecrease1:
	cmp si, 0
	jne isnotfirst
	cmp finalanswer[si], 30h
	jne isnotfirst
	mov finalanswer[si], 0
isnotfirst:
	dec si
	loop loopfinal
skippoint:
	call newline
	write finalanswer, lgfinalanswer ;;print final answer
	
	mov cx, value
	mov dx, value1
	
delaay:
	call delay	
	fwait	
	ret
	
start endp
code ends
end start