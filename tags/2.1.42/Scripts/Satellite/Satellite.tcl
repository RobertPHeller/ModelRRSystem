#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Thu Jun 11 15:26:40 2015
#  Last Modified : <150612.0924>
#
#  Description	
#
#  Notes
#
#  History
#	
#****************************************************************************
#
#    Copyright (C) 2015  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
#***************************************************************************

## @defgroup SatelliteModule SatelliteModule
# @brief Satellite master client
#
# This Tcl SNIT class interfaces with SatelliteDaemon processes (daemons) 
# running on slave computers (usually Raspberry Pis).
#
# @author Robert Heller \<heller\@deepsoft.com\>                                
#                                                                               
# @{


package require snit

snit::type Satellite {
    ## @brief Satellite class.
    #
    # This class implements the interface logic to connect to a Satellite
    # daemon running on a slave computer.
    #
    # @param hostname The name or address of the slave.
    # @param ... Options:
    # @arg -port The port to use to connect.  Readonly, default is 40000.
    # @par
    # @author Robert Heller \<heller\@deepsoft.com\>
    #
    option -port -default 40000 -type {snit::integer -min 1 -max 65535} -readonly yes
    variable socket
    ## @privatesection The connection socket.
    constructor {hostname args} {
        ## @publicsection Construct Satellite connection.
        # @param hostname The name or address of the slave.
        # @param ... Options:
        # @arg -port The port to use to connect.  Readonly, default is 40000.
        # @par
        $self configurelist $args
        set socket [socket $hostname $options(-port)]
    }
    method remoteeval {args} {
        ## Method to run a remote command.
        # @param ... Command list.
        # @returns The result of the remote command.
        puts $socket $args
        flush $socket
        return [gets $socket]
    }
    destructor {
        ## Clean up all data objects and free up all resources.
        puts $socket "exit"
        flush $socket
        close $socket
    }
}

## @}

package provide Satellite 1.0
