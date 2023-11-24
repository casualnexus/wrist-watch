stm8/
	#include "STM8L051F3.inc"
	extern mode
	extern seconds
	extern minutes
	extern hours
	extern date
	extern monthweekd
	extern year
	extern cls
	extern delay
	extern bcd_dec
	extern dec_bcd
	extern byte1
	extern byte2
	extern numofdays
	extern get_wd_string
	extern daystab
	extern melody
	extern beeperflag
	extern stop
	extern voltage
	extern set_threshold
	extern calibr
	extern hrly
	
	segment 'rom'
CEN 										equ 0
UIF 										equ 0
INIT										equ 7
INITF										equ 6
RSF											equ 5
ALRAE										equ 0
ALRAWF									equ 0

CFG_GCR_SWD 						equ 0
PCKEN10									equ 0
PCKEN11									equ 1
PCKEN12									equ 2
MELODY_NUM							equ 4

PVDE										equ 0
VREFINTF								equ 0
PVDIF										equ 5
PVDOF										equ 6

CALP										equ 7
RECALPF									equ 1
CALM8										equ 0

WUTWF										equ 2
WUTE										equ 2
WUTF										equ 2
WUCKSEL0								equ 0
WUCKSEL1								equ 1
WUCKSEL2								equ 2

	segment 'ram0'
.key1flag								ds.b
.key2flag								ds.b
.key3flag								ds.b
.key4flag								ds.b
.timerflag							ds.b
scndslft								ds.w

	segment 'rom'
.delay:
	bres TIM2_SR1, #UIF											;сбрасываем фдаг прерывания
	bres timerflag, #0											;сбрасываем флаг таймера												
	ld a, xh
	ld TIM2_ARRH, a													;загружаем значение задержки в таймер
	ld a, xl
	ld TIM2_ARRL, a
	mov TIM2_CNTRH, #$00										;обнуляем значение счетчика
	mov TIM2_CNTRL, #$00
	bset TIM2_CR1, #CEN											;запускаем таймер
	ret
	
.keyparse:
	ld a, #1
	cp a, key1flag	
	jreq key1parse
	jp keyparse2
	
key1parse
	mov key1flag, #0
	ld a, mode
	cp a, #0
	jreq key1_mode1													;wait -> show_hhmm -> hhmm
	cp a, #10
	jreq key1_mode2													;hhmm -> show_ss
	cp a, #2
	jreq key1_mode1													;show_ss -> show_hhmm -> hhmm
	cp a, #21
	jreq key1_mode21												;setup ss -> accept_ss -> show_ss
	
	cp a, #11
	jreq key1_mode11												;setup_mm: inc_mm
	cp a, #13
	jreq key1_mode13												;setup_hh: inc_hh
	cp a, #31
	jreq key1_mode31												;setup_mt: inc_mt
	cp a, #33
	jreq key1_mode33												;setup_dd: inc_dd
	cp a, #41
	jreq key1_mode41												;setup_wd: inc_wd
	cp a, #51
	jreq key1_mode51												;setup_wd: inc_yyyy
	
	cp a, #61
	jreq key1_mode61												;setup_alrm_mm: inc_amm
	cp a, #63
	jreq key1_mode63												;setup_alrm_hh: inc_ahh
	cp a, #65
	jreq key1_mode65												;setup_melody: inc_melody
	cp a, #66
	jreq key1_mode66												;arm_alrm: toggle_alrm_arm
	cp a, #81
	jreq key1_mode81												;setup_clbr: inc_clbr
	cp a, #91
	jreq key1_mode91												;setup_hrly: toggle_hrly
	jra key1_mode1
	ret
	
key1_mode1
	mov mode, #1
	ldw x, #12288
	call delay
	ret
key1_mode2
	mov mode, #2
	;ldw x, #20480
	;call delay
	ret
key1_mode21
	call reset_ss
	mov mode, #2
	ldw x, #20480
	call delay
	ret
key1_mode11
	call inc_mm
	ret
key1_mode13
	call inc_hh
	ret
key1_mode31
	call inc_mt
	ret
key1_mode33
	call inc_dd
	ret
key1_mode41
	call inc_wd
	ret
key1_mode51
	call inc_yyyy
	ret
key1_mode61:
	call inc_amm
	ret
key1_mode63
	call inc_ahh
	ret
key1_mode65
	call inc_melody
	ret
key1_mode66
	call toggle_alrm_arm
	ret
key1_mode81
	call inc_clbr
	ret
key1_mode91
	call toggle_hrly
	ret

keyparse2:
	cp a, key2flag
	jreq key2parse
	jp keyparse3
	
key2parse
	mov key2flag, #0
	ld a, mode
	cp a, #0
	jreq key2_mode3													;wait -> show_ddmm -> ddmm
	cp a, #30
	jreq key2_mode4													;ddmm -> show_wd -> wd
	cp a, #40
	jreq key2_mode5													;wd -> show_yyyy -> yyyy
	cp a, #50
	jreq key2_mode3													;yyyy -> show_ddmm -> ddmm
	
	cp a, #11
	jreq key2_mode11												;setup_mm: dec_mm
	cp a, #13
	jreq key2_mode13												;setup_hh: dec_hh
	cp a, #31
	jreq key2_mode31												;setup_mt: dec_mt
	cp a, #33
	jreq key2_mode33												;setup_dd: dec_dd
	cp a, #41
	jreq key2_mode41												;setup_wd: dec_wd
	cp a, #51
	jreq key2_mode51												;setup_yyyy: dec_yyyy
	
	cp a, #61
	jreq key2_mode61												;setup_alrm_mm: dec_amm
	cp a, #63
	jreq key2_mode63												;setup_alrm_hh: dec_ahh
	cp a, #65
	jreq key2_mode65												;setup_melody: dec_melody
	cp a, #66
	jreq key2_mode66												;arm_alrm: toggle_alrm_arm
	cp a, #81
	jreq key2_mode81												;setup_clbr: dec_clbr
	cp a, #91
	jreq key2_mode91												;setup_hrly: toggle_hrly
	jra key2_mode3
	ret
	
key2_mode3
	mov mode, #3
	ldw x, #12288
	call delay
	ret
key2_mode4
	mov mode, #4
	ldw x, #12288
	call delay
	ret
key2_mode5
	mov mode, #5
	ldw x, #12288
	call delay
	ret
key2_mode11
	call dec_mm
	ret
key2_mode13
	call dec_hh
	ret
key2_mode31
	call dec_mt
	ret
key2_mode33
	call dec_dd
	ret
key2_mode41
	call dec_wd
	ret
key2_mode51
	call dec_yyyy
	ret
key2_mode61
	call dec_amm
	ret
key2_mode63
	call dec_ahh
	ret
key2_mode65
	call dec_melody
	ret
key2_mode66
	call toggle_alrm_arm
	ret
key2_mode81
	call dec_clbr
	ret
key2_mode91
	call toggle_hrly
	ret

keyparse3:
	cp a, key3flag
	jreq key3parse
	jp keyparse4

key3parse:
	mov key3flag, #0
	ld a, mode
	
	cp a, #0
	jreq key3_mode7													;sleep -> show_batterty_v
	cp a, #7
	jreq key3_mode8													;show_batterty_v -> show_clbr_val
	cp a, #80
	jreq key3_mode9													;show_clbr_val -> show_hrly
	cp a, #90
	jreq key3_mode7													;show_hrly -> show_batterty_v
	jra key3_mode7
	ret
	
key3_mode7
	mov voltage, #6
	call set_threshold
	ldw x, #12288
	call delay
	mov mode, #7
	ret
key3_mode8
	ldw x, #12288
	call delay
	mov mode, #8
	ret
key3_mode9
	ldw x, #12288
	call delay
	mov mode, #9
	ret
	
keyparse4:
	cp a, key4flag
	jreq key4parse
	ret
	
key4parse:
	mov key4flag, #0
	
	btjt beeperflag, #2, key4_beep_off
	
	ldw x, #1024
	call delay
	ld a, mode
	
	cp a, #2
	jreq key4_mode21												;show_ss -> setup_ss
	cp a, #21
	jreq key4_mode22												;setup_ss -> show_ss
	
	cp a, #10
	jreq key4_mode11												;hhmm -> setup_mm
	cp a, #11
	jreq key4_mode12												;setup_mm -> accept_mm -> setup_hh
	cp a, #13
	jreq key4_mode14												;setup_hh -> accept_hh -> show_hhmm
	
	cp a, #30
	jreq key4_mode31												;ddmm -> setup_mt
	cp a, #31
	jreq key4_mode32												;setup_mt -> accept_mt -> setup_dd
	cp a, #33
	jreq key4_mode34												;setup_dd -> accept_dd -> show_ddmm
	
	cp a, #40
	jreq key4_mode41												;wd -> setup_wd
	cp a, #41
	jreq key4_mode42												;setup_wd -> accept_wd -> show_wd
	
	cp a, #50
	jreq key4_mode51												;yyyy -> setup_yyyy
	cp a, #51
	jreq key4_mode52												;setup_yyyy -> accept_yyyy -> show_yyyy
	
	jra key4parse2

key4_beep_off
	bset beeperflag, #1
	bres beeperflag, #2
	ret
key4_mode21
	mov mode, #21
	ret
key4_mode22
	ldw x, #12288
	call delay
	mov mode, #2
	ret
key4_mode11
	mov mode, #11
	ret
key4_mode12
	mov mode, #12
	ret
key4_mode14
	mov mode, #14
	ldw x, #12288
	call delay
	ret
key4_mode31
	mov mode, #31
	ret
key4_mode32
	mov mode, #32
	ret
key4_mode34
	mov mode, #34
	ldw x, #12288
	call delay
	ret
key4_mode41
	mov mode, #41
	ret
key4_mode42
	mov mode, #42
	ldw x, #12288
	call delay
	ret
key4_mode51
	mov mode, #51
	ret
key4_mode52
	mov mode, #52
	ldw x, #12288
	call delay
	ret

key4parse2:
	cp a, #0
	jreq key4_mode6							;halt -> alrm_hhmm
	cp a, #60
	jreq key4_mode61						;alrm_hhmm -> setup_alrm_mm
	cp a, #61
	jreq key4_mode62						;setup_alrm_mm -> accept_alrm_mm -> setup_alrm_hh
	cp a, #63
	jreq key4_mode64						;setup_alrm_hh -> accept_alrm_hh -> setup_melody
	cp a, #65
	jreq key4_mode66						;setup_melody -> arm_alrm
	cp a, #66
	jreq key4_mode6							;arm_alrm -> alrm_hhmm -> halt
	
	cp a, #80
	jreq key4_mode81						;calibration -> setup_clbr
	cp a, #81
	jreq key4_mode82						;setup_clbr -> accept_clbr -> calibration
	cp a, #90
	jreq key4_mode91						;hrly -> setup_hrly
	cp a, #91
	jreq key4_mode92						;setup_hrly -> accept_hrly -> hrly
	cp a, #92
	jra key4_mode6
	ret

key4_mode6
	mov mode, #6
	ldw x, #12288
	call delay
	ret
key4_mode61
	mov mode, #61
	ret
key4_mode62
	mov mode, #62
	ret
key4_mode64
	bset beeperflag, #3
	mov mode, #64
	ret
key4_mode66
	bres beeperflag, #3
	mov mode, #66
	ret
key4_mode81
	mov mode, #81
	ret
key4_mode82
	mov mode, #82
	ldw x, #12288
	call delay
	ret
key4_mode91
	mov mode, #91
	ret
key4_mode92
	mov mode, #92
	ret
		
.timerparse
	ld a, timerflag
	btjt timerflag, #0, timer_fired
	ret
	
timer_fired
	bres timerflag, #0											;сбрасываем флаг таймера
	
	ld a, mode
	cp a, #7
	jreq t_mode_halt
	cp a, #10
	jreq t_mode_halt
;	cp a, #2
;	jreq t_mode_halt
	cp a, #30
	jreq t_mode_halt
	cp a, #40
	jreq t_mode_halt
	cp a, #50
	jreq t_mode_halt
	cp a, #60
	jreq t_mode_halt
	cp a, #70
	jreq t_mode_halt
	cp a, #80
	jreq t_mode_halt
	cp a, #90
	jreq t_mode_halt
	
	cp a, #21
	jreq t_mode_flash
	cp a, #11
	jreq t_mode_flash
	cp a, #13
	jreq t_mode_flash
	cp a, #31
	jreq t_mode_flash
	cp a, #33
	jreq t_mode_flash
	cp a, #41
	jreq t_mode_flash
	cp a, #51
	jreq t_mode_flash
	cp a, #61
	jreq t_mode_flash
	cp a, #63
	jreq t_mode_flash
	cp a, #81
	jreq t_mode_flash
	cp a, #91
	jreq t_mode_flash
	
	cp a, #100
	jreq t_mode_beep
	ret
	
.t_mode_halt:															;засыпание
	call cls
	call check_hrly
	mov mode, #0
	bres CLK_PCKENR1, #PCKEN10							;тактовое питание TIM2
	bres CLK_PCKENR1, #PCKEN11							;тактовое питание TIM3
	bres CLK_PCKENR1, #PCKEN12							;тактовое питание TIM4
	bset CFG_GCR, #CFG_GCR_SWD
	halt
.restore_periph
	bres CFG_GCR, #CFG_GCR_SWD
	bset CLK_PCKENR1, #PCKEN12							;тактовое питание TIM4
	bres TIM4_SR1, #UIF											;сбрасываем фдаг прерывания
	bset CLK_PCKENR1, #PCKEN11							;тактовое питание TIM3
	bres TIM3_SR1, #UIF											;сбрасываем фдаг прерывания
	bset CLK_PCKENR1, #PCKEN10							;тактовое питание TIM2
	bres TIM2_SR1, #UIF											;сбрасываем фдаг прерывания
	
	;bres RTC_CR2, #WUTE												;останавливаем таймер пробуждения
	;bres RTC_ISR2, #WUTF											;сбрасываем флаг прерывания
	
wait_vref
	btjf PWR_CSR2, #VREFINTF, wait_vref			;ждем восст-я встр. ист. напр.
	ret
	
t_mode_flash:															;мигание
	bcpl timerflag, #7											;перекидываем флаг гашения
	ldw x, #1024
	call delay
	ret
	
t_mode_beep:
	bset beeperflag, #1												;останавливаем воспр-е сигнала
	mov mode, #1
	ldw x, #12288
	call delay
	ret

.reset_ss:
	mov byte1, seconds
	call bcd_dec
	ld a, byte2
	cp a, #30
	jrult skip_addup												;если секунд меньше 30 не добавл. мин.
	mov byte1, minutes
	call bcd_dec
	inc byte2
	mov byte1, byte2
	call dec_bcd
	ld a, byte2
	ld minutes, a
	ldw x, #RTC_TR2
	call write_RTC_calendar
skip_addup
	clr a																		;просто записываем 0
	ld seconds, a
	ldw x, #RTC_TR1
	call write_RTC_calendar
	ret
	
.inc_mm:
	mov byte1, minutes
	call bcd_dec
	ld a, #59
	cp a, byte2
	jreq bottom_mm
	inc byte2
	mov byte1, byte2
	call dec_bcd
	ld a, byte2
	ld minutes, a
	ldw x, #RTC_TR2
	call write_RTC_calendar
	ret
bottom_mm
	ld a, #0
	ld minutes, a
	ldw x, #RTC_TR2
	call write_RTC_calendar
	ret

.dec_mm:
	mov byte1, minutes
	call bcd_dec
	ld a, byte2
	cp a, #0
	jreq top_mm
	dec byte2
	mov byte1, byte2
	call dec_bcd
	ld a, byte2
	ld minutes, a
	ldw x, #RTC_TR2
	call write_RTC_calendar
	ret
top_mm
	mov byte1, #59
	call dec_bcd
	ld a, byte2
	ld minutes, a
	ldw x, #RTC_TR2
	call write_RTC_calendar
	ret

.inc_hh:
	mov byte1, hours
	call bcd_dec
	ld a, #23
	cp a, byte2
	jreq bottom_hh
	inc byte2
	mov byte1, byte2
	call dec_bcd
	ld a, byte2
	ld hours, a
	ldw x, #RTC_TR3
	call write_RTC_calendar
	ret
bottom_hh
	ld a, hours
	and a, #%11000000
	ld hours, a
	ldw x, #RTC_TR3
	call write_RTC_calendar
	ret

.dec_hh:
	mov byte1, hours
	call bcd_dec
	ld a, #0
	cp a, byte2
	jreq top_hh
	dec byte2
	mov byte1, byte2
	call dec_bcd
	ld a, byte2
	ld hours, a
	ldw x, #RTC_TR3
	call write_RTC_calendar
	ret
top_hh
	mov byte1, #23
	call dec_bcd
	ld a, byte2
	ld hours, a
	ldw x, #RTC_TR3
	call write_RTC_calendar
	ret

.inc_mt:
	ld a, monthweekd
	and a, #%00011111
	ld byte1, a
	call bcd_dec
	ld a, #12
	cp a, byte2
	jreq bottom_mt
	inc byte2
	mov byte1, byte2
	call dec_bcd
	ld a, monthweekd
	and a, #%11100000
	add a, byte2
	ld monthweekd, a
	ldw x, #RTC_DR2
	call write_RTC_calendar
	ret
bottom_mt
	ld a, monthweekd
	and a, #%11100000
	inc a
	ld monthweekd, a
	ldw x, #RTC_DR2
	call write_RTC_calendar
	ret

.dec_mt:
	ld a, monthweekd
	and a, #%00011111
	ld byte1, a
	call bcd_dec
	ld a, #0
	cp a, byte2
	jreq top_mt
	dec byte2
	mov byte1, byte2
	call dec_bcd
	ld a, monthweekd
	and a, #%11100000
	add a, byte2
	ld monthweekd, a
	ldw x, #RTC_DR2
	call write_RTC_calendar
	ret
top_mt
	mov byte1, #12
	call dec_bcd
	ld a, monthweekd
	and a, #%11100000
	add a, byte2
	ld monthweekd, a
	ldw x, #RTC_DR2
	call write_RTC_calendar
	ret
	
.inc_dd:
	ld a, monthweekd												;получаем количество дней в месяце
	call numofdays
	push a
	mov byte1, date													;сравниваем с текущей датой
	call bcd_dec
	pop a
	cp a, byte2
	jreq bottom_dd
	inc byte2																;если дата не последняя, то увелич
	mov byte1, byte2
	call dec_bcd
	ld a, byte2
	ld date, a
	ldw x, #RTC_DR1
	call write_RTC_calendar
	mov date, byte2
	ret
bottom_dd
	ld a, #1
	ld date, a
	ldw x, #RTC_DR1
	call write_RTC_calendar
	ret
	
.dec_dd:
	mov byte1, date
	call bcd_dec
	ld a, #1
	cp a, byte2
	jreq top_dd
	dec byte2
	mov byte1, byte2
	call dec_bcd
	ld a, byte2
	ld date, a
	ldw x, #RTC_DR1
	call write_RTC_calendar
	ret
top_dd
	ld a, monthweekd
	call numofdays
	ld byte1, a
	call dec_bcd
	ld a, byte2
	ld date, a
	ldw x, #RTC_DR1
	call write_RTC_calendar
	ret
	
.inc_wd:
	ld a, monthweekd
	and a, #%11100000
	swap a
	srl a
	cp a, #7
	jreq bottom_wd
	inc a
	sll a
	swap a
	push a
	ld a, monthweekd
	and a, #%00011111
	pop byte1
	add a, byte1
	ld monthweekd, a
	ldw x, #RTC_DR2
	call write_RTC_calendar
	ld byte1, a
	call get_wd_string
	ret
bottom_wd
	ld a, monthweekd
	and a, #%00011111
	or a, #%00100000
	ld monthweekd, a
	ldw x, #RTC_DR2
	call write_RTC_calendar
	ld byte1, a
	call get_wd_string
	ret

.dec_wd:
	ld a, monthweekd
	and a, #%11100000
	swap a
	srl a
	cp a, #1
	jreq top_wd
	dec a
	sll a
	swap a
	push a
	ld a, monthweekd
	and a, #%00011111
	pop byte1
	add a, byte1
	ld monthweekd, a
	ldw x, #RTC_DR2
	call write_RTC_calendar
	ld byte1, a
	call get_wd_string
	ret
top_wd
	ld a, monthweekd
	and a, #%00011111
	or a, #%11100000
	ld monthweekd, a
	ldw x, #RTC_DR2
	call write_RTC_calendar
	ld byte1, a
	call get_wd_string
	ret

.inc_yyyy:
	mov byte1, year
	call bcd_dec
	ld a, byte2
	cp a, #99
	jreq bottom_yyyy
	inc a
	ld byte1, a
	call dec_bcd
	ld a, byte2
	ld year, a
	ldw x, #RTC_DR3
	call write_RTC_calendar
	ret
bottom_yyyy
	ld a, #0
	ld year, a
	ldw x, #RTC_DR3
	call write_RTC_calendar
	ret
	
.dec_yyyy:
	mov byte1, year
	call bcd_dec
	ld a, byte2
	cp a, #0
	jreq top_yyyy
	dec a
	ld byte1, a
	call dec_bcd
	ld a, byte2
	ld year, a
	ldw x, #RTC_DR3
	call write_RTC_calendar
	ret
top_yyyy
	mov byte1, #99
	call dec_bcd
	ld a, byte2
	ld year, a
	ldw x, #RTC_DR3
	call write_RTC_calendar
	ret

.inc_amm:
	ld a, RTC_ALRMAR2
	and a, #%01111111
	ld byte1, a
	call bcd_dec
	ld a, #59
	cp a, byte2
	jreq bottom_amm
	inc byte2
	mov byte1, byte2
	call dec_bcd
	ld a, RTC_ALRMAR2
	and a, #%10000000
	or a, byte2
	ldw x, #RTC_ALRMAR2
	call write_RTC_alarm
	ret
bottom_amm
	ld a, RTC_ALRMAR2
	and a, #%10000000
	ldw x, #RTC_ALRMAR2
	call write_RTC_alarm
	ret

.dec_amm:
	ld a, RTC_ALRMAR2
	and a, #%01111111
	ld byte1, a
	call bcd_dec
	ld a, #0
	cp a, byte2
	jreq top_amm
	dec byte2
	mov byte1, byte2
	call dec_bcd
	ld a, RTC_ALRMAR2
	and a, #%10000000
	or a, byte2
	ldw x, #RTC_ALRMAR2
	call write_RTC_alarm
	ret
top_amm
	mov byte1, #59
	call dec_bcd
	ld a, RTC_ALRMAR2
	and a, #%10000000
	or a, byte2
	ldw x, #RTC_ALRMAR2
	call write_RTC_alarm
	ret

.inc_ahh:
	ld a, RTC_ALRMAR3
	and a, #%00111111
	ld byte1, a
	call bcd_dec
	ld a, #23
	cp a, byte2
	jreq bottom_ahh
	inc byte2
	mov byte1, byte2
	call dec_bcd
	ld a, RTC_ALRMAR3
	and a, #%11000000
	or a, byte2
	ldw x, #RTC_ALRMAR3
	call write_RTC_alarm
	ret
bottom_ahh
	ld a, RTC_ALRMAR3
	and a, #%11000000
	ldw x, #RTC_ALRMAR3
	call write_RTC_alarm
	ret

.dec_ahh:
	ld a, RTC_ALRMAR3
	and a, #%00111111
	ld byte1, a
	call bcd_dec
	ld a, #0
	cp a, byte2
	jreq top_ahh
	dec byte2
	mov byte1, byte2
	call dec_bcd
	ld a, RTC_ALRMAR3
	and a, #%11000000
	or a, byte2
	ldw x, #RTC_ALRMAR3
	call write_RTC_alarm
	ret
top_ahh
	mov byte1, #23
	call dec_bcd
	ld a, RTC_ALRMAR3
	and a, #%11000000
	or a, byte2
	ldw x, #RTC_ALRMAR3
	call write_RTC_alarm
	ret

.inc_melody:
	ld a, melody
	cp a, #MELODY_NUM
	jreq bottom_melody
	inc melody
	bset beeperflag, #0
	ret
bottom_melody
	mov melody, #0
	bset beeperflag, #0
	ret
	
.dec_melody:
	ld a, melody
	cp a, #0
	jreq top_melody
	dec  melody
	bset beeperflag, #0
	ret
top_melody
	mov melody, #MELODY_NUM
	bset beeperflag, #0
	ret
	
.toggle_alrm_arm:
	mov RTC_WPR, #$CA														;снимаем защиту от записи
	mov RTC_WPR, #$53
	bcpl RTC_CR2, #ALRAE
	ret
	
.inc_clbr:
	ldw x, RTC_CALRH														;считываем значение поправки
	ld a, xh																		;загружаем старший байт
	and a, #%00000001														;избавляемся от незначащих
	ld xh, a
	ldw calibr, x
	
	btjf RTC_CALRH, #CALP, clbrv_neg
	ldw x, #511																	;если число положительное
	subw x, calibr
	
	cpw x, #511
	jreq end_incr																;если пол-е зн-е уже максимально
																							;покидаем процедуру
	
	incw x																			;иначе увел на 1
	ldw calibr, x
	jra rec_CALR
	ret

clbrv_neg																			;если число отрицательное
	cpw x, #0
	jreq change_sign
	decw x
	ldw calibr, x
	jra rec_CALR
change_sign
	bset RTC_CALRH, #CALP
	;incw x
	ldw calibr, x
	
rec_CALR
	btjf RTC_CALRH, #CALP, rec_neg
waitp_REACLPF
	btjt RTC_ISR1, #RECALPF, waitp_REACLPF
	ldw x, #511
	subw x, calibr
	ld a, xh
	bres RTC_CALRH, #CALM8
	or a, RTC_CALRH
	ld RTC_CALRH, a
	ld a, xl
	ld RTC_CALRL, a
	ret
rec_neg
waitn_REACLPF
	btjt RTC_ISR1, #RECALPF, waitn_REACLPF
	ld a, xh
	bres RTC_CALRH, #CALM8
	or a, RTC_CALRH
	ld RTC_CALRH, a
	ld a, xl
	ld RTC_CALRL, a
end_incr
	ret

.dec_clbr:
	ldw x, RTC_CALRH														;считываем значение поправки
	ld a, xh																		;загружаем старший байт
	and a, #%00000001														;избавляемся от незначащих
	ld xh, a
	ldw calibr, x
	
	btjt RTC_CALRH, #CALP, clbrv_pos
	
	cpw x, #511																	;если отр-е зн-е уже минимально
	jreq end_decr																;покидаем процедуру
	
	incw x																			;иначе увеличиваем на 1
	ldw calibr, x
	jra rec_neg
	
clbrv_pos																			;если число положительное
	ldw x, #511																	;приводим к модулю
	subw x, calibr
	ldw calibr, x
	
	cpw x, #0																		;если проходим ноль в плюсе
	jreq sign_plus_minus												;меняем знак

	decw x																			;если не ноль -- просто уменьшаем
	ldw calibr, x
	jra rec_CALR

sign_plus_minus
	bres RTC_CALRH, #CALP												;меняем знак на отрицательный
	ldw x, #0
	ldw calibr, x
	jra rec_neg
	
end_decr
	ret
	
toggle_hrly:
	bcpl hrly, #0
	ret

.readtime:
	mov seconds, RTC_TR1
	mov minutes, RTC_TR2
	mov hours, RTC_TR3
	mov date, RTC_DR1
	mov monthweekd, RTC_DR2
	mov year, RTC_DR3
	ret
	
.write_RTC_calendar:
	mov RTC_WPR, #$CA														;снимаем защиту от записи
	mov RTC_WPR, #$53
	bset RTC_ISR1, #INIT												;входим в режим инициализации
wait_INITF																		;ждем переключения
	btjf RTC_ISR1, #INITF, wait_INITF
	ld (x), a
	bres RTC_ISR1, #INIT												;выходим из режим инициал
wait_RSF
	btjf RTC_ISR1, #RSF, wait_RSF
	ret
	
.write_RTC_alarm:
	bres RTC_CR2, #ALRAE
	ld (x), a
	bset RTC_CR2, #ALRAE
	ret
	
.corr_daystab:
	ld a, year
	cp a, #0
	jreq not_leap
	ld byte1, a
	call bcd_dec
	push byte2
	push #0
	popw x
	ld a, #4
	div x, a
	cp a, #0
	jrne not_leap
	ldw x, #daystab
	ld a, #29
	mov FLASH_DUKR, #$AE
	mov FLASH_DUKR, #$56
wait_DUL_l
	btjf FLASH_IAPSR, #3, wait_DUL_l
	ld (1,x), a
	bres FLASH_IAPSR, #3
	ret
not_leap
	ldw x, #daystab
	ld a, #28
	mov FLASH_DUKR, #$AE
	mov FLASH_DUKR, #$56
wait_DUL_nl
	btjf FLASH_IAPSR, #3, wait_DUL_nl
	ld (1,x), a
	bres FLASH_IAPSR, #3
	ret

check_hrly:
	btjt hrly, #0, hrly_on								;если флаг ежечасного сигала поднят,
	ret																		;иначе просто засыпаем
hrly_on
	mov byte1, minutes										;то вычисляем кол-во минут до сигнала
	call bcd_dec
	ld a, #59
	sub a, byte2 
	ldw x, #60														;вычисляем сколько секунд до сигнала
	mul x, a
	ldw scndslft, x

	mov byte1, seconds
	call bcd_dec
	ld a, #59
	sub a, byte2
	clrw x
	ld xl, a
	addw x, scndslft
skip_ss_sbt
	call WUT_setup_hrly										;и настраиваем таймер пробуждения
	ldw RTC_WUTRH, x
	bset RTC_CR2, #WUTE										;и запускаем таймер пробуждения
	ret
	
WUT_setup_hrly:
	bres RTC_CR2, #WUTE										;включаем запись в регистр
wait_WUTWF_hrly
	btjf RTC_ISR1, #WUTWF, wait_WUTWF_hrly
	bset RTC_CR1, #WUCKSEL2
	bres RTC_CR1, #WUCKSEL1
	bres RTC_CR1, #WUCKSEL0								;тактовое питание - ck_spre (1 Гц)
	ret
	
.WUT_setup_play:
	bres RTC_CR2, #WUTE										;включаем запись в регистр
wait_WUTWF_play
	btjf RTC_ISR1, #WUTWF, wait_WUTWF_play
	bres RTC_CR1, #WUCKSEL2
	bset RTC_CR1, #WUCKSEL1
	bset RTC_CR1, #WUCKSEL0								;тактовое питание с LSE RTCCLK/2
	ret
	end
