data segment para public 'data'
	value dw 0
	value1 dw 0	
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
	mov	AX, 0013h
	int 10h
	mov	AX, 0C03h
	xor	BX, BX
	mov	CX, 0064h	; 50 in hex
	mov	DX, 0064h	; 100 in hex
	int 10h
	mov bx, 0h
	
columnloop1:
	mov cx, 64h
	int 10h
	mov bl, 0
lineloop1:
	int	10h
	inc bl
	mov value, 0
delay1:
	nop
	inc value
	cmp value, 1000
	jl delay1
	inc cx
	cmp bl, 50
	JL	lineloop1
	inc bh	
	inc dx
	cmp bh, 50
	jl columnloop1
	
	mov	AX, 0C02h
	xor	BX, BX
	mov	CX, 30	; 50 in hex
	mov	DX, 30	; 100 in hex
	int 10h
	mov bx, 0h
	
columnloop2:
	mov cx, 30
	int 10h
	mov bl, 0
lineloop2:
	int	10h
	inc bl 
	mov value, 0
delay2:
	nop
	inc value
	cmp value, 1000
	jl delay2
	inc cx
	cmp bl, 50
	JL	lineloop2
	inc bh
	
	inc dx
	cmp bh, 50
	jl columnloop2
	
	mov	AX, 0C01h
	xor	BX, BX
	mov	CX, 200	; 50 in hex
	mov	DX, 70	; 100 in hex
	int 10h
	mov bx, 0h
	
columnloop3:
	mov cx, 200
	int 10h
	mov bl, 0
lineloop3:
	int	10h
	inc bl
	mov value, 0
delay3:
	nop
	inc value
	cmp value, 1000
	jl delay3
	inc cx
	cmp bl, 50
	JL	lineloop3
	inc bh
	inc dx
	cmp bh, 50
	jl columnloop3	
	
	mov value, 0
	
delay4:
	nop
	inc value
	mov value1, 0
moredelay: 
	nop
	inc value1
	cmp value1, 2500
	jl moredelay
	cmp value, 1000
	jl delay4
	
	mov value, 0

read:
	mov ah, 7
	int 21h
	mov dl, al
	mov ah,2
	int 21h
	inc i
	cmp i, 20
	jl read
	
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