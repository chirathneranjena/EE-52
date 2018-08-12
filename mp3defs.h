/****************************************************************************/
/*                                                                          */
/*                                MP3DEFS.H                                 */
/*                           General Definitions                            */
/*                               Include File                               */
/*                           MP3 Jukebox Project                            */
/*                                EE/CS  52                                 */
/*                                                                          */
/****************************************************************************/

/*
   This file contains the general definitions for the MP3 Jukebox.  This
   includes constant, macro, and structure definitions along with the function
   declarations for the assembly language functions.


   Revision History:
      6/5/00   Glen George       Initial revision.
      6/7/00   Glen George       Changed type of TIME_SCALE constant.
      6/14/00  Glen George       Increased BUFFER_BLOCKS from 2 to 32 to make
                                 the output smoother.
      6/14/00  Glen George       Changed the size element of the audio_buf
                                 structure from int to unsigned int and the
                                 pointer element (p) from char far * to
                                 unsigned char far *.
      6/2/02   Glen George       Replaced FFREV_SIZE with FFREV_RATE and added
                                 MIN_FFREV_TIME to support the new method of
                                 doing fast forward and reverse.
      6/2/02   Glen George       Removed declarations for ffrev_start() and
                                 ffrev_halt(), they are no longer used.
      6/2/02   Glen George       Added macro for creating far pointers to ease
                                 portablility for non-segmented architectures.
      6/2/02   Glen George       Updated comments.
      6/10/02  Glen George       Added SECTOR_ADJUST constant for dealing with
                                 hard drives with different geometries.
      6/10/02  Glen George       Updated comments.
*/



#ifndef  I__MP3DEFS_H__
    #define  I__MP3DEFS_H__


/* library include files */
  /* none */

/* local include files */
#include  "interfac.h"




/* constants */

/* general constants */
#define  FALSE       0
#define  TRUE        !FALSE
#define  NULL        (void *) 0


/* disk parameters */

/* starting block for the track index */
#define  INDEX_START    105604L

/* sector number adjustment needed to slightly different hard drives */
#define  SECTOR_ADJUST  0L

/* number of tracks on the disk */
#define  MAX_NO_TRACKS  100


/* audio parameters */

/* value to use when there is no MP3 data */
#define  NO_MP3_DATA          0

/* number of buffers to use for buffering MP3 data */
#define  NO_BUFFERS           3

/* number of bytes and blocks in an MP3 buffer */
#define  BUFFER_BLOCKS        32
#define  BUFFER_SIZE          (BUFFER_BLOCKS * IDE_BLOCK_SIZE)

/* rate at which fast forward and reverse are to run */
#define  FFREV_RATE           3
/* minimum amount of time (in ms) to move by when in fast forward or reverse */
#define  MIN_FFREV_TIME       500


/* timing parameters */

/* difference between elapsed_time() and display_time() times */
#define  TIME_SCALE           60L



/* macros */

/* macro to make a far pointer given a segment and offset */
#define  MAKE_FARPTR(seg, off)  ((void far *) ((0x10000UL * (seg)) + (unsigned long int) (off)))



/* structures, unions, and typedefs */

/* audio buffer structure */
struct  audio_buf  {
                      unsigned char far  *p;    /* pointer to actual buffer data */
                      unsigned int        size; /* size of the buffer */
                      int                 done; /* out of data flag */
                   };

/* track header structure */
struct  track_header  {
                         unsigned char      *title;         /* title of the track */
                         unsigned char      *artist;        /* track artist */
                         int                 time;          /* time length of track */
                         unsigned long int   start_block;   /* starting block on disk */
                         long int            length;        /* length in bytes */
                         long int            curpos;        /* current position (offset in bytes) */
                      };

/* status types */
enum status  {  STAT_IDLE,              /* system idle */
                STAT_PLAY,              /* playing (or repeat playing) a track */
                STAT_FF,                /* fast forwarding a track */
                STAT_REV,               /* reversing a track */
                NUM_STATUS              /* number of status types */
             };

/* key codes */
enum keycode  {  KEYCODE_TRACKUP,    /* <Track Up>     */
                 KEYCODE_TRACKDOWN,  /* <Track Down>   */
                 KEYCODE_PLAY,       /* <Play>         */
                 KEYCODE_RPTPLAY,    /* <Repeat Play>  */
                 KEYCODE_FASTFWD,    /* <Fast Forward> */
                 KEYCODE_REVERSE,    /* <Reverse>      */
                 KEYCODE_STOP,       /* <Stop>         */
                 KEYCODE_ILLEGAL,    /* other keys     */
                 NUM_KEYCODES        /* number of key codes */
              }; 




/* function declarations */

/* update needed function */
unsigned char  update(unsigned char far *, int);

/* how much time has elapsed */
int  elapsed_time(void);

/* keypad functions */
unsigned char  key_available(void);     /* key is available */
int            getkey(void);            /* get a key */

/* display functions  */
void  display_time(unsigned int);       /* display the track time */
void  display_track(unsigned int);      /* display the track number */
void  display_status(unsigned int);     /* display the system status */
void  display_title(const char far *);  /* display the track title */
void  display_artist(const char far *); /* display the track artist */

/* IDE interface functions */
int  get_blocks(unsigned long int, int, unsigned char far *);   /* get data */

/* audio functions */
void  audio_play(unsigned char far *, int);   /* start playing */
void  audio_halt(void);                       /* halt play or record */


#endif
