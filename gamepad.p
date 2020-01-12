// PRU0 firmware to interface with a pair of SNES gamepads. Written by Andrew 
// Henderson (hendersa@icculus.org). Four GPIOs are used by this firmware:
//
// OUTPUTS
// Clock: P9.11, GPIO0[30]
// Latch: P9.13, GPIO0[31]
// INPUTS
// P1DATA: P9.17, GPIO0[03]
// P2DATA: P9.21, GPIO0[05]

.origin 0
.entrypoint INIT

// Offsets of GPIO bits
#define GP0_BIT     #3
#define GP1_BIT     #5
#define CLOCK_BIT   t30
#define LATCH_BIT   t31

// Defines for regs
#define GPIO_OUT    r4
#define GPIO_IN     r5
#define TICK_CNT    r6
#define GPSTATE     r25
#define DELAY_CNT   r29
#define GP0_REG     r12
#define GP1_REG     r13

INIT:
  // Enable OCP master port
  LBCO r0, C4, #4, #4
  CLR  r0.t4
  SBCO r0, C4, #4, #4

  // Configure the programmable pointer register for PRU0 
  // by setting c28_pointer[15:0] field to 0x0120.  This 
  // will make C28 point to 0x00012000 (PRU shared RAM).
  MOV  r0, #0x00000120
  MOV  r1, #0x22028  // CTPPR_0
  SBBO r0, r1, #0, #4

  // Configure the programmable pointer register for 
  // PRU0 by setting c31_pointer[15:0] field to 0x0010.
  // This will make C31 point to 0x80001000 (DDR memory).
  MOV  r0, #0x00100000
  MOV  r1, #0x2202C  // CTPPR_1
  SBBO r0, r1, #0, #4

  // Setup constant registers
  MOV  GPIO_OUT, #0x44E0713C
  MOV  GPIO_IN,  #0x44E07138

BEGIN_POLL:
  // Set latch
  LBBO r0, GPIO_OUT, #0, #4
  SET  r0.LATCH_BIT
  SBBO r0, GPIO_OUT, #0, #4

  CALL DELAY_6US
  CALL DELAY_6US

  // Clear latch and set clock
  LBBO r0, GPIO_OUT, #0, #4
  CLR  r0.LATCH_BIT
  SET  r0.CLOCK_BIT
  SBBO r0, GPIO_OUT, #0, #4

  // Setup button state loop
  MOV  TICK_CNT, #16
  MOV  GPSTATE, #0

BUTTON_LOOP:
  CALL DELAY_6US

  // Clear clock
  LBBO r0, GPIO_OUT, #0, #4
  CLR  r0.CLOCK_BIT
  SBBO r0, GPIO_OUT, #0, #4

  // Read bit from each gamepad
  LBBO r0, GPIO_IN, #0, #4
  LSR  GP0_REG, r0, GP0_BIT
  AND  GP0_REG, GP0_REG, #1
  LSR  GP1_REG, r0, GP1_BIT
  AND  GP1_REG, GP1_REG, #1

  // Shift/store gamepad state
  LSL  GPSTATE, GPSTATE, #1
  OR   GPSTATE, GPSTATE, GP0_REG 
  LSL  GPSTATE, GPSTATE, #1
  OR   GPSTATE, GPSTATE, GP1_REG

  CALL DELAY_6US

  // Set clock
  LBBO r0, GPIO_OUT, #0, #4
  SET  r0.CLOCK_BIT
  SBBO r0, GPIO_OUT, #0, #4

  // Decrement counter and loop
  SUB  TICK_CNT, TICK_CNT, #1
  QBNE BUTTON_LOOP, TICK_CNT, #0
BUTTON_CLEANUP:
  // Store into PRU shared mem
  MOV  r0, GPSTATE
  SBCO r0, C28, #0, #4

  // Delay 16.4 ms and then loop
  CALL DELAY_16MS
  QBA  BEGIN_POLL

// 6us delay subroutine
DELAY_6US:
  MOV  DELAY_CNT, #12000
LOOP_6US:
  SUB  DELAY_CNT, DELAY_CNT, #1
  QBNE LOOP_6US, DELAY_CNT, #0
  RET

// 16.4ms delay subroutine
DELAY_16MS:
  MOV  DELAY_CNT, #4100000
LOOP_16MS:
  SUB  DELAY_CNT, DELAY_CNT, #1
  QBNE LOOP_16MS, DELAY_CNT, #0
  RET

  // Shutdown (never reached)
  MOV  r31.b0, 19+16

HALT

