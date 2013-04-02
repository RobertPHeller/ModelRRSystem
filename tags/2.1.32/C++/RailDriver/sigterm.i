/* 
 * ------------------------------------------------------------------
 * sigterm.i - Code to catch SIGTERM
 * Created by Robert Heller on Tue May  1 10:16:49 2012
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002-2012  Robert Heller D/B/A Deepwoods Software
 * 			51 Locke Hill Road
 * 			Wendell, MA 01379-9728
 * 
 *     This program is free software; you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation; either version 2 of the License, or
 *     (at your option) any later version.
 * 
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 * 
 *     You should have received a copy of the GNU General Public License
 *     along with this program; if not, write to the Free Software
 *     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 *  
 */

/*
 * Some of the code here was lifted from the TclX sources and greatly 
 * simplified -- I could not cross compile TclX and only needed a very small
 * bit of functionallity.
 */

%module Sigterm
%{

#include "config.h"
#include <signal.h>

#if defined(__WIN32__) || defined(_WIN32)

#ifndef NO_SIGACTION
#   define NO_SIGACTION
#endif
/*
 * No restartable signals in WIN32.
 */
#ifndef NO_SIG_RESTART
#   define NO_SIG_RESTART
#endif


#else

/*
 * If sigaction is available, check for restartable signals.
 */
#ifndef NO_SIGACTION
#    ifndef SA_RESTART
#        define NO_SIG_RESTART
#    endif
#else
#    define NO_SIG_RESTART
#endif

#endif

#ifndef CONST84
#  define CONST84
#endif

#ifndef RETSIGTYPE
#   define RETSIGTYPE void
#endif

typedef RETSIGTYPE (*signalProcPtr_t) _ANSI_ARGS_((int));

/*
 * Defines if this is not Posix.
 */
#ifndef SIG_BLOCK
#   define SIG_BLOCK       1
#   define SIG_UNBLOCK     2
#endif

/*
 * SunOS has sigaction but uses SA_INTERRUPT rather than SA_RESTART which
 * has the opposite meaning.
 */
#ifndef NO_SIGACTION
#if defined(SA_INTERRUPT) && !defined(SA_RESTART)
#define USE_SA_INTERRUPT
#endif
#endif

static unsigned sigtermReceived = 0;


/*-----------------------------------------------------------------------------
 * SignalTrap --
 *
 *   Trap handler for SIGTERM
 *-----------------------------------------------------------------------------
 */
static RETSIGTYPE SignalTrap (int signalNum)
{
    if (signalNum != SIGTERM) return;

    sigtermReceived++;

#ifdef NO_SIGACTION

    if (signal (signalNum, SignalTrap) == SIG_ERR) panic ("SignalTrap bug");

#endif /* NO_SIGACTION */

}

static bool sigterm_setfunct (signalProcPtr_t sigFunc)
{
#ifndef NO_SIGACTION
    struct sigaction newState;
    
    newState.sa_handler = sigFunc;
    sigfillset(&newState.sa_mask);
    newState.sa_flags = 0;
#ifdef USE_SA_INTERRUPT
    newState.sa_flags |= SA_INTERRUPT;
#endif
    if (sigaction (SIGTERM, &newState, NULL) < 0) return false;
    else return true;
#else
    if (signal (SIGTERM, sigFunc) == SIG_ERR) return false;
    else return true;
#endif
}

static bool sigterm_catch() {
  return sigterm_setfunct (SignalTrap);
}

static bool sigterm_default() {
  return sigterm_setfunct (SIG_DFL);
}

static int sigterm_received() {
  return sigtermReceived;
}

static void sigterm_reset() {
  sigtermReceived = 0;
}

#undef SWIG_name
#define SWIG_name "Sigterm"
#undef SWIG_version
#define SWIG_version "1.0"
%}

%include typemaps.i

bool sigterm_catch();

bool sigterm_default();

int sigterm_received();

void sigterm_reset();


