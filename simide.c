/****************************************************************************/
/*                                                                          */
/*                                  SIMIDE                                  */
/*                         IDE Simulation Functions                         */
/*                           MP3 Jukebox Project                            */
/*                                 EE/CS 52                                 */
/*                                                                          */
/****************************************************************************/

/*
   This file contains a function for simulation an IDE hard drive for the MP3
   Jukebox project.  This function can be used to test the software without a
   physical hard drive being connected.  The functions included are:
      get_blocks - retrieve blocks of data from the simulated hard drive.

   The local functions included are:
      none

   The locally global variable definitions included are:
      none


   Revision History
      6/7/00   Glen George       Initial revision.
      6/10/00  Glen George       Changed hex character constants to octal so
                                 will compile under Intel C.
      6/2/02   Glen George       Fixed format for simulated index file, it was
                                 inconsistent with current code.
      6/2/02   Glen George       Updated comments.
*/



/* library include files */
  /* none */

/* local include files */
#include  "mp3defs.h"
#include  "interfac.h"



/* useful definitions */
#define  MAX_READ_SIZE   3      /* maximum number of blocks to read */

#define  NO_ENTRIES      3      /* number of song entries */

#define  BLOCK_LENGTH    8      /* number of characters in the block number */
#define  CHAR_COUNT      26     /* number of characters to put in a block */




/*
   get_blocks

   Description:      This function simulates the reading of blocks from an IDE
                     hard drive.  The data "read" is written to the memory
                     pointed to by the third argument.  The number of blocks
                     requested is given as the second argument.  If this value
                     is greater than the MAX_READ_SIZE, only MAX_READ_SIZE
                     blocks are read.  The starting block number to read is
                     passed as the first argument.  If this is between 0 and
                     NO_ENTRIES a fake track information block is returned.
                     Otherwise the block returned has the hex string for the
                     block number followed by a thru z and then all 0 values.
                     The function returns the number of blocks "read" (the
                     smaller of MAX_READ_SIZE and the second argument).

   Arguments:        block (unsigned long int)  - block number at which to
                                                  start the read.
                     length (int)               - number of blocks to be read.
                     dest (unsigned char far *) - pointer to the memory where
                                                  the read data is to be
                                                  written.
   Return Value:     The number of blocks actually written (for this code it
                     is always either the passed length or MAX_READ_SIZE).

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: None.

   Author:           Glen George
   Last Modified:    June 6, 2000

*/

int  get_blocks(unsigned long int block, int length, unsigned char far *dest)
{
    /* variables */

    /* array of strings containing the "fake" data for reads in the song index area */
    static const char  *index_string[3] = { "\000\001\000\000\040\165\070\000\072\007Panic Song\0Green Day\0\377",
                                            "\003\002\001\000\200\311\121\000\166\012Spiderwebs\0No Doubt\0\377",
                                            "\170\126\064\022\140\260\135\000\376\013Going Away to College\0Blink 182\0\377"  };

    int  no_blocks;             /* number of blocks to "read" */

    int  digit;                 /* a hex digit to output */

    int  i;                     /* general loop indices */
    int  j;
    int  k;



    /* first figure how many blocks to transfer */
    if (length > MAX_READ_SIZE)
        /* too many requested, only "read" MAX_READ_SIZE */
        no_blocks = MAX_READ_SIZE;
    else
        /* can "read" all the requested blocks */
        no_blocks = length;


    /* fill the blocks */
    for (i = 0; i < no_blocks; i++)  {

        /* check the block number to figure out what to transfer */
        if ((block + i) < NO_ENTRIES)  {

            /* trying to read index information - fill the block */
            for (k = 0, j = 0; j < IDE_BLOCK_SIZE; j++)  {

                /* copy the appropriate string character */
                *dest++ = index_string[block + i][k];

                /* update the position in the index string if not at end */
                if (index_string[block + i][k] != '\377')
                    k++;
            }
        }
        else  {

            /* trying to read general blocks - fill the blocks */
            for (j = 0; j < IDE_BLOCK_SIZE; j++)  {

                /* figure out what to output */
                if (j < BLOCK_LENGTH)  {

                    /* output the block number in the first 8 bytes */
                    /* get this digit of the block number */
                    digit = (((block + i) >> (4 * i)) & 0x00000000FL);

                    /* and output it while converting to a hex digit */
                    if (digit < 10)
                        *dest++ = digit + '0';
                    else
                        *dest++ = digit + 'A';
                }
                else if (j < (BLOCK_LENGTH + CHAR_COUNT))  {

                    /* output a-z in the next bytes */
                    *dest++ = 'a' + (j - BLOCK_LENGTH);
                }
                else  {

                    /* rest of the block is 0 */
                    *dest++ = 0;
                }
            }
        }
    }


    /* all done - return the number of blocks actually transferred */
    return  no_blocks;

}
