#* 
#* ------------------------------------------------------------------
#* Makefile.am - Makefile for C++ API Manpages
#* Created by Robert Heller on Sun Apr 22 10:11:46 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
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

BASE_MANS  =  CMri.3mrr
BUILT_MANS = Inputs.3mrr Outputs.3mrr InitBoard.3mrr

man_MANS = $(BASE_MANS)  $(BUILT_MANS)

EXTRA_DIST = $(BASE_MANS)

Inputs.3mrr Outputs.3mrr InitBoard.3mrr : CMri.3mrr
	echo '.so man3/CMri.3mrr' > Inputs.3mrr
	echo '.so man3/CMri.3mrr' > Outputs.3mrr
	echo '.so man3/CMri.3mrr' > InitBoard.3mrr


