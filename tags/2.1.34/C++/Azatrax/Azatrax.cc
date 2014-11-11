/* 
 * ------------------------------------------------------------------
 * Azatrax.cc - Azatrax base class implementation code.
 * Created by Robert Heller on Mon Jun 25 16:01:20 2012
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
 *     Copyright (C) 1994,1995,2002-2012  Robert Heller D/B/A Deepwoods Software
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
#include <Azatrax.h>
#include <mrd.h>
#include <sl2.h>
#include <sr4.h>
#include "gettext.h"

using namespace azatrax;

int Azatrax::deviceOpenCount = 0;

char ** Azatrax::AllConnectedDevices()
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
		if (desc.idVendor != idAzatraxVendor) continue;
		//if (desc.idProduct != idProduct) continue;
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

Azatrax *Azatrax::OpenDevice(const char *serialnumber,
			    unsigned short int idProduct,
			    char **outmessage)
{
	// Error message buffer.
	static char messageBuffer[2048];
	bool found = false;
	unsigned short int prodid;

	bindmrrdomain();        // bind message catalog domain
	
	int err = 0; 
	if (deviceOpenCount == 0) {
		err = libusb_init(NULL);
		if (err != 0) {return NULL;}
	}
	libusb_device **list;
	ssize_t cnt = libusb_get_device_list(NULL, &list);
	ssize_t i = 0;
	if (cnt < 0) {
		if (deviceOpenCount == 0) libusb_exit(NULL);
		return NULL;
	}
	for (i = 0; i < cnt; i++) {
		libusb_device *dev = list[i];
		prodid = GetProductId(dev,serialnumber,idProduct);
		if (prodid != 0) {
			found = true;
			break;
		}
	}
	libusb_free_device_list(list, 1);
	if (deviceOpenCount == 0) libusb_exit(NULL);
	if (found) {
		switch (prodid) {
			case idMRDProduct:
				return (Azatrax*) new MRD(serialnumber,outmessage);
			case idSL2Product:
				return (Azatrax*) new SL2(serialnumber,outmessage);
			case idSR4Product:
				return (Azatrax*) new SR4(serialnumber,outmessage);
			default:
				if (outmessage != NULL) {
					sprintf(messageBuffer,_("Unsupported Azatrax product: 0x%04x."),idProduct);
					*outmessage = new char[strlen(messageBuffer)+1];
					strcpy(*outmessage,messageBuffer);
				}
				return NULL;
		}
	} else {
		if (outmessage != NULL) {
			sprintf(messageBuffer,_("Could not find a device with serial number %s and product id 0x%04x."),serialnumber,idProduct);
			*outmessage = new char[strlen(messageBuffer)+1];
			strcpy(*outmessage,messageBuffer);
		}
		return NULL;
	}
}

bool Azatrax::IsThisTheAzatraxWeAreLookingFor(libusb_device *dev,
					      const char *serialnumber,
					      unsigned short int idProduct)
{
	int err;
	struct libusb_device_descriptor desc;
	err = libusb_get_device_descriptor(dev,&desc);
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsThisTheAzatraxWeAreLookingFor(): err (libusb_get_device_descriptor) = %d\n",err);
#endif
	if (err != 0) return false;
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsThisTheAzatraxWeAreLookingFor(): desc.idVendor = 0x%04x, idVendor = 0x%04x\n",desc.idVendor,idVendor);
#endif
	if (desc.idVendor != idAzatraxVendor) return false;
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsThisTheAzatraxWeAreLookingFor(): desc.idProduct = 0x%04x, idProduct = 0x%04x\n",desc.idProduct,idProduct);
#endif
	if (desc.idProduct != idProduct) return false;
	libusb_device_handle *temphandle;
	err = libusb_open(dev,&temphandle);
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsThisTheAzatraxWeAreLookingFor(): err (libusb_open) = %d\n",err);
#endif
	if (err != 0) return false;
	unsigned char serial[16];
	err = libusb_get_string_descriptor_ascii(temphandle,desc.iSerialNumber,
						 serial,sizeof(serial));
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsTheMRDWeAreLookingFor(): err (libusb_get_string_descriptor_ascii) = %d\n",err);
#endif
	if (err < 0) {
		libusb_close(temphandle);
		return false;
	}
	libusb_close(temphandle);
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsTheMRDWeAreLookingFor(): serial = '%s',serialnumber = '%s'\n",serial,serialnumber);
#endif
	return strcmp((char *)serial,serialnumber) == 0;
}

unsigned short int Azatrax::GetProductId(libusb_device *dev,
					  const char *serialnumber,
					  unsigned short int idProductMatch)
{
	int err;
	struct libusb_device_descriptor desc;
	err = libusb_get_device_descriptor(dev,&desc);
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsThisTheAzatraxWeAreLookingFor(): err (libusb_get_device_descriptor) = %d\n",err);
#endif
	if (err != 0) return false;
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsThisTheAzatraxWeAreLookingFor(): desc.idVendor = 0x%04x, idVendor = 0x%04x\n",desc.idVendor,idVendor);
#endif
	if (desc.idVendor != idAzatraxVendor) return false;
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsThisTheAzatraxWeAreLookingFor(): desc.idProduct = 0x%04x, idProduct = 0x%04x\n",desc.idProduct,idProduct);
#endif
	if (idProductMatch != 0 && desc.idProduct != idProductMatch) return false;
	libusb_device_handle *temphandle;
	err = libusb_open(dev,&temphandle);
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsThisTheAzatraxWeAreLookingFor(): err (libusb_open) = %d\n",err);
#endif
	if (err != 0) return false;
	unsigned char serial[16];
	err = libusb_get_string_descriptor_ascii(temphandle,desc.iSerialNumber,
						 serial,sizeof(serial));
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsTheMRDWeAreLookingFor(): err (libusb_get_string_descriptor_ascii) = %d\n",err);
#endif
	if (err < 0) {
		libusb_close(temphandle);
		return false;
	}
	libusb_close(temphandle);
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::IsTheMRDWeAreLookingFor(): serial = '%s',serialnumber = '%s'\n",serial,serialnumber);
#endif
	if (strcmp((char *)serial,serialnumber) == 0) {
		return desc.idProduct;
	} else {
		return 0;
	}
}

Azatrax::Azatrax(const char *serialnumber,
		 unsigned short int idProduct,
		 char **outmessage)
{

	// Error message buffer.
	static char messageBuffer[2048];

	bindmrrdomain();	// bind message catalog domain
	
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
	    	if (IsThisTheAzatraxWeAreLookingFor(device,serialnumber,idProduct)) {
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
			sprintf(messageBuffer,_("Could not find Azatrax device with serial number %s."),serialnumber);
		} else {
			sprintf(messageBuffer,_("Could open Azatrax device with serial number %s: err is %d."),serialnumber,err);
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
	myProductId = idProduct;	
	deviceOpenCount++;
}

Azatrax::~Azatrax()
{
	int err;
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::~Azatrax: handle = 0x%016lx\n",(unsigned long long)handle);
#endif
	err = libusb_release_interface(handle,0);
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::~Azatrax: libusb_release_interface returns %d\n",err);
#endif
	libusb_close(handle);
	deviceOpenCount--;	
#ifdef DEBUG
	fprintf(stderr,"*** Azatrax::~Azatrax: deviceOpenCount = %d\n",deviceOpenCount);
#endif
	if (deviceOpenCount == 0) {
		libusb_exit(NULL);
	}
}

#define OUTPUTENDPOINT 0x01
ErrorCode Azatrax::sendByte(uint8_t commandByte) const
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

ErrorCode Azatrax::send2Bytes(uint8_t commandByte,uint8_t byte2) const
{
	uint8_t buffer[4];
	ErrorCode err;
	int xfercount;

	if (handle == NULL) return LIBUSB_ERROR_NO_DEVICE;

	buffer[0] = commandByte;
	buffer[1] = byte2;
	err = libusb_interrupt_transfer(handle,OUTPUTENDPOINT,buffer,2,
					&xfercount,100);
	return err;
}

ErrorCode Azatrax::send3Bytes(uint8_t commandByte,uint8_t byte2,uint8_t byte3) const
{
	uint8_t buffer[4];
	ErrorCode err;
	int xfercount;

	if (handle == NULL) return LIBUSB_ERROR_NO_DEVICE;

	buffer[0] = commandByte;
	buffer[1] = byte2;
	buffer[2] = byte3;
	err = libusb_interrupt_transfer(handle,OUTPUTENDPOINT,buffer,3,
					&xfercount,100);
	return err;
}

#define INPUTENDPOINT 0x81
ErrorCode Azatrax::GetStateData()
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
