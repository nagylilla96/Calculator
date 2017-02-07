code segment para 'code'
public delay
	assume cs:code
	delay proc far
delay5:
	nop
	inc cx
	mov dx, 0
moredelay1: 
	nop
	inc dx
	cmp dx, 2500
	jl moredelay1
	cmp cx, 2500
	jl delay5	
	retf
delay endp
code ends
end delay