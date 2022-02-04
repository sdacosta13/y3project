
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/shm.h>
#include <unistd.h>
#include <sys/signal.h>
#include <time.h>

#define TRUE  (0==0)
#define FALSE (0!=0)
typedef int boolean;

#define     button_nums 62


int     shm_ID;
struct  shm_struct {
  uint8_t   button_state[button_nums];
  uint32_t  button_time[button_nums];
};
struct  shm_struct *shm_ptr;
char    *dlibname;
boolean last_states[button_nums];

// unit information
#define BLOCKSIZE     4096
#define BASE_ADDR     0xf1002000
#define SIMPLE_ADDR   0xf1003000
#define LAST_ADDR     BASE_ADDR + VALUE_REG
#define DIRECTION_REG 0   // 'cpu' cycles as reported by steps_reset
#define VALUE_REG     4   // unix (epoch) second clock
char    *dlibname; // name given to us in jimulator arguments

// unit state
uint8_t   direction;
uint8_t   drive_value;

// link to steps counter variable in jimulator
extern unsigned int steps_reset;


boolean destructor(unsigned char *name) {
  fprintf(stderr, "%s: destructed\n", dlibname);
  free(dlibname);
  return TRUE;
}

// Compile this file with
// gcc lib_keyboard.c --shared -fPIC -g -o lib_keyboard.so

boolean constructor(unsigned char *name, unsigned char *arguments){
  char *parseptr;
  dlibname = strdup(strtok_r(arguments, " ", &parseptr));
  for(int i = 0; i < button_nums; i++){
    last_states[i] = 0;
  }
  pid_t new_PID = fork();
  if(new_PID == -1){
    fprintf(stderr, "%s: ERROR - Fork failed\n", dlibname);
    return FALSE;
  } else if(new_PID ==0){
    if(execlp("glade/glade_keyboard", "glade/glade_keyboard", NULL) < 0){  // Needs fix, change to static path
      fprintf(stderr, "%sERROR - execlp failed\n", dlibname);
      return FALSE;
    } else {
      return TRUE;
    }
  } else {
    key_t shm_key = 123456; // arbitrary key
    if((shm_ID = shmget(shm_key, sizeof(struct shm_struct), 0666 | IPC_CREAT)) < 0){  // get the shared memory
      fprintf(stderr, "%s: ERROR shmget FAIL\n", dlibname);
      return FALSE;
    }
    if ((shm_ptr = (struct shm_struct *) shmat(shm_ID, NULL, 0)) == (struct shm_struct *) -1) { // attach shared memory
      fprintf(stderr, "%s: ERROR - cannot attach shared memory.\n", dlibname);
      return FALSE;
    }
    return TRUE;
  }
}
int lastButtonUpdate = 0;
int lastButtonState = 0;
int capslockstate = 0;
void irq_handler(uint8_t *irq, uint8_t *fiq) { // Currently not throwing an interrupt for unpushing, might be due to lost updates
  *fiq = 0;
  *irq = 0;
  for(int i = 0; i < button_nums; i++){
    if(shm_ptr->button_state[i] != last_states[i]){
        *irq |= 1 << 7;
        lastButtonUpdate = i;
        lastButtonState = shm_ptr->button_state[i];
        if(i == 28){
          capslockstate += 1;
          if(capslockstate > 3) capslockstate = 0;
        }
    }
    last_states[i] = shm_ptr->button_state[i];
  }
  //fprintf(stderr, "%s: irq polled irq=%d fiq=%d\n", dlibname, *irq, *fiq);
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
unsigned int translateToAscii(int position, boolean upperLower){
    /*
      This function converts the ID read from the glade UI to an ascii character
      However as I am not interested in implementing the whole ascii character set,
      some keys which have no direct ascii code have had their code set differently
      I have only left these keys in for aesthetic purposes, the codes will still be readable
      for if i decide to use them later
      Remapped keys:
        Caps:  128 (capslock functionality should be implemented in this script)
        Shift: 129
        Control: 130
        Win: 131
        Alt: 132
        Alt Gr: 133
        Fn: 134
        Page: 135
        Pound sign: 36 (Set to also output $)
    */

    unsigned int ascii_characters_lower[] = {
      96, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 45, 61, 8,
      9, 113, 119, 101, 114, 116, 121, 117, 105, 111, 112, 91, 93, 10,
      128, 97, 115, 100, 102, 103, 104, 106, 107, 108, 59, 39, 35,
      129, 92, 122, 120, 99, 118, 98, 110, 109, 44, 46, 47, 129,
      130, 131, 132, 32, 133, 134, 135, 130
    };
    unsigned int ascii_characters_upper[] = {
      126, 33, 34, 36, 36, 37, 94, 38, 42, 40, 41, 95, 43, 8,
      9, 81, 87, 69, 82, 84, 89, 85, 73, 79, 80, 123, 125, 10,
      128, 65, 83, 68, 70, 71, 72, 74, 75, 76, 58, 64, 126,
      129, 124, 90, 88, 67, 86, 66, 78, 77, 60, 62, 63, 129,
      130, 131, 132, 32, 133, 134, 135, 130
    };
    if(!upperLower){
      return ascii_characters_lower[position];
    } else {
      return ascii_characters_upper[position];
    }
}
boolean mem_r_handler(unsigned int address, unsigned int *data, int size,
    boolean sign, boolean T, int source, boolean* abort) {
    *abort = FALSE;
    if(address == SIMPLE_ADDR){
      // Replaces Simple PIO address
      *data = 0; // set byte to 0
      if(capslockstate == 0 || capslockstate == 1){
        *data = translateToAscii(lastButtonUpdate, FALSE);
      }
      else{
        *data = translateToAscii(lastButtonUpdate, TRUE);
      }
      return TRUE;
    } else if(address == BASE_ADDR) {
      *data = 0;
      *data |= lastButtonState;
      return TRUE;
    } else {
      return FALSE;
    }
}
