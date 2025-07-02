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
#  Last Modified : <220810.1236>
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
package require ROText
package require ScrollWindow
package require ButtonBox
package require LCC

namespace eval lcc {
    ## 
    # @section EventDialogs Package provided
    #
    # EventDialogs 1.0
    
    snit::widget EventLog {
        ## Event received log, with event sender.
        #
        # Options:
        # @arg -transport The transport to use.
        # @par
        
        option -transport -readonly yes -default {}
        option -localeventhandler -readonly yes -default {}
        hulltype toplevel
        component logscroll
        ## @privatesection Log Scroll Widget.
        component logtext
        ## Log text Widget (readonly).
        component sendevent
        ## Send event entry
        
        constructor {args} {
            ## @publicsection @brief Construct an EventLog widget.
            # This is a toplevel window with a scrolling log of received 
            # events.  There is also an entry to send an event.
            #
            # @param ... Options:
            # @arg -transport The transport to use.
            # @par
            
            wm protocol $win WM_DELETE_WINDOW [mymethod _close]
            wm title  $win [_ "OpenLCB Event Log"]
            wm transient $win [winfo toplevel [winfo parent $win]]
            install logscroll using ScrolledWindow $win.logscroll \
                  -scrollbar vertical -auto vertical
            pack $logscroll -expand yes -fill both
            install logtext using ROText [$logscroll getframe].logtext
            $logscroll setwidget $logtext
            set sendeventLF [LabelFrame $win.sendevent \
                  -text [_m "Label|Send Event:"]]
            pack $sendeventLF -fill x
            install sendevent using ttk::entry [$sendeventLF getframe].e
            pack $sendevent -side left -fill x -expand yes
            set sendevent_button [ttk::button [$sendeventLF getframe].b \
                                  -text [_m "Label|Send"] \
                                  -command [mymethod _sendtheevent]]
            bind $sendevent <Return> [list $sendevent_button invoke]
            pack $sendevent_button -side right
            set bbox [ButtonBox $win.bbox -orient horizontal]
            pack $bbox -fill x -expand yes
            $bbox add ttk::button close -text [_m "Label|Close"] \
                  -command [mymethod _close]
            $bbox add ttk::button clear -text [_m "Label|Clear"] \
                  -command [mymethod _clear]
            $self configurelist $args
            focus $sendevent
        }
        method open {} {
            ## Open window
            
            wm deiconify $win
            focus $sendevent
        }
        method eventReceived {eventid} {
            ## Log a received event.
            #
            # @param eventid EventID object to log.
            #
            
            EventID validate $eventid
            $logtext insert end "[$eventid cget -eventidstring]\n"
        }
        method _sendtheevent {} {
            ## @privatesection Send an event.
            #
            
            set transport [$self cget -transport]
            set localeventhandler [$self cget -localeventhandler]
            set eventtosend [$sendevent get]
            if {$transport ne "" || $localeventhandler ne ""} {
                if {[catch {lcc::EventID %AUTO% -eventidstring $eventtosend} eventid]} {
                    tk_message -type ok -icon error -message \
                          [_ "Misformatted event id: %s" $eventtosend]
                    return
                }
            }
            if {$transport ne ""} {
                $transport ProduceEvent $eventid
            }
            if {$localeventhandler ne ""} {
                uplevel #0 "$localeventhandler $eventid"
            }
            $eventid destroy
        }
        method _close {} {
            ## Close the window.
            
            wm withdraw $win
        }
        method _clear {} {
            ## Clear the log.
            
            $logtext delete 1.0 end
        }
    }
    
    snit::widgetadaptor EventReceived {
        ## Display a received event.
        # 
        # Options:
        # @arg -eventid The event id -- this is required.
        # @par
        
        component eventid
        ## @privatesection LabelEntry (RO) containing the eventId.
        option -eventid -readonly yes -type lcc::EventID
        constructor {args} {
            ## @publicsection Construct an EventReceived dialog.
            #
            # @param name The widget path.
            # @param ... The options:
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
            install eventid using LabelEntry $dframe.eventid \
                  -label [_m "Label|Event ID:"] \
                  -text [[$self cget -eventid] cget -eventidstring] \
                  -editable no
            pack $eventid -fill x
            $hull draw
        }
        method _Close {} {
            ## Close and destroy the dialog box.
            destroy $win
        }
    }
    snit::widgetadaptor SendEvent {
        ## Send Event Dialog -- send PCRE message.
        #
        # Options:
        # @arg -transport The transport to use.
        # @par
        
        delegate method draw to hull
        component eventid
        ## @privatesection LabelEntry containing the eventId.
        option -transport -readonly yes -default {}
        constructor {args} {
            ## @publicsection Construct a SendEvent dialog.
            #
            # @param name Pathname of the widget.
            # @param ... Options:
            # @arg -transport LCC Transport object.
            # @par
            
            installhull using Dialog -separator 0 \
                  -modal none -parent . -place center \
                  -side bottom \
                  -title {Configuration R/W Tool 00:00:00:00:00:00} \
                  -transient 1 -anchor e \
                  -class ConfigMemory
            $hull add close -text Close -underline 0 -command [mymethod _Close]
            $hull add send  -text Send  -underline 0 -command [mymethod _Send]
            if {[lsearch $args -transport] < 0} {
                error [_ "The -transport option is required!"]
            }
            $self configurelist $args
            set dframe [$hull getframe]
            install eventid using LabelEntry $dframe.eventid \
                  -label [_m "Label|Event ID:"] \
                  -text "00.00.00.00.00.00.00.00" \
                  -editable yes
            pack $eventid -fill x
            $hull draw
        }
        method _Close {} {
            ## Close the window.
            
            $hull withdraw
        }
        method _Send {} {
            ## @brief Bound to the @c Send button.
            # Send an event.
            
            [$self cget -transport] ProduceEvent [lcc::EventID %AUTO% -eventidstring [$eventid cget -text]]
        }
            
            
    }
    
}

package provide EventDialogs 1.0
