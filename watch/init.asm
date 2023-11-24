stm8/
	#include "STM8L051F3.inc"
	extern delay
	extern timerflag
	
	extern key1flag
	extern key2flag
	extern key3flag
	extern key4flag
	
	extern beeperflag
	extern idx
	extern melody
	
	extern readtime
	extern calls
	
	extern voltage
	extern pvd_event
	
	extern hrly
	extern hrlyflag

	segment 'rom'
ULP								equ 1
FWU								equ 2

RTCSWBSY					equ 0
LSEON 						equ 2

RTCDIV_1_LSE			equ %00010000

INIT							equ 7
INITF							equ 6
FMT								equ 6
PCKEN22						equ 2
WUTWF							equ 2
WUTE							equ 2
WUTIE							equ 6
URS								equ	2
ALRAIE						equ 4
ALRAE							equ 0

WUTF							equ 2
ALRAF							equ 0
UIF								equ 0

PCKEN10						equ 0
PCKEN11						equ 1
PCKEN12						equ 2
OPM								equ 3
DIVIDER_1					equ 0
TIM2_ETR_CFG			equ %01110000
TIM3_ETR_CFG			equ %01000000
TIM2TRIGLSE_REMAP	equ 3
TIM3TRIGLSE_REMAP equ 4
TIM2_ETR_ECE			equ 6
ARPE							equ 7
UIE								equ 0

WUCKSEL0					equ 0
WUCKSEL1					equ 1
WUCKSEL2					equ 2

DSPLY_A0					equ	0
DSPLY_A1					equ 2
DSPLY_NWR					equ 3

DSPLY_CTRL_CFG		equ %00001101
DSPLY_DBUS_CFG		equ %01111111

PVDE							equ 0
PLS0							equ 1
PLS1							equ 2
PLS2							equ 3
PVDIEN						equ 4
PVDIF							equ 5

	segment 'rom'
.init:
	;инициализируем переменные
	mov timerflag, #0
	mov key1flag, #0
	mov key2flag, #0
	mov key3flag, #0
	mov key4flag, #0
	mov beeperflag, #0
		
	mov melody, #3
	mov idx, #0
	
	mov voltage, #6
	mov pvd_event, #0
	
	mov hrly, #0
	mov hrlyflag, #0
	
	;настраиваем подсистему питания
	bset PWR_CSR2, #ULP													;отключение внутр. и.п. в HALT
	bres PWR_CSR2, #FWU													;старт с ожиданием внутр. и.п.
	
	;настраиваем работу PVD
	bset PWR_CSR1, #PVDIF												;сбрасыаем прерываение перед актив
	bset PWR_CSR1, #PLS2
	bset PWR_CSR1, #PLS1												;пороговое = 3,05 В
	bset PWR_CSR1, #PVDIEN											;разрешаем прерывания
	bset PWR_CSR1, #PVDE												;включаем PVD
		
	;настраиваем тактовое питание RTC
	mov CLK_CRTCR, #RTCDIV_1_LSE 								;источник такт питаня -- RTC, /1
	bset CLK_PCKENR2, #PCKEN22									;подаем тактовое питание на RTC
		
	;запишем какие-то значения времени
	mov RTC_WPR, #$CA														;снимаем защиту от записи
	mov RTC_WPR, #$53
	
	bset RTC_ISR1, #INIT												;входим в режим инициализации
wait_init:																		;ждем переключения
	btjf RTC_ISR1, #INITF, wait_init
	mov RTC_TR2, #%00110000											;записываем минуты
	mov RTC_TR3, #%00000010											;часы
	mov RTC_DR1, #%00011001											;дату
	mov RTC_DR2, #%01000100											;день недели и месяц
	mov RTC_DR3, #%00100011											;год
	bres RTC_CR1, #FMT													;24-часовой формат
	bres RTC_ISR1, #INIT												;выходим из режим инициализации
	
	;настраиваем таймер пробуждения
	bres RTC_CR2, #WUTE													;включаем запись в регистр
wait_WUTWF
	btjf RTC_ISR1, #WUTWF, wait_WUTWF
	bres RTC_CR1, #WUCKSEL2
	bset RTC_CR1, #WUCKSEL1
	bset RTC_CR1, #WUCKSEL0											;тактовое питание с LSE RTCCLK/2
	bset RTC_CR2, #WUTIE												;разрешаем прерывание таймера
	
	;настраиываем будильник
	bres RTC_CR2, #ALRAE
	mov RTC_ALRMAR4, #%10000000									;не учитываются дата и день недели
	;mov RTC_ALRMAR2, #%00110001									;записываем минуты
	;mov RTC_ALRMAR3, #%00000010									;часы
	bset RTC_CR2, #ALRAIE												;включаем прерывание будильника
	;bset RTC_CR2, #ALRAE												;активируем будильник
	
	;настраиваем интерфейс с дисплеем
	;настраиваем TIM2 -- засыпание и мигание в режиме коррекции
	bset CLK_PCKENR1, #PCKEN10									;подаем т. питание на прескейлер
	mov TIM2_PSCR, #DIVIDER_1										;делитель = 1
	mov TIM2_ETR, #TIM2_ETR_CFG									;настраиваем на внешний источник
	bset SYSCFG_RMPCR2, #TIM2TRIGLSE_REMAP			;подаем LSE на вход TIM2
	bres TIM2_CR1, #ARPE												;откл автозагрузку
	bset TIM2_CR1, #OPM													;режим "one-pulse"
	bset TIM2_CR1, #URS													;прерыв по переполн или обнул сч.
	bset TIM2_IER, #UIE													;активируем прерывания TIM2
	
	;настраиваем TIM3 -- подавление дребезга и автоповтор нажатий
	bset CLK_PCKENR1, #PCKEN11									;подаем т. питание на прескейлер
	mov TIM3_PSCR, #DIVIDER_1										;делитель = 1
	mov TIM3_ETR, #TIM3_ETR_CFG									;настраиваем на внешний источник
	bset SYSCFG_RMPCR2, #TIM3TRIGLSE_REMAP			;подаем LSE на вход TIM3
	bres TIM3_CR1, #ARPE												;откл автозагрузку
	bset TIM3_CR1, #OPM													;режим "one-pulse"
	bset TIM3_CR1, #URS													;прерыв по переполн или обнул сч.
	
	;настраиваем TIM4 -- генератор звука
	bset CLK_PCKENR1, #PCKEN12									;подаем т. питание на прескейлер
	mov TIM4_PSCR, #%00000010										;делитель на 4
	bres TIM4_CR1, #ARPE												;откл автозагрузку
	bset TIM4_CR1, #OPM													;режим "one-pulse"
	bset TIM4_IER, #UIE													;активируем прерывания TIM4
	
	;настраиваем прерывания кнопок
	mov PC_DDR, #%00000000											;на вход (КН1, КН3, КН4)
	mov PC_CR1, #%00000000											;входы плавающие
	mov PC_CR2, #%00010011											;маска прерываний EXTI
	
	bres PB_DDR, #7															;КН2
	bres PB_CR1, #7
	bset PB_CR2, #7
	
	sim																					;запрещаем прерываения
	mov EXTI_CR1, #%00000000										;срабатывание входов по заднему
	mov EXTI_CR2, #%00000000										;фронту и низкому уровню
	bres RTC_ISR2, #ALRAF												;сбрасываем флаги прерываний
	bres RTC_ISR2, #WUTF
	bres TIM2_SR1, #UIF
	rim																					;разрешаем прерывания
	
	;настраиваем пищалку
	bset PD_DDR, #0
	bset PD_CR1, #0

	;настраиваем интерфейс дисплея
	;настраиваем адресные линии
	ld a, PA_DDR
	or a, #DSPLY_CTRL_CFG
	ld PA_DDR, a
	ld A, PA_CR1
	or A, #DSPLY_CTRL_CFG
	ld PA_CR1, a
	
	;шину данных
	mov PB_DDR, #DSPLY_DBUS_CFG
	mov PB_CR1, #DSPLY_DBUS_CFG
	
	;NWR в исходное состояние
	bset PA_ODR, #DSPLY_NWR
	
	;пауза 5 с
	ldw X, #20000
	call delay
wait_tim1:
	btjf timerflag, #0, wait_tim1								;ждем обновления счетчика
	
	ret
	end
	