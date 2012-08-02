/* 
 * ------------------------------------------------------------------
 * xpressnet.cc - XpressNet C++ code
 * Created by Robert Heller on Thu May 26 20:32:26 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.4  2005/11/05 05:52:09  heller
 * Modification History: Upgraded for G++ 3.2
 * Modification History:
 * Modification History: Revision 1.3  2005/05/30 22:55:49  heller
 * Modification History: May 30, 2005 -- Lockdown 2
 * Modification History:
 * Modification History: Revision 1.2  2005/05/30 18:47:52  heller
 * Modification History: May 30, 2005 Lockdown.  Code complete and compiles, but untested.
 * Modification History:
 * Modification History: Revision 1.1  2005/05/30 00:47:35  heller
 * Modification History: May 29 2005 Lock down
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

static char rcsid[] = "$Id$";

#include <xpressnet.h>
#include <stdarg.h>

/************************************************************************
 *									*
 * Accessory Decoder Information constructor.  Build an 		*
 * AccessoryDecoderInformation response object.				*
 *									*
 ************************************************************************/
 
AccessoryDecoderInformation::AccessoryDecoderInformation(unsigned int count,unsigned char addr,unsigned char d,...)
{
	int index;
	va_list ap;
	va_start(ap,d);
	unsigned char a, itnz;
	
	Response_Type = ACCESSORY_DECODER_INFORMATION;	// Set the response type.
	// There can only be 0 to 7 feedback elements per Accessory Decoder.
	if (count < 0 || count > 7) {
		numberOfFeedbackElements = 0;
	} else {
		// Loop over the Accessory Decoder feedback elements.
		numberOfFeedbackElements = count;
		a = addr;
		itnz = d;
		index = 0;
		do {
			// Process one Accessory Decoder feedback element.
			address[index] = a;		// Address
			// Completed?
			completed[index] = true;	
			if ((itnz & 0x080) != 0) completed[index] = false;
			// Type of accessory?
			switch ((itnz & 0x60) >> 5) {
				case 0x00:
					accessory_type[index] = AccessoryWithoutFeedback; 
					break;
				case 0x01:
					accessory_type[index] = AccessoryWithFeedback;
					break;
				case 0x02:
					accessory_type[index] = FeedbackModule;
					break;
				case 0x03:
					accessory_type[index] = Reserved;
					break;
			}
			// Which nibble?
			if ((itnz & 0x10) == 0) {
				nibble[index] = Lower;
			} else {
				nibble[index] = Upper;
			}
			// Function controlled.
			switch ((itnz & 0x0C) >> 2) {
				case 0x00: t1[index] = NotControlled; break;
				case 0x01: t1[index] = Left; break;
				case 0x02: t1[index] = Right; break;
				case 0x03: t1[index] = Invalid; break;
			}
			
			switch ((itnz & 0x03)) {
				case 0x00: t2[index] = NotControlled; break;
				case 0x01: t2[index] = Left; break;
				case 0x02: t2[index] = Right; break;
				case 0x03: t2[index] = Invalid; break;
			}
			// Next feedback elememnt.
			index++;
			count--;
			if (count > 0) {
				a = va_arg(ap,unsigned int);
				itnz = va_arg(ap,unsigned int);
			}
		} while (count > 0);
	}
	va_end(ap);
}
	

/************************************************************************
 *									*
 * Main XPressNet class constructor.  Open a connection to the specified*
 * serial port and set up the port for proper communication with the    *
 * Lenz XPressNet.							*
 *									*
 ************************************************************************/
 
XPressNet::XPressNet(const char *port, char **outmessage)
{
	// LI100 message buffer;
	unsigned char message[4], xorbyte;
	// Error message buffer.
	static char messageBuffer[2048];
	// Misc. integers.
	int i;
	// Variables for select/pselect
	fd_set rfds;
	struct timeval tv;
	int retval, len;
	
	ttyfd = -1;
	responseList = NULL;
	// Open port.
	ttyfd = open(port,O_RDWR|O_NOCTTY|O_NONBLOCK);
	// Open failure?  Create an error message.
	if (ttyfd < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"open of %s failed: %s",port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		return;
	}
	// Not a serial port?  Close it and create an error message.
	if (!isatty(ttyfd)) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Not a terminal port: %s\n",port);
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Get a prestine copy of the serial port's current settings.
	if (tcgetattr(ttyfd,&savedtermios) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Cannot get termios struct for %s because %s",port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Get a second copy of the serial port's current settings, to be modified.
	if (tcgetattr(ttyfd,&currenttermios) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Cannot get termios struct for %s because %s",port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Set the terminal to be raw
	cfmakeraw(&currenttermios);
	// Set the input speed  (assume a LI101F at 19200 bps).
	if (cfsetispeed(&currenttermios,B19200) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Cannot set termios struct in speed for %s because %s",port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// And output speed
	if (cfsetospeed(&currenttermios,B19200) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Cannot set termios struct out speed for %s because %s",port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Eight data bits.
	currenttermios.c_cflag &= ~CSIZE;
	currenttermios.c_cflag |= CS8;
	// One stop bit.
	currenttermios.c_cflag &= ~CSTOPB;
	// Disable all parity bit handling
	currenttermios.c_cflag &= ~(PARENB|PARODD);
	// Disable modem control lines.
	currenttermios.c_cflag |= CLOCAL;
	// Set the port settings.
	if (tcsetattr(ttyfd,TCSANOW,&currenttermios) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Cannot set termios struct for %s because %s",port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Send a BREAK.
	if (tcsendbreak(ttyfd,0) < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Cannot send BREAK %s because %s",port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		tcsetattr(ttyfd,TCSANOW,&savedtermios);
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	// Send startup message.
	message[0] = 0x0f;
	message[1] = 0x0f;
	write(ttyfd,message,2);
	FD_ZERO(&rfds);
	FD_SET(ttyfd, &rfds);
	tv.tv_sec = 5;
	tv.tv_usec = 0;
	retval = select(ttyfd+1, &rfds, NULL, NULL, &tv);
	if (retval < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Error from select on %s because %s",port,strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		tcsetattr(ttyfd,TCSANOW,&savedtermios);
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	if (retval == 0) {	// No response, maybe a LI100 or LI100F at 9600bps
		if (cfsetispeed(&currenttermios,B9600) < 0) {
			if (outmessage != NULL) {
				sprintf(messageBuffer,"Cannot set termios struct in speed for %s because %s",port,strerror(errno));
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			close(ttyfd);
			ttyfd = -1;
			return;
		}
		if (cfsetospeed(&currenttermios,B9600) < 0) {
			if (outmessage != NULL) {
				sprintf(messageBuffer,"Cannot set termios struct out speed for %s because %s",port,strerror(errno));
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			close(ttyfd);
			ttyfd = -1;
			return;
		}
		if (tcsetattr(ttyfd,TCSANOW,&currenttermios) < 0) {
			if (outmessage != NULL) {
				sprintf(messageBuffer,"Cannot set termios struct for %s because %s",port,strerror(errno));
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			close(ttyfd);
			ttyfd = -1;
			return;
		}
		message[0] = 0x0f;
		message[1] = 0x0f;
		write(ttyfd,message,2);
		FD_ZERO(&rfds);
		FD_SET(ttyfd, &rfds);
		tv.tv_sec = 5;
		tv.tv_usec = 0;
		retval = select(ttyfd+1, &rfds, NULL, NULL, &tv);
		if (retval < 0) {
			if (outmessage != NULL) {
				sprintf(messageBuffer,"Error from select on %s because %s",port,strerror(errno));
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			tcsetattr(ttyfd,TCSANOW,&savedtermios);
			close(ttyfd);
			ttyfd = -1;
			return;
		}
		if (retval == 0) {	// No response, nothing there??
			if (outmessage != NULL) {
				sprintf(messageBuffer,"No response on %s -- is a LI100/LI100F/LI101 connected?",port);
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			tcsetattr(ttyfd,TCSANOW,&savedtermios);
			close(ttyfd);
			ttyfd = -1;
			return;
		}
	}
	// Fetch software and hardware version codes.
	len = read(ttyfd,message,4);
	if (len != (message[0] & 0x0f)+1) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Read error on %s: read %d bytes, header says %d bytes -- is a LI100/LI100F/LI101 connected?",port,len,(message[0] & 0x0f)+1);
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
		}
		tcsetattr(ttyfd,TCSANOW,&savedtermios);
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	xorbyte = message[0];
	for (i = 1; i <= (message[0] & 0x0f); i++) xorbyte ^= message[i];
	if (xorbyte != message[(message[0] & 0x0f)+1]) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Bad X-Or-Byte on %s: computed 0x%02x, got 0x%02x -- is a LI100/LI100F/LI101 connected?",port,xorbyte,message[(message[0] & 0x0f)+1]);
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
		}
		tcsetattr(ttyfd,TCSANOW,&savedtermios);
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	if (message[0] != 0x02) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Bad response header byte (0x%02x) on %s -- is a LI100/LI100F/LI101 connected?",message[0],port);
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
		}
		tcsetattr(ttyfd,TCSANOW,&savedtermios);
		close(ttyfd);
		ttyfd = -1;
		return;
	}
	hardware_version = (((message[1] & 0x0f0) >> 4) * 10) + (message[1] & 0x0f);
	software_version = (((message[2] & 0x0f0) >> 4) * 10) + (message[2] & 0x0f);
}

/************************************************************************
 *									*
 * Destructor, close everything down, restoring serial port state.	*
 *									*
 ************************************************************************/
 
XPressNet::~XPressNet()
{
	CommandStationResponse *leftover;
	do {
		leftover = CommandStationResponse::PopTopOffList(responseList);
		if (leftover != NULL) delete leftover;
	} while (leftover != NULL);
	if (ttyfd < 0) return;
	tcsetattr(ttyfd,TCSANOW,&savedtermios);
	close(ttyfd);
}

/************************************************************************
 *									*
 * Check for a response code from the network.				*
 *									*
 ************************************************************************/
 
CommandStationResponse::TypeCode XPressNet::CheckForResponse(char **outmessage)
{
	// Error message buffer.
	static char messageBuffer[2048];
	// LI100 message buffer;
	unsigned char message[16], xorbyte;
	// Misc. integers.
	int i;
	// Variables for select/pselect
	fd_set rfds;
	struct timeval tv;
	int retval, len, count;
	// New response instance.
	CommandStationResponse *response = NULL;
	                                        
	if (ttyfd < 0) return CommandStationResponse::NO_RESPONSE_AVAILABLE;
	// Read from ttyfd and match to Command station response messages.
	FD_ZERO(&rfds);
	FD_SET(ttyfd, &rfds);
	tv.tv_sec = 5;
	tv.tv_usec = 0;
	retval = select(ttyfd+1, &rfds, NULL, NULL, &tv);
	if (retval < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Error from select because %s",strerror(errno));
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		return CommandStationResponse::NO_RESPONSE_AVAILABLE;
	}
	if (retval == 0) {
		return CommandStationResponse::NO_RESPONSE_AVAILABLE;
	}
	len = read(ttyfd,message,4);
	if (len != (message[0] & 0x0f)+1) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Read error: read %d bytes, header says %d bytes -- is a LI100/LI100F/LI101 connected?",len,(message[0] & 0x0f)+1);
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
		}
		return CommandStationResponse::NO_RESPONSE_AVAILABLE;
	}
	xorbyte = message[0];
	for (i = 1; i <= (message[0] & 0x0f); i++) xorbyte ^= message[i];
	if (xorbyte != message[(message[0] & 0x0f)+1]) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Bad X-Or-Byte: computed 0x%02x, got 0x%02x -- is a LI100/LI100F/LI101 connected?",xorbyte,message[(message[0] & 0x0f)+1]);
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
		}
		return CommandStationResponse::NO_RESPONSE_AVAILABLE;
	}
	// Create a response specific CommandStationResponse object and append
	// to responseList.  Return the response type code.
	switch (message[0] & 0x0f0) {
		case 0x00:
			if (message[0] == 0x01) {
				response = new LI100Message(message[1]);
			} else {
				response = NULL;
			}
			break;
		case 0x40:
			count = message[0] & 0x0f;
			switch (count) {
				case 2:
				   response = new AccessoryDecoderInformation(
						1,message[1],message[2]);
					break;
				case 4:
				   response = new AccessoryDecoderInformation(
						2,message[1],message[2],
						message[3],message[4]);
					break;
				case 6:
				   response = new AccessoryDecoderInformation(
						3,message[1],message[2],
						message[3],message[4],
						message[5],message[6]);
					break;
				case 8:
				   response = new AccessoryDecoderInformation(
						4,message[1],message[2],
						message[3],message[4],
						message[5],message[6],
						message[7],message[8]);
					break;
				case 10:
				   response = new AccessoryDecoderInformation(
						5,message[1],message[2],
						message[3],message[4],
						message[5],message[6],
						message[7],message[8],
						message[9],message[10]);
					break;
				case 12:
				   response = new AccessoryDecoderInformation(
						6,message[1],message[2],
						message[3],message[4],
						message[5],message[6],
						message[7],message[8],
						message[9],message[10],
						message[11],message[12]);
					break;
				case 14:
				   response = new AccessoryDecoderInformation(
						7,message[1],message[2],
						message[3],message[4],
						message[5],message[6],
						message[7],message[8],
						message[9],message[10],
						message[11],message[12],
						message[13],message[14]);
					break;
				default: response = NULL;
					break;
			}				
			break;
		case 0x60:
			if ((message[0] & 0x0f) < 1) {
				response = NULL;
				break;
			}
			switch (message[1]) {
				case 0x00:
					response = new TrackPowerOff();
					break;
				case 0x01:
					response = new NormalOperationResumed();
					break;
				case 0x02:
					response = new ServiceModeEntry();
					break;
				case 0x10:
					if ((message[0] & 0x0f) != 3) {
						response = NULL;
					} else {
						response = new ServiceModeResponse(message[1],message[2],message[3]);
					}
					break;
				case 0x11:
					response = new ProgrammingInfoCommandStationReady();
					break;
				case 0x12:
					response = new ProgrammingInfoShortCircuit();
					break;
				case 0x13:
					response = new ProgrammingInfoDataByteNotFound();
					break;
				case 0x14:
					if ((message[0] & 0x0f) != 3) {
						response = NULL;
					} else {
						response = new ServiceModeResponse(message[1],message[2],message[3]);
					}
					break;
				case 0x1f:
					response = new ProgrammingInfoCommandStationBusy();
					break;
				case 0x21: {
					unsigned char n1, n2;
					n1 = (message[2] >> 4) & 0x0f;
					n2 = message[2] & 0x0f;
					switch (message[0] & 0x0f) {
						case 2:
							response =
							    new SoftwareVersion(
								n1,
								n2);
							break;
						case 3:
							response =
							    new SoftwareVersion(
								n1,
								n2,
								message[3]);
							break;
						default: response = NULL;
					}
					break;}
				case 0x22:
					if ((message[0] & 0x0f) == 2) {
						response = new CommandStationStatus(message[2]);
					} else {
						response = NULL;
					}
					break;
				case 0x80:
					response = new TransferErrors();
					break;
				case 0x81:
					response = new CommandStationBusy();
					break;
				case 0x82:
					response = new InstructionNotSupported();
					break;
				case 0x83:
					response = new DoubleHeaderMuError(DoubleHeaderMuError::NotOperatedOr0);
					break;
				case 0x84:
					response = new DoubleHeaderMuError(DoubleHeaderMuError::UsedByAnotherDevice);
					break;
				case 0x85:
					response = new DoubleHeaderMuError(DoubleHeaderMuError::UsedInANotherDHMU);
					break;
				case 0x86:
					response = new DoubleHeaderMuError(DoubleHeaderMuError::SpeedNotZero);
					break;
				default:
					response = NULL;
			}
			break;
		case 0x80:
			if (message[0] == 0x81 && message[1] == 0x00) {
				response = new EmergencyStop();
			} else if (message[0] == 0x84 || message[0] == 0x83) {
				LocomotiveInformation::DirectionCode dir;
				LocomotiveInformation::SpeedStepModeCode ssm;
				unsigned char s;
				bool f0,f1,f2,f3,f4;
				unsigned short addr;
				if (message[0] == 0x83 || (message[4] & 0x03) == 0) {
					ssm = LocomotiveInformation::S14;
					if ((message[2] & 0x0f) == 1) {
					  	s = 255;
					} else if ((message[2] & 0x0f) == 0) {
					   	s = 0;
					} else {
					   	s = (message[2] & 0x0f) - 1;
					}
				} else {
					if ((message[4] & 0x03) == 1) {
						ssm = LocomotiveInformation::S27;
					} else {
						ssm = LocomotiveInformation::S28;
					}
					if ((message[2] & 0x1f) == 1) {
						s = 255;
					} else if ((message[2] & 0x1f) == 0) {
					  	s = 0;
					} else {
					   	s = ((message[2] & 0x0f) - 1) << 1;
					   	s += (((message[2] & 0x10) >> 4) ^ 0x01);
					}
				}
				addr = message[1];
				if ((message[2] & 0x40) == 0) {
					dir = LocomotiveInformation::Reverse;
				} else {
					dir = LocomotiveInformation::Forward;
				}
				f0 = (message[2] & 0x20) != 0;
				f1 = (message[3] & 0x01) != 0;
				f2 = (message[3] & 0x02) != 0;
				f3 = (message[3] & 0x04) != 0;
				f4 = (message[3] & 0x08) != 0;
				response = new LocomotiveInformation(addr,(message[2] & 0x80) == 0,dir,ssm,s,f0,f1,f2,f3,f4);
			} else {
				response = NULL;
			}
			break;
		case 0xa0:
			if (message[0] == 0xa4 || message[0] == 0xa3) {
				LocomotiveInformation::DirectionCode dir;
				LocomotiveInformation::SpeedStepModeCode ssm;
				unsigned char s;
				bool f0,f1,f2,f3,f4;
				unsigned short addr;
				if (message[0] == 0xa3 || (message[4] & 0x03) == 0) {
					ssm = LocomotiveInformation::S14;
					if ((message[2] & 0x0f) == 1) {
					  	s = 255;
					} else if ((message[2] & 0x0f) == 0) {
					   	s = 0;
					} else {
					   	s = (message[2] & 0x0f) - 1;
					}
				} else {
					if ((message[4] & 0x03) == 1) {
						ssm = LocomotiveInformation::S27;
					} else {
						ssm = LocomotiveInformation::S28;
					}
					if ((message[2] & 0x1f) == 1) {
						s = 255;
					} else if ((message[2] & 0x1f) == 0) {
					  	s = 0;
					} else {
					   	s = ((message[2] & 0x0f) - 1) << 1;
					   	s += (((message[2] & 0x10) >> 4) ^ 0x01);
					}
				}
				addr = message[1];
				if ((message[2] & 0x40) == 0) {
					dir = LocomotiveInformation::Reverse;
				} else {
					dir = LocomotiveInformation::Forward;
				}
				f0 = (message[2] & 0x20) != 0;
				f1 = (message[3] & 0x01) != 0;
				f2 = (message[3] & 0x02) != 0;
				f3 = (message[3] & 0x04) != 0;
				f4 = (message[3] & 0x08) != 0;
				response = new LocomotiveInformation(addr,false,dir,ssm,s,f0,f1,f2,f3,f4);
			} else {
				response = NULL;
			}
			break;
		case 0xc0: {
			int l = message[0] & 0x0f;
			if (l < 5 || l > 6) {
				response = NULL;
				break;
			}
			if (message[1] != 0x04 && message[1] != 0x05) {
				response = NULL;
				break;
			}
			bool avail = message[1] == 0x04;
			unsigned char modsel = 0;
			if (l == 6) modsel = message[6];
			DoubleHeaderInformation::DirectionCode dir;
			DoubleHeaderInformation::SpeedStepModeCode ssm;
			unsigned char s;
			bool f0,f1,f2,f3,f4;
			unsigned short addr1 = message[2];
			unsigned short addr2 = message[5];
			if ((modsel & 0x03) == 0) {
				ssm = DoubleHeaderInformation::S14;
				if ((message[3] & 0x0f) == 1) {
				  	s = 255;
				} else if ((message[3] & 0x0f) == 0) {
				   	s = 0;
				} else {
				   	s = (message[3] & 0x0f) - 1;
				}
			} else {
				if ((modsel & 0x03) == 1) {
					ssm = DoubleHeaderInformation::S27;
				} else {
					ssm = DoubleHeaderInformation::S28;
				}
				if ((message[3] & 0x1f) == 1) {
					s = 255;
				} else if ((message[3] & 0x1f) == 0) {
				  	s = 0;
				} else {
				   	s = ((message[3] & 0x0f) - 1) << 1;
				   	s += (((message[3] & 0x10) >> 4) ^ 0x01);
				}
			}
			if ((message[3] & 0x40) == 0) {
				dir = DoubleHeaderInformation::Reverse;
			} else {
				dir = DoubleHeaderInformation::Forward;
			}
			f0 = (message[3] & 0x20) != 0;
			f1 = (message[4] & 0x01) != 0;
			f2 = (message[4] & 0x02) != 0;
			f3 = (message[4] & 0x04) != 0;
			f4 = (message[4] & 0x08) != 0;
			response = new DoubleHeaderInformation(addr1,addr2,avail,dir,ssm,s,f0,f1,f2,f3,f4);
			break;}
		case 0xe0:
			switch (message[0] & 0x0f) {
				case 0x01:
					switch (message[1]) {
						case 0x81:
							response = new DoubleHeaderMuError(DoubleHeaderMuError::NotOperatedOr0);
							break;
						case 0x82:
							response = new DoubleHeaderMuError(DoubleHeaderMuError::UsedByAnotherDevice);
							break;
						case 0x83:
							response = new DoubleHeaderMuError(DoubleHeaderMuError::UsedInANotherDHMU);
							break;
						case 0x84:
							response = new DoubleHeaderMuError(DoubleHeaderMuError::SpeedNotZero);
							break;
						case 0x85:
							response = new DoubleHeaderMuError(DoubleHeaderMuError::NotMU);
							break;
						case 0x86:
							response = new DoubleHeaderMuError(DoubleHeaderMuError::NotMUBaseAddress);
							break;
						case 0x87:
							response = new DoubleHeaderMuError(DoubleHeaderMuError::CantDelete);
							break;
						case 0x88:
							response = new DoubleHeaderMuError(DoubleHeaderMuError::StackFull);
							break;
						default: response = NULL;
					}
					break;
				case 0x02:
				case 0x04:
				case 0x05:
				case 0x06: {
					bool avail = (message[1] & 0x08) == 0;
					LocomotiveInformation::DirectionCode dir;
					LocomotiveInformation::SpeedStepModeCode ssm;
					unsigned char s = 0;
					bool f0 = false,f1 = false,f2 = false,f3 = false,f4 = false,f5 = false,f6 = false,f7 = false,f8 = false,f9 = false,f10 = false,f11 = false,f12 = false;
					unsigned char mtr = 0;
					unsigned short address = 0;
					switch (message[1] & 0x07) {
						case 0x00: ssm = LocomotiveInformation::S14;
							   if ((message[2] & 0x0f) == 1) {
							   	s = 255;
							   } else if ((message[2] & 0x0f) == 0) {
							   	s = 0;
							   } else {
							   	s = (message[2] & 0x0f) - 1;
							   }
							   break;
						case 0x01: ssm = LocomotiveInformation::S27;
							   if ((message[2] & 0x1f) == 1) {
							   	s = 255;
							   } else if ((message[2] & 0x1f) == 0) {
							   	s = 0;
							   } else {
							   	s = ((message[2] & 0x0f) - 1) << 1;
							   	s += (((message[2] & 0x10) >> 4) ^ 0x01);
							   }
							   break;
						case 0x02: ssm = LocomotiveInformation::S28;
							   if ((message[2] & 0x1f) == 1) {
							   	s = 255;
							   } else if ((message[2] & 0x1f) == 0) {
							   	s = 0;
							   } else {
							   	s = ((message[2] & 0x0f) - 1) << 1;
							   	s += (((message[2] & 0x10) >> 4) ^ 0x01);
							   }
							   break;
						case 0x04: ssm = LocomotiveInformation::S128;
							   if ((message[2] & 0x7f) == 1) {
							   	s = 255;
							   } else if ((message[2] & 0x7f) == 0) {
							   	s = 0;
							   } else {
							   	s = (message[2] & 0x7f) - 1;
							   }
							   break;
					}
					mtr = 0;
					address = 0;
					if ((message[2] & 0x80) == 0) {
						dir = LocomotiveInformation::Reverse;
					} else {
						dir = LocomotiveInformation::Forward;
					}
					if ((message[0] & 0x0f) > 2) {
						f0 = (message[3] & 0x10) != 0;
						f1 = (message[3] & 0x01) != 0;
						f2 = (message[3] & 0x02) != 0;
						f3 = (message[3] & 0x04) != 0;
						f4 = (message[3] & 0x08) != 0;
						f5 = (message[4] & 0x01) != 0;
						f6 = (message[4] & 0x02) != 0;
						f7 = (message[4] & 0x04) != 0;
						f8 = (message[4] & 0x08) != 0;
						f9 = (message[4] & 0x10) != 0;
						f10 = (message[4] & 0x20) != 0;
						f11 = (message[4] & 0x40) != 0;
						f12 = (message[4] & 0x80) != 0;
					}
					if ((message[0] & 0x0f) == 5) {
						address = mtr = message[5];
					}
					if ((message[0] & 0x0f) == 6) {
						mtr = 0;
						address = (message[5] << 8) + message[6];
					}
					switch (message[1] & 0xf0) {
						case 0x00:
						   response = new LocomotiveInformation(0,avail,dir,ssm,s,f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12);
						   break;
						case 0x10:
						   response = new LocomotiveInformation(0,avail,dir,ssm,s,f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,mtr);
						   break;
						case 0x20:
						   response = new LocomotiveInformation(0,avail,dir,ssm,s);
						   break;
						case 0x60:
						   response = new LocomotiveInformation(0,avail,dir,ssm,s,f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,mtr,address);
						   break;
						default: response = NULL;
					}
					break;}
				case 0x03:
					if (message[1] == 0x40) {
					    response = new LocomotiveInformation((message[2] << 8) + message[3]);
					} else if (message[1] == 0x50) {
					    response = new FunctionStatus(
						(message[2] & 0x10) != 0,
						(message[2] & 0x01) != 0,
						(message[2] & 0x02) != 0,
						(message[2] & 0x04) != 0,
						(message[2] & 0x08) != 0,
						(message[3] & 0x01) != 0,
						(message[3] & 0x02) != 0,
						(message[3] & 0x04) != 0,
						(message[3] & 0x08) != 0,
						(message[3] & 0x10) != 0,
						(message[3] & 0x20) != 0,
						(message[3] & 0x40) != 0,
						(message[3] & 0x80) != 0);
					} else if ((message[1] & 0xf0) == 0x30) {
					    response = new LocomotiveAddress(
							message[1] & 0x0f,
							((message[2] << 8)+message[3]));
					} else response = NULL;
					break;
				default: response = NULL;
			}
			break;
	}
	if (response == NULL) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,"Bad or illformed message received, ignored.");
			*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
		}
		return CommandStationResponse::NO_RESPONSE_AVAILABLE;
	}
	responseList = response->AppendToList(responseList);
	return response->ResponseType();
}

/************************************************************************
 *									*
 * Return next command station response.				*
 *									*
 ************************************************************************/
 
CommandStationResponse * XPressNet::GetNextCommandStationResponse(char **outmessage)
{
	if (ttyfd < 0) return NULL;

	if (responseList == NULL &&
	    CheckForResponse(outmessage) == CommandStationResponse::NO_RESPONSE_AVAILABLE)
		return NULL;
	if (responseList == NULL) return NULL;
	return CommandStationResponse::PopTopOffList(responseList);
}


/************************************************************************
 * All of the messages sent from the computer to the command station.	*
 ************************************************************************/

/************************************************************************
 *									*
 * Send 'Resume Operations' message.
 *									*
 ************************************************************************/
 
void XPressNet::ResumeOperations()
{
	static unsigned char message[] = {0x21, 0x81, 0xa0};
	if (ttyfd < 0) return;
	write(ttyfd,message,3);
}

/************************************************************************
 *									*
 * Send 'Stop Operations' message.					*
 *									*
 ************************************************************************/
 
void XPressNet::StopOperations()
{
	static unsigned char message[] = {0x21, 0x80, 0xa1};
	if (ttyfd < 0) return;
	write(ttyfd,message,3);
}

/************************************************************************
 *									*
 * Put all locomotives into emergency stop.				*
 *									*
 ************************************************************************/
 
void XPressNet::EmergencyStopAllLocomotives()
{
	static unsigned char message[] = {0x80, 0x80};
	if (ttyfd < 0) return;
	write(ttyfd,message,2);
}

/************************************************************************
 *									*
 * Emergency stop a single locomotive.					*
 *									*
 ************************************************************************/
 
void XPressNet::EmergencyStopALocomotive(unsigned short la)
{
	unsigned char message[4];
	if (ttyfd < 0) return;
	message[0] = 0x92;
	message[1] = (la >> 8) & 0x0ff;
	message[2] = la & 0x0ff;
	message[3] = message[0] ^ message[1] ^  message[2];
	write(ttyfd,message,4);
}

/************************************************************************
 *									*
 * Read the selected mode register.					*
 *									*
 ************************************************************************/
 
void XPressNet::RegisterModeRead(unsigned char r)
{
	unsigned char message[4];
	if (ttyfd < 0) return;
	message[0] = 0x22;
	message[1] = 0x11;
	message[2] = (r & 0x0f);
	message[3] = message[0] ^ message[1] ^  message[2];
	write(ttyfd,message,4);
}

/************************************************************************
 *									*
 * Directly read a CV register.						*
 *									*
 ************************************************************************/
 
void XPressNet::DirectModeCVRead(unsigned char cv)
{
	unsigned char message[4];
	if (ttyfd < 0) return;
	message[0] = 0x22;
	message[1] = 0x15;
	message[2] = cv;
	message[3] = message[0] ^ message[1] ^  message[2];
	write(ttyfd,message,4);
}

/************************************************************************
 *									*
 * Read a CV in paged mode.						*
 *									*
 ************************************************************************/
 
void XPressNet::PagedModeCVRead(unsigned char cv)
{
	unsigned char message[4];
	if (ttyfd < 0) return;
	message[0] = 0x22;
	message[1] = 0x14;
	message[2] = cv;
	message[3] = message[0] ^ message[1] ^  message[2];
	write(ttyfd,message,4);
}

/************************************************************************
 *									*
 * Request service mode results.					*
 *									*
 ************************************************************************/
 
void XPressNet::RequestForServiceModeResults()
{
	static unsigned char message[] = {0x21, 0x10, 0x31};
	if (ttyfd < 0) return;
	write(ttyfd,message,3);
}

/************************************************************************
 *									*
 * Write a mode register.						*
 *									*
 ************************************************************************/
 
void XPressNet::RegisterModeWrite(unsigned char r,unsigned char d)
{
	unsigned char message[5];
	if (ttyfd < 0) return;
	message[0] = 0x23;
	message[1] = 0x12;
	message[2] = (r & 0x0f);
	message[3] = d;
	message[4] = message[0] ^ message[1] ^  message[2] ^ message[3];
	write(ttyfd,message,5);
}

/************************************************************************
 *									*
 * Write a CV register directly.					*
 *									*
 ************************************************************************/
 
void XPressNet::DirectModeCVWrite(unsigned char cv,unsigned char d)
{
	unsigned char message[5];
	if (ttyfd < 0) return;
	message[0] = 0x23;
	message[1] = 0x16;
	message[2] = cv;
	message[3] = d;
	message[4] = message[0] ^ message[1] ^  message[2] ^ message[3];
	write(ttyfd,message,5);
}

/************************************************************************
 *									*
 * Write a CV register in paged mode.					*
 *									*
 ************************************************************************/
 
void XPressNet::PagedModeCVWrite(unsigned char cv,unsigned char d)
{
	unsigned char message[5];
	if (ttyfd < 0) return;
	message[0] = 0x23;
	message[1] = 0x17;
	message[2] = cv;
	message[3] = d;
	message[4] = message[0] ^ message[1] ^  message[2] ^ message[3];
	write(ttyfd,message,5);
}

/************************************************************************
 *									*
 * Fetch command station software version.				*
 *									*
 ************************************************************************/
 
void XPressNet::CommandStationSoftwareVersion()
{
	static unsigned char message[] = {0x21, 0x21, 0x00};
	if (ttyfd < 0) return;
	write(ttyfd,message,3);
}

/************************************************************************
 *									*
 * Request command station status.					*
 *									*
 ************************************************************************/
 
void XPressNet::CommandStationStatusRequest()
{
	static unsigned char message[] = {0x21, 0x24, 0x05};
	if (ttyfd < 0) return;
	write(ttyfd,message,3);
}

/************************************************************************
 *									*
 * Set the command station's power up mode.				*
 *									*
 ************************************************************************/
 
void XPressNet::SetCommandStationPowerUpMode(CommandStationStatus::StartModeType mode)
{
	unsigned char message[3];
	if (ttyfd < 0) return;
	message[0] = 0x22;
	message[1] = 0x22;
	switch (mode) {
		case CommandStationStatus::Manual: message[2] = 0x00; break;
		case CommandStationStatus::Automatic: message[2] = 0x04; break;
		default: message[2] = 0x00; break;
	}
	message[3] = message[0] ^ message[1] ^ message[2];
	write(ttyfd,message,4);
}

/************************************************************************
 *									*
 * Request accessor decoder information.				*
 *									*
 ************************************************************************/
 
void XPressNet::AccessoryDecoderInformationRequest(unsigned char address,AccessoryDecoderInformation::NibbleCode nibble)
{
	unsigned char message[4];
	if (ttyfd < 0) return;
	message[0] = 0x42;
	message[1] = address;
	switch (nibble) {
		case AccessoryDecoderInformation::Lower: message[2] = 0x80; break;
		case AccessoryDecoderInformation::Upper: message[2] = 0x81; break;
	}
	message[3] = message[0] ^ message[1] ^ message[2];
	write(ttyfd,message,4);
}

/************************************************************************
 *									*
 * Perform an accessory decoder operation.				8
 *									*
 ************************************************************************/
 
void XPressNet::AccessoryDecoderOperation(unsigned char groupaddr,unsigned char elementaddr,bool activateOutput,bool useOutput2)
{
	unsigned char message[4];
	if (ttyfd < 0) return;
	message[0] = 0x52;
	message[1] = groupaddr;
	message[2] = 0x80 | ((elementaddr & 0x03) << 1);
	if (!activateOutput) message[2] |= 0x08;
	if (useOutput2) message[2] |= 0x01;
	message[3] = message[0] ^ message[1] ^ message[2];
	write(ttyfd,message,4);
}

/************************************************************************
 *									*
 * Request information about a locomotive.				*
 *									*
 ************************************************************************/
 
void XPressNet::LocomotiveInformationRequest(unsigned short int address)
{
	unsigned char message[5];
	if (ttyfd < 0) return;
	message[0] = 0xe3;
	message[1] = 0x00;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	message[4] = message[0] ^ message[1] ^  message[2] ^ message[3];
	write(ttyfd,message,5);
}

/************************************************************************
 *									*
 * Request the status of functions at a specificed address.		*
 *									*
 ************************************************************************/
 
void XPressNet::FunctionStatusRequest(unsigned short int address)
{
	unsigned char message[5];
	if (ttyfd < 0) return;
	message[0] = 0xe3;
	message[1] = 0x07;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	message[4] = message[0] ^ message[1] ^  message[2] ^ message[3];
	write(ttyfd,message,5);
}

/************************************************************************
 *									*
 * Set locomotive speed and direction.					*
 *									*
 ************************************************************************/
 
void XPressNet::SetLocomotiveSpeedAndDirection(unsigned short int address,
					       LocomotiveInformation::SpeedStepModeCode ssm,
					       LocomotiveInformation::DirectionCode dir,
					       unsigned char speed)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	switch (ssm) {
		case LocomotiveInformation::S14:
			message[1] = 0x10;
			if (speed == 255) message[4] = 0x01;
			if (speed == 0)   message[4] = 0x00;
			else message[4] = ((speed + 1) & 0x0f);
			if (dir == LocomotiveInformation::Forward) message[4] |= 0x80;
			break;
		case LocomotiveInformation::S27:
			message[1] = 0x11;
			if (speed == 255) message[4] = 0x01;
			if (speed == 0  ) message[4] = 0x00;
			else {
				unsigned char s14 = (speed >> 1) & 0x0f;
				unsigned char lsb = (speed & 0x01) ^ 0x01;
				message[4] = ((s14 + 1) & 0x0f);
				message[4] |= lsb << 4;
			}
			if (dir == LocomotiveInformation::Forward) message[4] |= 0x80;
		case LocomotiveInformation::S28:
			message[1] = 0x12;
			if (speed == 255) message[4] = 0x01;
			if (speed == 0  ) message[4] = 0x00;
			else {
				unsigned char s14 = (speed >> 1) & 0x0f;
				unsigned char lsb = (speed & 0x01) ^ 0x01;
				message[4] = ((s14 + 1) & 0x0f);
				message[4] |= lsb << 4;
			}
			if (dir == LocomotiveInformation::Forward) message[4] |= 0x80;
			break;
		case LocomotiveInformation::S128:
			message[1] = 0x13;
			if (speed == 255) message[4] = 0x01;
			if (speed == 0)   message[4] = 0x00;
			else message[4] = ((speed + 1) & 0x7f);
			if (dir == LocomotiveInformation::Forward) message[4] |= 0x80;
			break;
	}
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);
}

/************************************************************************
 *									*
 * Set locomotive group 1 functions.					*
 *									*
 ************************************************************************/
 
void XPressNet::SetLocomotiveFunctionsGroup1(unsigned short int address,bool f0,bool f1,bool f2,bool f3,bool f4)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[1] = 0x20;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	if (f0) message[4] = 0x10;
	else message[4] = 0x00;
	if (f1) message[4] |= 0x01;
	if (f2) message[4] |= 0x02;
	if (f3) message[4] |= 0x04;
	if (f4) message[4] |= 0x08;
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);
}

/************************************************************************
 *									*
 * Set locomotive group 2 functions.					*
 *									*
 ************************************************************************/
 
void XPressNet::SetLocomotiveFunctionsGroup2(unsigned short int address,bool f5,bool f6,bool f7,bool f8)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[1] = 0x21;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	if (f5) message[4] = 0x01;
	else message[4] = 0x00;
	if (f6) message[4] |= 0x02;
	if (f7) message[4] |= 0x04;
	if (f8) message[4] |= 0x08;
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);
}

/************************************************************************
 *									*
 * Set locomotive group 3 functions.					*
 *									*
 ************************************************************************/
 
void XPressNet::SetLocomotiveFunctionsGroup3(unsigned short int address,bool f9,bool f10,bool f11,bool f12)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[1] = 0x22;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	if (f9) message[4] = 0x01;
	else message[4] = 0x00;
	if (f10) message[4] |= 0x02;
	if (f11) message[4] |= 0x04;
	if (f12) message[4] |= 0x08;
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);
}

/************************************************************************
 *									*
 * Set locomotive group 1 state.					*
 *									*
 ************************************************************************/
 
void XPressNet::SetFunctionStateGroup1(unsigned short int address,bool f0,bool f1,bool f2,bool f3,bool f4)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[1] = 0x24;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	if (f0) message[4] = 0x10;
	else message[4] = 0x00;
	if (f1) message[4] |= 0x01;
	if (f2) message[4] |= 0x02;
	if (f3) message[4] |= 0x04;
	if (f4) message[4] |= 0x08;
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);
}

/************************************************************************
 *									*
 * Set locomotive group 2 state.					*
 *									*
 ************************************************************************/
 
void XPressNet::SetFunctionStateGroup2(unsigned short int address,bool f5,bool f6,bool f7,bool f8)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[1] = 0x25;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	if (f5) message[4] = 0x01;
	else message[4] = 0x00;
	if (f6) message[4] |= 0x02;
	if (f7) message[4] |= 0x04;
	if (f8) message[4] |= 0x08;
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);
}

/************************************************************************
 *									*
 * Set locomotive group 3 state.					*
 *									*
 ************************************************************************/
 
void XPressNet::SetFunctionStateGroup3(unsigned short int address,bool f9,bool f10,bool f11,bool f12)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[1] = 0x26;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	if (f9) message[4] = 0x01;
	else message[4] = 0x00;
	if (f10) message[4] |= 0x02;
	if (f11) message[4] |= 0x04;
	if (f12) message[4] |= 0x08;
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);
}

/************************************************************************
 *									*
 * Establish a double header.						*
 *									*
 ************************************************************************/
 
void XPressNet::EstablishDoubleHeader(unsigned short int address1,unsigned short int address2)
{
	unsigned char message[7];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe5;
	message[1] = 0x43;
	message[2] = (address1 >> 8) & 0x0ff;
	message[3] = address1 & 0x0ff;
	message[4] = (address2 >> 8) & 0x0ff;
	message[5] = address2 & 0x0ff;
	message[6] = message[0];
	for (i = 1; i < 6; ++i) message[6] ^= message[i];
	write(ttyfd,message,7);
}

/************************************************************************
 *									*
 * Programming byte mode write.						*
 *									*
 ************************************************************************/
 
void XPressNet::OperatingModeProgrammingByteModeWrite(unsigned short int address,unsigned short int cv,unsigned char data)
{
	unsigned char message[8];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe6;
	message[1] = 0x30;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	message[4] = 0xec | ((cv >> 8) & 0x03);
	message[5] = cv & 0x0ff;
	message[6] = data;
	message[7] = message[0];
	for (i = 1; i < 7; ++i) message[7] ^= message[i];
	write(ttyfd,message,8);
}

/************************************************************************
 *									*
 * Programming bit mode write.						*
 *									*
 ************************************************************************/
 
void XPressNet::OperatingModeProgrammingBitModeWrite(unsigned short int address,unsigned short int cv,unsigned char bitnum,bool value)
{
	unsigned char message[8];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe6;
	message[1] = 0x30;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	message[4] = 0xeb | ((cv >> 8) & 0x03);
	message[5] = cv & 0x0ff;
	message[6] = (bitnum & 0x07);
	if (value) message[6] |= 0x08;
	message[7] = message[0];
	for (i = 1; i < 7; ++i) message[7] ^= message[i];
	write(ttyfd,message,8);
}

/************************************************************************
 *									*
 * Add a locomotive to a multiple unit set.				*
 *									*
 ************************************************************************/
 
void XPressNet::AddLocomotiveToMultiUnit(unsigned short int address,unsigned char mtr,bool samedirection)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[1] = 0x40;
	if (!samedirection) message[1] |= 0x01;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	message[4] = mtr;
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);	
}

/************************************************************************
 *									*
 * Remove a locomotive from a multiple unit set.			*
 *									*
 ************************************************************************/
 
void XPressNet::RemoveLocomotiveFromMultiUnit(unsigned short int address,unsigned char mtr)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[1] = 0x42;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	message[4] = mtr;
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);	
}

/************************************************************************
 *									*
 * Inquire the next multiple unit member address.			*
 *									*
 ************************************************************************/
 
void XPressNet::AddressInquiryNextMUMember(unsigned char mtr,unsigned short int address)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[1] = 0x01;
	message[2] = mtr;
	message[3] = (address >> 8) & 0x0ff;
	message[4] = address & 0x0ff;
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);	
}

/************************************************************************
 *									*
 * Inquire the previous multiple unit member address.			*
 *									*
 ************************************************************************/
 
void XPressNet::AddressInquiryPreviousMUMember(unsigned char mtr,unsigned short int address)
{
	unsigned char message[6];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe4;
	message[1] = 0x02;
	message[2] = mtr;
	message[3] = (address >> 8) & 0x0ff;
	message[4] = address & 0x0ff;
	message[5] = message[0];
	for (i = 1; i < 5; ++i) message[5] ^= message[i];
	write(ttyfd,message,6);	
}

/************************************************************************
 *									*
 * Inquire the next multiple unit address.				*
 *									*
 ************************************************************************/
 
void XPressNet::AddressInquiryNextMU(unsigned char mtr)
{
	unsigned char message[4];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe2;
	message[1] = 0x03;
	message[2] = mtr;
	message[3] = message[0];
	for (i = 1; i < 3; ++i) message[3] ^= message[i];
	write(ttyfd,message,4);	
}

/************************************************************************
 *									*
 * Inquire the previous multiple unit address.				*
 *									*
 ************************************************************************/
 
void XPressNet::AddressInquiryPreviousMU(unsigned char mtr)
{
	unsigned char message[4];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe2;
	message[1] = 0x04;
	message[2] = mtr;
	message[3] = message[0];
	for (i = 1; i < 3; ++i) message[3] ^= message[i];
	write(ttyfd,message,4);	
}

/************************************************************************
 *									*
 * Inquire the next stacked address.					*
 *									*
 ************************************************************************/
 
void XPressNet::AddressInquiryNextStack(unsigned short int address)
{
	unsigned char message[5];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe3;
	message[1] = 0x05;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	message[4] = message[0];
	for (i = 1; i < 4; ++i) message[4] ^= message[i];
	write(ttyfd,message,5);	
}

/************************************************************************
 *									*
 * Inquire the previous stacked address.				*
 *									*
 ************************************************************************/
 
void XPressNet::AddressInquiryPreviousStack(unsigned short int address)
{
	unsigned char message[5];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe3;
	message[1] = 0x06;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	message[4] = message[0];
	for (i = 1; i < 4; ++i) message[4] ^= message[i];
	write(ttyfd,message,5);	
}

/************************************************************************
 *									*
 * Delete a locomotive from a stack.					*
 *									*
 ************************************************************************/
 
void XPressNet::DeleteLocomotiveFromStack(unsigned short int address)
{
	unsigned char message[5];
	int i;
	if (ttyfd < 0) return;
	message[0] = 0xe3;
	message[1] = 0x44;
	message[2] = (address >> 8) & 0x0ff;
	message[3] = address & 0x0ff;
	message[4] = message[0];
	for (i = 1; i < 4; ++i) message[4] ^= message[i];
	write(ttyfd,message,5);	
}
