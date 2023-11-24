stm8/
	#include "STM8L051F3.inc"
	extern mode
	extern timerflag
	extern key1flag
	extern key2flag
	extern key3flag
	extern key4flag
	extern byte1
	extern byte2
	extern minutes
	extern hours
	extern monthweekd
	extern date
	extern year
	
	extern inc_mm
	extern dec_mm
	extern inc_hh
	extern dec_hh
	extern inc_mt
	extern dec_mt
	extern inc_dd
	extern dec_dd
	extern inc_wd
	extern dec_wd
	extern inc_yyyy
	extern dec_yyyy
	extern inc_amm
	extern dec_amm
	extern inc_ahh
	extern dec_ahh
	
	extern show_first
	extern show_last
	extern show_wdstring
	
	extern restore_periph
	
	extern inc_clbr
	extern dec_clbr
	extern show_clbr_val

	segment 'rom'
CEN								equ 0
UIF								equ 0
WUTWF							equ 2

PCKEN10						equ 0
PCKEN11						equ 1

	interrupt tim2_handler
.tim2_handler.l:
	bres TIM2_SR1, #UIF											;сбрасываем фдаг прерывания
	bset timerflag, #0
	iret

	interrupt key1_handler
.key1_handler.l:
	bset CLK_PCKENR1, #PCKEN10
	bset CLK_PCKENR1, #PCKEN11
	bset EXTI_SR1, #1												;сбрасываем флаг прерывания
	btjt key1flag, #0, key1_repeat
	call debounce
	mov key1flag, #$1
	bset EXTI_SR1, #1												;сбрасываем флаг прерывания
	iret

key1_repeat:
	call cfg_repeat
	bset PC_CR2, #1
	
	ld a, mode
	cp a, #11
	jreq mm_inc_rpt
	cp a, #13
	jreq hh_inc_rpt
	cp a, #31
	jreq mt_inc_rpt
	cp a, #33
	jreq dd_inc_rpt
	cp a, #41
	jreq wd_inc_rpt
	cp a, #51
	jreq yyyy_inc_rpt
	cp a, #61
	jreq amm_inc_rpt
	jp key1_repeat2

mm_inc_rpt:
	call inc_mm
	mov byte2, minutes
	call show_last
	call strt_tmr
	iret	

hh_inc_rpt:
	call inc_hh
	mov byte1, hours
	call show_first
	call strt_tmr
	iret

mt_inc_rpt:
	call inc_mt
	ld a, monthweekd
	and a, #%00011111
	ld byte2, a
	call show_last
	call strt_tmr
	iret

dd_inc_rpt:
	call inc_dd
	mov byte1, date
	call show_first
	call strt_tmr
	iret
	
wd_inc_rpt
	call inc_wd
	call show_wdstring
	call strt_tmr
	iret
	
yyyy_inc_rpt
	call inc_yyyy
	mov byte1, #%00100000
	call show_first
	mov byte2, year
	call show_last
	call strt_tmr
	iret

amm_inc_rpt:
	call inc_amm
	ld a, RTC_ALRMAR2
	and a, #%01111111
	ld byte2, a
	call show_last
	call strt_tmr
	iret

key1_repeat2:
	cp a, #63
	jreq ahh_inc_rpt
	cp a, #81
	jreq clbr_inc_rpt
	iret
	
ahh_inc_rpt:
	call inc_ahh
	ld a, RTC_ALRMAR3
	and a, #%00111111
	ld byte1, a
	call show_first
	call strt_tmr
	iret

clbr_inc_rpt:
	call inc_clbr
	call show_clbr_val
	call strt_tmr
	iret
	
	interrupt key2_handler
.key2_handler.l:
	bset CLK_PCKENR1, #PCKEN10
	bset CLK_PCKENR1, #PCKEN11
	bset EXTI_SR1, #7
	btjt key2flag, #0, key2_repeat
	call debounce
	mov key2flag, #$1
	bset EXTI_SR1, #1												;сбрасываем флаг прерывания
	iret
	
key2_repeat:
	call cfg_repeat
	bset PB_CR2, #7
	
	ld a, mode
	cp a, #11
	jreq mm_dec_rpt
	cp a, #13
	jreq hh_dec_rpt
	cp a, #31
	jreq mt_dec_rpt
	cp a, #33
	jreq dd_dec_rpt
	cp a, #41
	jreq wd_dec_rpt
	cp a, #51
	jreq yyyy_dec_rpt
	cp a, #61
	jreq amm_dec_rpt
	cp a, #63
	jreq ahh_dec_rpt
	jp key2_repeat2

mm_dec_rpt:
	call dec_mm
	mov byte2, minutes
	call show_last
	call strt_tmr
	iret

hh_dec_rpt:
	call dec_hh
	mov byte1, hours
	call show_first
	call strt_tmr
	iret
	
mt_dec_rpt:
	call dec_mt
	ld a, monthweekd
	and a, #%00011111
	ld byte2, a
	call show_last
	call strt_tmr
	iret
	
dd_dec_rpt:
	call dec_dd
	mov byte1, date
	call show_first
	call strt_tmr
	iret

wd_dec_rpt:
	call dec_wd
	call show_wdstring
	call strt_tmr
	iret
	
yyyy_dec_rpt:
	call dec_yyyy
	mov byte1, #%00100000
	call show_first
	mov byte2, year
	call show_last
	call strt_tmr
	iret
	
amm_dec_rpt:
	call dec_amm
	ld a, RTC_ALRMAR2
	and a, #%01111111
	ld byte2, a
	call show_last
	call strt_tmr
	iret
	
ahh_dec_rpt:
	call dec_ahh
	ld a, RTC_ALRMAR3
	and a, #%00111111
	ld byte1, a
	call show_first
	call strt_tmr
	iret

key2_repeat2:
	cp a, #81
	jreq clbr_dec_rpt
	iret
	
clbr_dec_rpt:
	call dec_clbr
	call show_clbr_val
	call strt_tmr
	iret

	interrupt key3_handler
.key3_handler.l:
	bset CLK_PCKENR1, #PCKEN10
	bset CLK_PCKENR1, #PCKEN11
	bset EXTI_SR1, #4
	call debounce
	mov key3flag, #$1
	iret
	
	interrupt key4_handler
.key4_handler.l:
	bset CLK_PCKENR1, #PCKEN10
	bset CLK_PCKENR1, #PCKEN11
	bset EXTI_SR1, #0
	call debounce
	mov key4flag, #$1
	iret

debounce:
	call cfg_debounce
	bset TIM3_CR1, #CEN													;запускаем таймер
dbn_wait_CEN
	btjt TIM3_CR1, #0, dbn_wait_CEN
	bres TIM3_SR1, #UIF
	ret
	
cfg_repeat:
	mov TIM3_ARRH, #$19													;200 мс
	mov TIM3_ARRL, #$99
	mov TIM3_CNTRH, #$00
	mov TIM3_CNTRL, #$00
	ret
	
cfg_debounce:
	mov TIM3_ARRH, #$20													;загружаем значение задержки в таймер
	mov TIM3_ARRL, #$00													;250 мс
	mov TIM3_CNTRH, #$00												;обнуляем значение счетчика
	mov TIM3_CNTRL, #$00
	ret
	
strt_tmr:
	bset TIM3_CR1, #CEN													;запускаем таймер
rpt_wait_CEN
	btjt TIM3_CR1, #0, rpt_wait_CEN
	bres TIM3_SR1, #UIF
	ret
	
	end
	