/****************************************************************************/
/*                                                                          */
/*                                TRAKUTIL                                  */
/*                         Track Utility Functions                          */
/*                           MP3 Jukebox Project                            */
/*                                EE/CS 52                                  */
/*                                                                          */
/****************************************************************************/

/*
   This file contains the utility functions for dealing with tracks used by
   the background routines of the MP3 Jukebox Project.  The current track
   header and buffer are also defined in this file (locally).  The functions
   included are:
      get_track_artist           - return the artist for the current track
      get_track_length           - get number of bytes in the current track
      get_track_position         - get the current position on the track
      get_track_block_position   - get the current block position on the track
      get_track_remaining_length - get number of bytes left on current track
      get_track_time             - return the current time for a track
      get_track_total_time       - return the total time for a track
      get_track_title            - return the title of the current track
      init_track                 - initialize to the start of the track
      init_tracks                - initialize the track information
      update_track_no            - update the current track number
      update_track_position      - update the position on the track

   The local functions included are:
      get_track_info - retrieve the track information for the current track

   The locally global variable definitions included are:
      track_number      - the number of the current track
      track_info        - information on the current track
      track_info_buffer - buffer holding the current track information


   Revision History
      6/6/00   Glen George       Initial revision (from the 3/6/99 version of
                                 updatfnc.h for the Digital Audio Recorder
                                 Project).
      6/7/00   Glen George       Added local get_track_info() function.
      6/7/00   Glen George       Fixed overflow problem in get_track_time().
      6/7/00   Glen George       Added get_track_block_position() function.
      6/14/00  Glen George       Made get_track_info() function static so it
                                 really is local.
      6/14/00  Glen George       Correctly updated get_track_time().
      6/14/00  Glen George       Fixed the offset for the title in function
                                 get_track_info().
      6/14/00  Glen George       Changed track_info_buffer[] to unsigned char
                                 to fix some type conversion warnings.
      6/14/00  Glen George       Added casts to functions get_track_title()
                                 and get_track_artist() to fix some type
                                 conversion warnings.
      6/2/02   Glen George       Added get_track_total_time() function.
      6/2/02   Glen George       Updated comments.
      6/10/02  Glen George       Added use of SECTOR_ADJUST constant for
                                 dealing with hard drives with different
                                 geometries.
*/



/* library include files */
  /* none */

/* local include files */
#include  "interfac.h"
#include  "mp3defs.h"
#include  "trakutil.h"




/* locally global variables */
static int                  track_number;   /* current track number */
static struct track_header  track_info;     /* current track information */
static unsigned char        track_info_buffer[IDE_BLOCK_SIZE];  /* buffer holding the current information */




/* local function declarations */
void  get_track_info(void);      /* read the track information from disk */




/*
   init_track

   Description:      This function initializes the current track to the start
                     of the track.  The current position (curpos element) is
                     set to the start of the track.

   Arguments:        None.
   Return Value:     None.

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info - the curpos element is reset.

   Author:           Glen George
   Last Modified:    June 6, 2000

*/

void  init_track()
{
    /* variables */
      /* none */



    /* initialize the current position to the start of the track */
    track_info.curpos = 0;


    /* all done, return */
    return;

}




/*
   get_track_artist

   Description:      This function returns the artist for the track.

   Arguments:        None.
   Return Value:     (const char *) - pointer to the string containing the
                     artist for the current track.

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info - the artist element is returned.

   Author:           Glen George
   Last Modified:    June 14, 2000

*/

const char *  get_track_artist()
{
    /* variables */
      /* none */



    /* return the artist name */
    return  (const char *) track_info.artist;

}




/*
   get_track_title

   Description:      This function returns the title for the track.

   Arguments:        None.
   Return Value:     (const char *) - pointer to the string containing the
                     title of the current track.

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info - the title element is returned.

   Author:           Glen George
   Last Modified:    June 14, 2000

*/

const char *  get_track_title()
{
    /* variables */
      /* none */



    /* return the artist name */
    return  (const char *) track_info.title;

}




/*
   get_track_length

   Description:      This function returns the length of the track in bytes.

   Arguments:        None.
   Return Value:     (long int) - the length of the track in bytes.

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info - the length element is returned.

   Author:           Glen George
   Last Modified:    June 5, 2000

*/

long int  get_track_length()
{
    /* variables */
      /* none */



    /* return the track length */
    return  track_info.length;

}




/*
   get_track_position

   Description:      This function returns the current position of the track
                     in bytes from the start of the track.

   Arguments:        None.
   Return Value:     (long int) - the current position (offset from start) on
                     the track.

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info - the curpos element is returned.

   Author:           Glen George
   Last Modified:    June 5, 2000

*/

long int  get_track_position()
{
    /* variables */
      /* none */



    /* return the current position */
    return  track_info.curpos;

}




/*
   get_track_block_position

   Description:      This function returns the current position of the track.
                     This is the position on the hard drive (the block
                     number).

   Arguments:        None.
   Return Value:     (long int) - the current position (block number on hard
                     drive) on the track.

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info - the curpos and start elements are used.

   Author:           Glen George
   Last Modified:    June 7, 2000

*/

long int  get_track_block_position()
{
    /* variables */
      /* none */



    /* return the current position (on the hard drive, in blocks) */
    return  track_info.start_block + (track_info.curpos / IDE_BLOCK_SIZE);

}




/*
   get_track_remaining_length

   Description:      This function returns the number of bytes left on the
                     track.  This is the total length less the current
                     position.

   Arguments:        None.
   Return Value:     (long int) - the bytes left on the track.

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info - the curpos and length elements are used.

   Author:           Glen George
   Last Modified:    June 5, 2000

*/

long int  get_track_remaining_length()
{
    /* variables */
    long int  bytes_left;



    /* compute the number of bytes left */
    bytes_left = track_info.length - track_info.curpos;

    /* make sure it isn't negative */
    if (bytes_left < 0)
        bytes_left = 0;


    /* return the bytes remaining */
    return  bytes_left;

}




/*
   get_track_time

   Description:      This function returns the current time (time remaining)
                     for the passed track.  The current time is computed by
                     taking the ratio of the current position to the total
                     track length and multiplying that by the total time.

   Arguments:        None.
   Return Value:     (int) - the remaining time for the passed track (in
                     tenths of seconds).

   Input:            None.
   Output:           None.

   Error Handling:   There is no checking for overflow.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info - the current time is computed from the time,
                                  curpos, and length elements.

   Author:           Glen George
   Last Modified:    June 14, 2000

*/

int  get_track_time()
{
    /* variables */
      /* none */



    /* just compute and return the time remaining on the track */
    return  (track_info.length - track_info.curpos) / (track_info.length / track_info.time);

}




/*
   get_track_total_time

   Description:      This function returns the total time for the passed
                     track in tenths of seconds.

   Arguments:        None.
   Return Value:     (int) - the total time for the passed track (in tenths of
                     seconds).

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info - the time element is accessed and returned.

   Author:           Glen George
   Last Modified:    June 1, 2002

*/

int  get_track_total_time()
{
    /* variables */
      /* none */



    /* just return the total time */
    return  track_info.time;

}




/*
   update_track_position

   Description:      This function updates the current position on the track
                     by the passed amount.

   Arguments:        delta (long int) - amount by which to update the current
                                        position.
   Return Value:     None.

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info - the curpos element is updated.

   Author:           Glen George
   Last Modified:    June 6, 2000

*/

void  update_track_position(long int delta)
{
    /* variables */
      /* none */



    /* update the current position */
    track_info.curpos += delta;

    /* make sure not out of range */
    if (track_info.curpos < 0)
        track_info.curpos = 0;
    if (track_info.curpos > track_info.length)
        track_info.curpos = track_info.length;


    /* now return */
    return;

}




/*
   update_track_no

   Description:      This function updates (increments, decrements, or resets)
                     the current track number.  If the passed argument is
                     zero, the track number is reset to track 0, otherwise it
                     is updated by the passed amount.

   Arguments:        update (int) - amount to by which to update the track
                                    number, zero to reset it to track number
                                    0.
   Return Value:     (int) - the new track number.

   Input:            The new track information is read from the hard drive.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_number      - updated and returned.
                     track_info        - updated.
                     track_info_buffer - updated.

   Author:           Glen George
   Last Modified:    June 7, 2000

*/

int  update_track_no(int update)
{
    /* variables */
      /* none */



    /* check if need to update or reset the track number */
    if (update == 0)  {

        /* reset to track number 0 */
        track_number = 0;
    }
    else  {

        /* updating the track number */
        track_number += update;

        /* make sure it doesn't go out of range (range from 0 to MAX_NO_TRACKS - 1) */
        while (track_number < 0)
            /* track is too small, wrap to last track */
            track_number += MAX_NO_TRACKS;
        while (track_number >= MAX_NO_TRACKS)
            /* track number is too large, wrap to first track */
            track_number -= MAX_NO_TRACKS;
    }


    /* have the new track number - now read the information from the disk */
    get_track_info();


    /* finally done so return the new track number */
    return  track_number;

}




/*
   get_track_no

   Description:      This function returns the current track number.

   Arguments:        None.
   Return Value:     (int) - the current track number.

   Input:            None.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_number - returned.

   Author:           Glen George
   Last Modified:    Mar. 5, 1994

*/

int  get_track_no()
{
    /* variables */
      /* none */



    /* just return the locally global variable */
    return  track_number;

}




/*
   get_track_info

   Description:      This function loads the information for the current
                     track from the hard drive and initializes the track
                     information data structure.  The track is positioned to
                     the start of the track.

   Arguments:        None.
   Return Value:     None.

   Input:            The new track information is read from the hard drive.
   Output:           None.

   Error Handling:   None.

   Algorithms:       None.
   Data Structures:  None.

   Global Variables: track_info        - updated.
                     track_info_buffer - updated.

   Author:           Glen George
   Last Modified:    June 10, 2002

*/

static  void  get_track_info()
{
    /* variables */
    int  i;             /* loop index */



    /* first attempt to read the block containing the track information */
    if (get_blocks((INDEX_START + track_number + SECTOR_ADJUST), 1, track_info_buffer) == 1)  {

        /* got the track header from the disk, parse it */

        /* starting block is the first long int */
        track_info.start_block = ((long int *) track_info_buffer)[0];

        /* length is the second long int */
        track_info.length = ((long int *) track_info_buffer)[1];

        /* and the time is in the 3rd long int */
        /* note that it is actually only an int, but this gets the position */
        /*   correct and upper word which is garbage is truncated */
        track_info.time = ((long int *) track_info_buffer)[2];

        /* the title comes next */
        track_info.title = &(track_info_buffer[2 * sizeof(long int) + sizeof(int)]);

        /* the artist is after the title */
        for (i = (2 * sizeof(long int) + sizeof(int)); ((track_info_buffer[i] != '\0') && (i < IDE_BLOCK_SIZE)); i++);
        /* WARNING -- this assumes the title is properly null terminated */
        /*            should probably assert that i < IDE_BLOCK_SIZE     */
        track_info.artist = &(track_info_buffer[i + 1]);
    }
    else  {

        /* error reading the header info, set everything to blank */
        /* make sure the strings are empty */
        track_info_buffer[0] = '\0';
        track_info.start_block = 0;
        track_info.length = 0;
        track_info.time = 0;
        track_info.artist = &(track_info_buffer[0]);
        track_info.title = &(track_info_buffer[0]);
    }

    /* always reset to the start of the track */
    track_info.curpos = 0;


    /* finally done so return */
    return;

}
