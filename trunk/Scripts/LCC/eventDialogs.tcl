#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Thu Mar 3 14:36:20 2016
#  Last Modified : <160303.1641>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2016  Robert Heller D/B/A Deepwoods Software
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
#*****************************************************************************


package require Tk
package require tile
package require snit
package require Dialog
package require LabelFrames
package require LCC

namespace eval lcc {
    ## 
    # @section EventDialogs Package provided
    #
    # EventDialogs 1.0
    
    snit::widgetadaptor EventReceived {
        ## Display a received event.
        # 
        # Options:
        # @arg -srcid The source address.
        # @arg -eventid The event id -- this is required.
        # @par
        
        component source
        ## @privatesection LabelEntry (RO) containing the source address
        component eventid
        ## LabelEntry (RO) containing the eventId
        option -srcid -readonly yes -type lcc::nid -default 00:00:00:00:00:00
        option -eventid -readonly yes -type lcc::EventID
        constructor {args} {
            ## @publicsection Construct an EventReceived dialog.
            #
            # @param name The widget path.
            # @param ... The options:
            # @arg -srcid The source address.
            # @arg -eventid The event id -- this is required.
            # @par
            
            if {![info exists options(-eventid)]} {
                error [_ "The -eventid option is required!"]
            }
            installhull using Dialog -separator 0 \
                  -modal none -parent . -place center \
                  -side bottom -title {Event Received} \
                  -transient 1 -anchor e \
                  -class EventReceived
            $hull add close -text Close -underline 0 -command [mymethod _Close]
            $self configurelist $args
            set dframe [$hull getframe]
            install source using LabelEntry $dframe.source \
                  -label "Source Address: " -text [$self cget -srcid] \
                  -editable no
            pack $source -fill x
            install eventid using LabelEntry $dframe.eventid \
                  -label "Event ID: " -text [[$self cget -eventid] cget -eventidstring] \
                  -editable no
            pack $eventid -fill x
            $hull draw
        }
        method _Close {} {
            destroy $win
        }
    }
    snit::widgetadaptor SendEvent {
    }
    
}

package provide EventDialogs 1.0
