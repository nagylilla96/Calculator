code segment para 'code'
public newline
	assume cs:code
	newline proc far
	mov dl, 10 ;new line
	mov ah, 2
	int 21h	
	retf
newline endp
code ends
end newline