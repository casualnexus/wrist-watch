stm8/
	#include "STM8L051F3.inc"
	extern byte1
	extern byte2
	extern bitshift_left
	extern bitshift_right
	extern seconds
	extern minutes
	extern date
	extern hours
	extern monthweekd
	extern year
	extern timerflag
	extern delay
	extern wdstr
	extern get_wd_string
	extern wdtab
	extern melodies
	extern melody
	extern v_strings
	extern voltage
	extern dec_bcd_w
	extern hrly

	segment 'eeprom'
alrm_states																	dc.b " ON ","OFF "
hrly_states																	dc.b "!OFF","! ON"

	segment 'ram0'
.symbol																			ds.b
.prevsec																		ds.b
wdptr																				ds.b
strarr_ptr																	ds.w
m_idx																				ds.w
.calibr																			ds.w

	segment 'rom'
CFG_GCR_SWD 																equ 0
A0 																					equ 0
A1 																					equ 2
NWR 																				equ 3

CEN 																				equ 0
ALRAE																				equ 0

CALP																				equ 7

.show_ss
	ld a, seconds
	cp a, prevsec
	jreq ss_ret
	call cls_first														;очищаем старшие разряды
	mov byte2, seconds
	call show_last														;выводим секунды
	mov prevsec, seconds
ss_ret
	ret

.show_hhmm:
	mov byte2, minutes
	call show_last
	mov byte1, hours
	call show_first
	ret
	
.flash_first:
	btjf timerflag, #7, fdig_off							;если флаг гащения 0, гасим
	call show_first														;выводим
	ret
fdig_off
	call cls_first														;гасим
	ret

.flash_last
	btjf timerflag, #7, ldig_off
	call show_last
	ret
ldig_off
	call cls_last
	ret
	
.show_ddmm:
	mov byte1, date
	call show_first
	ld a, monthweekd
	and a, #%00011111
	ld byte2, a
	call show_last
	ret

.show_wd:
	mov byte1, monthweekd
	call get_wd_string
	call show_wdstring
	ret
	
.flash_wd:
	btjf timerflag, #7, wdstr_off
	call show_wdstring
	ret
wdstr_off
	call cls
	ret
	
.show_yyyy:
	mov byte1, #%00100000
	call show_first
	mov byte2, year
	call show_last
	ret

.show_batterty_v:
	ldw x, #v_strings
	ldw strarr_ptr, x
	clrw x
	ld a, voltage
	ld xl, a
	ldw m_idx, x
	call show_string
	ret
	
.flash_yyyy:
	btjf timerflag, #7, yyyy_off
	call show_yyyy
	ret
yyyy_off
	call cls
	ret

.show_alrm_hhmm:
	ld a, RTC_ALRMAR2
	and a, #%01111111
	ld byte2, a
	call show_last
	ld a, RTC_ALRMAR3
	and a, #%00111111
	ld byte1, a
	call show_first
	ret

.show_melody:
	ldw x, #melodies
	ldw strarr_ptr, x
	ldw x, #0
	ld a, melody
	ld xl, a
	ldw m_idx, x
	call show_string
	ret

.show_alrm_arm:
	ldw x, #alrm_states
	ldw strarr_ptr, x
	ldw x, #0
	btjt RTC_CR2, #ALRAE, armed
	ldw x, #1
	ldw m_idx, x
	call show_string
	ret
armed
	ldw x, #0
	ldw m_idx, x
	call show_string
	ret
	
.show_clbr_val:
	ldw x, RTC_CALRH
	ld a, xh
	and a, #1
	ld xh, a
	ldw calibr, x
	btjf RTC_CALRH, #CALP, clbrv_neg
	ldw x, #511
	subw x, calibr
	incw x
	mov symbol, #$2b
	jra sign_dspl
clbrv_neg
	mov symbol, #$2d

sign_dspl
	bset PA_ODR, #A0
	bset PA_ODR, #A1
	call write

	call dec_bcd_w
	ld a, byte1
	add a, #$30
	ld symbol, a
	
	bres PA_ODR, #A0
	bset PA_ODR, #A1
	call write
	
	call show_last
	ret
		
.flash_clbr:
	btjf timerflag, #7, clbr_off
	call show_clbr_val
	ret
clbr_off
	call cls
	ret
	
.show_hrly:
	ldw x, #hrly_states
	ldw strarr_ptr, x
	ldw x, #0
	ld a, hrly
	ld xl, a
	ldw m_idx, x
	call show_string
	ret

.flash_hrly:
	btjf timerflag, #7, hrly_off
	call  show_hrly
	ret
hrly_off
	call cls
	ret

.write:
	bset CFG_GCR, #CFG_GCR_SWD									;отключаем SWIM
	bres PA_ODR, #NWR
	mov PB_ODR, symbol													;выводим цифру
	bset PA_ODR, #NWR
	bres CFG_GCR, #CFG_GCR_SWD									;втключаем SWIM
	ret

.cls:
	call cls_first
	call cls_last
	ret
	
cls_first:
	mov symbol, #$20
	bres PA_ODR, #A0
	bset PA_ODR, #A1
	call write
	bset PA_ODR, #A0
	bset PA_ODR, #A1
	call write
	ret

cls_last:
	mov symbol, #$20
	bset PA_ODR, #A0
	bres PA_ODR, #A1
	call write
	bres PA_ODR, #A0
	bres PA_ODR, #A1
	call write
	ret

.show_last
	ld a, byte2																	;выводим единицы
	and a, #%00001111
	add a, #$30
	ld symbol, a
	
	bres PA_ODR, #A0
	bres PA_ODR, #A1
	call write

	ld a, byte2																	;выводим десятки
	and a, #%11110000
	swap a
	add a, #$30
	ld symbol, a

	bset PA_ODR, #A0
	bres PA_ODR, #A1
	call write
	ret

.show_first
	ld a, byte1																	;выводим единицы
	and a, #%00001111
	add a, #$30
	ld symbol, a
	
	bres PA_ODR, #A0
	bset PA_ODR, #A1
	call write
	
	ld a, byte1																	;выводим десятки
	and a, #%11110000
	swap a
	add a, #$30
	ld symbol, a
	
	bset PA_ODR, #A0
	bset PA_ODR, #A1
	call write
	ret

.show_wdstring:
	ldw x, #wdstr
	ld a, (x)
	ld symbol, a
	
	bset PA_ODR, #A0
	bset PA_ODR, #A1
	call write
	
	incw x
	ld a, (x)
	ld symbol, a
	
	bres PA_ODR, #A0
	bset PA_ODR, #A1
	call write
	
	incw x
	ld a, (x)
	ld symbol, a
	
	bset PA_ODR, #A0
	bres PA_ODR, #A1
	call write
	
	incw x
	ld a, (x)
	ld symbol, a
	
	bres PA_ODR, #A0
	bres PA_ODR, #A1
	call write
	ret
	
.show_string:
	ldw x, m_idx
	sllw x
	sllw x
	addw x, strarr_ptr
	
	ld a, (x)
	ld symbol, a
	
	bset PA_ODR, #A0
	bset PA_ODR, #A1
	call write
	
	incw x
	ld a, (x)
	ld symbol, a
	
	bres PA_ODR, #A0
	bset PA_ODR, #A1
	call write
	
	incw x
	ld a, (x)
	ld symbol, a
	
	bset PA_ODR, #A0
	bres PA_ODR, #A1
	call write
	
	incw x
	ld a, (x)
	ld symbol, a
	
	bres PA_ODR, #A0
	bres PA_ODR, #A1
	call write
	
	ret
	end
	