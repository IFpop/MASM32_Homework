; ����forѭ��
; Ϊ�˼��ټĴ�����ʹ�ã���ջ���в���

.386
.model flat,stdcall
option casemap:none

; ���ÿ⺯��
includelib msvcrt.lib
include msvcrt.inc

; ������ж���
printf	PROTO C:dword,:vararg

; ���ݶ�
.data
array dword 10 dup(0)
len dword 10
szFmt	byte	'array[%d] = %d', 0ah, 0	;��������ʽ�ַ���
i dword 0
j dword 0
k dword 0
; �����
.code 
Loopfunc proc
	mov ecx,len
	mov esi,0

firstloop:
	; ȡ�� array[i]
	mov eax, array[esi*4] 
	mov i,esi
	; ������ѹջ�����ظ�ʹ��
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
	
	; ˳�򲻿ɸı䣬ջ�Ĺ���
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
	; ����ѭ������
	invoke Loopfunc
	;������
	mov esi,0
	xor edi,edi
	invoke output
	ret
main endp
end main