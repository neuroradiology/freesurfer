#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>

#include "mri.h"
#include "macros.h"
#include "error.h"
#include "diag.h"
#include "proto.h"
#include "mrimorph.h"
#include "mri_conform.h"
#include "utils.h"
#include "const.h"
#include "timer.h"
#include "version.h"

int main(int argc, char *argv[]) ;
static int get_option(int argc, char *argv[]) ;

char *Progname ;
static void usage_exit(int code) ;

static int normalize_flag = 0 ;


int
main(int argc, char *argv[])
{
  char   **av, fname[STRLEN] ;
  int    ac, nargs, i ;
  char   *in_fname, *out_fname ;
  int          msec, minutes, seconds ;
  struct timeb start ;

  /* rkt: check for and handle version tag */
  nargs = handle_version_option (argc, argv, "$Id: main_template.c,v 1.2 2003/04/15 16:42:56 kteich Exp $");
  if (nargs && argc - nargs == 1)
    exit (0);
  argc -= nargs;

  Progname = argv[0] ;
  ErrorInit(NULL, NULL, NULL) ;
  DiagInit(NULL, NULL, NULL) ;

  TimerStart(&start) ;

  ac = argc ;
  av = argv ;
  for ( ; argc > 1 && ISOPTION(*argv[1]) ; argc--, argv++)
  {
    nargs = get_option(argc, argv) ;
    argc -= nargs ;
    argv += nargs ;
  }

  if (argc < 3)
    usage_exit(1) ;


  msec = TimerStop(&start) ;
  seconds = nint((float)msec/1000.0f) ;
  minutes = seconds / 60 ;
  seconds = seconds % 60 ;
  fprintf(stderr, "inverse operator application took %d minutes"
					" and %d seconds.\n", minutes, seconds) ;
  exit(0) ;
  return(0) ;
}
/*----------------------------------------------------------------------
            Parameters:

           Description:
----------------------------------------------------------------------*/
static int
get_option(int argc, char *argv[])
{
  int  nargs = 0 ;
  char *option ;
  
  option = argv[1] + 1 ;            /* past '-' */
  switch (toupper(*option))
  {
  case 'N':
		normalize_flag = atoi(argv[2]) ;
    fprintf(stderr, "noise-sensitiviy normalization %s\n",
						normalize_flag ? "on" : "off") ;
		nargs = 1 ;
    break ;
  case '?':
  case 'U':
    usage_exit(0) ;
    break ;
  default:
    fprintf(stderr, "unknown option %s\n", argv[1]) ;
    exit(1) ;
    break ;
  }

  return(nargs) ;
}
/*----------------------------------------------------------------------
            Parameters:

           Description:
----------------------------------------------------------------------*/
static void
usage_exit(int code)
{
  printf("usage: %s [options] <inverse operator> <EEG/MEG data file>",
				 Progname) ;
  printf(
				 "\tf <f low> <f hi> - apply specified filter (not implemented yet)\n"
				 );
	printf("\tn - noise-sensitivity normalize inverse (default=1)") ;
  exit(code) ;
}





