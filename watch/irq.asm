stm8/
	extern main
	#include "mapping.inc"
	extern tim2_handler.l
	extern tim4_handler.l
	extern RTC_handler.l
	extern key1_handler.l
	extern key2_handler.l
	extern key3_handler.l
	extern key4_handler.l
	extern PVD_handler.l
	
	segment 'rom'
reset.l
	; initialize SP
	ldw X,#$03ff
	ldw SP,X
	jp main
	jra reset
	
	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret
	
	segment 'vectit'
	dc.l {$82000000+reset}								; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+RTC_handler}					; irq4
	dc.l {$82000000+PVD_handler}					; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
	dc.l {$82000000+key4_handler}					; irq8
	dc.l {$82000000+key1_handler}					; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+key3_handler}					; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+key2_handler}					; irq15
	dc.l {$82000000+NonHandledInterrupt}	; irq16
	dc.l {$82000000+NonHandledInterrupt}	; irq17
	dc.l {$82000000+NonHandledInterrupt}	; irq18
	dc.l {$82000000+tim2_handler}					; irq19
	dc.l {$82000000+NonHandledInterrupt}	; irq20
	dc.l {$82000000+NonHandledInterrupt}	; irq21
	dc.l {$82000000+NonHandledInterrupt}	; irq22
	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+tim4_handler}					; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29
	
	end
	