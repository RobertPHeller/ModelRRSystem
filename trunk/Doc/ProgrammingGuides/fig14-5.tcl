#!/usr/bin/tclsh
#* 
#* ------------------------------------------------------------------
#* fig14-5.tcl - Tcl / libcmri port of fig14-5.bas
#* Created by Robert Heller on Tue May 13 07:57:16 2008
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

#     DEFINT A-Z
#     DECLARE SUB INIT ()
#     DECLARE SUB OUTPUTS ()
#     DECLARE SUB INPUTS ()
#     DECLARE SUB RXBYTE ()
#     DECLARE SUB TXPACK ()
#  REM**MULTI-NODE EXAMPLE USING 3-ASPECT COLOR LIGHT SIGNALS**
#  REM**GLOBALIZE SERIAL PROTOCOL HANDLING VARIABLES 
#     DIM SHARED OB(60), IB(60), CT(15), TB(80)       
#     COMMON SHARED UA, COMPORT, BAUD100, NDP$, DL, NS, NI, NO, MAXTRIES        
#     COMMON SHARED INBYTE, ABORTIN, INTRIES, INITERR, PA, LM, MT      

# Load MRR System packages
# Add MRR System package Paths
lappend auto_path /usr/local/share/MRRSystem;# Tcl packages
package require Cmri 2.0.0;#          Load the CMR/I package

#  
#  REM**INITIALIZE CONSTANTS FOR PACKING AND UNPACKING I/O BYTES
#     B0 = 1: B1 = 2: B2 = 4: B3 = 8: B4 = 16: B5 = 32: B6 = 64: B7 = 128
#     W1 = 1: W2 = 3: W3 = 7: W4 = 15: W5 = 31: W6 = 63: W7 = 127

#  REM**SUSIC SINGLE-NODE SYSTEM USING 3-ASPECT COLOR LIGHT SIGNALS**
#  REM**DEFINE VARIABLE TYPES AND ARRAY SIZES
#     DEFINT A-Z
#	DIM OB(60), IB(60), TB(80), CT(15)
#
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

#
#  REM**DEFINE BLOCK OCCUPATION CONSTANTS
#     CLR = 0       'Clear
#     OCC = 1       'Occupied

set CLR 0
set OCC 1

#
#    REM**DEFINE SIGNAL ASPECTS - Single Head
#     DRK = 0   'Dark    000
#     GRN = 1   'Green   001
#     YEL = 2   'Yellow  010
#     RED = 4   'Red     100

set DRK 0;# Dark    000
set GRN 1;# Green   001
set YEL 2;# Yellow  010
set RED 4;# Red     100

#
#  REM**DEFINE SIGNAL ASPECTS - Double Head
#     GRNRED = 17   'Green over red    10001
#     YELRED = 18   'Yellow over red   10010
#     REDYEL = 12   'Red over yellow   01100
#     REDRED = 20   'Red over red      10100

set GRNRED 0x11;# Green over red    10001
set YELRED 0x12;# Yellow over red   10010
set REDYEL 0x0c;# Red over yellow   01100
set REDRED 0x14;# Red over red      10100

#
#  REM**DEFINE SIGNAL ASPECTS - Triple Head
#     REDREDRED = 84   'Red over red over red     1010100
#     REDREDYEL = 52   'Red over red over yellow  0110100
#     REDYELRED = 76   'Red over yellow over red  1001100
#     YELREDRED = 82   'Yellow over red over red  1010010
#     GRNREDRED = 81   'Green over red over red   1010001

set REDREDRED 0x54;# Red over red over red     1010100
set REDREDYEL 0x34;# Red over red over yellow  0110100
set REDYELRED 0x4c;# Red over yellow over red  1001100
set YELREDRED 0x52;# Yellow over red over red  1010010
set GRNREDRED 0x51;# Green over red over red   1010001

#
#  REM**INITIALIZE TURNOUT POSITION CONSTANTS
#  REM**Constants assume direct connection to output pins (not using SMC)
#  REM**See other examples for using SMC card with one I/O line per machine
#     TUN = 1     '01
#     TUR = 2     '10

set TUN 0
set TUR 1

#
#  REM**DEFINE PUSHBUTTON AND TOGGLE POSITIONS
#     PBP = 1   'Pushbutton pressed
#     TGR = 1   'Toggle reverse position
#     TGN = 0   'Toggle normal position

set PBP 1;# Pushbutton pressed
set TGR 1;# Toggle reverse position
set TGN 0;# Toggle normal position

#
#  REM**DEFINE DIRECTION-OF-TRAFFIC RUNNING ON SINGLE TRACK
#     NDT = 0      'No direction-of-traffic defined on single track
#     EBD = 1      'EastBounD Direction
#     WBD = 2      'WestBounD Direction

set NDT 0;# No direction-of-traffic defined on single track
set EBD 1;# EastBounD Direction
set WBD 2;# WestBounD Direction

#
#  REM**INITIALIZE DIRECTION-OF-TRAFFIC VARIABLES TO NO DIRECTION-OF-TRAFFIC
#     DOT1 = NDT: DOT2 = NDT: DOT3 = NDT
	set DOT1 $NDT; set DOT2 $NDT; set DOT3 $NDT

#
#  PRINT "MULTIPLE NODE EXAMPLE USING 3-ASPECT COLOR LIGHT SIGNALS"

	puts "MULTIPLE NODE RAILROAD EXAMPLE USING 3-ASPECT COLOR LIGHT SIGNALS"

#
#  REM**INITIALIZE GENERAL SERIAL PROTOCOL PARAMETERS (same for all nodes)
#     COMPORT = 3      'PC SERIAL COMMUNICATIONS PORT = 1, 2, 3 OR 4 
#     BAUD100 = 192    'BAUD RATE OF 19200 DIVIDED BY 100
#     DL = 0           'USIC TRANSMISSION DELAY
#     MAXTRIES = 10000 'MAXIMUM READ TRIES BEFORE ABORT INPUTS
# Connect to the bus on COM3: (/dev/ttyS2), at 19200 BAUD, with
# a retry count of 10000, capturing error messages.
if {[catch {cmri::CMri bus /dev/ttyS2 -baud 19200 -retries 10000} result]} {
	# Handle error.
	puts -nonewline stderr "Could not connect to CMR/I bus on /dev/ttyS2: "
	puts stderr "$result"
	rename bus {}
	exit 99
}
#
#  REM**INITIALIZE NODE 0 (SMINI)
#     UA = 0           'USIC NODE ADDRESS
#     NDP$ = "M"       'NODE DEFINITION PARAMETER
#     NS = 0           'NUMBER OF 2-LEAD SEARCHLIGHT SIGNALS
#     NI = 3		  'NUMBER OF INPUT PORTS
#     NO = 6		  'NUMBER OF OUTPUT PORTS
#     CALL INIT        'INVOKE INITIALIZATION SUBROUTINE
set UA 0
if {[catch {bus InitBoard {} 3 6 0 $UA SMINI 0} result]} {
	# Handle error.
	puts -nonewline stderr "Could not initialize SMINI card at UA "
	puts stderr "$UA: $result"
	rename bus {}
	exit 99
}
#
#  REM**INITIALIZE NODE 1 (SMINI)
#     UA = 1           'USIC NODE ADDRESS
#     NDP$ = "M"       'NODE DEFINITION PARAMETER
#     NS = 0           'NUMBER OF 2-LEAD SEARCHLIGHT SIGNALS
#     NI = 3		  'NUMBER OF INPUT PORTS
#     NO = 6		  'NUMBER OF OUTPUT PORTS
#     CALL INIT        'INVOKE INITIALIZATION SUBROUTINE
set UA 1
if {[catch {bus InitBoard {} 3 6 0 $UA SMINI 0} result]} {
	# Handle error.
	puts -nonewline stderr "Could not initialize SMINI card at UA "
	puts stderr "$UA: $result"
	rename bus {}
	exit 99
}
#
#  REM**INITIALIZE NODE 2 (SMINI)
#     UA = 2           'USIC NODE ADDRESS
#     NDP$ = "M"       'NODE DEFINITION PARAMETER
#     NS = 0           'NUMBER OF 2-LEAD SEARCHLIGHT SIGNALS
#     NI = 3		  'NUMBER OF INPUT PORTS
#     NO = 6		  'NUMBER OF OUTPUT PORTS
#     CALL INIT        'INVOKE INITIALIZATION SUBROUTINE
set UA 2
if {[catch {bus InitBoard {} 3 6 0 $UA SMINI 0} result]} {
	# Handle error.
	puts -nonewline stderr "Could not initialize SMINI card at UA "
	puts stderr "$UA: $result"
	rename bus {}
	exit 99
}
#
#  REM**INITIALIZE NODE 3 (SMINI)
#     UA = 3           'USIC NODE ADDRESS
#     NDP$ = "M"       'NODE DEFINITION PARAMETER
#     NS = 0           'NUMBER OF 2-LEAD SEARCHLIGHT SIGNALS
#     NI = 3		  'NUMBER OF INPUT PORTS
#     NO = 6		  'NUMBER OF OUTPUT PORTS
#     CALL INIT        'INVOKE INITIALIZATION SUBROUTINE
set UA 3
if {[catch {bus InitBoard {} 3 6 0 $UA SMINI 0} result]} {
	# Handle error.
	puts -nonewline stderr "Could not initialize SMINI card at UA "
	puts stderr "$UA: $result"
	rename bus {}
	exit 99
}
#
#  REM**INITIALIZE NODE 4 (SUSIC)
#     UA = 4           'USIC NODE ADDRESS
#     NDP$ = "X"       'NODE DEFINITION PARAMETER
#     NS = 1           'NUMBER OF CARD SETS OF 4
#     CT(1) = 6        'CARD TYPE ARRAY ELEMENT FOR GROUPING OF OIXX
#     NI = 4		  'NUMBER OF INPUT PORTS
#     NO = 4		  'NUMBER OF OUTPUT PORTS
#     CALL INIT        'INVOKE INITIALIZATION SUBROUTINE
set UA 4
if {[catch {bus InitBoard {0x06} 4 4 0 $UA SUSICI 0} result]} {
	# Handle error.
	puts -nonewline stderr "Could not initialize SUSIC card at UA "
	puts stderr "$UA: $result"
	rename bus {}
	exit 99
}
#
#BRTL: '*******BEGIN REAL TIME LOOP*******

while {true} {

#  REM**READ AND UNPACK INPUTS FOR NODE 0 (SMINI)
#     UA = 0: NI = 3
#     CALL INPUTS
#     BK1 = IB(1)\B0 AND W1   'NODE 0 CARD 2 PORT A
#     BK2 = IB(1)\B1 AND W1
#     BK3 = IB(1)\B2 AND W1
#     BK4 = IB(1)\B3 AND W1
#     BK5 = IB(1)\B4 AND W1
#     BK6 = IB(1)\B5 AND W1
#     OS1 = IB(1)\B6 AND W1
#     BK7 = IB(1)\B7 AND W1     

	set UA 0
	if {[catch {bus Inputs 3 $UA} result]} {
		puts -nonewline stderr "Could not read from the input ports of "
		puts stderr "SMINI card at UA $UA: $result"
		break
	}
	set Inputs $result
	set tempByte [lindex $Inputs 0];#	 NODE 0 CARD 2 PORT A
	set BK1 [expr {$tempByte >> $B0 & $W1}]
	set BK2 [expr {$tempByte >> $B1 & $W1}]
	set BK3 [expr {$tempByte >> $B2 & $W1}]
	set BK4 [expr {$tempByte >> $B3 & $W1}]
	set BK5 [expr {$tempByte >> $B4 & $W1}]
	set BK6 [expr {$tempByte >> $B5 & $W1}]
	set OS1 [expr {$tempByte >> $B6 & $W1}]
	set BK7 [expr {$tempByte >> $B7 & $W1}]


#
#  REM**READ AND UNPACK INPUTS FOR NODE 1 (SMINI)
#     UA = 1: NI = 3
#     CALL INPUTS
#     BK8 = IB(1)\B0 AND W1    'NODE 1 CARD 2 PORT A
#     OS2 = IB(1)\B1 AND W1
#     BK9 = IB(1)\B2 AND W1
#     BK10 = IB(1)\B3 AND W1
#     OS3 = IB(1)\B4 AND W1
#     BK11 = IB(1)\B5 AND W1

	set UA 1
	if {[catch {bus Inputs 3 $UA} result]} {
		puts -nonewline stderr "Could not read from the input ports of "
		puts stderr "SMINI card at UA $UA: $result"
		break
	}
	set Inputs $result
	set tempByte [lindex $Inputs 0];#	 NODE 1 CARD 2 PORT A
	set BK8  [expr {$tempByte >> $B0 & $W1}]
	set OS2  [expr {$tempByte >> $B1 & $W1}]
	set BK9  [expr {$tempByte >> $B2 & $W1}]
	set BK10 [expr {$tempByte >> $B3 & $W1}]
	set OS3  [expr {$tempByte >> $B4 & $W1}]
	set BK11 [expr {$tempByte >> $B5 & $W1}]

#
# REM**READ AND UNPACK INPUTS FOR NODE 2 (SMINI)
#     UA = 2: NI = 3
#     CALL INPUTS
#     OS4 = IB(1)\B0 AND W1    'NODE 2 CARD 2 PORT A
#     BK13 = IB(1)\B1 AND W1
#     BK14 = IB(1)\B2 AND W1
#     OS5 = IB(1)\B3 AND W1
#     BK15 = IB(1)\B4 AND W1
#     BK20 = IB(1)\B5 AND W1

	set UA 2
	if {[catch {bus Inputs 3 $UA} result]} {
		puts -nonewline stderr "Could not read from the input ports of "
		puts stderr "SMINI card at UA $UA: $result"
		break
	}
	set Inputs $result
	set tempByte [lindex $Inputs 0];#	 NODE 2 CARD 2 PORT A
	set OS4  [expr {$tempByte >> $B0 & $W1}]
	set BK13 [expr {$tempByte >> $B1 & $W1}]
	set BK14 [expr {$tempByte >> $B2 & $W1}]
	set OS5  [expr {$tempByte >> $B3 & $W1}]
	set BK15 [expr {$tempByte >> $B4 & $W1}]
	set BK20 [expr {$tempByte >> $B5 & $W1}]
#
#  REM**READ AND UNPACK INPUTS FOR NODE 3 (SMINI)
#     UA = 3: NI = 3
#     CALL INPUTS
#     BK16 = IB(1)\B0 AND W1    'NODE 3 CARD 2 PORT A
#     BK17 = IB(1)\B1 AND W1  
#     OS6 = IB(1)\B2 AND W1
#     BK18 = IB(1)\B3 AND W1
#     TF12 = IB(1)\B4 AND W1

	set UA 3
	if {[catch {bus Inputs 3 $UA} result]} {
		puts -nonewline stderr "Could not read from the input ports of "
		puts stderr "SMINI card at UA $UA: $result"
		break
	}
	set Inputs $result
	set tempByte [lindex $Inputs 0];#	 NODE 3 CARD 2 PORT A
	set BK16 [expr {$tempByte >> $B0 & $W1}]
	set BK17 [expr {$tempByte >> $B1 & $W1}]
	set OS6  [expr {$tempByte >> $B2 & $W1}]
	set BK18 [expr {$tempByte >> $B3 & $W1}]
	set TF12 [expr {$tempByte >> $B4 & $W1}]
#
#  REM**READ AND UNPACK INPUTS FOR NODE 4 (SUSIC)
#     UA = 4: NI = 4
#     CALL INPUTS
#     PB1 = IB(1)\B0 AND W1     'NODE 4 CARD 1 PORT A
#     PB2 = IB(1)\B1 AND W1
#     PB3 = IB(1)\B2 AND W1
#     PB4 = IB(1)\B3 AND W1
#     PB5 = IB(1)\B4 AND W1
#     PB6 = IB(1)\B5 AND W1
#     TG6 = IB(1)\B6 AND W1
#     TG7 = IB(1)\B7 AND W1
#
#     TG8 = IB(2)\B0 AND W1     'NODE 4 CARD 1 PORT B
#     TG9 = IB(2)\B1 AND W1
#     TG10 = IB(2)\B2 AND W1
#     TG11 = IB(2)\B3 AND W1

	set UA 4
	if {[catch {bus Inputs 4 $UA} result]} {
		puts -nonewline stderr "Could not read from the input ports of "
		puts stderr "SUSIC card at UA $UA: $result"
		break
	}
	set Inputs $result
	set tempByte [lindex $Inputs 0];#	 NODE 4 CARD 1 PORT A
	set PB1  [expr {$tempByte >> $B0 & $W1}]
	set PB2  [expr {$tempByte >> $B1 & $W1}]
	set PB3  [expr {$tempByte >> $B2 & $W1}]
	set PB4  [expr {$tempByte >> $B3 & $W1}]
	set PB5  [expr {$tempByte >> $B4 & $W1}]
	set PB6  [expr {$tempByte >> $B5 & $W1}]
	set TG6  [expr {$tempByte >> $B6 & $W1}]
	set TG7  [expr {$tempByte >> $B7 & $W1}]
	set tempByte [lindex $Inputs 0];#	 NODE 4 CARD 1 PORT B
	set TG8  [expr {$tempByte >> $B0 & $W1}]
	set TG9  [expr {$tempByte >> $B1 & $W1}]
	set TG10 [expr {$tempByte >> $B2 & $W1}]
	set TG11 [expr {$tempByte >> $B3 & $W1}]
#
#  REM**ALIGN PUSHBUTTON CONTROLLED TURNOUTS IN BUTTE IF OS1 IS CLEAR
#     IF OS1 = OCC THEN GOTO TOGGLES
#     IF PB1 = PBP THEN SM4 = TUN: SM5 = TUN: TK = 1: GOTO TOGGLES
#     IF PB2 = PBP THEN SM4 = TUR: SM5 = TUN: TK = 2: GOTO TOGGLES
#     IF PB3 = PBP THEN SM5 = TUR: SM3 = TUR: TK = 3: GOTO TOGGLES
#     IF PB4 = PBP THEN SM5 = TUR: SM3 = TUN: SM2 = TUN: TK = 4: GOTO TOGGLES
#     IF PB5 = PBP THEN
#	SM5 = TUR: SM3 = TUN: SM2 = TUR: SM1 = TUR: TK = 5: GOTO TOGGLES
#     END IF
#     IF PB6 = PBP THEN SM5 = TUR: SM3 = TUN: SM2 = TUR: SM1 = TUN: TK = 6

	if {$OS1 != $OCC} {
	  if {$PB1 == $PBP} {
	    set SM4 $TUN; set SM5 $TUN; set TK 1
	  } elseif {$PB2 == $PBP} {
	    set SM4 $TUR; set SM5 $TUN; set TK 2
	  } elseif {$PB3 == $PBP} {
	    set SM5 $TUR; set SM3 $TUR; set TK 3
	  } elseif {$PB4 == $PBP} {
	    set SM5 $TUR; set SM3 $TUN; set SM2 $TUN; set TK 4
	  } elseif {$PB5 == $PBP} {
	    set SM5 $TUR; set SM3 $TUN; set SM2 $TUR; set SM1 $TUR; set TK 5
	  } elseif {$PB6 == $PBP} {
	    set SM5 $TUR; set SM3 $TUN; set SM2 $TUR; set SM1 $TUN; set TK 6
	  }
	}


#
#  REM**ALIGN TOGGLE CONTROLLED TURNOUTS IF OS SECTIONS ARE CLEAR
#TOGGLES:  
#     IF OS2 = CLR THEN SM6 = TG6
#     IF OS3 = CLR THEN SM7 = TG7
#     IF OS4 = CLR THEN SM8 = TG8: SM9 = TG9
#     IF OS5 = CLR THEN SM10 = TG10
#     IF OS6 = CLR THEN SM11 = TG11

	if {$OS2 == $CLR} {set SM6 $TG6}
	if {$OS3 == $CLR} {set SM7 $TG7}
	if {$OS4 == $CLR} {set SM8 $TG8; set SM9 $TG9}
	if {$OS5 == $CLR} {set SM10 $TG10}
	if {$OS6 == $CLR} {set SM11 $TG11}

#
#  REM**WHEN AN OS SECTION BECOMES OCCUPIED AND OPPOSING DIRECTION-
#  REM**OF-TRAFFIC IS NOT LOCKED-IN THEN SET DIRECTION-OF-TRAFFIC
#  REM**FOR SECTION OF SINGLE TRACK TO DIRECTION OF MOVEMENT
#     IF OS1 = OCC AND DOT1 <> WBD THEN DOT1 = EBD
#     IF OS2 = OCC AND DOT1 <> EBD THEN DOT1 = WBD
#     IF OS3 = OCC AND DOT2 <> WBD THEN DOT2 = EBD
#     IF OS4 = OCC AND DOT2 <> EBD THEN DOT2 = WBD
#     IF OS5 = OCC AND DOT3 <> WBD THEN DOT3 = EBD
#     IF OS6 = OCC AND DOT3 <> EBD THEN DOT3 = WBD

	if {$OS1 == $OCC && $DOT1 != $WBD} {set DOT1 $EBD}
	if {$OS2 == $OCC && $DOT1 != $EBD} {set DOT1 $WBD}
	if {$OS3 == $OCC && $DOT2 != $WBD} {set DOT2 $EBD}
	if {$OS4 == $OCC && $DOT2 != $EBD} {set DOT2 $WBD}
	if {$OS5 == $OCC && $DOT3 != $WBD} {set DOT3 $EBD}
	if {$OS6 == $OCC && $DOT3 != $EBD} {set DOT3 $WBD}

#  REM**RETAIN DIRECTIONT-OF-TRAFFIC WHILE SINGLE TRACK IS OCCUPIED
#DT1: IF OS1 = OCC THEN GOTO DT2
#     IF BK7 = OCC THEN GOTO DT2
#     IF BK8 = OCC THEN GOTO DT2
#     IF OS2 = OCC THEN GOTO DT2
#     DOT1 = NDT  'All trackage clear so set DOT1 to no direction-of-traffic

	if {$OS1 != $OCC &&
	    $BK7 != $OCC &&
	    $BK8 != $OCC &&
	    $OS2 != $OCC} {
	  set DOT1 $NDT; #All trackage clear so set DOT1 to no direction-of-traffic
	}

# 
#DT2: IF OS3 = OCC THEN GOTO DT3
#     IF BK11 = OCC THEN GOTO DT3
#     IF OS4 = OCC THEN GOTO DT3
#     DOT2 = NDT  'All trackage clear so set DOT2 to no direction-of-traffic

	if {$OS3 != $OCC &&
	    $BK11 != $OCC &&
	    $OS4 != $OCC} {
	  set DOT2 $NDT; #All trackage clear so set DOT2 to no direction-of-traffic
	}

#
#DT3: IF OS5 = OCC THEN GOTO DOTCMP
#     IF BK15 = OCC THEN GOTO DOTCMP
#     IF BK16 = OCC THEN GOTO DOTCMP
#     IF BK17 = OCC THEN GOTO DOTCMP
#     IF OS6 = OCC THEN GOTO DOTCMP
#     DOT1 = NDT  'All trackage clear so set DOT3 to no direction-of-traffic

	if {$OS5 != $OCC &&
	    $BK15 != $OCC &&
	    $BK16 != $OCC &&
	    $BK17 != $OCC &&
	    $OS6 != $OCC} {
	  set DOT3 $NDT; #All trackage clear so set DOT3 to no direction-of-traffic
	}

#DOTCMP:
#
#  REM*******************************
#  REM*******************************
#  REM**CALCULATE EASTBOUND SIGNALS**
#  REM*******************************
#  REM*******************************
#
#  REM**Calculate SIG20RABC
#SIG20R:
#     SIG20RABC = REDREDRED
#     IF OS6 = OCC THEN GOTO SIG18R
#     IF SM11 = TUN AND TF12 = TGR THEN SIG20RABC = REDREDYEL: GOTO SIG18R
#     IF BK18 = OCC THEN GOTO SIG18R
#     IF SM11 = TUN THEN SIG20RABC = YELREDRED ELSE SIG20RABC = REDYELRED

	set SIG20RABC $REDREDRED
	if {$OS6 != $OCC} {
	  if {$SM11 == $TUN && $TF12 == TGR} {
	    set SIG20RABC $REDREDYEL
	  } else {
	    if {$BK18 != $OCC} {
	      if (SM11 == TUN) {
	      	set SIG20RABC $YELREDRED
	      } else {
	      	set SIG20RABC $REDYELRED
	      }
	    }
	  }
	}

#     
#  REM**Calculate SIG18RA
#SIG18R:
#     SIG18RA = RED
#     IF DOT3 = WBD THEN GOTO SIG16R
#     IF BK17 = OCC THEN GOTO SIG16R
#     SIG18RA = YEL
#     IF SIG20RABC = REDREDRED THEN GOTO SIG16R
#     SIG18RA = GRN
#

	set SIG18RA $RED
	if {$DOT3 != $WBD && $BK17 != $OCC} {
	  set SIG18RA $YEL
	  if {$SIG20RABC != $REDREDRED} {set SIG18RA $GRN}
	}


#  REM**Calculate SIG16RA
#SIG16R:
#     SIG16RA = RED
#     IF DOT3 = WBD THEN GOTO SIG14R
#     IF BK16 = OCC THEN GOTO SIG14R
#     SIG16RA = YEL
#     IF SIG18R = RED THEN GOTO SIG14R
#     SIG16RA = GRN

	set SIG16RA $RED
	if {$DOT3 != $WBD && $BK16 != $OCC} {
	  set SIG16RA $YEL
	  if {$SIG18RA != $RED} {set SIG16RA $GRN}
	}

#
#  REM**Calculate SIG14RA and SIG14RC
#SIG14R:
#     SIG14RA = RED: SIG14RC = RED
#     IF DOT3 = WBD THEN GOTO SIG12R
#     IF OS5 = OCC THEN GOTO SIG12R
#     IF BK15 = OCC THEN GOTO SIG12R
#     SIG14R = YEL
#     IF SIG16RA = RED THEN GOTO SIG12R
#     SIG14R = GRN
#     IF SM10 = TUN THEN SIG14RA = SIG14R ELSE SIG14RC = SIG14R

	set SIG14RA $RED; set SIG14RC $RED
	if {$DOT3 != $WBD &&
	    $OS5  != $OCC &&
	    $BK15 != $OCC} {
	  set SIG14R $YEL
	  if {$SIG16RA != $RED} {set SIG14R $GRN}
	  if {$SM10 == $TUN} {set SIG14RA $SIG14R} else {set SIG14RC $SIG14R} 
	}

#
#  REM**Calculate SIG12RABC
#SIG12R:
#     SIG12RABC = REDREDRED
#     IF OS4 = OCC THEN GOTO SIG8R
#     IF SM8 = TUR THEN GOTO SM8REV
#     IF BK13 = OCC THEN GOTO SIG8R
#     SIG12RABC = YELREDRED
#     IF SIG14RA = RED THEN GOTO SIG8R
#     SIG12RABC = GRNREDRED: GOTO SIG8R
#SM8REV:
#     IF SM9 = TUR THEN SIG12RABC = REDREDYEL: GOTO SIG8R
#     IF BK14 = OCC THEN GOTO SIG8R
#     SIG12RABC = REDYELRED


	set SIG12RABC $REDREDRED
	if {$OS4 != $OCC} {
	  if {$SM8 != $TUR} {
	    if {$BK13 != $OCC} {
	      set SIG12RABC $YELREDRED
	      if {$SIG14RA != $RED} {set SIG12RABC $GRNREDRED}
	    }
	  } else {
	    # SM8REV:
	    if {$SM9 == $TUR} {
	      set SIG12RABC $REDREDYEL
	    } elseif {$BK14 != $OCC} {
	      set SIG12RABC $REDYELRED
	    }
	  }
	}


#
#  REM**Calculate SIG8RA and SIG8RC
#SIG8R:
#     SIG8RA = RED: SIG8RC = RED
#     IF DOT2 = WBD THEN GOTO SIG6R
#     IF OS3 = OCC THEN GOTO SIG6R
#     IF BK11 = OCC THEN GOTO SIG6R
#     SIG8R = YEL
#     IF SIG12RABC = REDREDRED THEN GOTO SIG6R
#     SIG8R = GRN
#     IF SM7 = TUN THEN SIG8RA = SIG8R ELSE SIG8RC = SIG8R

	set SIG8RA $RED; set SIG8RC $RED
	if {$DOT2 != $WBD && $OS3 != $OCC && $BK11 != $OCC} {
	  set SIG8R $YEL
	  if {$SIG12RABC != $REDREDRED} {set SIG8R $GRN}
	  if (SM7 == TUN) {set SIG8RA $SIG8R} else {set SIG8RC $SIG8R}
	}


#
#  REM**Calculate SIG6RAB
#SIG6R:
#     SIG6RAB = REDRED
#     IF OS2 = OCC THEN GOTO SIG4R
#     IF SM6 = TUR THEN GOTO SM6REV
#     IF BK9 = OCC THEN GOTO SIG4R
#     SIG6RAB = YELRED
#     IF SIG8RA = RED THEN GOTO SIG4R
#     SIG6RAB = GRNRED: GOTO SIG4R
#
#SM6REV:
#     IF BK10 = OCC THEN GOTO SIG4R
#     SIG6RAB = REDYEL

	set SIG6RAB $REDRED
	if {$OS2 != $OCC} {
	  if {$SM6 != $TUR} {
	    if {$BK9 != $OCC} {
	      set SIG6RAB $YELRED
	      if {$SIG8RA != $RED} {set SIG6RAB $GRNRED}
	    }
	  } else {
	    # SM6REV:
	    if {$BK10 != $OCC} {set SIG6RAB $REDYEL}
	  }
	}

#
#  REM**Calculate SIG4RA
#SIG4R:
#     SIG4RA = RED
#     IF DOT1 = WBD THEN GOTO SIG2R
#     IF BK8 = OCC THEN GOTO SIG2R
#     SIG4RA = YEL
#     IF SIG6RAB = REDRED THEN GOTO SIG2R
#     SIG4RA = GRN

	set SIG4RA $RED
	if {$DOT1 != $WBD && $BK8 != $OCC} {
	  set SIG4RA $YEL
	  if {$SIG6RAB != $REDRED} {set SIG4RA $GRN}
	}

#
#  REM**Calculate Red Butte exit signals
#  REM**Initialize all exit signals to RED
#SIG2R:
#     set SIG2RA $RED: SIG2RB = RED: SIG2RC = RED
#     SIG2RD = RED: SIG2RE = RED: SIG2RF = RED
#
#  REM**Calculate exit signal value for aligned track
#     EXITSIG = RED
#     IF DOT1 = WBD THEN GOTO SIGECMP
#     IF OS1 = OCC THEN GOTO SIGECMP
#     IF BK7 = OCC THEN GOTO SIGECMP
#     EXITSIG = YEL
#     IF SIG4RA = RED THEN GOTO EXSIG
#     EXITSIG = GRN
#
#  REM**Set track aligned exit signal to calculated signal value
#EXSIG:
#     IF TK = 1 THEN SIG2RA = EXITSIG
#     IF TK = 2 THEN SIG2RB = EXITSIG
#     IF TK = 3 THEN SIG2RC = EXITSIG
#     IF TK = 4 THEN SIG2RD = EXITSIG
#     IF TK = 5 THEN SIG2RE = EXITSIG
#     IF TK = 6 THEN SIG2RF = EXITSIG
#SIGECMP:

	set SIG2RA $RED; set SIG2RB $RED; set SIG2RC $RED
	set SIG2RD $RED; set SIG2RE $RED; set SIG2RF $RED
	set EXITSIG $RED
	if {$DOT1 != $WBD && $OS1 != $OCC && $BK7 != $OCC} {
	  set EXITSIG $YEL
	  if {$SIG4RA != $RED} {set EXITSIG $GRN}
	}
	switch $TK {
	  1 {set SIG2RA $EXITSIG}
	  2 {set SIG2RB $EXITSIG}
	  3 {set SIG2RC $EXITSIG}
	  4 {set SIG2RD $EXITSIG}
	  5 {set SIG2RE $EXITSIG}
	  6 {set SIG2RF $EXITSIG}
	}

#
#  REM*******************************
#  REM*******************************
#  REM**CALCULATE WESTBOUND SIGNALS**
#  REM*******************************
#  REM*******************************
#
#    REM**Calculate SIG2LAB (entrance signal into staging)
#SIG2L:
#     SIG2LAB = REDRED
#     IF OS1 = OCC THEN GOTO SIG4L
#     IF TK = 1 AND BK1 = CLR THEN SIG2LAB = YELRED: GOTO SIG4L
#     IF TK = 2 AND BK2 = CLR THEN SIG2LAB = REDYEL: GOTO SIG4L
#     IF TK = 3 AND BK3 = CLR THEN SIG2LAB = REDYEL: GOTO SIG4L
#     IF TK = 4 AND BK4 = CLR THEN SIG2LAB = REDYEL: GOTO SIG4L
#     IF TK = 5 AND BK5 = CLR THEN SIG2LAB = REDYEL: GOTO SIG4L
#     IF TK = 6 AND BK6 = CLR THEN SIG2LAB = REDYEL

	set SIG2LAB $REDRED
	if {$OS1 != $OCC} {
	  if {$TK == $1 && $BK1 == $CLR} {
	    set SIG2LAB $YELRED
	  } elseif {$TK == $2 && $BK2 == $CLR} {
	    set SIG2LAB $REDYEL
	  } elseif {$TK == $3 && $BK3 == $CLR} {
	    set SIG2LAB $REDYEL
	  } elseif {$TK == $4 && $BK4 == $CLR} {
	    set SIG2LAB $REDYEL
	  } elseif {$TK == $5 && $BK5 == $CLR} {
	    set SIG2LAB $REDYEL
	  } elseif {$TK == $6 && $BK6 == $CLR} {
	    set SIG2LAB $REDYEL
	  }
	}

#
#  REM**Calculate SIG4LA
#SIG4L:
#     SIG4LA = RED
#     IF DOT1 = EBD THEN GOTO SIG6L
#     IF BK7 = OCC THEN GOTO SIG6L
#     SIG4LA = YEL
#     IF SIG2LAB = REDRED THEN GOTO SIG6L
#     SIG4LA = GRN

	set SIG4LA $RED
	if {$DOT1 != $EBD && $BK7 != $OCC} {
	  set SIG4LA $YEL
	  if {$SIG2LAB != $REDRED} {set SIG4LA $GRN}
	}

#
#  REM**Calculate SIG6LA and SIG6LC
#SIG6L:
#     SIG6LA = RED: SIG6LC = RED
#     IF DOT1 = EBD THEN GOTO SIG8L
#     IF OS2 = OCC THEN GOTO SIG8L
#     IF BK8 = OCC THEN GOTO SIG8L
#     SIG6L = YEL
#     IF SIG4LA = RED THEN GOTO SIG8L
#     SIG6L = GRN
#     IF SM6 = TUN THEN SIG6LA = SIG6L ELSE SIG6LC = SIG6L
#

	set SIG6LA $RED; set SIG6LC $RED
	if {$DOT1 != $EBD && $OS2 != $OCC && $BK8 != $OCC} {
	  set SIG6L $YEL
	  if {$SIG4LA != $RED} {set SIG6L $GRN}
	  if {$SM6 == $TUN} {set SIG6LA $SIG6L} else {set SIG6LC $SIG6L}
	}


#  REM**Calculate SIG8LAB
#SIG8L:
#     SIG8LAB = REDRED
#     IF OS3 = OCC THEN GOTO SIG12L
#     IF SM7 = TUR THEN GOTO SM7REV
#     IF BK9 = OCC THEN GOTO SIG12L
#     SIG8LAB = YELRED
#     IF SIG6LA = RED THEN GOTO SIG12L
#     SIG8LAB = GRNRED: GOTO SIG12L
#SM7REV:
#     IF BK10 = OCC THEN GOTO SIG12L
#     SIG8LAB = REDYEL

	set SIG8LAB $REDRED
	if {$OS3 != $OCC} {
	  if {$SM7 != $TUR} {
	    if {$BK9 != $OCC} {
	      set SIG8LAB $YELRED
	      if {$SIG6LA != $RED} {set SIG8LAB $GRNRED}
	    }
	  } else {
	    # SM7REV:
	    if {$BK10 != $OCC} {set SIG8LAB $REDYEL}
	  }
	}

#
#  REM**Calculate SIG12LA, SIG12LC and SIG12LD
#SIG12L:
#     SIG12LA = RED: SIG12LC = RED: SIG12LD = RED
#     IF DOT2 = EBD THEN GOTO SIG14L
#     IF OS4 = OCC THEN GOTO SIG14L
#     IF BK11 = OCC THEN GOTO SIG14L
#     SIG12L = YEL
#     IF SIG8LAB = REDRED THEN GOTO SIG14L
#     SIG12L = GRN
#     IF SM8 = TUN THEN SIG12LA = SIG12L: GOTO SIG14L
#     IF SM9 = TUN THEN SIG12LC = SIG12L ELSE SIG12LD = SIG12L

	set SIG12LA $RED; set SIG12LC $RED; set SIG12LD $RED
	if {$DOT2 != $EBD && $OS4 != $OCC && $BK11 != $OCC} {
	  set SIG12L $YEL
	  if {$SIG8LAB != $REDRED} {set SIG12L $GRN}
	  if {$SM8 == $TUN} {
	    set SIG12LA $SIG12L
	  } elseif {$SM9 == $TUN} {
	    set SIG12LC $SIG12L
	  } else {
	    set SIG12LD $SIG12L
	  }
	}


#
#  REM**Calculate SIG14LAB
#SIG14L:
#     SIG14LAB = REDRED
#     IF OS5 = OCC THEN GOTO SIG16L
#     IF SM10 = TUR THEN GOTO SM10REV
#     IF BK13 = OCC THEN GOTO SIG16L
#     SIG14LAB = YELRED
#     IF SIG12LA = RED THEN GOTO SIG16L
#     SIG14LAB = GRNRED: GOTO SIG16L
#SM10REV:
#     IF BK14 = OCC THEN GOTO SIG16L
#     SIG14LAB = REDYEL

	set SIG14LAB $REDRED
	if {$OS5 != $OCC} {
	  if {$SM10 != $TUR} {
	    if {$BK13 != $OCC} {
	      set SIG14LAB $YELRED
	      if {$SIG12LA != $RED} {set SIG14LAB $GRNRED}
	    }
	  } else {
	    # SM10REV
	    if {$BK14 != $OCC} {set SIG14LAB $REDYEL}
	  }
	}

#
#  REM**Calculate SIG16LA
#SIG16L:
#     SIG16LA = RED
#     IF DOT3 = EBD THEN GOTO SIG18L
#     IF BK15 = OCC THEN GOTO SIG18L
#     SIG16LA = YEL
#     IF SIG14LAB = REDRED THEN GOTO SIG18L
#     SIG16LA = GRN

	set SIG16LA $RED
	if {$DOT3 != $EBD && $BK15 != $OCC} {
	  set SIG16LA $YEL
	  if {$SIG14LAB != $REDRED} {set SIG16LA $GRN}
	}

#
#  REM**Calculate SIG18LA
#SIG18L:
#     SIG18LA = RED
#     IF DOT3 = EBD THEN GOTO SIG20L
#     IF BK16 = OCC THEN GOTO SIG20L
#     SIG18LA = YEL
#     IF SIG16LA = RED THEN GOTO SIG20L
#     SIG18LA = GRN

	set SIG18LA $RED
	if {$DOT3 != $EBD && $BK16 != $OCC} {
	  set SIG18LA $YEL
	  if {$SIG16LA != $RED} {set SIG18LA $GRN}
	}

#
#  REM**Calculate SIG20LA, SIG20LB and SIG20LD
#SIG20L:
#     SIG20LA = RED: SIG20LB = RED: SIG20LD = RED
#     IF DOT3 = EBD THEN GOTO SIGWCMP
#     IF OS6 = OCC THEN GOTO SIGWCMP
#     IF BK17 = OCC THEN GOTO SIGWCMP
#     SIG20L = YEL
#     IF SIG18LA <> RED THEN SIG20L = GRN
#     IF SM11 = TUR THEN SIG20LB = SIG20L: GOTO SIGWCMP
#     IF TF12 = TGR THEN SIG20LD = SIG20L ELSE SIG20LA = SIG20L
#SIGWCMP:

	set SIG20LA $RED; set SIG20LB $RED; set SIG20LD $RED
	if {$DOT3 != $EBD && $OS6 != $OCC && $BK17 != $OCC} {
	  set SIG20L $YEL
	  if {$SIG18LA != $RED} {set SIG20L $GRN}
	  if {$SM11 == $TUR} {
	    set SIG20LB $SIG20L
	  } elseif {$TF12 == $TGR} {
	    set SIG20LD $SIG20L
	  } else {
	    set SIG20LA $SIG20L
	  }
	}
#
#  REM**PACK AND WRITE OUTPUT BYTES FOR NODE 0 (SMINI)
#     OB(1) = SIG2LAB		    'NODE 0 CARD 0 PORT A	
#     OB(1) = SIG2RA * B5 OR OB(1)

	set Outputs [expr {$SIG2LAB | $SIG2RA << $B5}];  #NODE 0 CARD 0 PORT A

#     
#     OB(2) = SIG2RB 		    'NODE 0 CARD 0 PORT B
#     OB(2) = SIG2RC * B3 OR OB(2)
#     OB(2) = SM1 * B6 OR OB(2)

	lappend Outputs [expr {$SIG2RB | \
			       $SIG2RC << $B3 | \
			       $SM1    << $B6}];	#NODE 0 CARD 0 PORT B
#
#     OB(3) = SIG2RD                  'NODE 0 CARD 0 PORT C
#     OB(3) = SIG2RE * B3 OR OB(3)
#     OB(3) = SM2 * B6 OR OB(3)

	lappend Outputs [expr {$SIG2RD | \
			       $SIG2RE << $B3 | \
			       $SM2    << $B6}];	#NODE 0 CARD 0 PORT C
#
#     OB(4) = SIG2RF                  'NODE 0 CARD 1 PORT A
#     OB(4) = SM3 * B3 OR OB(4)
#     OB(4) = SM4 * B5 OR OB(4)

	lappend Outputs [expr {$SIG2RF | \
			       $SM3    << $B3 | \
			       $SM4    << $B5}];	#NODE 0 CARD 1 PORT A
#
#     OB(5) = SM5                     'NODE 0 CARD 1 PORT B

	lappend Outputs $SM5;#				 NODE 0 CARD 1 PORT B

#     UA = 0: NO = 6
#     CALL OUTPUTS

	set UA 0
	if {[catch {bus Outputs $Outputs $UA} result]} {
		# Handle error.
		puts -nonewline stderr "Could not write to the output ports of "
		puts stderr "SMINI card at UA $UA: $result"
		break
	}
            


#
#  REM**PACK AND WRITE OUTPUT BYTES FOR NODE 1 (SMINI)
#     OB(1) = SIG4LA                  'NODE 1 CARD 0 PORT A
#     OB(1) = SIG4RA *B3 OR OB(1)                  
#     OB(1) = SM6 * B6 OR OB(1)

	set Outputs [expr {$SIG4LA | \
			   $SIG4RA << $B3 | \
			   $SM6    << $B6}];	#NODE 1 CARD 0 PORT A

#
#     OB(2) = SIG6RAB                 'NODE 1 CARD 0 PORT B                 
#     OB(2) = SIG6LA * B5 OR OB(2)

	lappend Outputs [expr {$SIG6RAB | \
			       $SIG6LA << $B5}];	#NODE 1 CARD 0 PORT B
#
#     OB(3) = SIG6LC                  'NODE 1 CARD 0 PORT C
#     OB(3) = SIG8RA * B3 OR OB(3)
#     OB(3) = SM7 * B6 OR OB(3)

	lappend Outputs [expr {$SIG6LC | \
			       $SIG8RA << $B3 | \
			       $SM7    << $B6}];	#NODE 1 CARD 0 PORT B
#
#     OB(4) = SIG8LAB                 'NODE 1 CARD 1 PORT A
#     OB(4) = SIG8RC * B5 OR OB(4)

	lappend Outputs [expr {$SIG8LAB | \
			       $SIG8RC  << $B5}];	#NODE 1 CARD 1 PORT A
#     UA = 1: NO = 6
#     CALL OUTPUTS

	set UA 1
	if {[catch {bus Outputs $Outputs $UA} result]} {
		# Handle error.
		puts -nonewline stderr "Could not write to the output ports of "
		puts stderr "SMINI card at UA $UA: $result"
		break
	}
            


#                                 
#  REM**PACK AND WRITE OUTPUT BYTES FOR NODE 2 (SMINI)
#     OB(1) = SIG12RABC               'NODE 2 CARD 0 PORT A

	set Outputs $SIG12RABC;		#NODE 2 CARD 0 PORT A

#
#     OB(2) = SIG12LA                 'NODE 2 CARD 0 PORT B
#     OB(2) = SIG12LC * B3 OR OB(2)                 
#     OB(2) = SM8 * B6 OR OB(2)     

	lappend Outputs [expr {$SIG12LA | \
			       $SIG12LC << $B3 | \
			       $SM8     << $B6}];	#NODE 2 CARD 0 PORT B
#           
#     OB(3) = SIG12LD                 'NODE 2 CARD 0 PORT C
#     OB(3) = SIG14RA * B3 OR OB(3)
#     OB(3) = SM9 * B6 OR OB(3)

	lappend Outputs [expr {$SIG12LD | \
			       $SIG14RA << $B3 | \
			       $SM9     << $B6}];	#NODE 2 CARD 0 PORT C
#
#     OB(4) = SIG14LAB                'NODE 2 CARD 1 PORT A                                           
#     OB(4) = SIG14RC * B5 OR OB(4)

	lappend Outputs [expr {$SIG14LAB | \
			       $SIG14RC << $B5}];	#NODE 2 CARD 1 PORT A
#
#     OB(5) = SIG16LA                 'NODE 2 CARD 1 PORT B
#     OB(5) = SIG16RA * B3 OR OB(5)
#     OB(5) = SM10 * B6 OR OB(5)                    

	lappend Outputs [expr {$SIG16LA | \
			       $SIG16RA << $B3 | \
			       $SM10    << $B6}];	#NODE 2 CARD 1 PORT B
#     UA = 2: NO = 6
#     CALL OUTPUTS

	set UA 2
	if {[catch {bus Outputs $Outputs $UA} result]} {
		# Handle error.
		puts -nonewline stderr "Could not write to the output ports of "
		puts stderr "SMINI card at UA $UA: $result"
		break
	}
            
#
#  REM**PACK AND WRITE OUTPUT BYTES FOR NODE 3 (SMINI)
#     OB(1) = SIG18LA                 'NODE 3 CARD 0 PORT A
#     OB(1) = SIG18RA * B3 OR OB(1)
#     OB(1) = SM11 * B6 OR OB(1) 

	set Outputs [expr {$SIG18LA | \
			   $SIG18RA << $B3 | \
			   $SM11    << $B6}];	#NODE 3 CARD 0 PORT A

#
#     OB(2) = SIG20RABC               'NODE 3 CARD 0 PORT B

	lappend Outputs $SIG20RABC;	#NODE 3 CARD 0 PORT B
#
#     OB(3) = SIG20LA 
#     OB(3) = SIG20LB * B3 OR OB(3)   'NODE 3 CARD 0 PORT C

	lappend Outputs [expr {$SIG20LA | \
			       $SIG20LB << $B3}];	#NODE 3 CARD 0 PORT C
#
#     OB(4) = SIG20LD                 'NODE 3 CARD 1 PORT A 

	lappend Outputs $SIG20LD;	#NODE 3 CARD 1 PORT A
#     UA = 3: NO = 6     
#     CALL OUTPUTS

	set UA 3
	if {[catch {bus Outputs $Outputs $UA} result]} {
		# Handle error.
		puts -nonewline stderr "Could not write to the output ports of "
		puts stderr "SMINI card at UA $UA: $result"
		break
	}
#
#  REM**PACK AND WRITE OUTPUT BYTES FOR NODE 4 (SUSIC)
#     OB(1) = DOT1                    'NODE 4 CARD 0 PORT A
#     OB(1) = DOT2 * B2 OR OB(1)
#     OB(1) = DOT3 * B4 OR OB(1)
#     OB(1) = BK1 * B6 OR OB(1)     
#     OB(1) = BK2 * B7 OR OB(1)

	set Outputs [expr {$DOT1 | \
			   $DOT2 << $B2 | \
			   $DOT3 << $B4 | \
			   $BK1  << $B6 | \
			   $BK2  << $B7}];	#NODE 4 CARD 0 PORT A

#     
#     OB(2) = BK3 * B0 OR OB(2)       'NODE 4 CARD 0 PORT B
#     OB(2) = BK4 * B1 OR OB(2)    
#     OB(2) = BK5 * B2 OR OB(2)
#     OB(2) = BK6 * B3 OR OB(2)
#     OB(2) = OS1 * B4 OR OB(2)
#     OB(2) = BK7 * B5 OR OB(2)
#     OB(2) = BK8 * B6 OR OB(2)
#     OB(2) = OS2 * B7 OR OB(2)

	lappend Outputs [expr {$BK3 | \
			       $BK4 << $B1 | \
			       $BK5 << $B2 | \
			       $BK6 << $B3 | \
			       $OS1 << $B4 | \
			       $BK7 << $B5 | \
			       $BK8 << $B6 | \
			       $OS2 << $B7}];	#NODE 4 CARD 0 PORT B
#
#     OB(3) = BK9 * B0 OR OB(3)       'NODE 4 CARD 0 PORT C
#     OB(3) = BK10 * B1 OR OB(3)
#     OB(3) = OS3 * B2 OR OB(3)
#     OB(3) = BK11 * B3 OR OB(3)
#     OB(3) = OS4 * B4 OR OB(3)
#     OB(3) = BK13 * B5 OR OB(3)
#     OB(3) = BK14 * B6 OR OB(3)
#     OB(4) = OS5 * B7 OR OB(4)    

	lappend Outputs [expr {$BK9  | \
			       $BK10 << $B1 | \
			       $OS3  << $B2 | \
			       $BK11 << $B3 | \
			       $OS4  << $B4 | \
			       $BK13 << $B5 | \
			       $BK14 << $B6 | \
			       $OS5  << $B7}];	#NODE 4 CARD 0 PORT C
#     
#     OB(4) = BK15 * B0 OR OB(4)      'NODE 4 CARD 0 PORT D
#     OB(4) = BK16 * B1 OR OB(4)
#     OB(4) = BK17 * B2 OR OB(4)
#     OB(4) = OS6 * B3 OR OB(4)
#     OB(4) = BK18 * B4 OR OB(4)

	lappend Outputs [expr {$BK15 | \
			       $BK16 << $B1 | \
			       $BK17 << $B2 | \
			       $OS6  << $B3 | \
			       $BK18 << $B4}];	#NODE 4 CARD 0 PORT D
#     UA = 4: NO = 4     
#     CALL OUTPUTS

	set UA 4
	if {[catch {bus Outputs $Outputs $UA} result]} {
		# Handle error.
		puts -nonewline stderr "Could not write to the output ports of "
		puts stderr "SUISC card at UA $UA: $result"
		break
	}
#   
#  REM**RETURN TO BEGINNING OF REAL-TIME LOOP
#     GOTO BRTL

}
