stm8/
	#include "STM8L051F3.inc"

	segment 'eeprom'
.wdtab										dc.b "MONDTUESWENDTHURFRIDSATUSUND"
.daystab									dc.b 31,28,31,30,31,30,31,31,30,31,30,31
	
	segment 'ram0'
.byte1										ds.b
.byte2 										ds.b
.wdstr										ds.b 4
counter										ds.b
	
	segment 'rom'
.bcd_dec:
	ld a, byte1
	and a,#%11110000
	swap a
	ld xl, a
	ld a, #10
	mul x, a
	ld a, xl
	ld byte2, a
	ld a, byte1
	and a, #%00001111
	add a, byte2
	ld byte2, a
	ret
	
.dec_bcd:
	ld a, byte1
	ldw x, #0
	ld xl, a
	ld a, #10
	div x, a
	push a
	ld a, xl
	swap a
	ld byte2, a
	pop a
	add a, byte2
	ld byte2, a
	ret
	
.dec_bcd_w:
	ld a, #100
	div x, a
	push a
	ld a, xl
	ld yl, a
	pop a
	ld byte1, a
	call dec_bcd
	ld a, yl
	ld byte1, a
	ret

.bitshift_left:
	sll byte1
	dec byte2
	jrne bitshift_left
	ret

.bitshift_right:
	srl byte1
	dec byte2
	jrne bitshift_right
	ret

.numofdays:
	and a, #%00011111
	ld byte1, a
	call bcd_dec
	dec byte2
	push byte2
	push #0
	popw x
	addw x, #daystab
	ld a, (X)
	ret
	
.get_wd_string:
	ld a, byte1							;загружаем календарное значение
	and a, #%11100000				;выделям данные о дне недели
	swap a
	srl a
	dec a										;приводим к виду идекса таблицы
	
	sll a										;умножаем номер дня недели на 2(4)
	sll a
	push a									;переносим смещение в x
	push #0
	popw x
	addw x, #wdtab					;добавляем к нему адрес таблицы
	ldw y, #wdstr						;переносим в y адрес буфера строки
	mov counter, #4					;записываем в счетчик 4
wds_loop
	ld a, (x)								;побайтно переносим строку в буфер
	ld (y), a
	incw x									;увеличиваем адрес смещения
	incw y
	dec counter
	jrne wds_loop
	
	ret
	end
	