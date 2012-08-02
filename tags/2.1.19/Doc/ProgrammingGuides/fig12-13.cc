/* 
 * ------------------------------------------------------------------
 * fig12-13.cc - C++ version of fig12-13.bas
 * Created by Robert Heller on Mon May 12 16:31:19 2008
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

/* $Id$ */


#include <iostream>
#include <MRRSystem/CMri/cmri.h>
#include <unistd.h>

using namespace std;

//  REM**SUSIC SINGLE-NODE SYSTEM USING 3-ASPECT COLOR LIGHT SIGNALS**
//  REM**DEFINE VARIABLE TYPES AND ARRAY SIZES
//     DEFINT A-Z
//	DIM OB(60), IB(60), TB(80), CT(15)
//
//  REM**DEFINE CONSTANTS FOR PACKING AND UNPACKING I/O BYTES
//     B0 = 1: B1 = 2: B2 = 4: B3 = 8: B4 = 16: B5 = 32: B6 = 64: B7 = 128
//     W1 = 1: W2 = 3: W3 = 7: W4 = 15: W5 = 31: W6 = 63: W7 = 127

/* Bit shift constants
 */
#define B0 0
#define B1 1
#define B2 2
#define B3 3
#define B4 4
#define B5 5
#define B6 6
#define B7 7

/* Bit mask constants
 */

#define W1 0x01
#define W2 0x03
#define W3 0x07
#define W4 0x0f
#define W5 0x1f
#define W6 0x3f
#define W7 0x7f

//
//  REM**DEFINE BLOCK OCCUPATION CONSTANTS
//     CLR = 0       'Clear
//     OCC = 1       'Occupied

#define CLR 0
#define OCC 1

//
//    REM**DEFINE SIGNAL ASPECTS - Single Head
//     DRK = 0   'Dark    000
//     GRN = 1   'Green   001
//     YEL = 2   'Yellow  010
//     RED = 4   'Red     100

#define DRK 0		// Dark    000
#define GRN 1		// Green   001
#define YEL 2		// Yellow  010
#define RED 4		// Red     100

//
//  REM**DEFINE SIGNAL ASPECTS - Double Head
//     GRNRED = 17   'Green over red    10001
//     YELRED = 18   'Yellow over red   10010
//     REDYEL = 12   'Red over yellow   01100
//     REDRED = 20   'Red over red      10100

#define GRNRED 0x11	// Green over red    10001
#define YELRED 0x12	// Yellow over red   10010
#define REDYEL 0x0c	// Red over yellow   01100
#define REDRED 0x14	// Red over red      10100

//
//  REM**DEFINE SIGNAL ASPECTS - Triple Head
//     REDREDRED = 84   'Red over red over red     1010100
//     REDREDYEL = 52   'Red over red over yellow  0110100
//     REDYELRED = 76   'Red over yellow over red  1001100
//     YELREDRED = 82   'Yellow over red over red  1010010
//     GRNREDRED = 81   'Green over red over red   1010001

#define REDREDRED 0x54	// Red over red over red     1010100
#define REDREDYEL 0x34	// Red over red over yellow  0110100
#define REDYELRED 0x4c	// Red over yellow over red  1001100
#define YELREDRED 0x52	// Yellow over red over red  1010010
#define GRNREDRED 0x51	// Green over red over red   1010001

//
//  REM**DEFINE TURNOUT POSITION
//  REM**Constants provided below assume SMC card connected between
//  REM**switchmotors and a single output pin on DOUT32 cards. See
//  REM**other examples for direct connections using 2 output pins
//     TUN = 0
//     TUR = 1

#define TUN 0
#define TUR 1

//
//  REM**DEFINE PUSHBUTTON AND TOGGLE POSITIONS
//     PBP = 1   'Pushbutton pressed
//     TGR = 1   'Toggle reverse position
//     TGN = 0   'Toggle normal position

#define PBP 1	// Pushbutton pressed
#define TGR 1	// Toggle reverse position
#define TGN 0	// Toggle normal position

//
//  REM**DEFINE DIRECTION-OF-TRAFFIC RUNNING ON SINGLE TRACK
//     NDT = 0      'No direction-of-traffic defined on single track
//     EBD = 1      'EastBounD Direction
//     WBD = 2      'WestBounD Direction

enum DirectionOfTravel {
	NDT = 0,	// No direction-of-traffic defined on single track
	EBD = 1,	// EastBounD Direction
	WBD = 2		// WestBounD Direction
};

#define UA 0    /* Address of our SUSIC card. */

int main(int argc, char *argv[])
{
	List Outputs(16);	/* Output Port Vector */
	List CT(2);		/* Card Type map */
	List *Inputs;		/* Pointer for inputs */
	CMri *bus;		/* The CMR/I bus */
	char *errorMessage;	/* Holds Error messages */
	static char line[256];	/* answer line  */
	/* Occupency flags */
	unsigned char BK1,  BK2, BK3,  BK4,  BK5,  BK6,  OS1, BK7,
		      BK8,  OS2, BK9,  BK10, OS3,  BK11, OS4, BK13,
		      BK14, OS5, BK15, BK20, BK16, BK17, OS6, BK18;
	/* Manual turnout sense contacts */
	unsigned char TF12;
	/* Pushbuttons */
	unsigned char PB1, PB2, PB3, PB4, PB5, PB6;
	/* Toggles */
	unsigned char TG6, TG7, TG8, TG9, TG10, TG11;
	/* Switch Machines */
	unsigned char SM1, SM2, SM3, SM4, SM5, SM6, SM7, SM8, SM9, SM10, SM11;
	/* Track number */
	unsigned char TK;
	/* Signals */
	unsigned char SIG20RABC, SIG18RA, SIG16RA, SIG14RA, SIG14RC, SIG14R,
			SIG12RABC, SIG8RA, SIG8RC, SIG8R, SIG6RAB, SIG4RA,
			SIG2RA, SIG2RB, SIG2RC, SIG2RD, SIG2RE, SIG2RF,
			EXITSIG, SIG2LAB, SIG4LA, SIG6LA, SIG6L, SIG6LC,
			SIG8LAB, SIG12LA, SIG12LC, SIG12LD, SIG12L, SIG14LAB,
			SIG16LA, SIG18LA, SIG20LA, SIG20LB, SIG20LD, SIG20L;
	/* Temp Byte. */
	unsigned char tempByte;
//
//  REM**INITIALIZE DIRECTION-OF-TRAFFIC VARIABLES TO NO DIRECTION-OF-TRAFFIC
//     DOT1 = NDT: DOT2 = NDT: DOT3 = NDT
	DirectionOfTravel DOT1 = NDT, DOT2 = NDT, DOT3 = NDT;	

//
//  PRINT "SINGLE NODE RAILROAD EXAMPLE USING 3-ASPECT COLOR LIGHT SIGNALS"
//

	cout << "SINGLE NODE RAILROAD EXAMPLE USING 3-ASPECT COLOR LIGHT SIGNALS"
	     << endl;

//  REM**INITIALIZE SUSIC
//     UA = 0           'USIC NODE ADDRESS
//     COMPORT = 3      'PC SERIAL COMMUNICATIONS PORT = 1, 2, 3 OR 4
//     BAUD100 = 192    'BAUD RATE OF 19200 DIVIDED BY 100
//     DL = 0           'USIC TRANSMISSION DELAY
//     NDP$ = "X"       'NODE DEFINITION PARAMETER
//     NS = 2           'NUMBER OF CARD SETS OF 4 (OIIO OOXX)
//     CT(1) = 150      'CARD TYPE SET OF (OIIO)
//     CT(2) = 10       'CARD TYPE SET OF (OOXX)
//     NI = 8               'NUMBER OF INPUT PORTS
//     NO = 16              'NUMBER OF OUTPUT PORTS
//     MAXTRIES = 10000 'MAXIMUM READ TRIES BEFORE ABORT INPUTS
//     GOSUB INIT       'INVOKE INITIALIZATION SUBPROGRAM

	/**************************************
	 * Initialize bus                     *
	 **************************************/
	errorMessage = NULL;    /* No message yet */
	// Connect to the bus on COM2: (/dev/ttyS1), at 19200 BAUD, with
	// a retry count of 10000, capturing error messages.
	bus = new CMri("/dev/ttyS1",19200,10000,&errorMessage);
	if (errorMessage != NULL) {	/* Error? */
		cerr << "Could not connect to CMR/I bus on /dev/ttyS1: " 
		     << errorMessage << endl;
		delete bus;
		delete errorMessage;
		abort();
	}
	/**************************************
	 * Initialize board                   *
	 **************************************/
	CT[0] = 0x96;	// 10010110
			//  O I I O
	CT[1] = 0x0A;	// 00001010
			//  X X O O
	bus->InitBoard(&CT,8,16,0,UA,SUSIC,0,&errorMessage);
	if (errorMessage != NULL) {	/* Error? */
		cerr << "Could not Initialize SUSIC at UA " << UA
		     << errorMessage << endl;
		delete bus;
		delete errorMessage;
		abort();
	}

//
//     PRINT "NODE INITIALIZATION IS COMPLETE - CHECK LED BLINK RATE"
//     PRINT "   AND PRESS ANY KEY TO CONTINUE"
//     SLEEP

	cout << "NODE INITIALIZATION IS COMPLETE - CHECK LED BLINK RATE" << endl;
	cout << "   AND PRESS ANY KEY TO CONTINUE" << endl;
	cin.getline(line,256);
     
//
//BRTL: '*******BEGIN REAL TIME LOOP*******

	while (1) {

//  REM**READ AND UNPACK INPUTS
//     GOSUB INPUTS
		Inputs = bus->Inputs(8,UA,&errorMessage);
		if (errorMessage != NULL) {     /* Error? */
			cerr <<
			"Error reading SUSIC card at UA "
				<< UA << ": " << errorMessage << endl;
			delete errorMessage;
			errorMessage = NULL;
			break;
		}

//     BK1 = IB(1) \ B0 AND W1      'CARD 1 PORT A
//     BK2 = IB(1) \ B1 AND W1
//     BK3 = IB(1) \ B2 AND W1
//     BK4 = IB(1) \ B3 AND W1
//     BK5 = IB(1) \ B4 AND W1
//     BK6 = IB(1) \ B5 AND W1
//     OS1 = IB(1) \ B6 AND W1
//     BK7 = IB(1) \ B7 AND W1

		tempByte = (*Inputs)[0];	// CARD 1 PORT A
		BK1 = tempByte >> B0 & W1;
		BK2 = tempByte >> B1 & W1;
		BK3 = tempByte >> B2 & W1;
		BK4 = tempByte >> B3 & W1;
		BK5 = tempByte >> B4 & W1;
		BK6 = tempByte >> B5 & W1;
		OS1 = tempByte >> B6 & W1;
		BK7 = tempByte >> B7 & W1;

//
//     BK8 = IB(2) \ B0 AND W1      'CARD 1 PORT B
//     OS2 = IB(2) \ B1 AND W1
//     BK9 = IB(2) \ B2 AND W1
//     BK10 = IB(2) \ B3 AND W1
//     OS3 = IB(2) \ B4 AND W1
//     BK11 = IB(2) \ B5 AND W1
//     OS4 = IB(2) \ B6 AND W1
//     BK13 = IB(2) \ B7 AND W1

		tempByte = (*Inputs)[1];        // CARD 1 PORT B
		BK8  = tempByte >> B0 & W1;
		OS2  = tempByte >> B1 & W1;
		BK9  = tempByte >> B2 & W1;
		BK10 = tempByte >> B3 & W1;
		OS3  = tempByte >> B4 & W1;
		BK11 = tempByte >> B5 & W1;
		OS4  = tempByte >> B6 & W1;
		BK13 = tempByte >> B7 & W1;

//
//     BK14 = IB(3) \ B0 AND W1      'CARD 1 PORT C
//     OS5 = IB(3) \ B1 AND W1
//     BK15 = IB(3) \ B2 AND W1
//     BK20 = IB(3) \ B3 AND W1
//     BK16 = IB(3) \ B4 AND W1
//     BK17 = IB(3) \ B5 AND W1
//     OS6 = IB(3) \ B6 AND W1
//     BK18 = IB(3) \ B7 AND W1

		tempByte = (*Inputs)[2];        // CARD 1 PORT C
		BK14 = tempByte >> B0 & W1;
		OS5  = tempByte >> B1 & W1;
		BK15 = tempByte >> B2 & W1;
		BK20 = tempByte >> B3 & W1;
		BK16 = tempByte >> B4 & W1;
		BK17 = tempByte >> B5 & W1;
		OS6  = tempByte >> B6 & W1;
		BK18 = tempByte >> B7 & W1;

//
//     TF12 = IB(4) \ B0 AND W1      'CARD 1 PORT D
//     PB1 = IB(4) \ B1 AND W1
//     PB2 = IB(4) \ B2 AND W1
//     PB3 = IB(4) \ B3 AND W1
//     PB4 = IB(4) \ B4 AND W1
//     PB5 = IB(4) \ B5 AND W1
//     PB6 = IB(4) \ B6 AND W1
//     TG6 = IB(4) \ B7 AND W1

		tempByte = (*Inputs)[3];        // CARD 1 PORT D
		TF12 = tempByte >> B0 & W1;
		PB1  = tempByte >> B1 & W1;
		PB2  = tempByte >> B2 & W1;
		PB3  = tempByte >> B3 & W1;
		PB4  = tempByte >> B4 & W1;
		PB5  = tempByte >> B5 & W1;
		PB6  = tempByte >> B6 & W1;
		TG6  = tempByte >> B7 & W1;

//
//     TG7 = IB(5) \ B0 AND W1       'CARD 2 PORT A
//     TG8 = IB(5) \ B1 AND W1
//     TG9 = IB(5) \ B2 AND W1
//     TG10 = IB(5) \ B3 AND W1
//     TG11 = IB(5) \ B4 AND W1

		tempByte = (*Inputs)[4];        // CARD 2 PORT A
		TG7  = tempByte >> B0 & W1;
		TG8  = tempByte >> B1 & W1;
		TG9  = tempByte >> B2 & W1;
		TG10 = tempByte >> B3 & W1;
		TG11 = tempByte >> B4 & W1;

//
//  REM**ALIGN PUSHBUTTON CONTROLLED TURNOUTS IN BUTTE IF OS1 IS CLEAR
//     IF OS1 = OCC THEN GOTO TOGGLES
//     IF PB1 = PBP THEN SM4 = TUN: SM5 = TUN: TK = 1: GOTO TOGGLES
//     IF PB2 = PBP THEN SM4 = TUR: SM5 = TUN: TK = 2: GOTO TOGGLES
//     IF PB3 = PBP THEN SM5 = TUR: SM3 = TUR: TK = 3: GOTO TOGGLES
//     IF PB4 = PBP THEN SM5 = TUR: SM3 = TUN: SM2 = TUN: TK = 4: GOTO TOGGLES
//     IF PB5 = PBP THEN
//	SM5 = TUR: SM3 = TUN: SM2 = TUR: SM1 = TUR: TK = 5: GOTO TOGGLES
//     END IF
//     IF PB6 = PBP THEN SM5 = TUR: SM3 = TUN: SM2 = TUR: SM1 = TUN: TK = 6

		if (OS1 != OCC) {
		  if      (PB1 == PBP) {SM4 = TUN; SM5 = TUN; TK = 1;}
		  else if (PB2 == PBP) {SM4 = TUR; SM5 = TUN; TK = 2;}
		  else if (PB3 == PBP) {SM5 = TUR; SM3 = TUR; TK = 3;}
		  else if (PB4 == PBP) {SM5 = TUR; SM3 = TUN; SM2 = TUN;
					TK = 4;}
		  else if (PB5 == PBP) {SM5 = TUR; SM3 = TUN; SM2 = TUR;
					SM1 = TUR; TK = 5;}
		  else if (PB6 == PBP) {SM5 = TUR; SM3 = TUN; SM2 = TUR;
					SM1 = TUN; TK = 6;}
		}


//
//  REM**ALIGN TOGGLE CONTROLLED TURNOUTS IF OS SECTIONS ARE CLEAR
//TOGGLES:  
//     IF OS2 = CLR THEN SM6 = TG6
//     IF OS3 = CLR THEN SM7 = TG7
//     IF OS4 = CLR THEN SM8 = TG8: SM9 = TG9
//     IF OS5 = CLR THEN SM10 = TG10
//     IF OS6 = CLR THEN SM11 = TG11

		if (OS2 == CLR) {SM6 = TG6;}
		if (OS3 == CLR) {SM7 = TG7;}
		if (OS4 == CLR) {SM8 = TG8; SM9 = TG9;}
		if (OS5 == CLR) {SM10 = TG10;}
		if (OS6 == CLR) {SM11 = TG11;}

//
//  REM**WHEN AN OS SECTION BECOMES OCCUPIED AND OPPOSING DIRECTION-
//  REM**OF-TRAFFIC IS NOT LOCKED-IN THEN SET DIRECTION-OF-TRAFFIC
//  REM**FOR SECTION OF SINGLE TRACK TO DIRECTION OF MOVEMENT
//     IF OS1 = OCC AND DOT1 <> WBD THEN DOT1 = EBD
//     IF OS2 = OCC AND DOT1 <> EBD THEN DOT1 = WBD
//     IF OS3 = OCC AND DOT2 <> WBD THEN DOT2 = EBD
//     IF OS4 = OCC AND DOT2 <> EBD THEN DOT2 = WBD
//     IF OS5 = OCC AND DOT3 <> WBD THEN DOT3 = EBD
//     IF OS6 = OCC AND DOT3 <> EBD THEN DOT3 = WBD

		if (OS1 == OCC && DOT1 != WBD) {DOT1 = EBD;}
		if (OS2 == OCC && DOT1 != EBD) {DOT1 = WBD;}
		if (OS3 == OCC && DOT2 != WBD) {DOT2 = EBD;}
		if (OS4 == OCC && DOT2 != EBD) {DOT2 = WBD;}
		if (OS5 == OCC && DOT3 != WBD) {DOT3 = EBD;}
		if (OS6 == OCC && DOT3 != EBD) {DOT3 = WBD;}
//
//  REM**RETAIN DIRECTIONT-OF-TRAFFIC WHILE SINGLE TRACK IS OCCUPIED
//DT1: IF OS1 = OCC THEN GOTO DT2
//     IF BK7 = OCC THEN GOTO DT2
//     IF BK8 = OCC THEN GOTO DT2
//     IF OS2 = OCC THEN GOTO DT2
//     DOT1 = NDT  'All trackage clear so set DOT1 to no direction-of-traffic

		if (OS1 != OCC &&
		    BK7 != OCC &&
		    BK8 != OCC &&
		    OS2 != OCC) {DOT1 = NDT;} //All trackage clear so set DOT1 to no direction-of-traffic

// 
//DT2: IF OS3 = OCC THEN GOTO DT3
//     IF BK11 = OCC THEN GOTO DT3
//     IF OS4 = OCC THEN GOTO DT3
//     DOT2 = NDT  'All trackage clear so set DOT2 to no direction-of-traffic

		if (OS3 != OCC &&
		    BK11 != OCC &&
		    OS4 != OCC) {DOT2 = NDT;} //All trackage clear so set DOT2 to no direction-of-traffic

//
//DT3: IF OS5 = OCC THEN GOTO DOTCMP
//     IF BK15 = OCC THEN GOTO DOTCMP
//     IF BK16 = OCC THEN GOTO DOTCMP
//     IF BK17 = OCC THEN GOTO DOTCMP
//     IF OS6 = OCC THEN GOTO DOTCMP
//     DOT1 = NDT  'All trackage clear so set DOT3 to no direction-of-traffic

		if (OS5 != OCC &&
		    BK15 != OCC &&
		    BK16 != OCC &&
		    BK17 != OCC &&
		    OS6 != OCC) {DOT3 = NDT;} //All trackage clear so set DOT3 to no direction-of-traffic

//DOTCMP:
//
//  REM*******************************
//  REM*******************************
//  REM**CALCULATE EASTBOUND SIGNALS**
//  REM*******************************
//  REM*******************************
//
//  REM**Calculate SIG20RABC
//SIG20R:
//     SIG20RABC = REDREDRED
//     IF OS6 = OCC THEN GOTO SIG18R
//     IF (SM11 = TUN AND TF12 = TGR) THEN SIG20RABC = REDREDYEL: GOTO SIG18R
//     IF BK18 = OCC THEN GOTO SIG18R
//     IF SM11 = TUN THEN SIG20RABC = YELREDRED ELSE SIG20RABC = REDYELRED

		SIG20RABC = REDREDRED;
		if (OS6 != OCC) {
		  if (SM11 == TUN && TF12 == TGR) {
		    SIG20RABC = REDREDYEL;
		  } else {
		    if (BK18 != OCC) {
		      if (SM11 == TUN) {
		      	SIG20RABC = YELREDRED;
		      } else {
		      	SIG20RABC = REDYELRED;
		      }
		    }
		  }
		}

//     
//  REM**Calculate SIG18RA
//SIG18R:
//     SIG18RA = RED
//     IF DOT3 = WBD THEN GOTO SIG16R
//     IF BK17 = OCC THEN GOTO SIG16R
//     SIG18RA = YEL
//     IF SIG20RABC = REDREDRED THEN GOTO SIG16R
//     SIG18RA = GRN
//

		SIG18RA = RED;
		if (DOT3 != WBD && BK17 != OCC) {
		  SIG18RA = YEL;
		  if (SIG20RABC != REDREDRED) {SIG18RA = GRN;}
		}


//  REM**Calculate SIG16RA
//SIG16R:
//     SIG16RA = RED
//     IF DOT3 = WBD THEN GOTO SIG14R
//     IF BK16 = OCC THEN GOTO SIG14R
//     SIG16RA = YEL
//     IF SIG18R = RED THEN GOTO SIG14R
//     SIG16RA = GRN

		SIG16RA = RED;
		if (DOT3 != WBD && BK16 != OCC) {
		  SIG16RA = YEL;
		  if (SIG18RA != RED) {SIG16RA = GRN;}
		}

//
//  REM**Calculate SIG14RA and SIG14RC
//SIG14R:
//     SIG14RA = RED: SIG14RC = RED
//     IF DOT3 = WBD THEN GOTO SIG12R
//     IF OS5 = OCC THEN GOTO SIG12R
//     IF BK15 = OCC THEN GOTO SIG12R
//     SIG14R = YEL
//     IF SIG16RA = RED THEN GOTO SIG12R
//     SIG14R = GRN
//     IF SM10 = TUN THEN SIG14RA = SIG14R ELSE SIG14RC = SIG14R

		SIG14RA = RED; SIG14RC = RED;
		if (DOT3 != WBD &&
		    OS5  != OCC &&
		    BK15 != OCC) {
		  SIG14R = YEL;
		  if (SIG16RA != RED) {SIG14R = GRN;}
		  if (SM10 == TUN) {SIG14RA = SIG14R;} else {SIG14RC = SIG14R;} 
		}

//
//  REM**Calculate SIG12RABC
//SIG12R:
//     SIG12RABC = REDREDRED
//     IF OS4 = OCC THEN GOTO SIG8R
//     IF SM8 = TUR THEN GOTO SM8REV
//     IF BK13 = OCC THEN GOTO SIG8R
//     SIG12RABC = YELREDRED
//     IF SIG14RA = RED THEN GOTO SIG8R
//     SIG12RABC = GRNREDRED: GOTO SIG8R
//SM8REV:
//     IF SM9 = TUR THEN SIG12RABC = REDREDYEL: GOTO SIG8R
//     IF BK14 = OCC THEN GOTO SIG8R
//     SIG12RABC = REDYELRED


		SIG12RABC = REDREDRED;
		if (OS4 != OCC) {
		  if (SM8 != TUR) {
		    if (BK13 != OCC) {
		      SIG12RABC = YELREDRED;
		      if (SIG14RA != RED) {SIG12RABC = GRNREDRED;}
		    }
		  } else {
		    // SM8REV:
		    if (SM9 == TUR) {SIG12RABC = REDREDYEL;}
		    else if (BK14 != OCC) {SIG12RABC = REDYELRED;}
		  }
		}


//
//  REM**Calculate SIG8RA and SIG8RC
//SIG8R:
//     SIG8RA = RED: SIG8RC = RED
//     IF DOT2 = WBD THEN GOTO SIG6R
//     IF OS3 = OCC THEN GOTO SIG6R
//     IF BK11 = OCC THEN GOTO SIG6R
//     SIG8R = YEL
//     IF SIG12RABC = REDREDRED THEN GOTO SIG6R
//     SIG8R = GRN
//     IF SM7 = TUN THEN SIG8RA = SIG8R ELSE SIG8RC = SIG8R

		SIG8RA = RED; SIG8RC = RED;
		if (DOT2 != WBD && OS3 != OCC && BK11 != OCC) {
		  SIG8R = YEL;
		  if (SIG12RABC != REDREDRED) {SIG8R = GRN;}
		  if (SM7 == TUN) {SIG8RA = SIG8R;} else {SIG8RC = SIG8R;}
		}


//
//  REM**Calculate SIG6RAB
//SIG6R:
//     SIG6RAB = REDRED
//     IF OS2 = OCC THEN GOTO SIG4R
//     IF SM6 = TUR THEN GOTO SM6REV
//     IF BK9 = OCC THEN GOTO SIG4R
//     SIG6RAB = YELRED
//     IF SIG8RA = RED THEN GOTO SIG4R
//     SIG6RAB = GRNRED: GOTO SIG4R
//
//SM6REV:
//     IF BK10 = OCC THEN GOTO SIG4R
//     SIG6RAB = REDYEL

		SIG6RAB = REDRED;
		if (OS2 != OCC) {
		  if (SM6 != TUR) {
		    if (BK9 != OCC) {
		      SIG6RAB = YELRED;
		      if (SIG8RA != RED) {SIG6RAB = GRNRED;}
		    }
		  } else {
		    // SM6REV:
		    if (BK10 != OCC) {SIG6RAB = REDYEL;}
		  }
		}

//
//  REM**Calculate SIG4RA
//SIG4R:
//     SIG4RA = RED
//     IF DOT1 = WBD THEN GOTO SIG2R
//     IF BK8 = OCC THEN GOTO SIG2R
//     SIG4RA = YEL
//     IF SIG6RAB = REDRED THEN GOTO SIG2R
//     SIG4RA = GRN

		SIG4RA = RED;
		if (DOT1 != WBD && BK8 != OCC) {
		  SIG4RA = YEL;
		  if (SIG6RAB != REDRED) {SIG4RA = GRN;}
		}

//
//  REM**Calculate Red Butte exit signals
//  REM**Initialize all exit signals to RED
//SIG2R:
//     SIG2RA = RED: SIG2RB = RED: SIG2RC = RED
//     SIG2RD = RED: SIG2RE = RED: SIG2RF = RED
//
//  REM**Calculate exit signal value for aligned track
//     EXITSIG = RED
//     IF DOT1 = WBD THEN GOTO SIGECMP
//     IF OS1 = OCC THEN GOTO SIGECMP
//     IF BK7 = OCC THEN GOTO SIGECMP
//     EXITSIG = YEL
//     IF SIG4RA = RED THEN GOTO EXSIG
//     EXITSIG = GRN
//
//  REM**Set track aligned exit signal to calculated signal value
//EXSIG:
//     IF TK = 1 THEN SIG2RA = EXITSIG
//     IF TK = 2 THEN SIG2RB = EXITSIG
//     IF TK = 3 THEN SIG2RC = EXITSIG
//     IF TK = 4 THEN SIG2RD = EXITSIG
//     IF TK = 5 THEN SIG2RE = EXITSIG
//     IF TK = 6 THEN SIG2RF = EXITSIG
//SIGECMP:

		SIG2RA = RED; SIG2RB = RED; SIG2RC = RED;
		SIG2RD = RED; SIG2RE = RED; SIG2RF = RED;
		EXITSIG = RED;
		if (DOT1 != WBD && OS1 != OCC && BK7 != OCC) {
		  EXITSIG = YEL;
		  if (SIG4RA != RED) {EXITSIG = GRN;}
		}
		switch (TK) {
		  case 1: SIG2RA = EXITSIG; break;
		  case 2: SIG2RB = EXITSIG; break;
		  case 3: SIG2RC = EXITSIG; break;
		  case 4: SIG2RD = EXITSIG; break;
		  case 5: SIG2RE = EXITSIG; break;
		  case 6: SIG2RF = EXITSIG; break;
		}

//
//  REM*******************************
//  REM*******************************
//  REM**CALCULATE WESTBOUND SIGNALS**
//  REM*******************************
//  REM*******************************
//
//    REM**Calculate SIG2LAB (entrance signal into staging)
//SIG2L:
//     SIG2LAB = REDRED
//     IF OS1 = OCC THEN GOTO SIG4L
//     IF TK = 1 AND BK1 = CLR THEN SIG2LAB = YELRED: GOTO SIG4L
//     IF TK = 2 AND BK2 = CLR THEN SIG2LAB = REDYEL: GOTO SIG4L
//     IF TK = 3 AND BK3 = CLR THEN SIG2LAB = REDYEL: GOTO SIG4L
//     IF TK = 4 AND BK4 = CLR THEN SIG2LAB = REDYEL: GOTO SIG4L
//     IF TK = 5 AND BK5 = CLR THEN SIG2LAB = REDYEL: GOTO SIG4L
//     IF TK = 6 AND BK6 = CLR THEN SIG2LAB = REDYEL

		SIG2LAB = REDRED;
		if (OS1 != OCC) {
		       if (TK == 1 && BK1 == CLR) {SIG2LAB = YELRED;}
		  else if (TK == 2 && BK2 == CLR) {SIG2LAB = REDYEL;}
		  else if (TK == 3 && BK3 == CLR) {SIG2LAB = REDYEL;}
		  else if (TK == 4 && BK4 == CLR) {SIG2LAB = REDYEL;}
		  else if (TK == 5 && BK5 == CLR) {SIG2LAB = REDYEL;}
		  else if (TK == 6 && BK6 == CLR) {SIG2LAB = REDYEL;}
		}

//
//  REM**Calculate SIG4LA
//SIG4L:
//     SIG4LA = RED
//     IF DOT1 = EBD THEN GOTO SIG6L
//     IF BK7 = OCC THEN GOTO SIG6L
//     SIG4LA = YEL
//     IF SIG2LAB = REDRED THEN GOTO SIG6L
//     SIG4LA = GRN

		SIG4LA = RED;
		if (DOT1 != EBD && BK7 != OCC) {
		  SIG4LA = YEL;
		  if (SIG2LAB != REDRED) {SIG4LA = GRN;}
		}

//
//  REM**Calculate SIG6LA and SIG6LC
//SIG6L:
//     SIG6LA = RED: SIG6LC = RED
//     IF DOT1 = EBD THEN GOTO SIG8L
//     IF OS2 = OCC THEN GOTO SIG8L
//     IF BK8 = OCC THEN GOTO SIG8L
//     SIG6L = YEL
//     IF SIG4LA = RED THEN GOTO SIG8L
//     SIG6L = GRN
//     IF SM6 = TUN THEN SIG6LA = SIG6L ELSE SIG6LC = SIG6L
//

		SIG6LA = RED; SIG6LC = RED;
		if (DOT1 != EBD && OS2 != OCC && BK8 != OCC) {
		  SIG6L = YEL;
		  if (SIG4LA != RED) {SIG6L = GRN;}
		  if (SM6 == TUN) {SIG6LA = SIG6L;} else {SIG6LC = SIG6L;}
		}


//  REM**Calculate SIG8LAB
//SIG8L:
//     SIG8LAB = REDRED
//     IF OS3 = OCC THEN GOTO SIG12L
//     IF SM7 = TUR THEN GOTO SM7REV
//     IF BK9 = OCC THEN GOTO SIG12L
//     SIG8LAB = YELRED
//     IF SIG6LA = RED THEN GOTO SIG12L
//     SIG8LAB = GRNRED: GOTO SIG12L
//SM7REV:
//     IF BK10 = OCC THEN GOTO SIG12L
//     SIG8LAB = REDYEL

		SIG8LAB = REDRED;
		if (OS3 != OCC) {
		  if (SM7 != TUR) {
		    if (BK9 != OCC) {
		      SIG8LAB = YELRED;
		      if (SIG6LA != RED) {SIG8LAB = GRNRED;}
		    }
		  } else {
		    // SM7REV:
		    if (BK10 != OCC) {SIG8LAB = REDYEL;}
		  }
		}

//
//  REM**Calculate SIG12LA, SIG12LC and SIG12LD
//SIG12L:
//     SIG12LA = RED: SIG12LC = RED: SIG12LD = RED
//     IF DOT2 = EBD THEN GOTO SIG14L
//     IF OS4 = OCC THEN GOTO SIG14L
//     IF BK11 = OCC THEN GOTO SIG14L
//     SIG12L = YEL
//     IF SIG8LAB = REDRED THEN GOTO SIG14L
//     SIG12L = GRN
//     IF SM8 = TUN THEN SIG12LA = SIG12L: GOTO SIG14L
//     IF SM9 = TUN THEN SIG12LC = SIG12L ELSE SIG12LD = SIG12L

		SIG12LA = RED; SIG12LC = RED; SIG12LD = RED;
		if (DOT2 != EBD && OS4 != OCC && BK11 != OCC) {
		  SIG12L = YEL;
		  if (SIG8LAB != REDRED) {SIG12L = GRN;}
		       if (SM8 == TUN) {SIG12LA = SIG12L;}
		  else if (SM9 == TUN) {SIG12LC = SIG12L;}
		  else                 {SIG12LD = SIG12L;}
		}


//
//  REM**Calculate SIG14LAB
//SIG14L:
//     SIG14LAB = REDRED
//     IF OS5 = OCC THEN GOTO SIG16L
//     IF SM10 = TUR THEN GOTO SM10REV
//     IF BK13 = OCC THEN GOTO SIG16L
//     SIG14LAB = YELRED
//     IF SIG12LA = RED THEN GOTO SIG16L
//     SIG14LAB = GRNRED: GOTO SIG16L
//SM10REV:
//     IF BK14 = OCC THEN GOTO SIG16L
//     SIG14LAB = REDYEL

		SIG14LAB = REDRED;
		if (OS5 != OCC) {
		  if (SM10 != TUR) {
		    if (BK13 != OCC) {
		      SIG14LAB = YELRED;
		      if (SIG12LA != RED) {SIG14LAB = GRNRED;}
		    }
		  } else {
		    // SM10REV
		    if (BK14 != OCC) {SIG14LAB = REDYEL;}
		  }
		}

//
//  REM**Calculate SIG16LA
//SIG16L:
//     SIG16LA = RED
//     IF DOT3 = EBD THEN GOTO SIG18L
//     IF BK15 = OCC THEN GOTO SIG18L
//     SIG16LA = YEL
//     IF SIG14LAB = REDRED THEN GOTO SIG18L
//     SIG16LA = GRN

		SIG16LA = RED;
		if (DOT3 != EBD && BK15 != OCC) {
		  SIG16LA = YEL;
		  if (SIG14LAB != REDRED) {SIG16LA = GRN;}
		}

//
//  REM**Calculate SIG18LA
//SIG18L:
//     SIG18LA = RED
//     IF DOT3 = EBD THEN GOTO SIG20L
//     IF BK16 = OCC THEN GOTO SIG20L
//     SIG18LA = YEL
//     IF SIG16LA = RED THEN GOTO SIG20L
//     SIG18LA = GRN

		SIG18LA = RED;
		if (DOT3 != EBD && BK16 != OCC) {
		  SIG18LA = YEL;
		  if (SIG16LA != RED) {SIG18LA = GRN;}
		}

//
//  REM**Calculate SIG20LA, SIG20LB and SIG20LD
//SIG20L:
//     SIG20LA = RED: SIG20LB = RED: SIG20LD = RED
//     IF DOT3 = EBD THEN GOTO SIGWCMP
//     IF OS6 = OCC THEN GOTO SIGWCMP
//     IF BK17 = OCC THEN GOTO SIGWCMP
//     SIG20L = YEL
//     IF SIG18LA <> RED THEN SIG20L = GRN
//     IF SM11 = TUR THEN SIG20LB = SIG20L: GOTO SIGWCMP
//     IF TF12 = TGR THEN SIG20LD = SIG20L ELSE SIG20LA = SIG20L
//SIGWCMP:

		SIG20LA = RED; SIG20LB = RED; SIG20LD = RED;
		if (DOT3 != EBD && OS6 != OCC && BK17 != OCC) {
		  SIG20L = YEL;
		  if (SIG18LA != RED) {SIG20L = GRN;}
		       if (SM11 == TUR) {SIG20LB = SIG20L;}
		  else if (TF12 == TGR) {SIG20LD = SIG20L;}
		  else                  {SIG20LA = SIG20L;}
		}
		

//   
//  REM**PACK AND WRITE OUTPUT BYTES
//     OB(1) = SIG2LAB                'CARD 0 PORT A     
//     OB(1) = SIG2RA * B5 OR OB(1)

		tempByte  = SIG2LAB;
		tempByte |= SIG2RA << B5;
		Outputs[0] = tempByte;	// CARD 0 PORT A

//     
//     OB(2) = SIG2RB                 'CARD 0 PORT B
//     OB(2) = SIG2RC * B3 OR OB(2)
//     OB(2) = SM1 * B6 OR OB(2)
//     OB(2) = SM2 * B7 OR OB(2)

		tempByte  = SIG2RB;
		tempByte |= SIG2RC << B3;
		tempByte |= SM1    << B6;
		tempByte |= SM2    << B7;
		Outputs[1] = tempByte;	//CARD 0 PORT B
//
//     OB(3) = SIG2RD                  'CARD 0 PORT C
//     OB(3) = SIG2RE * B3 OR OB(3)
//     OB(3) = SM3 * B6 OR OB(3)
//     OB(3) = SM4 * B7 OR OB(3)

		tempByte  = SIG2RD;
		tempByte |= SIG2RE << B3;
		tempByte |= SM3    << B6;
		tempByte |= SM4    << B7;
		Outputs[2] = tempByte;	//CARD 0 PORT C
//
//     OB(4) = SIG2RF                  'CARD 0 PORT D
//     OB(4) = SIG4LA * B3 OR OB(4)
//     OB(4) = SM5 * B6 OR OB(4)
//     OB(4) = SM6 * B7 OR OB(4)

		tempByte  = SIG2RF;
		tempByte |= SIG4LA << B3;
		tempByte |= SM5    << B6;
		tempByte |= SM6    << B7;
		Outputs[3] = tempByte;	//CARD 0 PORT D
//				    
//     OB(5) = SIG6RAB                 'CARD 3 PORT A              
//     OB(5) = SIG4RA * B5 OR OB(5)

		tempByte  = SIG6RAB;
		tempByte |= SIG4RA << B5;
		Outputs[4] = tempByte;	//CARD 3 PORT A
//     
//     OB(6) = SIG6LA                  'CARD 3 PORT B
//     OB(6) = SIG6LC * B3 OR OB(6)
//     OB(6) = SM7 * B6 OR OB(6)
//     OB(6) = SM8 * B7 OR OB(6)

		tempByte  = SIG6LA;
		tempByte |= SIG6LC << B3;
		tempByte |= SM7    << B6;
		tempByte |= SM8    << B7;
		Outputs[5] = tempByte;	//CARD 3 PORT B
//     
//     OB(7) = SIG8LAB                 'CARD 3 PORT C             
//     OB(7) = SIG8RA * B5 OR OB(7)

		tempByte  = SIG8LAB;
		tempByte |= SIG8RA << B5;
		Outputs[6] = tempByte;	//CARD 3 PORT C
//    
//     OB(8) = SIG8RC                  'CARD 3 PORT D            
//     OB(8) = SIG12LA * B3 OR OB(8)

		tempByte  = SIG8RC;
		tempByte |= SIG12LA << B3;
		Outputs[7] = tempByte;	//CARD 3 PORT D
//						       
//     OB(9) = SIG12RABC               'CARD 4 PORT A
//     OB(9) = SM9 * B7 OR OB(9)

		tempByte  = SIG12RABC;
		tempByte |= SM9 << B7;
		Outputs[8] = tempByte;	//CARD 4 PORT A
//
//     OB(10) = SIG12LC                'CARD 4 PORT B
//     OB(10) = SIG12LD * B3 OR OB(10)
//     OB(10) = SM10 * B6 OR OB(10)
//     OB(10) = SM11 * B7 OR OB(10)

		tempByte  = SIG12LC;
		tempByte |= SIG12LD << B3;
		tempByte |= SM10    << B6;
		tempByte |= SM11    << B7;
		Outputs[9] = tempByte;	//CARD 4 PORT B
//
//     OB(11) = SIG14LAB               'CARD 4 PORT C    
//     OB(11) = SIG14RA * B5 OR OB(11)

		tempByte  = SIG14LAB;
		tempByte |= SIG14RA << B5;
		Outputs[10] = tempByte;	//CARD 4 PORT C
//
//     OB(12) = SIG14RC                'CARD 4 PORT D
//     OB(12) = SIG16LA * B3 OR OB(12)

		tempByte  = SIG14RC;
		tempByte |= SIG16LA << B3;
		Outputs[11] = tempByte;	//CARD 4 PORT D
//		 
//     OB(13) = SIG16RA                'CARD 5 PORT A
//     OB(13) = SIG18LA * B3 OR OB(13)

		tempByte  = SIG16RA;
		tempByte |= SIG18LA << B3;
		Outputs[12] = tempByte;	//CARD 5 PORT A
//
//     OB(14) = SIG18RA                'CARD 5 PORT B
//     OB(14) = SIG20LA * B3 OR OB(14)

		tempByte  = SIG18RA;
		tempByte |= SIG20LA << B3;
		Outputs[13] = tempByte;	//CARD 5 PORT B
//
//     OB(15) = SIG20RABC              'CARD 5 PORT C

		Outputs[14] = SIG20RABC; //CARD 5 PORT C
//
//     OB(16) = SIG20LB                'CARD 5 PORT D
//     OB(16) = SIG20LD * B3 OR OB(16)

		tempByte  = SIG20LB;
		tempByte |= SIG20LD << B3;
		Outputs[15] = tempByte;	//CARD 5 PORT D
//
//     GOSUB OUTPUTS     'INVOKE OUTPUTS SUBROUTINE

		bus->Outputs(&Outputs,UA,&errorMessage);
		if (errorMessage != NULL) {     /* Error? */
			cerr << 
			"Error writing SMINI card at UA " 
			     << UA << ": " << errorMessage << endl;
			delete errorMessage;
			errorMessage = NULL;
			break;
		}
            
//     
//  REM**RETURN TO BEGINNING OF REAL-TIME LOOP
//     GOTO BRTL

	}
}
