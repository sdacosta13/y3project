#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

// booleans as defined by jimulator
#define TRUE  (0==0)
#define FALSE (0!=0)
typedef int boolean;

void write_mem(unsigned int address, int data, int size, boolean T, int source, boolean *abort);

#define BLOCKSIZE     4096
#define BASE_ADDR     0xf1000000
#define LAST_ADDR     BASE_ADDR + SIZE_REG
#define BUFFER_REG    0
#define SECTOR_REG    4
#define SIZE_REG      8

// file information
char    *fname;
FILE    *fp = NULL;
size_t  fsize = 0;
char    fbuf[BLOCKSIZE];

// module state
unsigned int buffer_location = 0x0;

boolean constructor(unsigned char *name, unsigned char *arguments) {
  //fprintf(stderr, "lib_fileaccess: constructed! name: %s, args: %s\n",
  //    name, arguments);
  char *parseptr;
  strtok_r(arguments, " ", &parseptr);             // throw away arg[0]
  fname = strdup(strtok_r(NULL, " ", &parseptr));  // copy arg[1]
  fp = fopen(fname, "rb");
  fseek(fp, 0, SEEK_END); // seek to end of file
  fsize = ftell(fp); // get current file pointer
  fseek(fp, 0, SEEK_SET); // seek back to beginning of file
  //fprintf(stderr, "lib_fileaccess: loaded: %s size: %ldb\n", fname, fsize);
  return TRUE;
}

boolean destructor(unsigned char *name) {
  fclose(fp);
  free(fname);
}


boolean mem_r_handler(unsigned int address, unsigned int *data, int size,
    boolean sign, boolean T, int source, boolean* abort) {
  if (address >= BASE_ADDR && address <= LAST_ADDR) {
    if (size == 4 && address % 4 == 0) {
      //fprintf(stderr, "lib_fileaccess: read(%08x) OK!\n", address);
      //fprintf(stderr, "lib_fileaccess: read(%08x) ", address);

      switch (address - BASE_ADDR) {
        case BUFFER_REG:
          *data = buffer_location;
          //fprintf(stderr, "BUFFER_REG = %08x\n", *data);
          break;
        case SECTOR_REG:
          *data = 0x0;
          //fprintf(stderr, "SECTOR_REG = %08x\n", *data);
          break;
        case SIZE_REG:
          *data = fsize;
          //fprintf(stderr, "SIZE_REG = %08x\n", *data);
          break;
        default:
          *abort = TRUE;
          break;
      }

      *abort = FALSE;
    } else {
      //fprintf(stderr, "lib_fileaccess: read(%08x) aborted\n", address);
      *abort = TRUE;
    }
    return TRUE;
  } else {
    //fprintf(stderr, "lib_fileaccess: read(%08x) ingored\n", address);
    return FALSE;
  }
}

boolean loadIntoRam(int sector) {
  //fprintf(stderr, "lib_fileaccess: Loading file %s, sec %d into 0x%08x!\n",
  //    fname, sector, buffer_location);

  int start = sector * BLOCKSIZE;   // index of first byte read
  if (start > fsize)
    return FALSE;

  int end = (sector+1) * BLOCKSIZE; // inded of first byte after 
  if (end > fsize)
    end = fsize;

  int count = end - start;          // read the data into buffer
  fseek(fp, start, SEEK_SET);
  int read = fread(fbuf, 1, count, fp);

  //fprintf(stderr, "lib_fileaccess: Read bytes %d to %d (%d/%d bytes read)\n",
  //    start, end-1, read, count);

  // write the buffer data to the emulator memory
  for (int i = 0; i < BLOCKSIZE / 1; i++) {
    boolean abort = FALSE;
    write_mem(buffer_location + i, fbuf[i], 1, FALSE, FALSE, &abort);
    if (abort) return FALSE;
  }

  return TRUE;
}

boolean mem_w_handler(unsigned int address, unsigned int data, int size,
    boolean T, int source, boolean* abort) {
  if (address >= BASE_ADDR && address <= LAST_ADDR) {
    if (size == 4 && address % 4 == 0) {
      //fprintf(stderr, "lib_fileaccess: write(%08x) = %08x OK!\n", address, data);
      //fprintf(stderr, "lib_fileaccess: write(%08x) ", address);

      switch (address - BASE_ADDR) {
        case BUFFER_REG:
          //fprintf(stderr, "BUFFER_REG = %08x\n", data);
          buffer_location = data;
          *abort = FALSE;
          break;
        case SECTOR_REG:
          //fprintf(stderr, "SECTOR_REG = %08x\n", data);
          loadIntoRam(data);
          *abort = FALSE;
          break;
        case SIZE_REG:
        default:
          //fprintf(stderr, "SIZE_REG = %08x\n", data);
          *abort = TRUE;
          break;
      }
      
    } else {
      //fprintf(stderr, "lib_fileaccess: write(%08x) = %08x aborted\n", address, data);
      *abort = TRUE;
    }
    return TRUE;
  } else {
    //fprintf(stderr, "lib_fileaccess: write(%08x) = %08x ingored\n", address, data);
    return FALSE;
  }
}
