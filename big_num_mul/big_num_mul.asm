; 大数乘法
; 实现思路：采用两个数组将字符存储起来，然后逐字相乘进位

.386
.model flat,stdcall
option casemap:none

; 调用库函数
includelib msvcrt.lib
include msvcrt.inc

; 输入输出进行定义
scanf	PROTO C :ptr sbyte, :vararg
printf	PROTO C :ptr sbyte, :vararg

; 数据段
.data

; 使用CHAR型数组A/B,且全部初始化，按题目要求100以上
CharA byte 110 dup(0)
CharB byte 110 dup(0)
; 同样的CHAR数组C存储结果
CharC byte 220 dup(0)

; 整型数字
NumA dword 110 dup(0)
NumB dword 110 dup(0)
NumC dword 220 dup(0)

; 输入的格式
InputAFmt byte "please input a A: ",0
InputBFmt byte "please input a B: ",0
SzFmt    byte "%s",0

; 输出格式
OutputFmt byte "the ans is %s",0ah,0
OutputFmt2 byte "the ans is -%s",0ah,0

; 记录三个数组的长度
LenA dword 0
LenB dword 0
LenC dword 0
NumDiv dword 10

; 设置符号位，0 → 正 ， 1 → 负
flag dword 0
negativetag byte "-"

; 代码块
.code 
; 将char转换为int，并使用栈进行反转
Char2Int_reverse proc stdcall numChar:ptr byte, numInt:ptr dword, len:dword
	; 循环字数
	mov ecx,len
	mov esi,numChar
L1:
	; 获取第一位，高0扩展
	movzx eax,byte ptr [esi]
	; 获取数值，30H是'0'
	sub eax, 30H
	; 数值入栈
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

; 预处理部分，获取数组长度，以及获取符号,最后将字符串转换为数字
pretreatment proc
	; 对于A
	.if CharA == 2DH ; 判断首位是否为'-'
		xor flag,1
		invoke crt_strlen, offset (CharA+1)
		mov LenA,eax
		invoke Char2Int_reverse, offset (CharA + 1), offset NumA, LenA
	.else
		invoke crt_strlen, offset CharA
		mov LenA,eax
		invoke Char2Int_reverse, offset CharA, offset NumA, LenA
	.endif

	; 对于B
	.if CharB == 2DH ; 判断首位是否为'-'
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
; 两层for循环，对结果C中采用这样的加法
;c[i + j] = c[i + j] + a[i] * b[j]

	mov ebx,-1  
; 外层循环
L1:
	inc ebx
	cmp ebx,LenA
	jnb endL1 ; 遍历完，就结束循环
	xor ecx,ecx ;将ecx重置为0,作为B的下标
; 内层循环
L2:
	xor edx,edx
	; 取出A中第一个数
	mov eax, dword ptr NumA[4*ebx]
	; 取出第二个数
	mov edx, dword ptr NumB[4*ecx]
	; a[i] * b[j]
	mul edx
	; 计算C的下标  i+j
	mov esi,ebx
	add esi,ecx
	add NumC[4*esi],eax
	; 调试查看信息
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
	; 给LenC赋值
	mov [esi],ecx 

	; 现在需要去除前导0
	mov ecx,LenC
moveZero:
	 cmp dword ptr NumC[4 * ecx], 0
	 ; 如果末尾不为0，则直接退出
	 jnz endAll
	 dec ecx
	 jmp moveZero

endAll:
	;求出实际长度，并退出
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
	; 键盘输入A,B
	invoke printf, offset InputAFmt
	invoke scanf, offset SzFmt,offset CharA
	invoke printf, offset InputBFmt
	invoke scanf, offset SzFmt,offset CharB

	; 进行预处理
	invoke pretreatment  

	; 调用大数乘法
	invoke big_num_mul

	; 重新倒置字符，以字符串的形式输出
	invoke output_ans

	ret
main endp
end main