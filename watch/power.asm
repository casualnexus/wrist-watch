stm8/
	#include "STM8L051F3.inc"
	extern show_batterty_v

	segment 'eeprom'
.v_strings
	dc.b "1.85","2.05","2.26","2.45","2.65","2.85","3.05"

	segment 'ram0'
.voltage							ds.b
.pvd_event						ds.b

	segment 'rom'
PVDE									equ 0
PLS0									equ 1
PLS1									equ 2
PLS2									equ 3
PVDIEN								equ 4
PVDIF									equ 5
PVDOF									equ 6
	
	interrupt PVD_handler
.PVD_handler.l:
	bset PWR_CSR1, #PVDIF											;сбрасываем флаг
	mov pvd_event, #1
	iret
	
.batteryparse
	ld a, pvd_event
	jreq stop_measuring
	
	mov pvd_event, #0
	btjf PWR_CSR1, #PVDOF, stop_measuring			;если зн-е выше порогового - увел
	ld a, voltage
	cp a, #0
	jreq stop_measuring												;если напр€жение мин. - стоп
	dec voltage
	call set_threshold												;записываем новый порог
stop_measuring
	ret

.set_threshold:
	ld a, voltage
	sll a
	
	bres PWR_CSR1, #PVDIEN
	bres PWR_CSR1, #PVDE
		
	ld PWR_CSR1, a
	
	bset PWR_CSR1, #PVDIEN
	bset PWR_CSR1, #PVDE
	
	ret
	
	end
	