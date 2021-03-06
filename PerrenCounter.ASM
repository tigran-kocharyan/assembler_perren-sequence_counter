; ������� ������, ���199, ������� 10.
; ����������� ���������, ������������ ����� ����� �������
; �� 1 �� ������������ ��������� �����.

format PE console
entry start

include 'include\win32a.inc'

;--------------------------------------------------------------------------
; ������ .data � ������������ �����������.
;--------------------------------------------------------------------------
section '.data' data readable writable
;       �������� ����������, ������� ����� ������������ � ����������.
        strInputMaximum       db 'Input the maximum number >= 1: ', 0
        strIncorrectMaximum   db 'Incorrect maximum value = %u. Should be a number > 0', 10, 0
        strCheck              db 'Current maximum = %u', 10, 0
        strFinish             db 'Calculations finished. The amount of Perrin Numbers smaller than %u is %u', 0
        strOverflowFinish     db 'Overflow happened. The amount of Perrin Numbers smaller than %u is %u', 0
        strScanMax            db '%u', 0

;       �������� ������� �� 4 ���������, ��� �������� ������������������ ����� �������
        arrayNumbers          rd 4
        maxNumber             dd ?
        currentCount          dd 1

;--------------------------------------------------------------------------
; ������ .code ��� ������ ��������� ��������.
;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) ��������� ����������� ������������ ������ ������������ ����� �� 1 �� (2^32)-1
        call MaximumInput
; 2) ����� ��������� ��������� ������ ��������������� ���������� 3 2 5 5. ���� ��������� maxNumber <= 6,
; �� ������������ ������� �����.
        call FillInitialCheck
; 3) ��������� ��������� ��������� �� ��� ���, ���� arrayNumbers[3] <= maxNumber.
        call IteratePerrins

;--------------------------------------------------------------------------
; ������ ����� ������� ������� �������� - DD �����.
;--------------------------------------------------------------------------
MaximumInput:
;       ������ ��������� ��� ����� ����� maxNumber.
        push strInputMaximum
        call [printf]
        add esp, 4
        push maxNumber
        push strScanMax
        call [scanf]
        add esp, 8

;       ���������� �������� [maxNumber] � 1. ���� ��� ������, �� ���������.
        cmp [maxNumber], 1
        jae endInputArray
;       ���� maxNumber > 1, �������� ����������.
;       � ��������� ������, ���������.
        call WrongInput

endInputArray:
        ret

;--------------------------------------------------------------------------
; ���������� ������� ���������� ���������� ������������������ ����� �������
; � ������ ��������� �������� ��� maxNumber <= 6.
;--------------------------------------------------------------------------
FillInitialCheck:
;       ���������� �������.
        mov dword[arrayNumbers], 3
        mov dword[arrayNumbers+4], 2
        mov dword[arrayNumbers+8], 5
        mov dword[arrayNumbers+12], 5
;       ������ ��������� maxNumber c 1,2,4,6 � ����� ��������������� ���������.
;       ��������� � 1. ���������� currentCount �� 2.
        cmp [maxNumber], 1
        je Finish
;       ��������� � 2. ���������� currentCount �� 2.
        call IncreaseCountInitial
        cmp [maxNumber], 2
        je Finish
;       ��������� � 4. ���������� currentCount �� 2.
        call IncreaseCountInitial
        cmp [maxNumber], 4
        jbe Finish
;       ��������� � 6. ���������� currentCount �� 2.
        call IncreaseCountInitial
        cmp [maxNumber], 6
        jbe Finish
        ret

;--------------------------------------------------------------------------
; �������� �� �������, ������� �������� [arrayNumbers+12] �� �������:
; P(n) = P(n - 2) + P(n - 3).
;--------------------------------------------------------------------------
IteratePerrins:
        ; ����� ��� �������� �������� ������� ��� �� ���� �����������
        ; memmove(arrayNumbers, arrayNumbers+4, 12) for moveing the array.
        ; �� ��� �������� ������� ������ �������. ������� ��� ����������� ����� ������:

;       � �������� eax, ebx, ecx ����������� �������� �������, ���������� ������� � �����.
;       ����� ���������� �������� ��������� ����� ������ � ����.
        mov eax, [arrayNumbers+12]
        mov ebx, [arrayNumbers+8]
        mov ecx, [arrayNumbers+4]
        mov [arrayNumbers+8], eax
        mov [arrayNumbers+4], ebx
        mov [arrayNumbers], ecx
;       �������� ���������.
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx

;       ������� ������ �������� ��� [arrayNumbers+12] �� ������� P(n) = P(n - 2) + P(n - 3).
        mov ebx, [arrayNumbers+4]
        add ebx, [arrayNumbers]
;       ���� [arrayNumbers+12] ����������� ����������� ������� �����,
;       ��������� ����������� � ������� ������� �������� currentCount.
        jc OverflowFinish
        mov [arrayNumbers+12], ebx

;       ������� �������� [arrayNumbers+12] � ������� ebx ��� ���������.
        mov ebx, [arrayNumbers+12]
        cmp [maxNumber],ebx
;       ���� [maxNumber] < [arrayNumbers+12], �� ��������� �������� � ������ �����.
        jb Finish

;       ����������� �������� currentCount �� 1 � ��������� ��������.
        call IncreaseCount
        jmp IteratePerrins

;--------------------------------------------------------------------------
; ���������� �������� ���� �� 1, ���� �� 2 (���������� �� 2 ���������� � ������ ��������� ������ ����� �����,
; ������� ����������� 2 ���� � ������������������.
;--------------------------------------------------------------------------

;       ����������� currentCount � ������� eax, ���������� �� 2 � ����������� �� eax � currentCount.
IncreaseCountInitial:
        mov eax, [currentCount]
        add eax, 2
        mov [currentCount], eax
        ret

;       ����������� currentCount � ������� eax, ���������� �� 1 � ����������� �� eax � currentCount.
IncreaseCount:
        mov eax, [currentCount]
        add eax, 1
        mov [currentCount], eax
        ret
;--------------------------------------------------------------------------
; ���������� ��������� ���� � ���������� �� ������, ���� � ������� ������ -
; ���������� ����� �� ������������������ �������, ������� ������ maxNumber.
;--------------------------------------------------------------------------

;       ����� ��������� �� ������ � ������������ ��������� maxNumber.
WrongInput:
;       ���� ���� ������������, ��������� ���������.
        push [maxNumber]
        push strIncorrectMaximum
        call [printf]
;       �������� ������� ������� ��� ��������.
        add esp, 8
        call [getch]
;       ����������.
        push 0
        call [ExitProcess]

OverflowFinish:
;       ����� �������� �������� �������� � ������ ����,
;       ��� ��������� ������������ ������������ �������� �����.
        push [currentCount]
        push [maxNumber]
        push strOverflowFinish
        call [printf]
;       �������� ������� ������� ��� ��������.
        add esp, 12
        call [getch]
;       ����������.
        push 0
        call [ExitProcess]

;       ����� �������� �������� �������� � ������� � ����������.
Finish:
;       ����� �������� ��������.
        push [currentCount]
        push [maxNumber]
        push strFinish
        call [printf]
;       �������� ������� ������� ��� ��������.
        add esp, 12
        call [getch]
;       ����������.
        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
; ��������������� ���������� � ������ .data: user32.inc, kernel32.inc � �.�.
;--------------------------------------------------------------------------
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'include\api\user32.inc'
include 'include\api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
include 'include\api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           memmove, 'memmove',\
           scanf, 'scanf',\
           getch, '_getch'