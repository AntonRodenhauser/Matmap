/* gdbmsetopt.c - set options pertaining to a GDBM descriptor. */

/*  This file is part of GDBM, the GNU data base manager, by Philip A. Nelson.
    Copyright (C) 1993, 1994  Free Software Foundation, Inc.

    GDBM is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2, or (at your option)
    any later version.

    GDBM is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with GDBM; see the file COPYING.  If not, write to
    the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

    You may contact the original author by:
       e-mail:  phil@cs.wwu.edu
      us-mail:  Philip A. Nelson
                Computer Science Department
                Western Washington University
                Bellingham, WA 98226
       
    The author of this file is:
       e-mail:  downsj@downsj.com

*************************************************************************/

/* PATCHED VERSION OF GDBM LIBRARY *******************************************
 * This patch is intended to copy the functionality of the 
 * GDBM library as it is found on the SGI platform.
 * The original version of the library created different 
 * fileformats at different platforms. This patched version
 * intends to create the same file at each different platform.
 * The current patched version has been tested for OS X, IRIX,
 * and LINUX. As the original files were all created under
 * IRIX, this patch conforms to the files created at that
 * platform.
 *
 * patch includes:
 * 1) definition of off_t as my_int64_t to be sure that this
 *    field is 8 bytes across platforms. off_t is 4 bytes
 *    on linux and 8 bytes on sgi and osx.
 * 2) includes byteswapping to store the files in the SGI
 *    native format to ensure cross platform compatibility.
 * 3) saving data structures field by field to ensure that
 *    no zero padding is added in between members of these
 *    structures.
 * 4) to add empty dummy fields at those places where the original
 *    SGI version of this library did put additional zeros to have
 *    64 bit integers align properly in memory.
 *
 * notes:
 * the definition of my_int64_t in autoconf.h may need some adjustments
 * in the future to be compatible with more compilers.
 *
 * All lines that have been patched are marked with a PATCH marker
 * the only exception is the conversion of off_t to my_int64_t
 *
 * patch generated by : JG Stinstra
 *
 ****************************************************************************/

/* include system configuration before all else. */
#include "autoconf.h"

#include "gdbmdefs.h"
#include "gdbmerrno.h"

/* operate on an already open descriptor. */

/* ARGSUSED */
int
gdbm_setopt(dbf, optflag, optval, optlen)
    gdbm_file_info *dbf;	/* descriptor to operate on. */
    int optflag;		/* option to set. */
    int *optval;		/* pointer to option value. */
    int optlen;			/* size of optval. */
{
  switch(optflag)
    {
      case GDBM_CACHESIZE:
        /* Optval will point to the new size of the cache. */
        if (dbf->bucket_cache != NULL)
          {
            gdbm_errno = GDBM_OPT_ALREADY_SET;
            return(-1);
          }

        return(_gdbm_init_cache(dbf, ((*optval) > 9) ? (*optval) : 10));

      case GDBM_FASTMODE:
      	/* Obsolete form of SYNCMODE. */
	if ((*optval != TRUE) && (*optval != FALSE))
	  {
	    gdbm_errno = GDBM_OPT_ILLEGAL;
	    return(-1);
	  }

	dbf->fast_write = *optval;
	break;

      case GDBM_SYNCMODE:
      	/* Optval will point to either true or false. */
	if ((*optval != TRUE) && (*optval != FALSE))
	  {
	    gdbm_errno = GDBM_OPT_ILLEGAL;
	    return(-1);
	  }

	dbf->fast_write = !(*optval);
	break;

      case GDBM_CENTFREE:
      	/* Optval will point to either true or false. */
	if ((*optval != TRUE) && (*optval != FALSE))
	  {
	    gdbm_errno = GDBM_OPT_ILLEGAL;
	    return(-1);
	  }

	dbf->fast_write = *optval;
	break;

      case GDBM_COALESCEBLKS:
      	/* Optval will point to either true or false. */
	if ((*optval != TRUE) && (*optval != FALSE))
	  {
	    gdbm_errno = GDBM_OPT_ILLEGAL;
	    return(-1);
	  }

	dbf->fast_write = *optval;
	break;

      default:
        gdbm_errno = GDBM_OPT_ILLEGAL;
        return(-1);
    }

  return(0);
}
