#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/shm.h>
#include <unistd.h>
#include <sys/signal.h>
#include <time.h>

// booleans as defined by jimulator
#define TRUE  (0==0)
#define FALSE (0!=0)
typedef int boolean;

// link to steps counter variable in jimulator
extern unsigned int steps_reset;
boolean last_state_a, last_state_b;

// unit information
#define BLOCKSIZE     4096
#define BASE_ADDR     0xf1002000
#define SIMPLE_ADDR   0xf1003000
#define LAST_ADDR     BASE_ADDR + VALUE_REG
#define DIRECTION_REG 0   // 'cpu' cycles as reported by steps_reset
#define VALUE_REG     4   // unix (epoch) second clock
char    *dlibname; // name given to us in jimulator arguments

// shm stuff
int     shm_ID;
int     shm_key = 124;
struct  shm_struct {
  uint8_t   button_state[16];
  uint32_t  button_time[16];
};
struct  shm_struct *shm_ptr;

// unit state
uint8_t   direction;
uint8_t   drive_value;

boolean constructor(unsigned char *name, unsigned char *arguments) {
  char *parseptr;
  dlibname = strdup(strtok_r(arguments, " ", &parseptr));  // get arg[0] (library name)
  //fprintf(stderr, "%s: constructed\n", dlibname);

  pid_t new_PID = fork();
  if (new_PID == -1) {
    fprintf(stderr, "%s: ERROR - cannot fork virtual screen.\n", dlibname);
    return FALSE;
  } else if (new_PID == 0) {
  
    if (execlp("kmd_keypad", "kmd_keypad", NULL) < 0) {
      fprintf(stderr, "%s: ERROR - cannot start kmd_keypad.\n", dlibname);
      return FALSE;
    }
    
  } else {
  
    if ((shm_ID = shmget((key_t) shm_key, sizeof(struct shm_struct), 0666 | IPC_CREAT)) < 0) {
      fprintf(stderr, "%s: ERROR - cannot locate shared memory.\n", dlibname);
      return FALSE;
    }

    if ((shm_ptr = (struct shm_struct *) shmat(shm_ID, NULL, 0)) == (struct shm_struct *) -1) {
      fprintf(stderr, "%s: ERROR - cannot attach shared memory.\n", dlibname);
      return FALSE;
    }
    return TRUE;
    
  }
}

boolean destructor(unsigned char *name) {
  fprintf(stderr, "%s: destructed\n", dlibname);
  free(dlibname);
  return TRUE;
}


void irq_handler(uint8_t *irq, uint8_t *fiq) {
  *fiq = 0;
  *irq = 0;
  
  if(shm_ptr->button_state[12] != last_state_a)
    *irq |= 1<<6;
  if(shm_ptr->button_state[13] != last_state_b)
    *irq |= 1<<7;
    
  last_state_a = shm_ptr->button_state[12];
  last_state_b = shm_ptr->button_state[13];
  //fprintf(stderr, "%s: irq polled irq=%d fiq=%d\n", dlibname, *irq, *fiq);
}


boolean mem_r_handler(unsigned int address, unsigned int *data, int size,
    boolean sign, boolean T, int source, boolean* abort) {
  if (address >= BASE_ADDR && address <= LAST_ADDR) {
    if (size == 1 && address % 4 == 0) {
      uint8_t input_value = 0, final_value = 0;
      *abort = FALSE;
      switch (address - BASE_ADDR) {
        case DIRECTION_REG:
          *data = direction;
          break;
        case VALUE_REG:
          for (int row = 0; row < 3; row++) // calculate keypad value
            if (!(direction & 1<<(7-row)) && drive_value & 1<<(7-row))
              for (int col = 0; col < 4; col++)
                if(shm_ptr->button_state[col*3+row])
                  input_value |= 1<<col;
          for (int bit = 0; bit < 8; bit++) // calculate returned value
            if (direction & 1<<bit)
              final_value |= input_value & 1<<bit;
            else
              final_value |= drive_value & 1<<bit;
          *data = final_value;
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
  } else if (address == SIMPLE_ADDR) {
    *abort = FALSE;
    *data = 0;
    for (int bit = 0; bit < 4; bit++)
      if(shm_ptr->button_state[12+bit])
        *data |= 1<<bit;
    return TRUE;
  } else {
    return FALSE;
  }
}

// abort all writes
boolean mem_w_handler(unsigned int address, unsigned int data, int size,
    boolean T, int source, boolean* abort) {
  if (address >= BASE_ADDR && address <= LAST_ADDR) {
    if (size == 1 && address % 4 == 0) {
      *abort = FALSE;
      switch (address - BASE_ADDR) {
        case DIRECTION_REG:
          direction = data;
          break;
        case VALUE_REG:
          drive_value = data;
          break;
        default:
          *abort = TRUE;
          break;
      }
      //fprintf(stderr, "%s: write(%08x) = %d\n", dlibname, address, data);
    } else {
      //fprintf(stderr, "%s: write(%08x) aborted\n", dlibname, address);
      *abort = TRUE;
    }
    return TRUE;
  } else if (address == SIMPLE_ADDR) {
    *abort = TRUE;
    return TRUE;
  } else {
    return FALSE;
  }
}
