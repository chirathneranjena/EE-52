/****************************************************************************/
/*                                                                          */
/*                               TRAKUTIL.H                                 */
/*                         Track Utility Functions                          */
/*                              Include File                                */
/*                           MP3 Jukebox Project                            */
/*                                EE/CS 52                                  */
/*                                                                          */
/****************************************************************************/

/*
   This file contains the constants and function prototypes for the track
   utility functions defined in trakutil.c.


   Revision History
      6/6/00   Glen George       Initial revision (from the 3/6/99 version of
                                 updatfnc.h for the Digital Audio Recorder
                                 Project).
      6/7/00   Glen George       Added function prototype for
                                 get_track_block_position().
      6/2/02   Glen George       Added function prototype for
                                 get_track_total_time().
*/




#ifndef  I__TRAKUTIL_H__
    #define  I__TRAKUTIL_H__


/* library include files */
  /* none */

/* local include files */
#include  "mp3defs.h"




/* constants */
    /* none */




/* structures, unions, and typedefs */
    /* none */




/* function declarations */

/* initialization functions */
void  init_track(void);         /* initialize to the start of the track */

/* track running functions */
void  update_track_position(long int);  /* update the current position of the track */

/* track accessor functions */
long int     get_track_position(void);          /* get the current position of the track (relative to start in bytes) */
long int     get_track_block_position(void);    /* get the current position of the track (in blocks on hard drive) */
long int     get_track_length(void);            /* get the length of the track */
long int     get_track_remaining_length(void);  /* get the remaining length of the track */
const char  *get_track_title(void);             /* get the title of the track */
const char  *get_track_artist(void);            /* get the artist for the track */
int          get_track_no(void);                /* get the current track number */
int          get_track_time(void);              /* get the current time for the track */
int          get_track_total_time(void);        /* get the total time for the track */

/* miscellaneous functions */
int   update_track_no(int);             /* update current track number */


#endif
