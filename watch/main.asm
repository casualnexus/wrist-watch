stm8/
	#include "STM8L051F3.inc"
	extern init.w
	extern show_hhmm
	extern show_ss
	extern show_ddmm
	extern show_wd
	extern show_yyyy
	extern show_alrm_hhmm
	extern show_melody
	extern show_alrm_arm
	extern show_batterty_v
	extern show_clbr_val
	extern show_hrly
	extern flash_first
	extern flash_last
	extern flash_wd
	extern flash_yyyy
	extern flash_alrm
	extern flash_clbr
	extern flash_hrly
	extern corr_daystab
	extern byte1
	extern byte2
	extern keyparse
	extern timerparse
	extern beeperparse
	extern alarmparse
	extern batteryparse
	extern hourlyparse
	extern readtime
	extern reset_ss
	extern delay

	segment 'rom'
BEEPER 									equ 0
RTC_ISR1_RSF						equ 5
TIM2_CR1_CEN						equ 0

	segment 'ram0'
.seconds								ds.b
.minutes								ds.b
.hours									ds.b
.date										ds.b
.monthweekd							ds.b
.year										ds.b
.mode										ds.b
.hrly										ds.b

	segment 'rom'
.main
	call init
	mov mode, #1
	ldw x, #12288
	call delay
loop1:
	call readtime
	call keyparse
	call timerparse
	call beeperparse
	call alarmparse
	call batteryparse

	ld a, mode
	cp a, #1
	jreq hhmm
	cp a, #2
	jreq ss
	cp a, #3
	jreq ddmm
	cp a, #4
	jreq weekd
	cp a, #5
	jreq yyyy
	cp a, #6
	jreq alrm_hhmm
	cp a, #7
	jreq battery_v
	cp a, #8
	jreq calibration
	cp a, #9
	jreq hourly
	cp a, #21
	jreq setup_ss
	cp a, #11
	jreq setup_mm
	cp a, #12
	jreq accept_mm
	
	jp loop2
	
hhmm:															;mode = 1
	call show_hhmm
	mov mode, #10
	jp loop1
ss:																;mode = 2
	call show_ss
	jp loop1
ddmm:															;mode = 3
	call show_ddmm
	mov mode, #30
	jp loop1
weekd:														;mode = 4
	call show_wd
	mov mode, #40
	jp loop1
yyyy:															;mode = 5
	call show_yyyy
	mov mode, #50
	jp loop1
alrm_hhmm:												;mode = 6
	call show_alrm_hhmm
	mov mode, #60
	jp loop1
battery_v:												;mode = 7
	call show_batterty_v
	;mov mode, #70
	jp loop1
calibration:											;mode = 8
	call show_clbr_val
	mov mode, #80
	jp loop1
hourly:														;mode = 9
	call show_hrly
	mov mode, #90
	jp loop1
	
setup_ss:													;mode = 21
	mov byte2, seconds
	call flash_last
	jp loop1

setup_mm:													;mode = 11
	mov byte2, minutes
	call flash_last
	jp loop1
accept_mm:												;mode = 12
	call show_hhmm
	mov mode, #13
	jp loop1

loop2:
	cp a, #13
	jreq setup_hh
	cp a, #14
	jreq accept_hh
	cp a, #31
	jreq setup_mt
	cp a, #32
	jreq accept_mt
	cp a, #33
	jreq setup_dd
	cp a, #34
	jreq accept_dd
	cp a, #41
	jreq setup_wd
	cp a, #42
	jreq accept_wd
	cp a, #51
	jreq setup_yyyy
	cp a, #52
	jreq accept_yyyy
	cp a, #61
	jreq setup_alrm_mm
	cp a, #62
	jreq accept_alrm_mm
	cp a, #63
	jreq setup_alrm_hh
	
	jp loop3

setup_hh:													;mode = 13
	mov byte1, hours
	call flash_first
	jp loop1

accept_hh:												;mode = 14
	mov mode, #1
	jp loop1
	
setup_mt:													;mode = 31
	ld a, monthweekd
	and a, #%00011111
	ld byte2, a
	call flash_last
	jp loop1
	
accept_mt:												;mode = 32
	call show_ddmm
	mov mode, #33
	jp loop1
	
setup_dd:													;mode = 33
	mov byte1, date
	call flash_first
	jp loop1
accept_dd:												;mode = 34
	mov mode, #3
	jp loop1

setup_wd:													;mode = 41
	call flash_wd
	jp loop1
accept_wd													;mode = 42
	mov mode, #4
	jp loop1
	
setup_yyyy:												;mode = 51
	call flash_yyyy
	jp loop1
accept_yyyy:											;mode = 52
	call corr_daystab
	mov mode, #5
	jp loop1

setup_alrm_mm:										;mode = 61
	ld a, RTC_ALRMAR2
	and a, #%01111111
	ld byte2, a
	call flash_last
	jp loop1
accept_alrm_mm:										;mode = 62
	call show_alrm_hhmm
	mov mode, #63
	jp loop1
setup_alrm_hh:										;mode = 63
	ld a, RTC_ALRMAR3
	and a, #%00111111
	ld byte1, a
	call flash_first
	jp loop1
	
loop3:
	cp a, #64
	jreq accept_alrm_hh
	cp a, #65
	jreq setup_melody
	cp a, #66
	jreq arm_alrm
	cp a, #81
	jreq setup_clbr
	cp a, #82
	jreq accept_clbr
	cp a, #91
	jreq setup_hrly
	cp a, #92
	jreq accept_hrly
	
	jp loop1

accept_alrm_hh:										;mode = 64
	;call show_alrm_hhmm
	mov mode, #65
	jp loop1
setup_melody:											;mode = 65
	call show_melody
	jp loop1
arm_alrm:													;mode = 66
	call show_alrm_arm
	jp loop1
setup_clbr:												;mode = 81
	call flash_clbr
	jp loop1
accept_clbr:											;mode = 82
	mov mode, #8
	jp loop1
setup_hrly:												;mode = 91
	call flash_hrly
	jp loop1
accept_hrly:											;mode = 92
	mov mode, #9
	jp loop1
	
	end
	