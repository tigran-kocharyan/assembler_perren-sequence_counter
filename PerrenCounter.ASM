; Кочарян Тигран, БПИ199, Вариант 10.
; Разработать программу, определяющую число чисел Перрена
; от 1 до беззнакового машинного слова.

format PE console
entry start

include 'include\win32a.inc'

;--------------------------------------------------------------------------
; Секция .data с объявленными переменными.
;--------------------------------------------------------------------------
section '.data' data readable writable
;       Создание переменных, которые будут использованы в дальнейшем.
        strInputMaximum       db 'Input the maximum number >= 1: ', 0
        strIncorrectMaximum   db 'Incorrect maximum value = %u. Should be a number > 0', 10, 0
        strCheck              db 'Current maximum = %u', 10, 0
        strFinish             db 'Calculations finished. The amount of Perrin Numbers smaller than %u is %u', 0
        strOverflowFinish     db 'Overflow happened. The amount of Perrin Numbers smaller than %u is %u', 0
        strScanMax            db '%u', 0

;       Создание массива из 4 элементов, для хранения последовательности чисел Перрена
        arrayNumbers          rd 4
        maxNumber             dd ?
        currentCount          dd 1

;--------------------------------------------------------------------------
; Секция .code для вызова различных процедур.
;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) Программа запрашивает пользователя ввести максимальное число от 1 до (2^32)-1
        call MaximumInput
; 2) Затем программа заполняет массив первоначальными элементами 3 2 5 5. Если введенное maxNumber <= 6,
; то пользователь получит ответ.
        call FillInitialCheck
; 3) Программа итерирует процедуру до тех пор, пока arrayNumbers[3] <= maxNumber.
        call IteratePerrins

;--------------------------------------------------------------------------
; Запрос ввода верхней границы расчетов - DD число.
;--------------------------------------------------------------------------
MaximumInput:
;       Печать сообщения для ввода числа maxNumber.
        push strInputMaximum
        call [printf]
        add esp, 4
        push maxNumber
        push strScanMax
        call [scanf]
        add esp, 8

;       Сравниваем значение [maxNumber] с 1. Если оно меньше, то завершаем.
        cmp [maxNumber], 1
        jae endInputArray
;       если maxNumber > 1, начинаем вычисления.
;       в противном случае, завершаем.
        call WrongInput

endInputArray:
        ret

;--------------------------------------------------------------------------
; Заполнение массива первичными значениями последовательности чисел Перрена
; и делаем первичные проверки для maxNumber <= 6.
;--------------------------------------------------------------------------
FillInitialCheck:
;       Заполнение массива.
        mov dword[arrayNumbers], 3
        mov dword[arrayNumbers+4], 2
        mov dword[arrayNumbers+8], 5
        mov dword[arrayNumbers+12], 5
;       Начало сравнения maxNumber c 1,2,4,6 и вывод соответствующих сообщений.
;       Сравнение с 1. Увеличение currentCount на 2.
        cmp [maxNumber], 1
        je Finish
;       Сравнение с 2. Увеличение currentCount на 2.
        call IncreaseCountInitial
        cmp [maxNumber], 2
        je Finish
;       Сравнение с 4. Увеличение currentCount на 2.
        call IncreaseCountInitial
        cmp [maxNumber], 4
        jbe Finish
;       Сравнение с 6. Увеличение currentCount на 2.
        call IncreaseCountInitial
        cmp [maxNumber], 6
        jbe Finish
        ret

;--------------------------------------------------------------------------
; Итерация по массиву, подсчет значения [arrayNumbers+12] по формуле:
; P(n) = P(n - 2) + P(n - 3).
;--------------------------------------------------------------------------
IteratePerrins:
        ; также для переноса значения массива мог бы быть использован
        ; memmove(arrayNumbers, arrayNumbers+4, 12) for moveing the array.
        ; но это занимает немного больше времени. Поэтому был использован такой способ:

;       В регистры eax, ebx, ecx переносятся значения массива, происходит подсчет и сдвиг.
;       Затем происходит зачистка регистров после работы с ними.
        mov eax, [arrayNumbers+12]
        mov ebx, [arrayNumbers+8]
        mov ecx, [arrayNumbers+4]
        mov [arrayNumbers+8], eax
        mov [arrayNumbers+4], ebx
        mov [arrayNumbers], ecx
;       Зачистка регистров.
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx

;       Подсчет нового значения для [arrayNumbers+12] по формуле P(n) = P(n - 2) + P(n - 3).
        mov ebx, [arrayNumbers+4]
        add ebx, [arrayNumbers]
;       Если [arrayNumbers+12] переполняет беззнаковое двойное слово,
;       программа завершается и выводит текущее значение currentCount.
        jc OverflowFinish
        mov [arrayNumbers+12], ebx

;       Перенос значения [arrayNumbers+12] в регистр ebx для сравнения.
        mov ebx, [arrayNumbers+12]
        cmp [maxNumber],ebx
;       Если [maxNumber] < [arrayNumbers+12], то завершаем подсчеты и выводи ответ.
        jb Finish

;       Увеличиваем значение currentCount на 1 и повторяем итерацию.
        call IncreaseCount
        jmp IteratePerrins

;--------------------------------------------------------------------------
; Увеличение счетчика либо на 1, либо на 2 (увеличение на 2 необходимо в случае некоторых первых чисел чисел,
; которые повторяются 2 раза в последовательности.
;--------------------------------------------------------------------------

;       Копирование currentCount в регистр eax, увеличение на 2 и копирование из eax в currentCount.
IncreaseCountInitial:
        mov eax, [currentCount]
        add eax, 2
        mov [currentCount], eax
        ret

;       Копирование currentCount в регистр eax, увеличение на 1 и копирование из eax в currentCount.
IncreaseCount:
        mov eax, [currentCount]
        add eax, 1
        mov [currentCount], eax
        ret
;--------------------------------------------------------------------------
; Завершение программы либо с сообщением об ошибке, либо с выводом ответа -
; количества чисел из последовательности Перрена, которые меньше maxNumber.
;--------------------------------------------------------------------------

;       Вывод сообщения об ошибки с некорректным значением maxNumber.
WrongInput:
;       Если ввод некорректный, выводится сообщение.
        push [maxNumber]
        push strIncorrectMaximum
        call [printf]
;       Ожидание нажатия клавиши для закрытия.
        add esp, 8
        call [getch]
;       Завершение.
        push 0
        call [ExitProcess]

OverflowFinish:
;       Вывод текущего значения счетчика с учетом того,
;       что произошло переполнение беззнакового двойного слова.
        push [currentCount]
        push [maxNumber]
        push strOverflowFinish
        call [printf]
;       Ожидание нажатия клавиши для закрытия.
        add esp, 12
        call [getch]
;       Завершение.
        push 0
        call [ExitProcess]

;       Вывод текущего значения счетчика в консоль и завершение.
Finish:
;       Вывод значения счетчика.
        push [currentCount]
        push [maxNumber]
        push strFinish
        call [printf]
;       Ожидание нажатия клавиши для закрытия.
        add esp, 12
        call [getch]
;       Завершение.
        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
; Импортированные библиотеки в секции .data: user32.inc, kernel32.inc и т.д.
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