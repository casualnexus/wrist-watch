stm8/
	#include "STM8L051F3.inc"
	
	extern byte1
	extern minutes
	extern readtime
	extern restore_periph
	extern hrly
	extern delay
	extern mode
	extern WUT_setup_play
	extern melody
	extern melody_bu
	
	segment 'rom'
UIF											equ 0
WUTE										equ 2
CEN											equ 0
WUTWF										equ 2
WUTF										equ 2
WUCKSEL2								equ 2

ALRAF										equ 0
ALRAE										equ 0

PCKEN10									equ 0
PCKEN11									equ 1

beep_beep_n
	dc.b 20,255,20,255,20,255,20,255
beep_beep_d
	dc.b 2,2,2,8,2,2,2,8

tri_konya_n
	dc.b 26,25,25,23,25,26,26,25,25,23,
	dc.b 25,26,26,25,23,21,19,18,16,18,21,21,
	dc.b 255,21,21,19,16,13,19,19,19,18,23,26
	dc.b 255,26,25,20,23,22,23,25,23

tri_konya_d
	dc.b 8,6,6,4,4,4,6,4,6,4
	dc.b 4,7,4,6,4,4,6,4,4,4,7,6
	dc.b 6,4,6,4,4,4,6,4,6,4,4,6
	dc.b 4,4,6,4,4,6,4,4,6

ostyl_n
	dc.b 18,23,18,23,18,16,14,13,14,13,11,255
	dc.b 21,21,21,21,23,21,19,18,255,18,16,18
	dc.b 16,16,16,18,16,26,25,255,16,14,16,14
	dc.b 14,14,16,14,25,23,255,13,13,13,13,13
	dc.b 13,14,13,12,13,18,18,18,255
	
ostyl_d
	dc.b 4,6,4,6,4,4,4,6,4,6,7,4
	dc.b 4,4,4,5,2,4,4,9,6,6,4,6
	dc.b 4,4,4,6,4,6,4,6,6,4,6,4
	dc.b 4,4,6,4,6,4,7,6,4,4,4,4
	dc.b 4,6,6,4,6,4,10,4,4
	
popc_n
	dc.b 14,12																		;1
	dc.b 14,9,5,9,2,14,12													;2
	dc.b 14,9,5,9,2,14,16													;3
	dc.b 17,16,17,14,16,14,16,12									;4
	dc.b 14,12,14,10,14,14,12											;5
	dc.b 14,9,5,9,2,14,12													;6
	dc.b 14,9,5,9,2,14,16													;7
	dc.b 17,16,17,14,16,14,16,12									;8
	dc.b 14,12,14,16,17,21,19											;9
	dc.b 21,17,12,17,9,21,19											;10
	dc.b 21,17,12,17,9,21,23											;11
	dc.b 24,23,24,21,23,21,23,19									;12
	dc.b 21,19,21,17,21,21,17											;13
	dc.b 21,17,12,17,9,21,19											;14
	dc.b 21,17,12,17,9,21,23											;15
	dc.b 24,23,24,21,23,21,23,19									;16
	dc.b 21,19,16,19,21														;17
	
popc_d
	dc.b 4,4																			;1
	dc.b 4,4,4,4,6,4,4														;2
	dc.b 4,4,4,4,6,4,4														;3
	dc.b 4,4,4,4,4,4,4,4													;4
	dc.b 4,4,4,4,6,4,4														;5
	dc.b 4,4,4,4,6,4,4														;6
	dc.b 4,4,4,4,6,4,4														;7
	dc.b 4,4,4,4,4,4,4,4													;8
	dc.b 4,4,4,4,6,4,4														;9
	dc.b 4,4,4,4,6,4,4														;10
	dc.b 4,4,4,4,6,4,4														;11
	dc.b 4,4,4,4,4,4,4,4													;12
	dc.b 4,4,4,4,6,4,4														;13
	dc.b 4,4,4,4,6,4,4														;14
	dc.b 4,4,4,4,6,4,4														;15
	dc.b 4,4,4,4,4,4,4,4													;16
	dc.b 4,4,4,4,6																;17
	
resu_n
	dc.b 14,255,16,17,16													;5
	dc.b 14,255,16,17,16													;6
	dc.b 14,16,17,16,14,16,17,16									;7
	dc.b 14,16,17,16,14,9													;8
	dc.b 12																				;9
	dc.b 255																			;10
	dc.b 14,255,16,17,16													;11
	dc.b 14,255,16,17,16													;12
	dc.b 14,16,17,16,14,16,17,16									;13
	dc.b 14,16,17,16,14,9													;14
	dc.b 12																				;15
	dc.b 255																			;16
	dc.b 10,17,20,17,16														;17
	dc.b 17,255,19,17,16													;18
	dc.b 17,19,17,16,17,19,17,16									;19
	dc.b 17,19,17,16,17,19,17,16									;20
	dc.b 17,16,14,255															;21
	dc.b 255																			;22
	dc.b 10,17,20,17,16														;23
	dc.b 17,255,19,17,16													;24
	dc.b 17,19,17,16,17,19,17,16									;25
	dc.b 17,19,17,16,17,19,17,16									;26
	dc.b 17,16,14,255															;27
	dc.b 12,255																		;28
	
resu_d
	dc.b 8,4,4,4,4																;5
	dc.b 8,4,4,4,4																;6
	dc.b 4,4,4,4,4,4,4,4													;7
	dc.b 4,4,4,4,6,6															;8
	dc.b 10																				;9
	dc.b 10																				;10
	dc.b 8,4,4,4,4																;11
	dc.b 8,4,4,4,4																;12
	dc.b 4,4,4,4,4,4,4,4													;13
	dc.b 4,4,4,4,6,6															;14
	dc.b 10																				;15
	dc.b 10																				;16
	dc.b 7,6,4,4,4																;17
	dc.b 8,4,4,4,4																;18
	dc.b 4,4,4,4,4,4,4,4													;19
	dc.b 4,4,4,4,4,4,4,4													;20
	dc.b 2,2,9,4																	;21
	dc.b 10																				;22
	dc.b 7,6,4,4,4																;23
	dc.b 8,4,4,4,4																;24
	dc.b 4,4,4,4,4,4,4,4													;25
	dc.b 4,4,4,4,4,4,4,4													;26
	dc.b 2,2,9,4																	;27
	dc.b 9,6																			;28
	
hrly_n
	dc.b 20
	
hrly_d
	dc.b 4

	segment 'eeprom'
			 ;C3,C#3,D3, D#3,E3, F3, F#3,G3, G#3,A3, A#3, B3
notes
	dc.b 239,225,213,201,190,179,169,159,150,142,134,127
			 ;0   1   2   3   4   5   6   7   8   9  10  11
			 ;C4,C#4, D4,D#4,E4,F4,F#4,G4,G#4,A4,A#4,B4
	dc.b 119,113,106,100,95,89,84,80,75,71,67,63
			 ;12  13  14  15 16 17 18 19 20 21 22 23
			 ;C5C#5D5,D#5E5,F5,F#5G5,G#5A5,A#5B5
	dc.b 60,56,53,50,47,45,42,40,38,36,33,31
			 ;2425 26 27 28 29 30 31 32 33 34 35
				
				;/32 /32. /16  /16.  /8  /8.  /4    /4.   /2    /2.    1     1.    2
durations
	dc.w	1024,1536,2048,3072,4096,6144,8192,12288,16384,24576,32768,49152,65535
				;0    1    2    3    4    5    6     7     8     9     10    11    12

.melodies								dc.b	"BEEP","KONI","OSTY","POPC","RESU"

	segment 'ram0'
top_idx									ds.b
.alarmflag							ds.b
.beeperflag							ds.b
.melody									ds.b
.idx										ds.b
notes_ptr								ds.w
durations_ptr						ds.w
.hrlyflag								ds.b

	segment 'rom'
	
	interrupt tim4_handler
.tim4_handler.l:
	bres TIM4_SR1, #UIF												;сбрасываем фдаг прерывания
	bcpl PD_ODR, #0
	bset TIM4_CR1, #CEN
	iret

	interrupt RTC_handler
.RTC_handler.l:
	
	btjt RTC_ISR2, #ALRAF, alarm							;если прерывание вызвал будильник
	btjt RTC_ISR2, #WUTF, wakeup_tim					;если прерывание вызвал wakeup_tim
	;iret
	
alarm
	bres RTC_ISR2, #ALRAF											;сбрасываем флаг прерывания
	bset alarmflag, #0
	call WUT_setup_play												;настраиваем таймер на воспр.
	iret

wakeup_tim
	bres RTC_ISR2, #WUTF											;сбрасываем флаг прерывания
	
	btjt RTC_CR1, #WUCKSEL2, hrly_event				;если это ежечасный сигнал - перех.
																						;если это не ежечасный сигнал
	btjt beeperflag, #1, return								;если команда стоп - выходим
	bset beeperflag, #2												;если не стоп - флаг след. ноты
return
	iret
hrly_event																	;если прерыв - ежечасн сигнал
	call WUT_setup_play												;настраиваем таймер на воспр.
	bset beeperflag, #4												;команда на воспр. сигнала
	iret
	
.beeperparse:
	btjt beeperflag, #0, start
	btjt beeperflag, #1, stop
	btjt beeperflag, #4, beep
	jp beeperparse2

.stop
	bres beeperflag, #1												;сбрасываем флаг стопа
	bres beeperflag, #2												;сбрасываем флаг воспроизведения
	bres RTC_CR2, #WUTE												;останавливаем таймер пробуждения
	bres RTC_ISR2, #WUTF											;сбрасываем флаг прерывания
	bres TIM4_CR1, #CEN												;останавливаем таймер генератора
	bres TIM4_SR1, #UIF												;сбрасываем фдаг прерывания
	bres PD_ODR, #0
	ret
	
start
	bres beeperflag, #0												;сбрасываем флаг старта
	call WUT_setup_play												;настраиваем таймер на сигнал
	ld a, melody
	cp a, #0
	jreq melody0
	cp a, #1
	jreq melody1
	cp a, #2
	jreq melody2
	cp a, #3
	jreq melody3
	cp a, #4
	jreq melody4

beep:
	bres beeperflag, #4												;сбрасываем флаг ежечасного сигнала
	
	mov mode, #100
	
	mov TIM4_ARR, #75													;загружаем значене в регистр
	bset TIM4_CR1, #CEN												;запускаем таймер генератора
	
	ldw x, #1000
	call delay
	ret

melody0
	mov top_idx, #8
	ldw x, #beep_beep_n 
	ldw notes_ptr, x
	ldw x, #beep_beep_d 
	ldw durations_ptr, x
	
	mov idx, #0
	jra play

melody1
	mov top_idx, #43
	ldw x, #tri_konya_n 
	ldw notes_ptr, x
	ldw x, #tri_konya_d 
	ldw durations_ptr, x
	
	mov idx, #0
	jra play
	
melody2
	mov top_idx, #57
	ldw x, #ostyl_n 
	ldw notes_ptr, x
	ldw x, #ostyl_d 
	ldw durations_ptr, x
	
	mov idx, #0
	jra play

melody3
	mov top_idx, #116
	ldw x, #popc_n 
	ldw notes_ptr, x
	ldw x, #popc_d 
	ldw durations_ptr, x
	
	mov idx, #0
	jra play
	
melody4
	mov top_idx, #115
	ldw x, #resu_n 
	ldw notes_ptr, x
	ldw x, #resu_d 
	ldw durations_ptr, x
	
	mov idx, #0
	jra play
	
beeperparse2:
	btjt beeperflag, #2, play									;обработка события play из прерыв.
	ret
	
play:
	bres beeperflag, #2												;сбрасываем флаг вспр. уст. прерыв.
	
	ld a, idx
	cp a, top_idx															;если идекс достиг макимума
	jreq end_of_tune													;обрабатываем событие окончания мел.
	
	bres RTC_CR2, #WUTE												;отключаем таймер пробуждения
wait_WUTWF
	btjf RTC_ISR1, #WUTWF, wait_WUTWF					;ждем разрешения на запись
	
	clrw x
	ld a, idx
	ld xl, a
	ld a, ([durations_ptr],x)									;получ индекс текущ длительности
	sll a																			;получаем смещение в словах
	ld xl, a
	ldw x, (durations,x)											;загружаем зн-е счетчика из табл
	ldw RTC_WUTRH, x													;загружаем значение в регистр
	
	clrw x
	ld a, idx
	ld xl, a
	ld a, ([notes_ptr],x)											;получаем индекс ноты
	
	cp a, #255
	jreq pause																;это пауза -- переходим к pause
	
	ld xl, a
	ld a, (notes,x)														;получаем зн-я счетчика для ноты
	
	inc idx																		;увеличиваем индекс
	
	ld TIM4_ARR, a														;загружаем значене в регистр
	bset RTC_CR2, #WUTE												;запускаем таймер пробуждения
	bset TIM4_CR1, #CEN												;запускаем таймер генератора
	ret
pause
	bres PD_ODR, #0
	inc idx																		;увеличиваем индекс
	bset RTC_CR2, #WUTE												;запускаем таймер пробуждения
	bres TIM4_CR1, #CEN												;таймер генератора выключаем
	ret
end_of_tune
	bres PD_ODR, #0
	btjf beeperflag, #3, cmnd_stop						;если флага повтора нет - стоп
	bset beeperflag, #0												;иначе старт
	ret
cmnd_stop
	bset beeperflag, #1
	ret

	end
	