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
	;�������������� ����������
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
	
	;����������� ���������� �������
	bset PWR_CSR2, #ULP													;���������� �����. �.�. � HALT
	bres PWR_CSR2, #FWU													;����� � ��������� �����. �.�.
	
	;����������� ������ PVD
	bset PWR_CSR1, #PVDIF												;��������� ����������� ����� �����
	bset PWR_CSR1, #PLS2
	bset PWR_CSR1, #PLS1												;��������� = 3,05 �
	bset PWR_CSR1, #PVDIEN											;��������� ����������
	bset PWR_CSR1, #PVDE												;�������� PVD
		
	;����������� �������� ������� RTC
	mov CLK_CRTCR, #RTCDIV_1_LSE 								;�������� ���� ������ -- RTC, /1
	bset CLK_PCKENR2, #PCKEN22									;������ �������� ������� �� RTC
		
	;������� �����-�� �������� �������
	mov RTC_WPR, #$CA														;������� ������ �� ������
	mov RTC_WPR, #$53
	
	bset RTC_ISR1, #INIT												;������ � ����� �������������
wait_init:																		;���� ������������
	btjf RTC_ISR1, #INITF, wait_init
	mov RTC_TR2, #%00110000											;���������� ������
	mov RTC_TR3, #%00000010											;����
	mov RTC_DR1, #%00011001											;����
	mov RTC_DR2, #%01000100											;���� ������ � �����
	mov RTC_DR3, #%00100011											;���
	bres RTC_CR1, #FMT													;24-������� ������
	bres RTC_ISR1, #INIT												;������� �� ����� �������������
	
	;����������� ������ �����������
	bres RTC_CR2, #WUTE													;�������� ������ � �������
wait_WUTWF
	btjf RTC_ISR1, #WUTWF, wait_WUTWF
	bres RTC_CR1, #WUCKSEL2
	bset RTC_CR1, #WUCKSEL1
	bset RTC_CR1, #WUCKSEL0											;�������� ������� � LSE RTCCLK/2
	bset RTC_CR2, #WUTIE												;��������� ���������� �������
	
	;������������ ���������
	bres RTC_CR2, #ALRAE
	mov RTC_ALRMAR4, #%10000000									;�� ����������� ���� � ���� ������
	;mov RTC_ALRMAR2, #%00110001									;���������� ������
	;mov RTC_ALRMAR3, #%00000010									;����
	bset RTC_CR2, #ALRAIE												;�������� ���������� ����������
	;bset RTC_CR2, #ALRAE												;���������� ���������
	
	;����������� ��������� � ��������
	;����������� TIM2 -- ��������� � ������� � ������ ���������
	bset CLK_PCKENR1, #PCKEN10									;������ �. ������� �� ����������
	mov TIM2_PSCR, #DIVIDER_1										;�������� = 1
	mov TIM2_ETR, #TIM2_ETR_CFG									;����������� �� ������� ��������
	bset SYSCFG_RMPCR2, #TIM2TRIGLSE_REMAP			;������ LSE �� ���� TIM2
	bres TIM2_CR1, #ARPE												;���� ������������
	bset TIM2_CR1, #OPM													;����� "one-pulse"
	bset TIM2_CR1, #URS													;������ �� �������� ��� ����� ��.
	bset TIM2_IER, #UIE													;���������� ���������� TIM2
	
	;����������� TIM3 -- ���������� �������� � ���������� �������
	bset CLK_PCKENR1, #PCKEN11									;������ �. ������� �� ����������
	mov TIM3_PSCR, #DIVIDER_1										;�������� = 1
	mov TIM3_ETR, #TIM3_ETR_CFG									;����������� �� ������� ��������
	bset SYSCFG_RMPCR2, #TIM3TRIGLSE_REMAP			;������ LSE �� ���� TIM3
	bres TIM3_CR1, #ARPE												;���� ������������
	bset TIM3_CR1, #OPM													;����� "one-pulse"
	bset TIM3_CR1, #URS													;������ �� �������� ��� ����� ��.
	
	;����������� TIM4 -- ��������� �����
	bset CLK_PCKENR1, #PCKEN12									;������ �. ������� �� ����������
	mov TIM4_PSCR, #%00000010										;�������� �� 4
	bres TIM4_CR1, #ARPE												;���� ������������
	bset TIM4_CR1, #OPM													;����� "one-pulse"
	bset TIM4_IER, #UIE													;���������� ���������� TIM4
	
	;����������� ���������� ������
	mov PC_DDR, #%00000000											;�� ���� (��1, ��3, ��4)
	mov PC_CR1, #%00000000											;����� ���������
	mov PC_CR2, #%00010011											;����� ���������� EXTI
	
	bres PB_DDR, #7															;��2
	bres PB_CR1, #7
	bset PB_CR2, #7
	
	sim																					;��������� �����������
	mov EXTI_CR1, #%00000000										;������������ ������ �� �������
	mov EXTI_CR2, #%00000000										;������ � ������� ������
	bres RTC_ISR2, #ALRAF												;���������� ����� ����������
	bres RTC_ISR2, #WUTF
	bres TIM2_SR1, #UIF
	rim																					;��������� ����������
	
	;����������� �������
	bset PD_DDR, #0
	bset PD_CR1, #0

	;����������� ��������� �������
	;����������� �������� �����
	ld a, PA_DDR
	or a, #DSPLY_CTRL_CFG
	ld PA_DDR, a
	ld A, PA_CR1
	or A, #DSPLY_CTRL_CFG
	ld PA_CR1, a
	
	;���� ������
	mov PB_DDR, #DSPLY_DBUS_CFG
	mov PB_CR1, #DSPLY_DBUS_CFG
	
	;NWR � �������� ���������
	bset PA_ODR, #DSPLY_NWR
	
	;����� 5 �
	ldw X, #20000
	call delay
wait_tim1:
	btjf timerflag, #0, wait_tim1								;���� ���������� ��������
	
	ret
	end
	