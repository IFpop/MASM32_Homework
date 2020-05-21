; 多重for循环
; 为了减少寄存器的使用，用栈进行操作

.386
.model flat,stdcall
option casemap:none

; 调用库函数
includelib msvcrt.lib
include msvcrt.inc

; 输出进行定义
printf	PROTO C:dword,:vararg

; 数据段
.data
array dword 10 dup(0)
len dword 10
szFmt	byte	'array[%d] = %d', 0ah, 0	;输出结果格式字符串
i dword 0
j dword 0
k dword 0
; 代码块
.code 
Loopfunc proc
	mov ecx,len
	mov esi,0

firstloop:
	; 取出 array[i]
	mov eax, array[esi*4] 
	mov i,esi
	; 将二者压栈方便重复使用
	push ecx
	push esi
	mov ecx,len
	mov esi,0

secondloop:
	mov j,esi
	push ecx
	push esi
	mov ecx,len
	mov esi,0

thirdloop:
	mov k,esi
	push ecx
	push esi
	mov ecx,len
	mov esi,0

lastloop:
	add eax,esi
	add eax,i;
	add eax,j;
	add eax,k;
	inc esi
	loop lastloop
	
	; 顺序不可改变，栈的规则
	pop esi
	pop ecx
	inc esi
	loop thirdloop

	pop esi
	pop ecx
	inc esi
	loop secondloop

	pop esi
	pop ecx
	mov array[esi*4],eax
	inc esi

	loop firstloop
	ret
Loopfunc endp

output proc
	invoke	printf, offset szFmt, edi, array[edi * 4]
	inc		edi
	cmp		edi, len
	JB		output
	ret
output endp

main proc
	; 调用循环函数
	invoke Loopfunc
	;输出结果
	mov esi,0
	xor edi,edi
	invoke output
	ret
main endp
end main