stm8/
	#include "STM8L051F3.inc"
	extern readtime
	
	extern alarmflag
	extern beeperflag
	extern minutes
	extern delay
	extern mode
	
	extern hrlyflag
	extern WUT_setup_play
	extern melody
	
	segment 'rom'
ALRAE																				equ 0
	
.alarmparse:
	btjt alarmflag, #0, alarm_fired
	btjt alarmflag, #1, active
	ret
	
active
	call readtime
	ld a, RTC_ALRMAR2
	and a, #%01111111
	cp a, minutes
	jrne deactive
	ret
deactive
	bres alarmflag, #1												;��������� ����� ����������
	
	bset beeperflag, #1												;������������� �����. �������
	bres beeperflag, #3												;��������� ����� �������
	mov mode, #1
	ldw x, #12288
	call delay
	ret
	
alarm_fired
	bres alarmflag, #0												;���������� ���� ����������
	
	bset alarmflag, #1												;�������� ����� ����������
	
	bset beeperflag, #0												;��������� �����. �������
	bset beeperflag, #3												;�������� ����� �������
	ret
	
	end
	