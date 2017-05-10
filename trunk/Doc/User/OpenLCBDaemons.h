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
//  Last Modified : <170510.1120>
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
 * 
 * The Hub Daemons 
 * @latexonly
 * \footnote{In UNIX usage, a daemon is a non-interactive process running in
 * the background, usually (but not always) presenting some sort of connection
 * API (like a network socket) for other processes to connect to as a way of
 * aquiring some sort of service.}
 * @endlatexonly
 * create a virtual "wire" that connects multiple virtual nodes.  Each node is
 * a separately running process that has connected to the daemons network port.
 * The hub deamon reads LCC messages from each of its connections and then 
 * writes those messages out to one (if it is specificly addressed) or all (if 
 * it is a broadcast message) of its connections. It does not write the 
 * message back out to the connection the message came from.  It maintains a
 * routing table that maps source addresses (or aliases) with source 
 * connections.  Hub deamons are configured from their command line.  Mostly
 * this is the address to bind the port to and the port to bind (listen on).
 * By default the hub deamons bind only to localhost, the loopback network 
 * device.  This means that only virtual nodes running on the local machine
 * can connect and the resultant network is "private" and local to the local
 * machine.  Optionally, the bind host (-host) can be set to 0.0.0.0.  This
 * causes the daemon to bind to all available network interfaces and make 
 * itself generally available to the whole network.
 * @latexonly 
 * \footnote{If the machine has a network interface that is "public facing", 
 * this would make the daemon available on the public Internet.  You should be
 * careful, since the LCC system provides no partitular security features.}
 * @endlatexonly
 * 
 * 
 * There are two hub daemons that implement a OpenLCB network over Tcp/Ip and
 * connect CAN busses connected to different host computers connected via
 * Tcp/Ip over Ethernet.  These daemons are:
 *   @li @ref OpenLCBTcpHub The OpenLCBTcpHub daemon implememts the binary
 *   OpenLCB messaging protocol over Tcp/Ip.
 *   @li @ref OpenLCBGCTcpHub The OpenLCBGCTcpHub daemon implememts the OpenLCB
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
 *
 * There are several virtual nodes that implement OpenLCB nodes to provide
 * useful functions.  These daemons are:
 *   @li @ref OpenLCB_MRD2 The OpenLCB_MRD2 daemon implememts an OpenLCB node
 * that implements the EventExchange protocol for Azatrax MRD2 boards.
 *   @li @ref OpenLCB_PiGPIO The OpenLCB_PiGPIO daemon implememts an OpenLCB
 *   node that implements the EventExchange protocol for Raspberry Pi GPIO
 *   pins.
 *   @li @ref OpenLCB_PiMCP23008 The OpenLCB_PiMCP23008 daemon implememts an 
 *   OpenLCB node that implements the EventExchange protocol for the GPIO pins 
 *   on a MCP23008 I2C port expander connected to a Raspberry Pi.
 *   @li @ref OpenLCB_PiMCP23017 The OpenLCB_PiMCP23017 daemon implememts an 
 *   OpenLCB node that implements the EventExchange protocol for the GPIO pins
 *   on a MCP23017 I2C port expander connected to a Raspberry Pi.
 *   @li @ref OpenLCB_TrackCircuits The OpenLCB_TrackCircuits daemon implememts
 *   an OpenLCB node that implements virtual track circuit messaging logic
 *   using OpenLCB Events.
 *   @li @ref OpenLCB_Logic The OpenLCB_Login daemon implememts
 *   an OpenLCB node that implements logic blocks using OpenLCB Events.
 *   @li @ref OpenLCB_Acela The OpenLCB_Acela daemon implememts an OpenLCB node
 *   that implements EventExchange protocol for a CTIAcela network.
 * 
 * All of these programs normally run as non-interactive daemon processes and
 * use a configuration file in XML format to define the detailed operation of
 * the programs. This configuration file can either be hand edited or can be
 * edited by the programs themselves using the specific GUI configuration
 * editor built-in to each program.
 * 
 * Additionally, the @ref dispatcher_Reference "Dispatcher" program can 
 * generate Event Exchange based CTC panel programs that connects to a OpenLCB 
 * network as nodes and produces events in response to control elements and 
 * consumes events to update track work state and control element indicators.
 * 
 * Not only can these nodes interact with devices on a physical OpenLCB
 * network (such as a CAN bus), but also with each other over a virtual
 * OpenLCB network or even both at the same time.
 *
 * @subsection CommonNodeConfiguration Common Node Configuration
 *
 * All of the Virtual Nodes have these common configuration fields:
 * 
 * 
 *  - An identification section, containing fields for the user supplied name
 *    and description for the node.  These are free form text fields and can
 *    contain a name and description of the node.
 *  - A transport section, containing fields for a transport constructor and
 *    options for the transport constructor.  There are presently three 
 *    transports. There is a @b Select button next to the constructor field to 
 *    select the transport to use. The options for the transport constructor 
 *    can be selected with the @b Select button next to the transport options 
 *    field.  The three transports are: 
 *    - CANGridConnectOverUSBSerial: Grid Connect CAN over USBSerial
 *    - CANGridConnectOverTcp: Grid Connect CAN over Tcp
 *    - OpenLCBOverTcp: OpenLCB over Tcp
 * 
 * 
 * @subsection MRD2 EventExchange node for Azatrax MRD2 boards.
 * 
 * The OpenLCB_MRD2 daemon is used to tie one or more USB connected Azatrax
 * MRD2 boards to an OpenLCB network, tying event production to the Sense and
 * Latch inputs of each defined connected device and, for relay equiped
 * boards, event consumption to the Channel 1 and Channel 2 outputs of each
 * defined connected device.
 * 
 * In addition to the @ref CommonNodeConfiguration "Common Node Configuration" 
 * fields the OpenLCB_MRD2 daemon has a field for a polling interval in 
 * miliseconds, defaulting to 500.  This is the interval between polls of the 
 * MRD2 devices.  Then for each device there is a tab containing these fields:
 *  - description A textual description of the device.  This could be the name
 *    of the block it senses.
 *  - serial number The serial number of the device.  This is printed on a 
 *    sticker attached to the device.
 *  - sense 1 on The event to send when sense 1 is activated.
 *  - sense 1 off The event to send when sense 1 is deactivated.
 *  - sense 2 on The event to send when sense 2 is activated.
 *  - sense 2 off The event to send when sense 2 is deactivated.
 *  - latch 1 on The event to send when latch 1 is activated.
 *  - latch 1 off The event to send when latch 1 is deactivated.
 *  - latch 2 on The event to send when latch 2 is activated.
 *  - latch 2 off The event to send when latch 2 is deactivated.
 *  - set chan 1 The event that triggers setting channel 1.
 *  - set chan 2 The event that triggers setting channel 2.
 * 
 * @subsubsection MRD2_XMLSchema XML Schema for configuration files
 * 
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
            <xs:element name="identification" minOccurs="0" maxOccurs="1">
              <xs:annotation>
                <xs:documentation>
                  This is the node identification section.
                </xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="name" minOccurs="0" maxOccurs="1" />
                  <xs:element name="description" minOccurs="0" maxOccurs="1" />
                </xs:sequence>
              </xs:complexType></xs:complexType>
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
                  <xs:element name="latch1off" minOccurs="0" maxOccurs="1" />
                  <xs:element name="latch2on" minOccurs="0" maxOccurs="1" />
                  <xs:element name="latch2off" minOccurs="0" maxOccurs="1" />
                  <xs:element name="setchan1" minOccurs="0" maxOccurs="1" />
                  <xs:element name="setchan2" minOccurs="0" maxOccurs="1" />
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
 * In addition to the @ref CommonNodeConfiguration "Common Node Configuration" 
 * fields the OpenLCB_PiGPIO daemon has a field for a polling interval in 
 * miliseconds, defaulting to 500.  This is the interval between polls of the 
 * GPIO Pins.  Then for each pin there is a tab containing these fields:
 *  - description A textual description of the pin.
 *  - number The number of the pin.
 *  - mode The mode of the pin, one of disabled, in, out, high, low.
 *  - pin in 0 The event to send when the pin goes to 0.
 *  - pin in 1 The event to send when the pin goes to 1.
 *  - pin out 0 The event to set the pin to 0.
 *  - pin out 1 The event to set the pin to 1.
 *
 * @subsubsection PiGPIO_XMLSchema XML Schema for configuration files
 * 
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
            <xs:element name="identification" minOccurs="0" maxOccurs="1">
              <xs:annotation>
                <xs:documentation>
                  This is the node identification section.
                </xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="name" minOccurs="0" maxOccurs="1" />
                  <xs:element name="description" minOccurs="0" maxOccurs="1" />
                </xs:sequence>
              </xs:complexType></xs:complexType>
            </xs:element>
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
 * @subsection PiMCP23008 EventExchange node for MCP23008 GPIO pins.
 * 
 * The OpenLCB_PiMCP23008 daemon is used to tie one or more of a MCP23008's
 * GPIO pins to event production (input pins) or event consumption (output
 * pins).  A MCP23008 is a 8 bit I2C port expander that can be connected to
 * a Raspberry Pi.
 * 
 * In addition to the @ref CommonNodeConfiguration "Common Node Configuration" 
 * fields the OpenLCB_PiMCP23008 daemon has a field for a polling interval in 
 * miliseconds, defaulting to 500.  This is the interval between polls of the 
 * GPIO Pins.  There is also a field containing the low 3 bits of the address 
 * of the MCP23008's I2C address (the default is 7). Then for each pin there 
 * is a tab containing these fields:
 *  - description A textual description of the pin.
 *  - number The number of the pin.
 *  - mode The mode of the pin, one of disabled, in, out, high, low.
 *  - pin in 0 The event to send when the pin goes to 0.
 *  - pin in 1 The event to send when the pin goes to 1.
 *  - pin out 0 The event to set the pin to 0.
 *  - pin out 1 The event to set the pin to 1.
 *
 * @subsubsection PiMCP23008_XMLSchema XML Schema for configuration files
 * 
 * @verbatim
    <?xml version="1.0" ?>
    <?xml-stylesheet href="schema2xhtml.xsl" type="text/xsl" ?>
    <!-- XML Schema for OpenLCB_PiMCP23008 configuration files -->
    <xs:schema version="OpenLCB_PiMCP23008 1.0"
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <xs:element name="OpenLCB_PiMCP23008" minOccurs="1" maxOccurs="1">
        <xs:annotation>
          <xs:documentation>
            This is the configuration container for the OpenLCB_PiMCP23008 daemon.
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
            <xs:element name="identification" minOccurs="0" maxOccurs="1">
              <xs:annotation>
                <xs:documentation>
                  This is the node identification section.
                </xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="name" minOccurs="0" maxOccurs="1" />
                  <xs:element name="description" minOccurs="0" maxOccurs="1" />
                </xs:sequence>
              </xs:complexType></xs:complexType>
            </xs:element>
            <xs:element name="pollinterval" minOccurs="0" maxOccurs="1" />
            <xs:element name="i2caddress" minOccurs="0" maxOccurs="1" />
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
 * @subsection PiMCP23017 EventExchange node for MCP23017 GPIO pins.
 * 
 * The OpenLCB_PiMCP23017 daemon is used to tie one or more of a MCP23017's
 * GPIO pins to event production (input pins) or event consumption (output
 * pins).  A MCP23017 is a 16 bit I2C port expander that can be connected to
 * a Raspberry Pi.
 * 
 * In addition to the @ref CommonNodeConfiguration "Common Node Configuration" 
 * fields the OpenLCB_PiMCP23017 daemon has a field for a polling interval in 
 * miliseconds, defaulting to 500.  This is the interval between polls of the 
 * GPIO Pins.  There is also a field containing the low 3 bits of the address 
 * of the MCP23017's I2C address (the default is 7). Then for each pin there 
 * is a tab containing these fields:
 *  - description A textual description of the pin.
 *  - number The number of the pin.
 *  - mode The mode of the pin, one of disabled, in, out, high, low.
 *  - pin in 0 The event to send when the pin goes to 0.
 *  - pin in 1 The event to send when the pin goes to 1.
 *  - pin out 0 The event to set the pin to 0.
 *  - pin out 1 The event to set the pin to 1.
 *
 * @subsubsection PiMCP23017_XMLSchema XML Schema for configuration files
 * 
 * @verbatim
    <?xml version="1.0" ?>
    <?xml-stylesheet href="schema2xhtml.xsl" type="text/xsl" ?>
    <!-- XML Schema for OpenLCB_PiMCP23017 configuration files -->
    <xs:schema version="OpenLCB_PiMCP23017 1.0"
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <xs:element name="OpenLCB_PiMCP23017" minOccurs="1" maxOccurs="1">
        <xs:annotation>
          <xs:documentation>
            This is the configuration container for the OpenLCB_PiMCP23017 daemon.
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
            <xs:element name="identification" minOccurs="0" maxOccurs="1">
              <xs:annotation>
                <xs:documentation>
                  This is the node identification section.
                </xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="name" minOccurs="0" maxOccurs="1" />
                  <xs:element name="description" minOccurs="0" maxOccurs="1" />
                </xs:sequence>
              </xs:complexType></xs:complexType>
            </xs:element>
            <xs:element name="pollinterval" minOccurs="0" maxOccurs="1" />
            <xs:element name="i2caddress" minOccurs="0" maxOccurs="1" />
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
 * 
 * In addition to the @ref CommonNodeConfiguration "Common Node Configuration" 
 * fields the OpenLCB_TrackCircuits daemon has tabs for each track, containing
 * these fields:
 *  - Description A textual description of the track
 *  - Track Service Enabled or Disabled
 *  - Command tabs Zero or more command tabs which map a received event to a 
 *    track code.
 *  - Transmit Group Base Event The track code will be added to this event.
 *  - Receive Group Base Event This is the base track code reciever event.
 *  - Code 1 Start Event The event to send when a Code 1 Start occur.
 *  - Action tabs Zero or more action tabs which map an event to send when a
 *    track code received.
 * 
 * The track codes defined for transmitters and receivers are:
 * 
 *  - @c None No track code.
 *  - @c Code7 Clear
 *  - @c Code4 Advance Approach
 *  - @c Code3 Approach Limited
 *  - @c Code8 Approach Medium
 *  - @c Code2 Approach
 *  - @c Code9 Approach Slow
 *  - @c Code6 Accelerated Tumble Down
 *  - @c Code5_occupied Non-Vital (occupied)
 *  - @c Code5_normal Non-Vital (normal)
 *  - @c CodeM_failed Power/Lamp (failed)
 *  - @c CodeM_normal Power/Lamp (normal)
 *  .
 *
 * @subsubsection TrackCircuits_XMLSchema XML Schema for configuration files
 * 
 * @verbatim <?xml version="1.0" ?>
  <?xml-stylesheet href="schema2xhtml.xsl" type="text/xsl" ?> 
   <!-- XML Schema for OpenLCB_TrackCircuits configuration files --> 
   <xs:schema version="OpenLCB_TrackCircuits 1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> 
     <xs:element name="OpenLCB_TrackCircuits" minOccurs="1" maxOccurs="1">
       <xs:annotation>
         <xs:documentation>
           This is the configuration container for the OpenLCB_TrackCircuits 
           daemon. 
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
           <xs:element name="identification" minOccurs="0" maxOccurs="1">
              <xs:annotation>
                <xs:documentation>
                  This is the node identification section.
                </xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="name" minOccurs="0" maxOccurs="1" />
                  <xs:element name="description" minOccurs="0" maxOccurs="1" />
                </xs:sequence>
              </xs:complexType></xs:complexType>
           </xs:element>
           <xs:element name="track" minOccurs="0" maxOccurs="unbounded" > 
             <xs:annotation> 
               <xs:documentation> 
                 This defines one track. 
               </xs:documentation> 
             </xs:annotation> 
             <xs:complexType> 
               <xs:sequence>
                 <xs:element name="description" minOccurs="0" maxOccurs="1" /> 
                 <xs:element name="enabled" minOccurs="0" maxOccurs="1" />
                 <xs:element name="transmitter" minOccurs="0" 
                             maxOccurs="unbounded" > 
                   <xs:complexType>
                     <xs:sequence> 
                       <xs:element name="code" minOccurs="1" maxOccurs="1" />
                       <xs:element name="eventid" minOccurs="1" 
                                   maxOccurs="1" /> 
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
                       <xs:element name="eventid" minOccurs="1" 
                                   maxOccurs="1" /> 
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
 * 
 * @subsection Logic EventExchange node for logic blocks.
 * 
 * The OpenLCB_Logics daemon is used to implement one or more logic blocks. 
 * Each logic can be standalone or part of a mast or ladder group.
 * 
 * In addition to the @ref CommonNodeConfiguration "Common Node Configuration" 
 * fields the OpenLCB_Logic daemon has tabs for each logic block, containing
 * these fields:
 *  - Description A textual description of the track
 *  - The Group Type, one of @c single (Single or last), @c mast (Mast Group), 
 *    or @c ladder (Ladder Group). 
 *  - An event to set variable 1 true.
 *  - An event to set variable 1 false.
 *  - The logic function, one of @c and (V1 and V2), @c or (V1 or V2), 
 *    @c xor (V1 xor V2), @c andch (V1 and V2 change), 
 *    @c orch (V1 or V2 change), @c then (V1 then V2), or @c true.
 *  - An event to set variable 2 true.
 *  - An event to set variable 2 false.
 *  - The delay in miliseconds (0 means no delay).
 *  - Whether the delay is retriggerable.
 *  - Four (4) action tabs, each with a delay flag and an event.  
 *
 * @subsubsection Logic_XMLSchema XML Schema for configuration files
 * 
 * @verbatim <?xml version="1.0" ?>
  <?xml-stylesheet href="schema2xhtml.xsl" type="text/xsl" ?> 
   <!-- XML Schema for OpenLCB_Logic configuration files --> 
   <xs:schema version="OpenLCB_Logic 1.0" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> 
     <xs:element name="OpenLCB_Logic" minOccurs="1" maxOccurs="1">
       <xs:annotation>
         <xs:documentation>
           This is the configuration container for the OpenLCB_Logic 
           daemon. 
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
           <xs:element name="identification" minOccurs="0" maxOccurs="1">
              <xs:annotation>
                <xs:documentation>
                  This is the node identification section.
                </xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="name" minOccurs="0" maxOccurs="1" />
                  <xs:element name="description" minOccurs="0" maxOccurs="1" />
                </xs:sequence>
              </xs:complexType></xs:complexType>
           </xs:element>
           <xs:element name="logic" minOccurs="0" maxOccurs="unbounded" > 
             <xs:annotation> 
               <xs:documentation> 
                 This defines one logic block. 
               </xs:documentation> 
             </xs:annotation> 
             <xs:complexType> 
               <xs:sequence>
                 <xs:element name="description" minOccurs="0" maxOccurs="1" /> 
                 <xs:element name="grouptype" minOccurs="1" maxOccurs="1" />
                 <xs:element name="v1onevent" minOccurs="0" maxOccurs="1" />
                 <xs:element name="v1offevent" minOccurs="0" maxOccurs="1" />
                 <xs:element name="logicfunction" minOccurs="1" maxOccurs="1" />
                 <xs:element name="v2onevent" minOccurs="0" maxOccurs="1" />
                 <xs:element name="v2offevent" minOccurs="0" maxOccurs="1" />
                 <xs:element name="delay" minOccurs="0" maxOccurs="1" />
                 <xs:element name="retriggerable" minOccurs="0" maxOccurs="1" />
                 <xs:element name="action1delay" minOccurs="0" maxOccurs="1" />
                 <xs:element name="action1event" minOccurs="0" maxOccurs="1" />
                 <xs:element name="action2delay" minOccurs="0" maxOccurs="1" />
                 <xs:element name="action2event" minOccurs="0" maxOccurs="1" />
                 <xs:element name="action3delay" minOccurs="0" maxOccurs="1" />
                 <xs:element name="action3event" minOccurs="0" maxOccurs="1" />
                 <xs:element name="action4delay" minOccurs="0" maxOccurs="1" />
                 <xs:element name="action4event" minOccurs="0" maxOccurs="1" />
               </xs:sequence> 
             </xs:complexType> 
           </xs:element> 
         </xs:sequence>
       </xs:complexType> 
     </xs:element> 
   </xs:schema> 
   @endverbatim
 * 
 * @subsection Acela EventExchange node for a CTI Acela network.
 * 
 * The OpenLCB_Acela daemon is used to tie a CTI Acela network to an OpenLCB
 * network, tying event production to the inputs (sensors) and outputs
 * (controls and signals) connected to a CTI Acela network.
 * 
 * In addition to the @ref CommonNodeConfiguration "Common Node Configuration" 
 * fields the OpenLCB_Acels daemon has tabs for each Control, Signal, or 
 * Sensor.  Each type has a numerical address and a textual description.
 * 
 * You will want to read the "The Acela Network Bridge Programmer's Guide"
 * for an explaination of some of the terminolgy used here. 
 * 
 * In addition each Control has these fields:
 *   - Pulse Width in 10ths of a second.  Used with the Pulse on and Pulse off
 *     events.
 *   - Blink Period in 10ths of a second.  Used with the Blink and Reverse 
 *     Blink events.
 *   - Activate eventid
 *   - Deactivate eventid
 *   - Pulse on eventid
 *   - Pulse off eventid
 *   - Blink eventid
 *   - Reverse Blink eventid
 * 
 * In addition each Signal has these fields:
 *   - Signal command, one of Signal2, Signal3, or Signal4.
 *     Signal2 uses two consequential outputs and assumes a bi-color led 
 *     (red/green) and simulates yellow
 *     Signal3 uses three consequential outputs and assumes three descrete
 *     lamps or leds.
 *     Signal4 uses four consequential outputs and assumes four descrete lamps 
 *     or leds. 
 *   - Plus zero or more Aspect tabs.  Each Aspect tab has a event field and
 *     an argument list for a signal.  This 2 or 3 elements for Signal2, three 
 *     elements for Signal3 and four elements for Signal4.
 *     Eacl element defines one lamp or led and is one of: on, off, blink,
 *     revblink.
 * 
 * There are also three common fields for all signals:
 *   - Signal blink rate in 10ths of a second.
 *   - Yellow Hue
 *   - Signal brightless
 * 
 * In addition each sensor has these fields:
 *   - Filter Threshold
 *   - Filter Select
 *   - Polarity
 *   - The on eventid
 *   - The off eventid
 * 
 * @subsubsection Acela_XMLSchema XML Schema for configuration files
 * 
 * @verbatim
    <?xml version="1.0" ?>
    <?xml-stylesheet href="schema2xhtml.xsl" type="text/xsl" ?>
    <!-- XML Schema for OpenLCB_Acela configuration files -->
    <xs:schema version="OpenLCB_Acela 1.0"
       xmlns:xs="http://www.w3.org/2001/XMLSchema"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <xs:element name="OpenLCB_Acela" minOccurs="1" maxOccurs="1">
        <xs:annotation>
          <xs:documentation>
            This is the configuration container for the OpenLCB_Acela daemon.
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
            <xs:element name="identification" minOccurs="0" maxOccurs="1">
              <xs:annotation>
                <xs:documentation>
                  This is the node identification section.
                </xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="name" minOccurs="0" maxOccurs="1" />
                  <xs:element name="description" minOccurs="0" maxOccurs="1" />
                </xs:sequence>
              </xs:complexType></xs:complexType>
            </xs:element>
            <xs:element name="acelaport" minOccurs="1" maxOccurs="1" />
            <xs:element name="blinkrate" minOccurs="0" maxOccurs="1" />
            <xs:element name="yellowhue" minOccurs="0" maxOccurs="1" />
            <xs:element name="brightness" minOccurs="0" maxOccurs="1" />
            <xs:element name="control" minOccurs="0" maxOccurs="unbounded">
              <xs:annotation>
                <xs:documentation>
                  This defines one Control.
                </xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="address" minOccurs="1" maxOccurs="1" />
                  <xs:element name="description" minOccurs="0" maxOccurs="1" />
                  <xs:element name="pulsewidth" minOccurs="0" maxOccurs="1" />
                  <xs:element name="blinkperiod" minOccurs="0" maxOccurs="1" />
                  <xs:element name="activate" minOccurs="0" maxOccurs="1" />
                  <xs:element name="deactivate " minOccurs="0" maxOccurs="1" />
                  <xs:element name="pulseon " minOccurs="0" maxOccurs="1" />
                  <xs:element name="pulseoff " minOccurs="0" maxOccurs="1" />
                  <xs:element name="blink " minOccurs="0" maxOccurs="1" />
                  <xs:element name="revblink" minOccurs="0" maxOccurs="1" />
                </xs:sequence>
              </xs:complexType>
            </xs:element>
            <xs:element name="signal" minOccurs="0" maxOccurs="unbounded">
              <xs:annotation>
                <xs:documentation>
                  This defines one Signal.
                </xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="address" minOccurs="1" maxOccurs="1" />
                  <xs:element name="description" minOccurs="0" maxOccurs="1" />
                  <xs:element name="pulsewidth" minOccurs="0" maxOccurs="1" />
                  <xs:element name="aspect" minOccurs="0" 
                              maxOccurs="unbounded">
                    <xs:complexType>
                      <xs:sequence>
                        <xs:element name="eventid" minOccurs="0" 
                                    maxOccurs="1" />
                        <xs:element name="arglist" minOccurs="0" 
                                    maxOccurs="1" />
                      </xs:sequence>
                    </xs:complexType>
                  </xs:element>
                </xs:sequence>
              </xs:complexType>
            </xs:element>
            <xs:element name="sensor" minOccurs="0" maxOccurs="unbounded">
              <xs:annotation>
                <xs:documentation>
                  This defines one Sensor.
                </xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="address" minOccurs="1" maxOccurs="1" />
                  <xs:element name="description" minOccurs="0" maxOccurs="1" />
                  <xs:element name="filterthresh" minOccurs="0" 
                                                  maxOccurs="1" />
                  <xs:element name="filterselect" minOccurs="0" 
                                                  maxOccurs="1" />
                  <xs:element name="polarity" minOccurs="0" maxOccurs="1" />
                  <xs:element name="onevent" minOccurs="0" maxOccurs="1" />
                  <xs:element name="offevent" minOccurs="0" maxOccurs="1" />
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

