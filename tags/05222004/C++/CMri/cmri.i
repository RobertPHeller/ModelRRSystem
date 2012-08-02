/* 
 * ------------------------------------------------------------------
 * cmri.i - C/MRI interface wrapper
 * Created by Robert Heller on Sat Mar 13 10:58:14 2004
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2004/03/16 14:49:28  heller
 * Modification History: Code comments added
 * Modification History:
 * Modification History: Revision 1.2  2004/03/16 02:37:39  heller
 * Modification History: Base class documentation
 * Modification History:
 * Modification History: Revision 1.1  2004/03/14 05:20:17  heller
 * Modification History: First Alpha Release Lockdown
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

%module Cmri
%{
#include <stdio.h>
#include <ctype.h>
#include <cmri.h>
static char rcsid[] = "$Id$";
%}

%include typemaps.i

%init %{
	// Make the module Stubs aware.
	if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
	    return TCL_ERROR;
	}
	// Make it a proper Tcl package.
	Tcl_PkgProvide(interp,"Cmri","1.0");
%}

/*
 Typemaps for handling the List class.  This maps a Tcl list of integers to
 a List class instance.
 */

%typedef List *ListP;	// Help SWIG's pattern matching

/*
 * Input method: convert a Tcl list (of integers) to a freshly allocated List 
 * object.
 */

%typemap(tcl8,in) const List * {
	Tcl_Obj **objvPtr;
	int       objcPtr,i;
	if (Tcl_ListObjGetElements(interp,$source,&objcPtr,&objvPtr) != TCL_OK)
		return(TCL_ERROR);
	$target = new List(objcPtr);
	for (i = 0; i < objcPtr; i++) {
		if (Tcl_GetIntFromObj(interp,objvPtr[i],&((*$target)[i])) != TCL_OK)
			return(TCL_ERROR);
	}
}

%typemap(tcl8,freearg) const List * {
	delete $source;
}


/*
 * Output (function result) method: convert the List object pointer to a Tcl
 * list.  Free up the List object pointer.  If the result was a NULL, return
 * an empty Tcl list.
 */

%typemap(tcl8,out) ListP {
	int i, length;
	if ($source == NULL) length = 0;
	else length = $source->Length();
	tcl_result = Tcl_GetObjResult(interp);
	Tcl_SetListObj(tcl_result,0,NULL);
	for (i = 0; i < length; i++) {
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewIntObj((*$source)[i])) != TCL_OK)
			return TCL_ERROR;
	}
	if ($source != NULL) delete $source;
}

/*
 * Type map to handle error messages.  Hide this parameter from Tcl, but return
 * it as a second result, returning TCL_ERROR, if there is an error message.
 */

%typemap(tcl8,ignore) char **outmessage {
	$target = new char*;
	*$target = NULL;
}

%typemap(tcl8,argout) char **outmessage {
	if (*$source != NULL) {
		int mlen = strlen(*$source);
		if (Tcl_ListObjAppendElement(interp,tcl_result,Tcl_NewStringObj(*$source,mlen)) != TCL_OK) {
			delete *$source;
			delete $source;
			return TCL_ERROR;
		}
		delete *$source;
		delete $source;
		return TCL_ERROR;
	}
	delete $source;
}

/*
 * Typemap for the CardType Enum.  Map the first character of the input string
 * to the CardType Enum type.
 */

enum CardType {USIC='N',SUSIC='X',SMINI='M'};

%typemap(tcl8,in) CardType {
	char *p;
	p = Tcl_GetString($source);
	if (p == NULL || strlen(p) < 1) {
		Tcl_SetStringObj(tcl_result,"Missing CardType, should be one of N, X, or M!",-1);
		return TCL_ERROR;
	}
	switch (toupper(p[0])) {
		case 'N': $target = USIC; break;
		case 'X': $target = SUSIC; break;
		case 'M': $target = SMINI; break;
		default:
			Tcl_SetStringObj(tcl_result,"Bad CardType, should be one of N, X, or M! Got: ",-1);
			Tcl_AppendObjToObj(tcl_result,$source);
			return TCL_ERROR;
	}
}

/*
 * Simplified CMri class, taken from cmri.h
 */

class CMri {
public:
	CMri(const char *port="/dev/ttyS0", int baud=9600,int maxtries=10000,char **outmessage=NULL);
	~CMri();
	ListP Inputs(int ni,int ua=0,char **outmessage=NULL);
	void Outputs(const List *ports,int ua=0,char **outmessage=NULL);
	void InitBoard(const List *CT,int ni,int no,int ns=0,int ua=0, CardType card=(CardType)SMINI,int dl=0,char **outmessage=NULL);
};	


