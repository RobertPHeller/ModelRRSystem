/* -*- C -*- ****************************************************************
 *
 *  System        : 
 *  Module        : 
 *  Object Name   : $RCSfile$
 *  Revision      : $Revision$
 *  Date          : $Date$
 *  Author        : $Author$
 *  Created By    : Robert Heller
 *  Created       : Sun Apr 30 12:11:26 2017
 *  Last Modified : <170508.1139>
 *
 *  Description	
 *
 *  Notes
 *
 *  History
 *	
 ****************************************************************************
 *
 *    Copyright (C) 2017  Robert Heller D/B/A Deepwoods Software
 *			51 Locke Hill Road
 *			Wendell, MA 01379-9728
 *
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * 
 *
 ****************************************************************************/

static const char rcsid[] = "@(#) : $Id$";


#include <stdio.h>
#include <tcl.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/uio.h>
#include <net/if.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#include <linux/can.h>
#include <linux/can/bcm.h>


#if !defined(INT2PTR) && !defined(PTR2INT)
#   if defined(HAVE_INTPTR_T) || defined(intptr_t)
#	define INT2PTR(p) ((void*)(intptr_t)(p))
#	define PTR2INT(p) ((int)(intptr_t)(p))
#   else
#	define INT2PTR(p) ((void*)(p))
#	define PTR2INT(p) ((int)(p))
#   endif
#endif
#if !defined(UINT2PTR) && !defined(PTR2UINT)
#   if defined(HAVE_UINTPTR_T) || defined(uintptr_t)
#	define UINT2PTR(p) ((void*)(uintptr_t)(p))
#	define PTR2UINT(p) ((unsigned int)(uintptr_t)(p))
#   else
#	define UINT2PTR(p) ((void*)(p))
#	define PTR2UINT(p) ((unsigned int)(p))
#   endif
#endif

/*
 * Helper macros to make parts of this file clearer. The macros do exactly
 * what they say on the tin. :-) They also only ever refer to their arguments
 * once, and so can be used without regard to side effects.
 */

#define SET_BITS(var, bits)	((var) |= (bits))
#define CLEAR_BITS(var, bits)	((var) &= ~(bits))

/*
 * This structure describes per-instance state of a  CAN Socket based channel.
 */

typedef struct CANState {
    Tcl_Channel channel;        /* Channel associated with this file. */
    int fd;                     /* The socket itself. */
    int flags;                  /* ORed combination of the bitfields defined
                                 * below. */
} CANState;

/*
 * These bits may be ORed together into the "flags" field of a CanState
 * structure.
 */

#define CAN_ASYNC_SOCKET	(1<<0)	/* Asynchronous socket. */
#define CAN_ASYNC_CONNECT	(1<<1)	/* Async connect in progress. */

static CANState * CreateCANSocket(Tcl_Interp *interp, const char *myaddr);

static int        CanBlockModeProc(ClientData data, int mode);
static int        CanCloseProc(ClientData instanceData, Tcl_Interp *interp);
static int        CanGetHandleProc(ClientData instanceData, int direction, 
                                   ClientData *handlePtr);
static int        CanGetOptionProc(ClientData instanceData, 
                                   Tcl_Interp *interp, const char *optionName, 
                                   Tcl_DString *dsPtr);
static int        CanInputProc(ClientData instanceData, char *buf, int toRead, 
                               int *errorCode);
static int        CanOutputProc(ClientData instanceData, const char *buf, 
                                int toWrite, int *errorCode);
static void       CanWatchProc(ClientData instanceData, int mask);

/*
 * This structure describes the channel type structure for CAN socket
 * based IO:
 */

static Tcl_ChannelType canChannelType = {
    "can",                      /* Type name. */
    TCL_CHANNEL_VERSION_5,      /* v5 channel */
    CanCloseProc,               /* Close proc. */
    CanInputProc,               /* Input proc. */
    CanOutputProc,              /* Output proc. */
    NULL,                       /* Seek proc. */
    NULL,                       /* Set option proc. */
    CanGetOptionProc,           /* Get option proc. */
    CanWatchProc,               /* Initialize notifier. */
    CanGetHandleProc,           /* Get OS handles out of channel. */
    NULL,                       /* close2proc. */
    CanBlockModeProc,           /* Set blocking or non-blocking mode.*/
    NULL,                       /* flush proc. */
    NULL,                       /* handler proc. */
    NULL,                       /* wide seek proc. */
    NULL,                       /* thread action proc. */
    NULL,                       /* truncate proc. */
};

/*
 *----------------------------------------------------------------------
 *
 * CanBlockModeProc --
 *
 *	This function is invoked by the generic IO level to set blocking and
 *	nonblocking mode on a CAN socket based channel.
 *
 * Results:
 *	0 if successful, errno when failed.
 *
 * Side effects:
 *	Sets the device into blocking or nonblocking mode.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
static int
CanBlockModeProc(
    ClientData instanceData,	/* Socket state. */
    int mode)			/* The mode to set. Can be one of
				 * TCL_MODE_BLOCKING or
				 * TCL_MODE_NONBLOCKING. */
{
    CANState *statePtr = (CANState *) instanceData;

    if (mode == TCL_MODE_BLOCKING) {
	CLEAR_BITS(statePtr->flags, CAN_ASYNC_SOCKET);
    } else {
	SET_BITS(statePtr->flags, CAN_ASYNC_SOCKET);
    }
    int flags = fcntl(statePtr->fd, F_GETFL);
    if (mode == TCL_MODE_BLOCKING) {
        flags &= ~O_NONBLOCK;
    } else {
        flags |= O_NONBLOCK;
    }
    if (fcntl(statePtr->fd, F_SETFL, flags) < 0) {
        return errno;
    } else {
        return 0;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * CanInputProc --
 *
 *	This function is invoked by the generic IO level to read input from a
 *	CAN socket based channel.
 * 
 *      Note: All CAN I/O is encoded as GridConnect format message.
 *
 * Results:
 *	The number of bytes read is returned or -1 on error. An output
 *	argument contains the POSIX error code on error, or zero if no error
 *	occurred.
 *
 * Side effects:
 *	Reads input from the input device of the channel.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
static int
CanInputProc(
    ClientData instanceData,	/* Socket state. */
    char *buf,			/* Where to store data read. */
    int bufSize,		/* How much space is available in the
				 * buffer? */
    int *errorCodePtr)		/* Where to store error code. */
{
    CANState *statePtr = (CANState *) instanceData;
    int bytesRead, state;
    int nbytes, id;
    char *doff, *fmt;
    int bremain,i;
    struct can_frame frame;
    canid_t mask;
    
#ifdef DEBUG
    fprintf(stderr,"*** CanInputProc()\n");
#endif
    *errorCodePtr = 0;
    nbytes = read(statePtr->fd, &frame, sizeof(frame));
#ifdef DEBUG                                                                    
    fprintf(stderr,"*** -: nbytes = %d\n",nbytes);
    fprintf(stderr,"*** -: frame.can_id = %08X\n",frame.can_id);
#endif                                                                          
    
    if (nbytes > -1) {
        if (nbytes < sizeof(frame)) {
            *errorCodePtr = ENOMSG;
            return -1;
        }
        if ((frame.can_id & CAN_EFF_FLAG) != 0) {
            if ((frame.can_id & CAN_RTR_FLAG) == 1) {
                fmt = ":X%08XR";
            } else {
                fmt = ":X%08XN";
            }
            mask = CAN_EFF_MASK;
        } else {
            if ((frame.can_id & CAN_RTR_FLAG) != 0) {
                fmt = ":S%03XR";
            } else {
                fmt = ":S%03XN";
            }
            mask = CAN_SFF_MASK;
        }
#ifdef DEBUG                                                                   $
        fprintf(stderr,"*** -: fmt is %s\n",fmt);
#endif
        nbytes = snprintf(buf,(size_t) bufSize,fmt,(frame.can_id & mask));
        bytesRead = nbytes;
        if (nbytes >= bufSize) return bufSize;
        doff = buf+nbytes;
        bremain = bufSize-nbytes;
#ifdef DEBUG                                                                   $
        fprintf(stderr,"*** -: frame.can_dlc is %d\n",frame.can_dlc);
#endif                                                                          
        for (i = 0; i < frame.can_dlc; i++) {
            nbytes = snprintf(doff,(size_t)bremain,"%02X",frame.data[i]);
            bytesRead += nbytes;
            if (nbytes >= bremain) return bufSize;
            doff += nbytes;
            bremain -= nbytes;
        }
        *doff++ = ';';
        bremain--;
        if (bremain < 1) return bufSize;
        *doff++ = '\r';
        bremain--;
        if (bremain < 1) return bufSize;
        *doff++ = '\n';
        bremain--;
        if (bremain < 1) return bufSize;
        *doff++ = '\0';
        bytesRead += 3;
        return bytesRead;
    }
    if (errno == ECONNRESET) {
	/*
	 * Turn ECONNRESET into a soft EOF condition.
	 */

	return 0;
    }
    *errorCodePtr = errno;
    return -1;
}


static unsigned char asc2nibble(char c) {
    
    if ((c >= '0') && (c <= '9'))
        return c - '0';
    
    if ((c >= 'A') && (c <= 'F'))
        return c - 'A' + 10;
    
    if ((c >= 'a') && (c <= 'f'))
        return c - 'a' + 10;
    
    return 16; /* error */
}

/*
 *----------------------------------------------------------------------
 *
 * CanOutputProc --
 *
 *	This function is invoked by the generic IO level to write output to a
 *	CAN socket based channel.
 *
 *      Note: All CAN I/O is encoded as GridConnect format message.
 *
 * Results:
 *	The number of bytes written is returned. An output argument is set to
 *	a POSIX error code if an error occurred, or zero.
 *
 * Side effects:
 *	Writes output on the output device of the channel.
 *
 *----------------------------------------------------------------------
 */

static int
CanOutputProc(
    ClientData instanceData,	/* Socket state. */
    const char *buf,		/* The data buffer. */
    int toWrite,		/* How many bytes to write? */
    int *errorCodePtr)		/* Where to store error code. */
{
    CANState *statePtr = (CANState *) instanceData;
    int written;
    int state;				/* Of waiting for connection. */
    char *p;
    int i;
    unsigned char tmp;
    
    
    struct can_frame frame;
    written = toWrite;
    *errorCodePtr = 0;
    if (*buf != ':' || toWrite < 7) {
        *errorCodePtr = ENOMSG;
        return -1;
    }
    p = buf+1;toWrite--;
    memset(&frame,0,sizeof(frame));
    if (*p == 'X') {
        p++;
        toWrite--;
        for (i = 0; i < 8; i++) {
            if ((tmp = asc2nibble(*p++)) > 0x0F) {
                *errorCodePtr = ENOMSG;
                return -1;
            }
            toWrite--;
            frame.can_id = frame.can_id << 4;
            frame.can_id |= tmp;
        }
        frame.can_id |= CAN_EFF_FLAG;
    } else if (*p == 'S') {
        p++;
        toWrite--;
        for (i = 0; i < 3; i++) {
            if ((tmp = asc2nibble(*p++)) > 0x0F) {
                *errorCodePtr = ENOMSG;
                return -1;
            }
            toWrite--;
            frame.can_id = frame.can_id << 4;
            frame.can_id |= tmp;
        }
    }
    if (*p == 'R') {
        frame.can_id |= CAN_RTR_FLAG;
    } else if (*p != 'N') {
        *errorCodePtr = ENOMSG;
        return -1;
    }
    p++;toWrite--;
    while (toWrite > 0 && *p != ';' && frame.can_dlc < 8) {
        if ((tmp = asc2nibble(*p++)) > 0x0F) {
            *errorCodePtr = ENOMSG;
            return -1;
        }
        toWrite--;
        frame.data[frame.can_dlc] = tmp << 4;
        if ((tmp = asc2nibble(*p++)) > 0x0F) {
            *errorCodePtr = ENOMSG;
            return -1;
        }
        toWrite--;
        frame.data[frame.can_dlc] |= tmp;
        frame.can_dlc++;
    }
    if (toWrite-- > 0 && *p++ != ';') {
        *errorCodePtr = ENOMSG;
        return -1;
    }
    if (toWrite-- > 0 && *p++ != '\r') {
        *errorCodePtr = ENOMSG;
        return -1;
    }
    if (toWrite-- > 0 && *p++ != '\n') {
        *errorCodePtr = ENOMSG;
        return -1;
    }
#ifdef DEBUG
    fprintf(stderr,"*** CanOutputProc(): frame.can_id is %08X\n",frame.can_id);
#endif
    if (write(statePtr->fd,&frame,sizeof(frame)) != sizeof(frame)) {
        *errorCodePtr = errno;
        return -1;
    }
#ifdef DEBUG                                                                    
    fprintf(stderr,"*** CanOutputProc():  written = %d, toWrite = %d, written-toWrite = %d\n",written,toWrite,written-toWrite);
#endif                                                                          
    return written-toWrite;
}

/*
 *----------------------------------------------------------------------
 *
 * CanCloseProc --
 *
 *	This function is invoked by the generic IO level to perform
 *	channel-type-specific cleanup when a CAN socket based channel is
 *	closed.
 *
 * Results:
 *	0 if successful, the value of errno if failed.
 *
 * Side effects:
 *	Closes the socket of the channel.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
static int
CanCloseProc(
    ClientData instanceData,	/* The socket to close. */
    Tcl_Interp *interp)		/* For error reporting - unused. */
{
    CANState *statePtr = (CANState *) instanceData;
    int errorCode = 0;

    /*
     * Delete a file handler that may be active for this socket if this is a
     * server socket - the file handler was created automatically by Tcl as
     * part of the mechanism to accept new client connections. Channel
     * handlers are already deleted in the generic IO channel closing code
     * that called this function, so we do not have to delete them here.
     */

    Tcl_DeleteFileHandler(statePtr->fd);

    if (close(statePtr->fd) < 0) {
	errorCode = errno;
    }
    ckfree((char *) statePtr);

    return errorCode;
}

/*
 *----------------------------------------------------------------------
 *
 * CanGetOptionProc --
 *
 *	Computes an option value for a CAN socket based channel, or a list of
 *	all options and their values.
 *
 *	Note: This code is based on code contributed by John Haxby.
 *
 * Results:
 *	A standard Tcl result. The value of the specified option or a list of
 *	all options and their values is returned in the supplied DString. Sets
 *	Error message if needed.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

static int
CanGetOptionProc(
    ClientData instanceData,	/* Socket state. */
    Tcl_Interp *interp,		/* For error reporting - can be NULL. */
    const char *optionName,	/* Name of the option to retrieve the value
				 * for, or NULL to get all options and their
				 * values. */
    Tcl_DString *dsPtr)		/* Where to store the computed value;
				 * initialized by caller. */
{
    CANState *statePtr = (CANState *) instanceData;
    size_t len = 0;
    char buf[TCL_INTEGER_SPACE];

    if (optionName != NULL) {
	len = strlen(optionName);
    }

    if ((len > 1) && (optionName[1] == 'e') &&
	    (strncmp(optionName, "-error", len) == 0)) {
	socklen_t optlen = sizeof(int);
	int err, ret;

	ret = getsockopt(statePtr->fd, SOL_SOCKET, SO_ERROR,
		(char *)&err, &optlen);
	if (ret < 0) {
	    err = errno;
	}
	if (err != 0) {
	    Tcl_DStringAppend(dsPtr, Tcl_ErrnoMsg(err), -1);
	}
	return TCL_OK;
    }

    if (len > 0) {
	return Tcl_BadChannelOption(interp, optionName, "error");
    }

    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * CanWatchProc --
 *
 *	Initialize the notifier to watch the fd from this channel.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Sets up the notifier so that a future event on the channel will be
 *	seen by Tcl.
 *
 *----------------------------------------------------------------------
 */

static void
CanWatchProc(
    ClientData instanceData,	/* The socket state. */
    int mask)			/* Events of interest; an OR-ed combination of
				 * TCL_READABLE, TCL_WRITABLE and
				 * TCL_EXCEPTION. */
{
    CANState *statePtr = (CANState *) instanceData;

    /*
     * Make sure we don't mess with server sockets since they will never be
     * readable or writable at the Tcl level. This keeps Tcl scripts from
     * interfering with the -accept behavior.
     */

    if (mask) {
        Tcl_CreateFileHandler(statePtr->fd, mask,
                              (Tcl_FileProc *) Tcl_NotifyChannel,
                              (ClientData) statePtr->channel);
    } else {
        Tcl_DeleteFileHandler(statePtr->fd);
    }

}

/*
 *----------------------------------------------------------------------
 *
 * CanGetHandleProc --
 *
 *	Called from Tcl_GetChannelHandle to retrieve OS handles from inside a
 *	CAN socket based channel.
 *
 * Results:
 *	Returns TCL_OK with the fd in handlePtr, or TCL_ERROR if there is no
 *	handle for the specified direction.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

	/* ARGSUSED */
static int
CanGetHandleProc(
    ClientData instanceData,	/* The socket state. */
    int direction,		/* Not used. */
    ClientData *handlePtr)	/* Where to store the handle. */
{
    CANState *statePtr = (CANState *) instanceData;

    *handlePtr = (ClientData) INT2PTR(statePtr->fd);
    return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * CreateSocket --
 *
 *	This function opens a new AF_CAN socket and
 *	initializes the CANState structure.
 *
 * Results:
 *	Returns a new CANState, or NULL with an error in the interp's result,
 *	if interp is not NULL.
 *
 * Side effects:
 *	Opens a socket.
 *
 *----------------------------------------------------------------------
 */

static CANState *
CreateSocket(
    Tcl_Interp *interp,		/* For error reporting; can be NULL. */
    const char *candev)		/* CAN device name */
{
    int status, sock, curState;
    struct sockaddr_can addr;
    CANState *statePtr;
    const char *errorMsg = NULL;
    struct ifreq ifr;
    
    sock = socket(AF_CAN, SOCK_RAW, CAN_RAW);
    if (sock < 0) {
	goto addressError;
    }

    /*
     * Set the close-on-exec flag so that the socket will not get inherited by
     * child processes.
     */

    fcntl(sock, F_SETFD, FD_CLOEXEC);

    status = 0;
    strncpy(ifr.ifr_name, candev, IFNAMSIZ - 1);
    ifr.ifr_ifindex = if_nametoindex(ifr.ifr_name);
    if (!ifr.ifr_ifindex) {
        goto addressError;
    }
    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;
    status = bind(sock, (struct sockaddr *)&addr, sizeof(addr));
    if (status < 0) {
	if (interp != NULL) {
	    Tcl_AppendResult(interp, "couldn't open socket: ",
		    Tcl_PosixError(interp), NULL);
	}
	if (sock != -1) {
	    close(sock);
	}
	return NULL;
    }

    /*
     * Allocate a new CANState for this socket.
     */

    statePtr = (CANState *) ckalloc((unsigned) sizeof(CANState));
    statePtr->flags = 0;
    statePtr->fd = sock;

    return statePtr;

  addressError:
    if (sock != -1) {
	close(sock);
    }
    if (interp != NULL) {
	Tcl_AppendResult(interp, "couldn't open socket: ",
		Tcl_PosixError(interp), NULL);
	if (errorMsg != NULL) {
	    Tcl_AppendResult(interp, " (", errorMsg, ")", NULL);
	}
    }
    return NULL;
}


/*
 * Create a TclChannel for a CAN Socket.
 * 
 */

int SocketCAN(Tcl_Interp *interp, const char *candev)
{
    CANState *statePtr;
    char channelName[16 + TCL_INTEGER_SPACE];
    
    statePtr = CreateSocket(interp, candev);
    if (statePtr == NULL) {
        return TCL_ERROR;
    }
    sprintf(channelName, "can%d", statePtr->fd);
    statePtr->channel = Tcl_CreateChannel(&canChannelType, channelName,
                                          (ClientData) statePtr, 
                                          (TCL_READABLE | TCL_WRITABLE));
    if (Tcl_SetChannelOption(interp, statePtr->channel, "-translation",
                             "auto crlf") == TCL_ERROR) {
        Tcl_Close(NULL, statePtr->channel);
        return TCL_ERROR;
    }
    if (Tcl_SetChannelOption(interp, statePtr->channel, "-buffering",
                             "line") == TCL_ERROR) {
        Tcl_Close(NULL, statePtr->channel);
        return TCL_ERROR;
    }
    Tcl_RegisterChannel(interp, statePtr->channel);
    Tcl_AppendResult(interp, channelName, NULL);
    return TCL_OK;          
}
