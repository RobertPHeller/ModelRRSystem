/* 
 * ------------------------------------------------------------------
 * mrd.cc - Azatrax MRD series Model Railroad Sensor / Relay units
 * Created by Robert Heller on Sun Oct 23 11:46:21 2011
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

#include <stdio.h>
#include <string.h>
#include <mrd.h>
#include "gettext.h"

using namespace mrd;

const unsigned short int MRD::idVendor = 0x04d8;
const unsigned short int MRD::idProduct = 0xfcb2;
int MRD::deviceOpenCount = 0;

bool MRD::IsTheMRDWeAreLookingFor(libusb_device *dev,const char *serialnumber)
{
	int err;
	struct libusb_device_descriptor desc;
	err = libusb_get_device_descriptor(dev,&desc);
#ifdef DEBUG
	fprintf(stderr,"*** MRD::IsTheMRDWeAreLookingFor(): err (libusb_get_device_descriptor) = %d\n",err);
#endif
	if (err != 0) return false;
#ifdef DEBUG
	fprintf(stderr,"*** MRD::IsTheMRDWeAreLookingFor(): desc.idVendor = 0x%04x, idVendor = 0x%04x\n",desc.idVendor,idVendor);
#endif
	if (desc.idVendor != idVendor) return false;
#ifdef DEBUG
	fprintf(stderr,"*** MRD::IsTheMRDWeAreLookingFor(): desc.idProduct = 0x%04x, idProduct = 0x%04x\n",desc.idProduct,idProduct);
#endif
	if (desc.idProduct != idProduct) return false;
	libusb_device_handle *temphandle;
	err = libusb_open(dev,&temphandle);
#ifdef DEBUG
	fprintf(stderr,"*** MRD::IsTheMRDWeAreLookingFor(): err (libusb_open) = %d\n",err);
#endif
	if (err != 0) return false;
	unsigned char serial[16];
	err = libusb_get_string_descriptor_ascii(temphandle,desc.iSerialNumber,
						 serial,sizeof(serial));
#ifdef DEBUG
	fprintf(stderr,"*** MRD::IsTheMRDWeAreLookingFor(): err (libusb_get_string_descriptor_ascii) = %d\n",err);
#endif
	if (err < 0) {
		libusb_close(temphandle);
		return false;
	}
	libusb_close(temphandle);
#ifdef DEBUG
	fprintf(stderr,"*** MRD::IsTheMRDWeAreLookingFor(): serial = '%s',serialnumber = '%s'\n",serial,serialnumber);
#endif
	return strcmp((char *)serial,serialnumber) == 0;	
}

char ** MRD::AllConnectedDevices()
{
	char **result = NULL;
	size_t indx = 0, count = 0;
	int err = 0; 
	if (deviceOpenCount == 0) {
		err = libusb_init(NULL);
		if (err != 0) {return result;}
	}
	libusb_device **list;
	ssize_t cnt = libusb_get_device_list(NULL, &list);
	ssize_t i = 0;
	if (cnt < 0) {
		if (deviceOpenCount == 0) libusb_exit(NULL);
		return result;
	}
	for (i = 0; i < cnt; i++) {
		
		libusb_device *dev = list[i];
		struct libusb_device_descriptor desc;
		err = libusb_get_device_descriptor(dev,&desc);
		if (err != 0) continue;
		if (desc.idVendor != idVendor) continue;
		if (desc.idProduct != idProduct) continue;
		libusb_device_handle *temphandle;
		err = libusb_open(dev,&temphandle);
		if (err != 0) continue;
		unsigned char serial[16];
		err = libusb_get_string_descriptor_ascii(temphandle,
							 desc.iSerialNumber,
							 serial,sizeof(serial));
		libusb_close(temphandle);
		if (err < 0) continue;
		if (indx >= count) {
			if (count == 0) {
				result = new char *[(size_t)_InitSize];
				count = (size_t) _InitSize;
				indx  = 0;
			} else {
				char ** newresult = new char *[count+(size_t)_GrowSize];
				size_t ii; char **p,**q;
				for (p = result, q = newresult,ii = 0;
					ii < indx;p++,q++,ii++) {*q = *p;}
				delete result;
				result = newresult;
				count += (size_t)_GrowSize;
			}
		}
		result[indx] = new char [strlen((const char*)serial)+1];
		strcpy(result[indx],(const char*)serial);
		indx++;
	}
	libusb_free_device_list(list, 1);
	if (deviceOpenCount == 0) libusb_exit(NULL);
	if (indx >= count) {
		if (count == 0) {
			result = new char *[1];
			count  = 1;
			indx   = 0;
		} else {
			char ** newresult = new char *[count+1];
			char **p, **q; size_t ii;
			for (p = result, q = newresult,ii = 0;
				ii < indx;p++,q++,ii++) {*q = *p;}
			delete result;
			result = newresult;
			count++;
		}
	}
	result[indx] = NULL;
	return result;
}

MRD::MRD(const char *serialnumber, char **outmessage)
{
	// Error message buffer.
	static char messageBuffer[2048];
	
	handle = NULL;
	int err = 0;
	if (deviceOpenCount == 0) {
		err = libusb_init(NULL);
		if (err != 0) {
			if (outmessage != NULL) {
				sprintf(messageBuffer,_("Failed to initialize libusb: err is %d."),err);
				*outmessage = new char[strlen(messageBuffer)+1];
				strcpy(*outmessage,messageBuffer);
			}
			return;
		}
	}
	libusb_device **list;
	libusb_device *found = NULL;
	ssize_t cnt = libusb_get_device_list(NULL, &list);
	ssize_t i = 0;
	if (cnt < 0) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,_("Failed to get device list: err is %d."),err);
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		if (deviceOpenCount == 0) libusb_exit(NULL);
		return;
	}

	for (i = 0; i < cnt; i++) {
		libusb_device *device = list[i];
	    	if (IsTheMRDWeAreLookingFor(device,serialnumber)) {
	    		found = device;
	    		break;
	    	}
	}

	err = 0;
	if (found) {
	    	err = libusb_open(found, &handle);
	}
	
	libusb_free_device_list(list, 1);

	if (handle == NULL) {
		/* device not found (err == 0) or
		   error opening device (err != 0) */
		if (err == 0) {
			sprintf(messageBuffer,_("Could not find MRD device with serial number %s."),serialnumber);
		} else {
			sprintf(messageBuffer,_("Could open MRD device with serial number %s: err is %d."),serialnumber,err);
		}
		if (outmessage != NULL) {
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		if (deviceOpenCount == 0) libusb_exit(NULL);
		return;
	}
	err = libusb_claim_interface(handle,0);
	if (err) {
		if (outmessage != NULL) {
			sprintf(messageBuffer,_("Could not claim interface 0: err is %d."),err);
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		libusb_close(handle);
		if (deviceOpenCount == 0) libusb_exit(NULL);
	}

	strncpy(mySerialNumber,serialnumber,sizeof(mySerialNumber)-1);
	mySerialNumber[9] = '\0';
	memset((void *)&stateDataPacket,0x00,sizeof(stateDataPacket));
	
	deviceOpenCount++;
}

MRD::~MRD()
{
	int err;
//	fprintf(stderr,"*** MRD::~MRD: handle = 0x%016lx\n",(unsigned long long)handle);
	err = libusb_release_interface(handle,0);
//	fprintf(stderr,"*** MRD::~MRD: libusb_release_interface returns %d\n",err);
	libusb_close(handle);
	deviceOpenCount--;	
//	fprintf(stderr,"*** MRD::~MRD: deviceOpenCount = %d\n",deviceOpenCount);
	if (deviceOpenCount == 0) {
		libusb_exit(NULL);
	}
}

#define INPUTENDPOINT 0x81
ErrorCode MRD::GetStateData()
{
	ErrorCode err;
	int xfercount, retrycount = 10;

	if (handle == NULL) return LIBUSB_ERROR_NO_DEVICE;

	err = sendByte(cmd_GetStateData);
#ifdef DEBUG
	fprintf(stderr,"*** MRD::GetStateData(): sendByte returns %d\n",err);
#endif
	if (err != 0) {return err;}
#ifdef DEBUG
	fprintf(stderr,"*** MRD::GetStateData(): sizeof(stateDataPacket) = %d\n",sizeof(stateDataPacket));
#endif
	err = libusb_interrupt_transfer(handle,INPUTENDPOINT,
					(unsigned char *)&stateDataPacket,
					sizeof(stateDataPacket),&xfercount,
					100);
#ifdef DEBUG
	fprintf(stderr,"*** MRD::GetStateData(): libusb_interrupt_transfer returns %d, xfercount = %d\n",err,xfercount);
#endif
	while (err == LIBUSB_ERROR_TIMEOUT && retrycount > 0) {
		err = sendByte(cmd_GetStateData);
		if (err != 0) {return err;}
		err = libusb_interrupt_transfer(handle,INPUTENDPOINT,
					(unsigned char *)&stateDataPacket,
					sizeof(stateDataPacket),&xfercount,
					100);
		retrycount--;
	}
	return err;
}


#define OUTPUTENDPOINT 0x01
ErrorCode MRD::sendByte(uint8_t commandByte) const
{
	uint8_t buffer[2];
	ErrorCode err;
	int xfercount;

	if (handle == NULL) return LIBUSB_ERROR_NO_DEVICE;

	buffer[0] = commandByte;
	err = libusb_interrupt_transfer(handle,OUTPUTENDPOINT,buffer,1,
					&xfercount,100);
	return err;
}

