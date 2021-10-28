#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>

// booleans as defined by jimulator
#define TRUE  (0==0)
#define FALSE (0!=0)
typedef int boolean;

// link to steps counter variable in jimulator
extern unsigned int steps_reset;

// unit information
#define CLOCK_FREQ      1000000
#define CLOCK_PER_MSEC  (CLOCK_FREQ / 1000)
#define BASE_ADDR       0xf1001000
#define LAST_ADDR       BASE_ADDR + TRIG_REG
#define CYCLES_REG      0x0       // emul: 'cpu' cycles as reported by steps_reset
#define UNIX_SEC_REG    0x4       // real: unix (epoch) second clock
#define UNIX_NSEC_REG   0x8       // real: unix (epoch) nanosecond clock
#define CTRL_REG        0xC       // emul: control register
#define MSEC_REG        0x10      // emul: msec register
#define TRIG_REG        0x14      // emul: msec trigger register

#define CTRL_MASK_INT_ENABLE    1<<0    // enable or disable interrupts
#define CTRL_MASK_INT_FIQ       1<<1    // perform FIQ instead of IRQ 

char            *dlibname;      // name given to us in jimulator arguments
unsigned int    ctrl_reg;    // control reg value
unsigned int    trig_reg;    // control reg value

boolean constructor(unsigned char *name, unsigned char *arguments) {
  char *parseptr;
  dlibname = strdup(strtok_r(arguments, " ", &parseptr));  // get arg[0] (library name)
  fprintf(stderr, "%s: constructed\n", dlibname);
  ctrl_reg = 0;
  trig_reg = 0;
  return TRUE;
}

boolean destructor(unsigned char *name) {
  fprintf(stderr, "%s: destructed\n", dlibname);
  free(dlibname);
  return TRUE;
}

unsigned int get_msec() {
  return (steps_reset / CLOCK_PER_MSEC) % 256;
}

void irq_handler(uint8_t *irq, uint8_t *fiq) {
  *irq = 0;
  *fiq = 0;
  if (ctrl_reg & CTRL_MASK_INT_ENABLE) {
    struct timespec time;
    clock_gettime(CLOCK_REALTIME, &time);
    if (get_msec() == trig_reg)
      *((ctrl_reg & CTRL_MASK_INT_FIQ) ? fiq : irq) = 1<<0;
  }

  //fprintf(stderr, "%s: irq polled irq=%d fiq=%d\n", dlibname, *irq, *fiq);
}

boolean mem_r_handler(unsigned int address, unsigned int *data, int size,
    boolean sign, boolean T, int source, boolean* abort) {
  if (address >= BASE_ADDR && address <= LAST_ADDR) {
    if (size == 4 && address % 4 == 0) {

      struct timespec time;
      *abort = FALSE;

      switch (address - BASE_ADDR) {
        case CYCLES_REG:
          *data = steps_reset;
          break;
        case UNIX_SEC_REG:
          clock_gettime(CLOCK_REALTIME, &time);
          *data = time.tv_sec;
          break;
        case UNIX_NSEC_REG:
          clock_gettime(CLOCK_REALTIME, &time);
          *data = time.tv_nsec;
          break;
        case CTRL_REG:
          *data = ctrl_reg;
          break;
        case MSEC_REG:
          *data = get_msec();
          break;
        case TRIG_REG:
          *data = trig_reg;
          break;
        default:
          *abort = TRUE;
          break;
      }
      //fprintf(stderr, "%s: read(%08x) = %d\n", dlibname, address, *data);
    } else {
      //fprintf(stderr, "%s: read(%08x) aborted\n", dlibname, address);
      *abort = TRUE;
    }
    return TRUE;
  } else {
    return FALSE;
  }
}

// abort all writes
boolean mem_w_handler(unsigned int address, unsigned int data, int size,
    boolean T, int source, boolean* abort) {
  if (address >= BASE_ADDR && address <= LAST_ADDR) {
    if (size == 4 && address % 4 == 0) {
      *abort = FALSE;
      switch (address - BASE_ADDR) {
        case CTRL_REG:
          ctrl_reg = data;
          break;
        case TRIG_REG:
          trig_reg = data;
          break;
        default:
          *abort = TRUE;
          break;
      }
      //fprintf(stderr, "%s: read(%08x) = %d\n", dlibname, address, *data);
    } else {
      //fprintf(stderr, "%s: read(%08x) aborted\n", dlibname, address);
      *abort = TRUE;
    }
    return TRUE;
  } else {
    return FALSE;
  }
}
