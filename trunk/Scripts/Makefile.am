#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file
#* Created by Robert Heller on Mon Aug 22 21:07:47 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2006/01/03 15:30:21  heller
#* Modification History: Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:37  heller
#* Modification History: Nov 4, 2005 Lockdown
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

if HAVE_WIRINGPI
CMRISLAVE = CMRI_Slave
else
CMRISLAVE =
endif

if DONT_HAVE_BISONXX
DISPATCHER =
else
DISPATCHER = Dispatcher
endif

if TARGET_IS_LINUX
LINUXGPIO = LinuxGpio
else
LINUXGPIO =
endif

SUBDIRS = Common GRSupport $(DISPATCHER) CameraScripts \
	  CalcScripts FreightCarForwarder2 \
	  TimeTable2 ControlSupport MainProgram GenericThrottle CMri \
	  XPressNet NCE LocoNet RailDriverSupport Satellite CTIAcela \
	  LCC $(CMRISLAVE) $(LINUXGPIO) EquipmentInventory FreightCarForwarder3

