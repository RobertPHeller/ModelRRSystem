#* 
#* ------------------------------------------------------------------
#* Role PlayingDB V2.0 by Deepwoods Software
#* ------------------------------------------------------------------
#* diskfree.i - Diskfree
#* Created by Robert Heller on Sat Oct 28 02:27:11 2000
#* ------------------------------------------------------------------
#* Modification History: 
#* $Log: diskfree.i,v $
#* Revision 1.1.1.1  2000/11/09 19:20:19  heller
#* Imported sources
#*
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Role Playing DB -- A database package that creates and maintains
#* 		       a database of RPG characters, monsters, treasures,
#* 		       spells, and playing environments.
#* 
#*     Copyright (C) 1995,1998,1999  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#* 

%module Diskfree
%{
#if defined(__WIN32__)

#include <windows.h>

typedef int (WINAPI *FARPROC4)(LPCSTR,PULARGE_INTEGER,PULARGE_INTEGER,PULARGE_INTEGER);

double SpaceAvailable(const char *device)
{
	static ULARGE_INTEGER FreeBytesAvailable,TotalNumberOfBytes,
			TotalNumberOfFreeBytes;
	static DWORD SectPerClust, BytesPerSect, FreeClusters, TotalClusters;
	BOOL status;

	FARPROC4 pGetDiskFreeSpaceEx;

	pGetDiskFreeSpaceEx = (FARPROC4) GetProcAddress( GetModuleHandle("kernel32.dll"),
					      "GetDiskFreeSpaceExA");

	if (pGetDiskFreeSpaceEx)
	{
	  status = pGetDiskFreeSpaceEx (device, &FreeBytesAvailable,
					&TotalNumberOfBytes,
					&TotalNumberOfFreeBytes);
	  if (status) {
	    return ((double) (FreeBytesAvailable.QuadPart));
	  } else return -1.0;
	} else {
	  status = GetDiskFreeSpace (device, &SectPerClust, &BytesPerSect, 
				     &FreeClusters, &TotalClusters);
	  if (status) {
	    return ((double) FreeClusters) * ((double) SectPerClust)  
					   * ((double) BytesPerSect);
	  } else return -1.0;
	}
	
}

#else

#include <sys/vfs.h>

double SpaceAvailable(const char *device)
{
	static struct statfs statbuffer;
	int status;

	status = statfs(device,&statbuffer);
	if (status < 0) { return -1.0; }

	return ((double)statbuffer.f_bavail) *
	       ((double) statbuffer.f_bsize);
}

#endif
%}

%init %{
	if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
	  return TCL_ERROR;
	}
	Tcl_PkgProvide(interp,"Diskfree","1.0");
%}

double SpaceAvailable(const char *device);
