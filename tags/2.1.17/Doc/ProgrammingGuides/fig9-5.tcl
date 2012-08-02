#!/usr/bin/tclsh
#* 
#* ------------------------------------------------------------------
#* fig9-5.tcl - Tcl / libcmri version of fig9-5.bas
#* Created by Robert Heller on Sun May 11 18:39:08 2008
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

# $Id$ 

# Load MRR System packages
# Add MRR System package Paths
lappend auto_path /usr/local/lib/MRRSystem;# C++ (binary) packages
package require Cmri;#          Load the CMR/I package

#  REM**DEFINE CONSTANTS FOR PACKING AND UNPACKING I/O BYTES
#     B0 = 1: B1 = 2: B2 = 4: B3 = 8: B4 = 16: B5 = 32: B6 = 64: B7 = 128
#     W1 = 1: W2 = 3: W3 = 7: W4 = 15: W5 = 31: W6 = 63: W7 = 127

# Bit shift constants
#
set B0 0
set B1 1
set B2 2
set B3 3
set B4 4
set B5 5
set B6 6
set B7 7

# Bit mask constants
#
set W1 0x01
set W2 0x03
set W3 0x07
set W4 0x0f
set W5 0x1f
set W6 0x3f
set W7 0x7f


#  REM**DEFINE BLOCK OCCUPATION CONSTANTS
#     CLR = 0       'Clear
#     OCC = 1       'Occupied

set CLR 0
set OCC 1

#  REM**DEFINE SIGNAL ASPECTS
#     DRK = 0       'Dark  00
#     GRN = 1       'Green 01
#     RED = 2       'Red   10

set DRK 0		# Dark  00
set GRN 1		# Green 01
set RED 2		# Red   10

set UA 0;#    Address of our SMINI card

#  PRINT "SIGNALING LOOP TRACK USING SMINI WITH 2-ASPECT COLOR LIGHT SIGNALS"

puts "SIGNALING LOOP TRACK USING SMINI WITH 2-ASPECT COLOR LIGHT SIGNALS"

#  REM**INITIALIZE SMINI**
#     UA = 0           'USIC NODE ADDRESS
#     COMPORT = 2      'PC SERIAL COMMUNICATIONS PORT = 1, 2, 3 OR 4
#     BAUD100 = 96     'BAUD RATE OF 9600 DIVIDED BY 100
#     DL = 0           'USIC TRANSMISSION DELAY
#     NDP$ = "M"       'NODE DEFINITION PARAMETER
#     NS = 0           'NUMBER OF 2-LEAD SEARCHLIGHT SIGNALS
#     NI = 3               'NUMBER OF INPUT PORTS
#     NO = 6               'NUMBER OF OUTPUT PORTS
#     MAXTRIES = 10000 'MAXIMUM READ TRIES BEFORE ABORT INPUTS
#     GOSUB INIT   'INVOKE INITIALIZATION SUBROUTINE

#**************************************
#* Initialize bus                     *
#**************************************
# Connect to the bus on COM2: (/dev/ttyS1), at 9600 BAUD, with
# a retry count of 10000, capturing error messages.
if {[catch {CMri bus /dev/ttyS1 9600 10000} result]} {
	set errorMessage [lindex $result 1] 
	# Handle error.
	puts -nonewline stderr "Could not connect to CMR/I bus on /dev/ttyS1: "
	puts stderr "$errorMessage"
	rename bus {}
	exit 99
}
#**************************************
#* Initialize board                   *
#**************************************
if {[catch {bus InitBoard {0 0 0 0 0 0} 3 6 0 $UA SMINI 0} result]} {
	set errorMessage [lindex $result 1]
	# Handle error.
	puts -nonewline stderr "Could not initialize SMINI card at UA "
	puts stderr "$UA: $errorMessage"
	rename bus {}
	exit 99
}

#     PRINT "NODE INITIALIZATION IS COMPLETE - CHECK LED BLINK RATE"
#     PRINT "   AND PRESS ANY KEY TO CONTINUE"
#     SLEEP

puts "NODE INITIALIZATION IS COMPLETE - CHECK LED BLINK RATE"
puts "   AND PRESS ANY KEY TO CONTINUE"
gets stdin
     
#BRTL:   '*******BEGIN REAL TIME LOOP*******

while {true} {
		
#  REM**READ INPUT BYTES FROM SMINI's 3 INPUT PORTS
#     GOSUB INPUTS    'Input bytes are stored as IB(1), IB(2), IB(3)

	if {[catch {bus Inputs 3 $UA} result]} {
		set errorMessage [lindex $result 1]
		puts -nonewline stderr "Could not read from the input ports of "
		puts stderr "SMINI card at UA $UA: $errorMessage"
		break
	}
	set Inputs $result
#
#  REM**UNPACK INPUTS
#     BK(1) = IB(1) \ B0 AND W1  'CARD 2 PORT A
#     BK(2) = IB(1) \ B1 AND W1
#     BK(3) = IB(1) \ B2 AND W1
#     BK(4) = IB(1) \ B3 AND W1
#     BK(5) = IB(1) \ B4 AND W1
#     BK(6) = IB(1) \ B5 AND W1

	set BK(0) [expr {[lindex $Inputs 0] << $B0 & $W1}];# CARD 2 PORT A
	set BK(1) [expr {[lindex $Inputs 0] << $B1 & $W1}]
	set BK(2) [expr {[lindex $Inputs 0] << $B2 & $W1}]
	set BK(3) [expr {[lindex $Inputs 0] << $B3 & $W1}]
	set BK(4) [expr {[lindex $Inputs 0] << $B4 & $W1}]
	set BK(5) [expr {[lindex $Inputs 0] << $B5 & $W1}]
#
#  REM**INITIALIZE ALL SIGNALS TO GREEN
#     FOR I = 1 TO 6: SE(I) = GRN: SW(I) = GRN: NEXT I

	for {set i 0} {$i < 6} {incr i) {set SE($i) $GRN;set SW($i) $GRN}

# 
# REM**CHECK IF BLOCK OCCUPIED THEN SET SIGNALS LEADING INTO BLOCK RED
#     IF BK(1) = OCC THEN SE(6) = RED: SW(2) = RED
#     IF BK(2) = OCC THEN SE(1) = RED: SW(3) = RED
#     IF BK(3) = OCC THEN SE(2) = RED: SW(4) = RED
#     IF BK(4) = OCC THEN SE(3) = RED: SW(5) = RED
#     IF BK(5) = OCC THEN SE(4) = RED: SW(6) = RED
#     IF BK(6) = OCC THEN SE(5) = RED: SW(1) = RED

	if {$BK(0) == $OCC} {set SE(5) $RED;set SW(1) $RED}
	if {$BK(1) == $OCC} {set SE(0) $RED;set SW(2) $RED}
	if {$BK(2) == $OCC} {set SE(1) $RED;set SW(3) $RED}
	if {$BK(3) == $OCC} {set SE(2) $RED;set SW(4) $RED}
	if {$BK(4) == $OCC} {set SE(3) $RED;set SW(5) $RED}
	if {$BK(5) == $OCC} {set SE(4) $RED;set SW(0) $RED}

#
# REM**IMPLEMENT APPROACH LIGHTING BY SETTING SIGNALS TO DARK...
# REM**      ...IF BLOCK APPROACHING SIGNAL IS CLEAR
#     FOR I = 1 TO 6
#	 IF BK(I) = CLR THEN SE(I) = DRK: SW(I) = DRK
#     NEXT I

	for {set i 0} {$i < 6} {incr i} {
		if {$BK(i) == $CLR} {set SE(i) $DRK; set SW(i) $DRK}
	}

#
#  REM**PACK OUTPUT BYTES
#     OB(1) = SE(1)                     'SMINI CARD 0 PORT A    
#     OB(1) = SW(1) * B2 OR OB(1)
#     OB(1) = SE(2) * B4 OR OB(1)
#     OB(1) = SW(2) * B6 OR OB(1)

	# SMINI CARD 0 PORT A
	set Outputs [expr {$SE(0) |		\
			   $SW(0) << $B2 |	\
			   $SE(1) << $B4 |	\
			   $SW(1) << B6}]

#
#     OB(2) = SE(3)                     'SMINI CARD 0 PORT B
#     OB(2) = SW(3) * B2 OR OB(2)
#     OB(2) = SE(4) * B4 OR OB(2)
#     OB(2) = SW(4) * B6 OR OB(2)

	# SMINI CARD 0 PORT B
	lappend Outputs [expr {$SE(2) |		\
			       $SW(2) << $B2 |	\
			       $SE(3) << $B4 |	\
			       $SW(3) << $B6}]

#
#     OB(3) = SE(5)                     'SMINI CARD 0 PORT C
#     OB(3) = SW(5) * B2 OR OB(3)
#     OB(3) = SE(6) * B4 OR OB(3)
#     OB(3) = SW(6) * B6 OR OB(3)

	# SMINI CARD 0 PORT C
	lappend Outputs [expr {$SE(4) |		\
			       $SW(4) << $B2 |	\
			       $SE(5) << $B4 |	\
			       $SW(5) << $B6}]

	lappend Outputs 0 0 0;	# SMINI CARD 1 PORTs A, B, C
#
#  REM**WRITE OUTPUT BYTES TO SMINI's 6 OUTPUT PORTS
#     GOSUB OUTPUTS

	if {[catch {bus Outputs $Outputs $UA} result]} {
		set errorMessage [lindex $result 1]
		# Handle error.
		puts -nonewline stderr "Could not write to the output ports of "
		puts stderr "SMINI card at UA $UA: $errorMessage"
		break
	}
#
#  REM**RETURN TO BEGINNING OF REAL-TIME LOOP
#     GOTO BRTL

}

