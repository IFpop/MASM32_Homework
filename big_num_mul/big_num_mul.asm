; �����˷�
; ʵ��˼·�������������齫�ַ��洢������Ȼ��������˽�λ

.386
.model flat,stdcall
option casemap:none

; ���ÿ⺯��
includelib msvcrt.lib
include msvcrt.inc

; ����������ж���
scanf	PROTO C :ptr sbyte, :vararg
printf	PROTO C :ptr sbyte, :vararg

; ���ݶ�
.data

; ʹ��CHAR������A/B,��ȫ����ʼ��������ĿҪ��100����
CharA byte 110 dup(0)
CharB byte 110 dup(0)
; ͬ����CHAR����C�洢���
CharC byte 220 dup(0)

; ��������
NumA dword 110 dup(0)
NumB dword 110 dup(0)
NumC dword 220 dup(0)

; ����ĸ�ʽ
InputAFmt byte "please input a A: ",0
InputBFmt byte "please input a B: ",0
SzFmt    byte "%s",0

; �����ʽ
OutputFmt byte "the ans is %s",0ah,0
OutputFmt2 byte "the ans is -%s",0ah,0

; ��¼��������ĳ���
LenA dword 0
LenB dword 0
LenC dword 0
NumDiv dword 10

; ���÷���λ��0 �� �� �� 1 �� ��
flag dword 0
negativetag byte "-"

; �����
.code 
; ��charת��Ϊint����ʹ��ջ���з�ת
Char2Int_reverse proc stdcall numChar:ptr byte, numInt:ptr dword, len:dword
	; ѭ������
	mov ecx,len
	mov esi,numChar
L1:
	; ��ȡ��һλ����0��չ
	movzx eax,byte ptr [esi]
	; ��ȡ��ֵ��30H��'0'
	sub eax, 30H
	; ��ֵ��ջ
	push eax
	; esi++
	inc esi
	loop L1

	mov ecx,len
	mov esi,numInt

L2:
	pop eax
	mov dword ptr [esi],eax
	add esi,4
	loop L2
	
	ret
Char2Int_reverse endp

; Ԥ�����֣���ȡ���鳤�ȣ��Լ���ȡ����,����ַ���ת��Ϊ����
pretreatment proc
	; ����A
	.if CharA == 2DH ; �ж���λ�Ƿ�Ϊ'-'
		xor flag,1
		invoke crt_strlen, offset (CharA+1)
		mov LenA,eax
		invoke Char2Int_reverse, offset (CharA + 1), offset NumA, LenA
	.else
		invoke crt_strlen, offset CharA
		mov LenA,eax
		invoke Char2Int_reverse, offset CharA, offset NumA, LenA
	.endif

	; ����B
	.if CharB == 2DH ; �ж���λ�Ƿ�Ϊ'-'
		xor flag,1
		invoke crt_strlen, offset (CharB+1)
		mov LenB,eax
		invoke Char2Int_reverse, offset (CharB + 1), offset NumB, LenB
	.else
		invoke crt_strlen, offset CharB
		mov LenB,eax
		invoke Char2Int_reverse, offset CharB, offset NumB, LenB
	.endif
	ret
pretreatment endp

big_num_mul proc
; ����forѭ�����Խ��C�в��������ļӷ�
;c[i + j] = c[i + j] + a[i] * b[j]

	mov ebx,-1  
; ���ѭ��
L1:
	inc ebx
	cmp ebx,LenA
	jnb endL1 ; �����꣬�ͽ���ѭ��
	xor ecx,ecx ;��ecx����Ϊ0,��ΪB���±�
; �ڲ�ѭ��
L2:
	xor edx,edx
	; ȡ��A�е�һ����
	mov eax, dword ptr NumA[4*ebx]
	; ȡ���ڶ�����
	mov edx, dword ptr NumB[4*ecx]
	; a[i] * b[j]
	mul edx
	; ����C���±�  i+j
	mov esi,ebx
	add esi,ecx
	add NumC[4*esi],eax
	; ���Բ鿴��Ϣ
	mov eax, NumC[4*esi]
	.if eax > 9
		xor edx,edx
		div NumDiv
		add NumC[4*esi+4],eax
		mov NumC[4*esi],edx
	.endif
	mov edx,NumC[4*esi]
	inc ecx
	cmp ecx,LenB
	jnb L1
	jmp L2
endL1:
	mov ecx,LenA
	add ecx,LenB
	inc ecx  ; LenA+LenB+1
	mov esi,offset LenC
	; ��LenC��ֵ
	mov [esi],ecx 

	; ������Ҫȥ��ǰ��0
	mov ecx,LenC
moveZero:
	 cmp dword ptr NumC[4 * ecx], 0
	 ; ���ĩβ��Ϊ0����ֱ���˳�
	 jnz endAll
	 dec ecx
	 jmp moveZero

endAll:
	;���ʵ�ʳ��ȣ����˳�
	inc ecx
	mov esi, offset LenC
	mov [esi], ecx

	ret
big_num_mul endp

output_ans proc
	mov ecx,LenC
	mov esi,0
L1:
	mov eax, dword ptr NumC[4 * esi] 
	add eax, 30H ;
	push eax
	inc esi
	loop L1

	mov ecx, LenC
	mov esi, 0
L2:
	pop eax
	mov byte ptr CharC[esi],al
	inc esi
	loop L2

	.if flag == 1
		invoke printf, offset OutputFmt2 , offset CharC
	.else
		invoke printf, offset OutputFmt, offset CharC
	.endif
	ret
output_ans endp

main proc
	; ��������A,B
	invoke printf, offset InputAFmt
	invoke scanf, offset SzFmt,offset CharA
	invoke printf, offset InputBFmt
	invoke scanf, offset SzFmt,offset CharB

	; ����Ԥ����
	invoke pretreatment  

	; ���ô����˷�
	invoke big_num_mul

	; ���µ����ַ������ַ�������ʽ���
	invoke output_ans

	ret
main endp
end main