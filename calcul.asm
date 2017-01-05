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
	float dd 3.45678
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
	fld float
	fwait
	mov	AX, 0004h
	;int 10h
	;mov	AX, 0C03h
	;xor	BX, BX
	;mov	CX, 0064h	; 50 in hex
	;mov	DX, 0064h	; 100 in hex
	int 10h
	mov bx, 0h
	mov si, 0	
	mov value2, lgtext1
	
write1: ; write the first string (and so on)
	mov dl, text1[si]
	mov ah, 2
	int 21h
	add si, 1
	cmp si, value2
	jl write1

	mov dl, 10 ;new line
	mov ah, 2
	int 21h	
	mov si, 0
	mov value2, lgtext2
	
write2: 
	mov dl, text2[si]
	mov ah, 2
	int 21h
	add si, 1
	cmp si, value2
	jl write2
	
	mov dl, 10 ;new line
	mov ah, 2
	int 21h	
	mov si, 0
	mov value2, lgtext3
	
write3: 
	mov dl, text3[si]
	mov ah, 2
	int 21h
	add si, 1
	cmp si, value2
	jl write3
	
	mov dl, 10 ;new line
	mov ah, 2
	int 21h	
	mov si, 0
	mov value2, lgtext4
	
write4: 
	mov dl, text4[si]
	mov ah, 2
	int 21h
	add si, 1
	cmp si, value2
	jl write4
	
	mov dl, 10 ;new line
	mov ah, 2
	int 21h	
	mov si, 0
	mov value2, lgtext5
	
write5: 
	mov dl, text5[si]
	mov ah, 2
	int 21h
	add si, 1
	cmp si, value2
	jl write5
	
	mov dl, 10 ;new line
	mov ah, 2
	int 21h	
	mov si, 0
	mov value2, lgtext6
	
write6: 
	mov dl, text6[si]
	mov ah, 2
	int 21h
	add si, 1
	cmp si, value2
	jl write6
	
	mov dl, 10 ;new line
	mov ah, 2
	int 21h	
	
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
	jne delay5
	
	
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
	
	ret
	
start endp
code ends
end start