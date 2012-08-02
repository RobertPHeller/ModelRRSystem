/* 
 * ------------------------------------------------------------------
 * SocketPair.h - Socket pair interface code
 * Created by Robert Heller on Fri Apr 13 13:27:04 2007
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
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

%apply int MyTcl_Result { int tcl_socketpair };

%{

#if !HAVE_SOCKETPAIR
#include <winsock2.h>
#include <errno.h>;

#ifdef BROKEN
int socketpair(int af, int type, int protocol, int sv[2])
{
    SOCKET temp, s1, s2;
    SOCKADDR_IN saddr;
    int nameLen;
    u_long arg = 1;
    fd_set reads, writes; //excepts;
    TIMEVAL tv;
    int err;

    /* ignore address family for now; just stay with AF_INET */
    if ((temp = socket(AF_INET, type, protocol)) == INVALID_SOCKET) {
	errno = WSAGetLastError() - WSABASEERR;
        return -1; /* error case */
    }

    /* set to non-blocking. */
    ioctlsocket(temp, FIONBIO, &arg);

    /* We *SHOULD* choose the correct sockaddr structure based
    on the address family requested... */

    memset(&saddr, 0, sizeof(saddr));
    saddr.sin_family = AF_INET;
    saddr.sin_addr.s_addr = INADDR_LOOPBACK;
    saddr.sin_port = INADDR_ANY;

    if (bind(temp, (const struct sockaddr*)&saddr, sizeof(saddr)) == SOCKET_ERROR) {
	err = WSAGetLastError();
        closesocket(temp);
	WSASetLastError(err);
	errno = err - WSABASEERR;
        return -1; /* error case */
    }

    if (listen(temp, 1) == SOCKET_ERROR) {
	err = WSAGetLastError();
        closesocket(temp);
	WSASetLastError(err);
	errno = err - WSABASEERR;
        return -1; /* error case */
    }

    nameLen = sizeof(SOCKADDR_IN);
    if (getsockname(temp, (SOCKADDR *)&saddr, &nameLen) == SOCKET_ERROR) {
	err = WSAGetLastError();
        closesocket(temp);
	WSASetLastError(err);
	errno = err - WSABASEERR;
        return -1; /* error case */
    }

    if ((s1 = socket(AF_INET, type, protocol)) == INVALID_SOCKET) {
	err = WSAGetLastError();
        closesocket(temp);
	WSASetLastError(err);
	errno = err - WSABASEERR;
        return -1; /* error case */
    }

    /* set to non-blocking. */
    ioctlsocket(s1, FIONBIO, &arg);

    if (connect(s1, (SOCKADDR *)&saddr, nameLen) != SOCKET_ERROR
            || WSAGetLastError() != WSAEWOULDBLOCK) {
	err = WSAGetLastError();
        closesocket(temp);
        closesocket(s1);
	WSASetLastError(err);
	errno = err - WSABASEERR;
        return -1; /* error case */
    }

    FD_SET(temp, &reads);
    //FD_SET(s1, &writes);
    //FD_SET(s1, &excepts);
    tv.tv_sec = 0;
    tv.tv_usec = 0;

    select(0, &reads, &writes, NULL, &tv);

    /* How can these not be true? */
    if (FD_ISSET(temp, &reads)) {
        s2 = accept(temp, (SOCKADDR *)&saddr, &nameLen);
        closesocket(temp);
    }
    if (FD_ISSET(s1, &writes)) {
        /* return to blocking */
        arg = 0;
        ioctlsocket(s1, FIONBIO, &arg);
    }

    sv[1] = (int)s1; sv[2] = (int)s2;
    return 0;  /* normal case */
}
#else

#include <assert.h>

int socketpair(int af, int type, int protocol, int socks[2])
{
    struct sockaddr_in addr;
    SOCKET listener;
    int e;
    int addrlen = sizeof(addr);
    DWORD flags = 0;

    if (socks == 0) {
      WSASetLastError(WSAEINVAL);
      errno = EINVAL;
      return SOCKET_ERROR;
    }

    socks[0] = socks[1] = INVALID_SOCKET;
    if ((listener = socket(AF_INET, type, protocol)) == INVALID_SOCKET) {
	errno = WSAGetLastError() - WSABASEERR;
        return SOCKET_ERROR;
    }
    
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(0x7f000001);
    addr.sin_port = 0;

    e = bind(listener, (const struct sockaddr*) &addr, sizeof(addr));
    if (e == SOCKET_ERROR) {
        e = WSAGetLastError();
    	closesocket(listener);
        WSASetLastError(e);
	errno = WSAGetLastError() - WSABASEERR;
        return SOCKET_ERROR;
    }
    e = getsockname(listener, (struct sockaddr*) &addr, &addrlen);
    if (e == SOCKET_ERROR) {
        e = WSAGetLastError();
    	closesocket(listener);
        WSASetLastError(e);
	errno = WSAGetLastError() - WSABASEERR;
        return SOCKET_ERROR;
    }

    do {
        if (listen(listener, 1) == SOCKET_ERROR)                      break;
        if ((socks[0] = WSASocket(AF_INET, SOCK_STREAM, 0, NULL, 0, flags))
                == INVALID_SOCKET)                                    break;
        if (connect(socks[0], (const struct sockaddr*) &addr,
                    sizeof(addr)) == SOCKET_ERROR)                    break;
        if ((socks[1] = accept(listener, NULL, NULL))
                == INVALID_SOCKET)                                    break;
        closesocket(listener);
        return 0;
    } while (0);
    e = WSAGetLastError();
    closesocket(listener);
    closesocket(socks[0]);
    closesocket(socks[1]);
    WSASetLastError(e);
    errno = WSAGetLastError() - WSABASEERR;
    return SOCKET_ERROR;
}

#endif
#else
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <errno.h>
#endif
%}

%inline %{
/** @name tcl_socketpair
  * @memo Tcl interface to socketpair.
  * @args none
  * @type list
  * @doc returns a list of two file channels, which are opposite ends of
  * a connected pair of sockets.
  */
int tcl_socketpair(Tcl_Interp *interp)
{
	static char name[16 + TCL_INTEGER_SPACE];
	int fds[2], i;
	Tcl_Channel chans[2];

	if (socketpair(AF_UNIX,SOCK_STREAM,0,fds) < 0) {
		Tcl_AppendResult(interp,strerror(errno),(char*)NULL);
#ifdef VERBOSE
		sprintf(name,": %d",errno);
		Tcl_AppendResult(interp,name,(char*)NULL);
#endif
		return TCL_ERROR;
	}
	Tcl_ResetResult(interp);
	for (i = 0; i < 2; i++) {
		chans[i] = Tcl_MakeTcpClientChannel((ClientData) fds[i]);
		Tcl_RegisterChannel(interp,chans[i]);
		sprintf(name,"sock%d",fds[i]);
		Tcl_AppendElement(interp,name);
	}
	return TCL_OK;
		
}
%}



