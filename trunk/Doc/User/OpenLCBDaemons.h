// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sun Aug 14 14:40:15 2016
//  Last Modified : <160815.1324>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2016  Robert Heller D/B/A Deepwoods Software
//			51 Locke Hill Road
//			Wendell, MA 01379-9728
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// 
//
//////////////////////////////////////////////////////////////////////////////

#ifndef __OPENLCBDAEMONS_H
#define __OPENLCBDAEMONS_H

/** @page openlcbdaemons OpenLCB Daemons (Hubs and Virtual nodes)
 * A number of OpenLCB daemons are provided by the Model Railroad System.
 * These daemons provide operational OpenLCB functionallity, including
 * providing hubs and gateways for both real physical nodes and virtual nodes,
 * along with several virtual nodes.
 * 
 * @section hubs Hub Daemons
 * There are two hub daemons that implement a OpenLCB network over Tcp/Ip and
 * connect CAN busses connected to different host computers connected via
 * Tcp/Ip over Ethernet.  These daemons are:
 *   - \ref OpenLCBTcpHub The OpenLCBTcpHub daemon implememts the binary
 *   OpenLCB messaging protocol over Tcp/Ip.
 *   - \ref OpenLCBGCTcpHub The OpenLCBGCTcpHub daemon implememts the OpenLCB
 *   messaging using the GridConnect protocol over both Tcp/Ip and using the
 *   CAN Bus over a USB/Serial connection.
 * 
 * Both hub daemons implement a OpenLCB network over Tcp/Ip, although using
 * different message formats. Both also take a common set of command line
 * arguments. The common command line arguments define the host ports and
 * devices to bind sockets to. The GridConnect hub can also connect to both
 * physical CAN busses (over [USB] serial ports) and other OpenLCB network
 * hubs over Tcp/Ip. The daemons run non-interactively and log their activity
 * to a log file.
 * 
 * @section vnodes Virtual Nodes
 * There are three virtual nodes that implement OpenLCB nodes to provide
 * useful functions.  There daemons are:
 *   - \ref OpenLCB_MRD2 The OpenLCB_MRD2 daemon implememts an OpenLCB node
 * that implements the EventExchange protocol for Azatrax MRD2 boards.
 *   - \ref OpenLCB_PiGPIO The OpenLCB_PiGPIO daemon implememts an OpenLCB
 *   node that implements the EventExchange protocol for Raspberry Pi GPIO
 *   pins.
 *   - \ref OpenLCB_TrackCircuits The OpenLCB_TrackCircuits daemon implememts
 *   an OpenLCB node that implements virtual track circuit messaging logic
 *   using OpenLCB Events.
 * 
 * All three programs normally run as non-interactive daemon processes and use
 * a configuration file in XML format to define the detailed operation of the
 * programs. This configuration file can either be hand edited or can be
 * edited by the programs themselves using the specific GUI configuration
 * editor built-in to each program.
 * 
 * @subsection MRD2 EventExchange node for Azatrax MRD2 boards.
 * 
 * The OpenLCB_MRD2 daemon is used to tie one or more USB connected Azatrax
 * MRD2 boards to an OpenLCB network, tying event production to the Sense and
 * Latch inputs of each defined connected device and, for relay equiped
 * boards, event consumption to the Channel 1 and Channel 2 outputs of each
 * defined connected device.
 * 
 * @subsubsection XMLSchema XML Schema for configuration files
 * @verbatim
  <?xml version="1.0" ?>
  <?xml-stylesheet href="schema2xhtml.xsl" type="text/xsl" ?>
  <!-- XML Schema for OpenLCB_MRD2 configuration files -->
  <xs:schema version="OpenLCB_MRD2 1.0" 
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <xs:element name="OpenLCB_MRD2" minOccurs="1" maxOccurs="1">
      <xs:annotation>
        <xs:documentation>
          This is the configuration container for the OpenLCB_MRD2 daemon.
        </xs:documentation>
      </xs:annotation>
      <xs:complexType>
        <xs:sequence>
          <xs:element name="transport" minOccurs="1" maxOccurs="1">
            <xs:annotation>
               <xs:documentation>
                 This defines the transport to use for this node.
               </xs:documentation>
            </xs:annotation>
            <xs:complexType>
              <xs:sequence>
                <xs:element name="constructor" minOccurs="1" maxOccurs="1" />
                <xs:element name="options" minOccurs="1" maxOccurs="1" />
              </xs:sequence>
            </xs:complexType>
          </xs:element>
          <xs:element name="pollinterval" minOccurs="0" maxOccurs="1" />
          <xs:element name="name" minOccurs="0" maxOccurs="1" />
          <xs:element name="description" minOccurs="0" maxOccurs="1" />
          <xs:element name="device" minOccurs="0" maxOccurs="unbounded" >
            <xs:annotation>
              <xs:documentation>
                This defines one device.
              </xs:documentation>
            </xs:annotation>
            <xs:complexType>
              <xs:sequence>
                <xs:element name="serial" minOccurs="1" maxOccurs="1" />
                <xs:element name="description" minOccurs="0" maxOccurs="1" />
                <xs:element name="sense1on" minOccurs="0" maxOccurs="1" />
                <xs:element name="sense1off" minOccurs="0" maxOccurs="1" />
                <xs:element name="sense2on" minOccurs="0" maxOccurs="1" />
                <xs:element name="sense2off" minOccurs="0" maxOccurs="1" />
                <xs:element name="latch1on" minOccurs="0" maxOccurs="1" />
                <xs:element name="setchan" minOccurs="0" maxOccurs="1" />
                <xs:element name="setchan" minOccurs="0" maxOccurs="1" />
              </xs:sequence>
            </xs:complexType>
          </xs:element>
        </xs:sequence>
      </xs:complexType>
    </xs:element>
  </xs:schema>
  @endverbatim
 * 
 * 
 * @subsection PiGPIO EventExchange node for Raspberry Pi GPIO pins.
 * 
 * The OpenLCB_PiGPIO daemon is used to tie one or more of a Raspberry Pi's
 * GPIO pins to event production (input pins) or event consumption (output
 * pins).
 * 
 * @subsubsection XMLSchema XML Schema for configuration files
 * @verbatim
  <?xml version="1.0" ?>
  <?xml-stylesheet href="schema2xhtml.xsl" type="text/xsl" ?>
  <!-- XML Schema for OpenLCB_PiGPIO configuration files -->
  <xs:schema version="OpenLCB_PiGPIO 1.0" 
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <xs:element name="OpenLCB_PiGPIO" minOccurs="1" maxOccurs="1">
      <xs:annotation>
        <xs:documentation>
          This is the configuration container for the OpenLCB_PiGPIO daemon.
        </xs:documentation>
      </xs:annotation>
      <xs:complexType>
        <xs:sequence>
          <xs:element name="transport" minOccurs="1" maxOccurs="1">
            <xs:annotation>
               <xs:documentation>
                 This defines the transport to use for this node.
               </xs:documentation>
            </xs:annotation>
            <xs:complexType>
              <xs:sequence>
                <xs:element name="constructor" minOccurs="1" maxOccurs="1" />
                <xs:element name="options" minOccurs="1" maxOccurs="1" />
              </xs:sequence>
            </xs:complexType>
          </xs:element>
          <xs:element name="name" minOccurs="0" maxOccurs="1" />
          <xs:element name="description" minOccurs="0" maxOccurs="1" />
          <xs:element name="pollinterval" minOccurs="0" maxOccurs="1" />
          <xs:element name="pin" minOccurs="0" maxOccurs="unbounded" >
            <xs:annotation>
              <xs:documentation>
                This defines one pin.
              </xs:documentation>
            </xs:annotation>
            <xs:complexType>
              <xs:sequence>
                <xs:element name="number" minOccurs="1" maxOccurs="1" />
                <xs:element name="description" minOccurs="0" maxOccurs="1" />
                <xs:element name="mode" minOccurs="0" maxOccurs="1" />
                <xs:element name="pinin0" minOccurs="0" maxOccurs="1" />
                <xs:element name="pinin1" minOccurs="0" maxOccurs="1" />
                <xs:element name="pinout0" minOccurs="0" maxOccurs="1" />
                <xs:element name="pinout1" minOccurs="0" maxOccurs="1" />
              </xs:sequence>
            </xs:complexType>
          </xs:element>
        </xs:sequence>
      </xs:complexType>
    </xs:element>
  </xs:schema>
   @endverbatim
 * 
 * @subsection TrackCircuits EventExchange node for virtual track circuits.
 * 
 * The OpenLCB_TrackCircuits daemon is used to implement one or more virtual
 * track circuits. Each track circuit can emit a code event in response to an
 * event and can emit an event in response to a code event, possibly prefixed
 * with a Code 1 Start event.
 * @subsubsection XMLSchema XML Schema for configuration files
 * @verbatim
  <?xml version="1.0" ?>
  <?xml-stylesheet href="schema2xhtml.xsl" type="text/xsl" ?>
  <!-- XML Schema for OpenLCB_TrackCircuits configuration files -->
  <xs:schema version="OpenLCB_TrackCircuits 1.0" 
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <xs:element name="OpenLCB_TrackCircuits" minOccurs="1" maxOccurs="1">
      <xs:annotation>
        <xs:documentation>
          This is the configuration container for the OpenLCB_TrackCircuits daemon.
        </xs:documentation>
      </xs:annotation>
      <xs:complexType>
        <xs:sequence>
          <xs:element name="transport" minOccurs="1" maxOccurs="1">
            <xs:annotation>
               <xs:documentation>
                 This defines the transport to use for this node.
               </xs:documentation>
            </xs:annotation>
            <xs:complexType>
              <xs:sequence>
                <xs:element name="constructor" minOccurs="1" maxOccurs="1" />
                <xs:element name="options" minOccurs="1" maxOccurs="1" />
              </xs:sequence>
            </xs:complexType>
          </xs:element>
          <xs:element name="name" minOccurs="0" maxOccurs="1" />
          <xs:element name="description" minOccurs="0" maxOccurs="1" />
          <xs:element name="track" minOccurs="0" maxOccurs="unbounded" >
            <xs:annotation>
              <xs:documentation>
                This defines one track.
              </xs:documentation>
            </xs:annotation>
            <xs:complexType>
              <xs:sequence>
                <xs:element name="description" minOccurs="0" maxOccurs="1" />
                <xs:element name="transmitter" minOccurs="0" 
                          maxOccurs="unbounded" >
                  <xs:complexType>
                    <xs:sequence>
                      <xs:element name="code" minOccurs="1" maxOccurs="1" />
                      <xs:element name="eventid" minOccurs="1" maxOccurs="1" />
                    </xs:sequence>
                  </xs:complexType>
                </xs:element>
                <xs:element name="transmitbaseevent" minOccurs="0" 
                            maxOccurs="1" />
                <xs:element name="receivebaseevent" minOccurs="0" 
                            maxOccurs="1" />
                <xs:element name="code1startevent" minOccurs="0" 
                            maxOccurs="1" />
                <xs:element name="receiver" minOccurs="0" 
                          maxOccurs="unbounded" >
                  <xs:complexType>
                    <xs:sequence>
                      <xs:element name="code" minOccurs="1" maxOccurs="1" />
                      <xs:element name="eventid" minOccurs="1" maxOccurs="1" />
                    </xs:sequence>
                  </xs:complexType>
                </xs:element>
              </xs:sequence>
            </xs:complexType>
          </xs:element>
        </xs:sequence>
      </xs:complexType>
    </xs:element>
  </xs:schema>
   @endverbatim
 */

#endif // __OPENLCBDAEMONS_H

