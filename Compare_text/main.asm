.386
.model flat,stdcall
option casemap:none

;��ǰ���������inc��lib
include     windows.inc
include     gdi32.inc
includelib  gdi32.lib
include     user32.inc
includelib  user32.lib
include    kernel32.inc
includelib  kernel32.lib
includelib msvcrt.lib
include msvcrt.inc

DoMessage PROTO  :HWND,:UINT,:WPARAM,:LPARAM
printf	PROTO C:dword,:vararg
sprintf PROTO C:dword,:dword,:vararg

;---------------------------------------------------------------------------------
; ���ݶΣ�δ��ʼ���ı����� 
.data?
	hInstance dd ?
	hWinMain dd ?
	bResult dd ? ;���н��
	buffer1 db 1024 dup(?)
	buffer2 db 1024 dup(?)
	output_text db 1024 dup(?)
.data
	; ��¼����,���100��
	array dword 100 dup(0)
	array_row1 dword 100 dup(0)
	array_row2 dword 100 dup(0)
	len_row1 dword 1
	len_row2 dword 1
	row dword 1
	len1 dword 0
	len2 dword 0
.const
	szFmt1	byte	'buffer1: %s', 0ah, 0	;��������ʽ�ַ���
	szFmt2	byte	'buffer2: %s', 0ah, 0	;��������ʽ�ַ���
	szFmt3	byte	'len1: %d len2: %d', 0ah, 0	;��������ʽ�ַ���
	szFmt4	byte	'line %d is not matched',0dh,0ah,0	;��������ʽ�ַ���
	szFmt	byte	'end', 0ah, 0	;��������ʽ�ַ���
	szClassName db  'MyClass',0
	DlgName db "compare",0
	TextSame  byte '�ı�һ��',0ah, 0

	COMPARE   equ    3
	IDC_EDIT1          equ        1001
	IDC_EDIT2          equ        1002
	IDC_BUTTON1        equ        1003
	IDC_EDIT3          equ        1004

;---------------------------------------------------------------------------------
; �����
.code

;---------------------------------------------------------------------------------
;windows���ڳ������ں���
WinMain proc
        local   @stWndClass:WNDCLASSEX
        local   @stMsg:MSG
		local   @hDlg:HWND

        ;�õ���ǰ����ľ��
        invoke  GetModuleHandle,NULL
        mov hInstance,eax

        ;����ǰ���������ڴ�
        invoke  RtlZeroMemory,addr @stWndClass,sizeof @stWndClass

		 ;�õ����
        invoke  LoadCursor,0,IDC_ARROW
        mov @stWndClass.hCursor,eax  ;��eax��ȡ��������������õ���������
        push    hInstance
        pop @stWndClass.hInstance
        mov @stWndClass.cbSize,sizeof WNDCLASSEX
        mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW
        mov @stWndClass.lpfnWndProc,offset DoMessage
        mov @stWndClass.hbrBackground,COLOR_WINDOW + 1
        mov @stWndClass.lpszClassName,offset szClassName

        invoke  RegisterClassEx,addr @stWndClass ;ע�ᴰ����

		mov bResult,eax ;�õ�ע�ᴰ�ڽ��

        ;��ע�ᴰ�������ж�
        .if bResult==0
           invoke ExitProcess,NULL ;ע�ᴰ����ʧ�ܣ�ֱ���˳���ǰ��
		.endif
		; ��������ʾ����
		invoke CreateDialogParam,hInstance,COMPARE,NULL,addr DoMessage,NULL
        mov hWinMain,eax
        invoke  ShowWindow,hWinMain,SW_SHOWNORMAL
        invoke  UpdateWindow,hWinMain

        ; ��Ϣѭ��
        .while  TRUE
            invoke  GetMessage,addr @stMsg,NULL,0,0
            .if eax == 0
              .break
            .endif
            invoke  TranslateMessage,addr @stMsg
            invoke  DispatchMessage,addr @stMsg
        .endw
        ret

WinMain endp

; ��ȡȫ���к�
GetRow proc
	; ����buffer1
	mov esi, 0
	mov eax,len_row1
	mov dword ptr array_row1[4*eax], esi
	inc eax
	mov [len_row1],eax
	mov ebx, 0
L_buffer1:
	movzx eax, [buffer1+esi]
	.if eax == 0AH
		mov eax,len_row1
		mov dword ptr array_row1[4*eax], esi
		inc eax
		mov [len_row1],eax
	.endif
	inc esi
	cmp esi,len1
	jnz L_buffer1

	mov eax,len_row1
	dec esi
	mov dword ptr array_row1[4*eax], esi

	; ����buffer2
	mov esi, 0
	mov eax,len_row2
	mov dword ptr array_row2[4*eax], esi
	inc eax
	mov [len_row2],eax
	mov ebx, 0
L_buffer2:
	movzx eax, [buffer2+esi]
	.if eax == 0AH
		mov eax,len_row2
		mov dword ptr array_row2[4*eax], esi
		inc eax
		mov [len_row2],eax
	.endif
	inc esi
	cmp esi,len2
	jnz L_buffer2

	mov eax,len_row2
	dec esi
	mov dword ptr array_row2[4*eax], esi
	ret
GetRow endp

; �ȽϺ���
doCompare proc
	; invoke printf, offset szFmt1 , offset buffer1
	; invoke printf, offset szFmt2 , offset buffer2

	; ��ȡ���鳤��
	invoke crt_strlen, offset (buffer1)
	mov len1,eax
	invoke crt_strlen, offset (buffer2)
	mov len2,eax
	; invoke printf, offset szFmt3 ,len1,len2

	invoke GetRow  ; ��ȡ�к�

	mov esi, 0
	mov edi, 0
	mov ebx, 0

	mov eax,len_row1
	.if eax > len_row2
		jmp L1
	.else
		jmp L2
	.endif

L1:
	; ȡ����������
	movzx eax, [buffer1+edi]
	movzx edx, [buffer2+esi]
	cmp eax,edx
	jnz Diff1

	.if eax == 0ah
		mov eax, row
		inc eax
		mov [row],eax
	.elseif edx == 0ah
		mov eax, row
		inc eax
		mov [row],eax
	.endif
L11:
	inc esi
	inc edi
	.if edi < len1
		.if esi < len2
			jmp L1
		.endif
	.endif

	jmp Other1

L2:
	;ȡ����������
	movzx eax, [buffer1+edi]
	movzx edx, [buffer2+esi]
	cmp eax,edx
	jnz Diff2

	.if eax == 0ah
		mov eax, row
		inc eax
		mov [row],eax
	.elseif edx == 0ah
		mov eax, row
		inc eax
		mov [row],eax
	.endif
L22:
	inc esi
	inc edi
	.if edi < len1
		.if esi < len2
			jmp L2
		.endif
	.endif

	jmp Other2
	
Other1:
	.if edi == len1
		.if esi == len2
			jmp ENDER
		.else
			movzx eax, [buffer2+esi]
			.if eax == 0dh
				mov eax, row
				inc eax
				mov [row],eax
			.endif
			jmp Add2
		.endif
	.else
		movzx eax, [buffer1+edi]
		.if eax == 0dh
			mov eax, row
			inc eax
			mov [row],eax
		.endif
	.endif
Add1:
	mov eax, row
	mov dword ptr array[4*ebx], eax
	inc ebx
	inc eax
	mov [row],eax
	cmp eax,len_row1
	jnz Add1

	jmp ENDER

Other2:
	.if edi == len1
		.if esi == len2
			jmp ENDER
		.else
			movzx eax, [buffer2+esi]
			.if eax == 0dh
				mov eax, row
				inc eax
				mov [row],eax
			.endif
			jmp Add2
		.endif
	.else
		movzx eax, [buffer1+edi]
		.if eax == 0dh
			mov eax, row
			inc eax
			mov [row],eax
		.endif
	.endif

Add2:
	mov eax, row
	mov dword ptr array[4*ebx], eax
	inc ebx
	inc eax
	mov [row],eax
	cmp eax,len_row2
	jnz Add2

	jmp ENDER

Diff1:
	mov eax, row
	.if eax < len_row2
		mov dword ptr array[4*ebx], eax
		inc ebx
		inc eax
		mov edi, dword ptr array_row1[4*eax]
		mov esi, dword ptr array_row2[4*eax]
		mov [row],eax
		jmp L11
	.else
		jmp Other1
	.endif

Diff2:
	mov eax, row
	.if eax < len_row1
		mov dword ptr array[4*ebx], eax
		inc ebx
		inc eax
		mov edi, dword ptr array_row1[4*eax]
		mov esi, dword ptr array_row2[4*eax]
		mov [row],eax
		jmp L22
	.else
		jmp Other2
	.endif

ENDER:
	mov esi,0
	cmp ebx,0
	mov edi,offset output_text
    jnz Output

	invoke sprintf, offset output_text, offset TextSame
	invoke printf, offset TextSame
	ret

Output:
	invoke sprintf,edi, offset szFmt4, dword ptr array[4*esi]
	add edi,23
	invoke printf, offset szFmt4 ,dword ptr array[4*esi]
	inc esi
	cmp esi,ebx
	jnz Output
	ret

doCompare endp
;---------------------------------------------------------------------------------
; ����windows��Ϣ�Ĺ��̣�Windows�Ļص�����
DoMessage    proc    hWnd,uMsg,wParam,lParam
		local   @stPs:PAINTSTRUCT
        local   @stRect:RECT

        mov eax,uMsg
        .if eax ==  WM_CLOSE
            invoke  DestroyWindow,hWinMain
            invoke  PostQuitMessage,NULL
		.elseif eax == WM_COMMAND
			mov eax,wParam
			.if ax == IDC_BUTTON1
				; ��ȡ�ַ���
				invoke   GetDlgItemText,hWnd,IDC_EDIT1,addr buffer1,sizeof buffer1
				invoke   GetDlgItemText,hWnd,IDC_EDIT2,addr buffer2,sizeof buffer2

				mov eax,1
				mov [len_row1],eax
				mov [len_row2],eax
				mov [row],eax
				mov eax,0
				mov [len1],eax
				mov [len2],eax

				invoke doCompare

				invoke   SetDlgItemText,hWnd,IDC_EDIT3,offset output_text
			.endif
		.else
            invoke  DefWindowProc,hWnd,uMsg,wParam,lParam
            ret
        .endif

        xor eax,eax
        ret

DoMessage endp


;---------------------------------------------------------------------------------
;������ڵ㣬����WinMain����
main proc
	call WinMain
    invoke ExitProcess,NULL	
main endp
end main