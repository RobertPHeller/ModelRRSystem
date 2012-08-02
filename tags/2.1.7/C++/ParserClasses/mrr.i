/* 
 * ------------------------------------------------------------------
 * mrr.i - 
 * Created by Robert Heller on Sun Jul 28 10:05:27 2002
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.10  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
 * Modification History:
 * Modification History: Revision 1.9  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.8  2005/11/05 18:28:01  heller
 * Modification History: Assorted updates: cleaned all of the "backwards compatible header" messages
 * Modification History:
 * Modification History: Revision 1.7  2005/11/04 19:06:35  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.6  2004/06/26 13:31:09  heller
 * Modification History: Update versioning for new release
 * Modification History:
 * Modification History: Revision 1.5  2004/03/13 15:50:03  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 1.4  2002/10/17 00:02:07  heller
 * Modification History: Implement turnout body, track length, and turntable support, along with
 * Modification History: accessors.
 * Modification History:
 * Modification History: Revision 1.3  2002/09/25 01:55:14  heller
 * Modification History: Implement Tcl access to graph nodes.
 * Modification History:
 * Modification History: Revision 1.2  2002/07/28 14:06:34  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%title ""
#endif
%module Mrr
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%section "Model Railroad"
#endif
%{
#include <iostream>   
#include <fstream>
#if __GNUC__ >= 3
using namespace std;
#endif
#include <ParseFile.h>
#include <TrackGraph.h>
/*#include <Tree.h>*/
/*#include <MRRSigExpr.tab.h>*/
#include <MRRXtrkCad.tab.h>
static char rcsid[] = "$Id$";

#include <sstream>

%}


%include typemaps.i

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%init %{
	if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
	    return TCL_ERROR;
	}
	Tcl_PkgProvide(interp,"Mrr",MRR_PATCH_LEVEL);
%}
#else
%{
#undef SWIG_name
#define SWIG_name "Mrr"
#undef SWIG_version
#define SWIG_version MRR_PATCH_LEVEL
%}
#endif

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%style before
#endif

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%subsection "TrackGraph"
#endif
%include TrackGraph.h

#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%subsection "MRRXtrkCad"
#endif

class MRRXtrkCad {
public:
	MRRXtrkCad(const char *);
	~MRRXtrkCad();
	const char * SourceFile();
	bool IsNodeP(int nid);
	int NumEdges(int nid);
	int EdgeIndex(int nid, int edgenum);
	float EdgeX(int nid, int edgenum);
	float EdgeY(int nid, int edgenum);
	float EdgeA(int nid, int edgenum);
	float LengthOfNode(int nid);
	const TurnoutGraphic *NodeTurnoutGraphic(int nid) const;
	const TurnoutRoutelist *NodeTurnoutRoutelist(int nid) const;
	int LowestNode();
	int HighestNode();
};

%typemap(tcl8,out) int MyTcl_Result {
#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
 return $source;
#else
 return $1;
#endif
}
%apply int MyTcl_Result { int MRRXtrkCad_Emit };
%apply int MyTcl_Result { int MRRXtrkCad_ProcessFile };


#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%addmethods 
#else
%extend
#endif
	MRRXtrkCad {
	int ProcessFile(Tcl_Interp *interp) {
		std::ostringstream error;
		if (self->ProcessFile(error) != 0) {
			const std::string bytes = error.str();
			int i = bytes.size();
			Tcl_Obj * tcl_result = (Tcl_GetObjResult(interp));
			Tcl_AppendToObj(tcl_result,bytes.c_str(),i);
			return TCL_ERROR;
		} else return TCL_OK;
	}
	int Emit(Tcl_Interp *interp,const char * outfile) {
		Tcl_ResetResult(interp);
		ofstream output(outfile);
		self->Emit(output);
		return TCL_OK;
	}
	const char * TypeOfNode(int nid)
	{
		switch (self->TypeOfNode(nid))
		{
			case TrackGraph::Track: return("TrackGraph::Track"); break;
			case TrackGraph::Turnout: return("TrackGraph::Turnout"); break;
			case TrackGraph::Turntable: return("TrackGraph::Turntable"); break;
		}
		return NULL;
	}
}


#if SWIGVERSIONMINOR == 1 && SWIGVERSIONMAJOR == 1
%subsection "Socketpair"
#endif

%apply int MyTcl_Result { int tcl_socketpair };

%{

#if !HAVE_SOCKETPAIR
#include <winsock2.h>

int socketpair(int af, int type, int protocol, int sv[2])
{
    SOCKET temp, s1, s2;
    SOCKADDR_IN saddr;
    int nameLen;
    u_long arg = 1;
    fd_set reads, writes; //excepts;
    TIMEVAL tv;

    /* ignore address family for now; just stay with AF_INET */
    if ((temp = socket(AF_INET, type, protocol)) == INVALID_SOCKET) {
        return -1; /* error case */
    }

    /* set to non-blocking. */
    ioctlsocket(temp, FIONBIO, &arg);

    /* We *SHOULD* choose the correct sockaddr structure based
    on the address family requested... */

    saddr.sin_family = AF_INET;
    saddr.sin_addr.s_addr = INADDR_LOOPBACK;
    saddr.sin_port = INADDR_ANY;

    if (bind(temp, (SOCKADDR *)&saddr, sizeof(SOCKADDR_IN)) == SOCKET_ERROR) {
        closesocket(temp);
        return -1; /* error case */
    }

    if (listen(temp, 1) == SOCKET_ERROR) {
        closesocket(temp);
        return -1; /* error case */
    }

    nameLen = sizeof(SOCKADDR_IN);
    if (getsockname(temp, (SOCKADDR *)&saddr, &nameLen) == SOCKET_ERROR) {
        closesocket(temp);
        return -1; /* error case */
    }

    if ((s1 = socket(AF_INET, type, protocol)) == INVALID_SOCKET) {
        closesocket(temp);
        return -1; /* error case */
    }

    /* set to non-blocking. */
    ioctlsocket(s1, FIONBIO, &arg);

    if (connect(s1, (SOCKADDR *)&saddr, nameLen) != SOCKET_ERROR
            || WSAGetLastError() != WSAEWOULDBLOCK) {
        closesocket(temp);
        closesocket(s1);
        return -1; /* error case */
    }

    FD_SET(temp, &reads);
    FD_SET(s1, &writes);
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
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <errno.h>
#endif
%}

%inline %{
int tcl_socketpair(Tcl_Interp *interp)
{
	static char name[16 + TCL_INTEGER_SPACE];
	int fds[2], i;
	Tcl_Channel chans[2];

	if (socketpair(AF_UNIX,SOCK_STREAM,0,fds) < 0) {
		Tcl_AppendResult(interp,strerror(errno),(char*)NULL);
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


