#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Fri Dec 6 10:51:17 2024
#  Last Modified : <250213.2111>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
## @copyright
#    Copyright (C) 2024  Robert Heller D/B/A Deepwoods Software
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
# @file LCCTrafficMonitor.tcl
# @author Robert Heller
# @date Fri Dec 6 10:51:17 2024
# 
#
#*****************************************************************************


package require gettext
package require Tk
package require tile
package require snit
package require LCC
package require ScrollWindow
package require ROText

snit::widget LCCTrafficMonitor {
    ## @brief Generate LCC Traffic Monitor Window.
    # Create a toplevel to display LCC traffic.
    #
    # Note: only one such window is allowed.
    # @param Options:
    # @arg -transport The transport to display traffic on.
    # @arg -menu  Delegated to the toplevel
    # @arg -class Delegated to the toplevel
    # @arg -debugprint A function to handle debug output.

    hulltype tk::toplevel
    widgetclass LCCTrafficMonitor
    
    delegate option -class to hull
    delegate option -menu to hull
    component main
    ## @privatesection Main Frame.
    component scroll
    ## Scrolled Window.
    component logwindow
    ## Log window
    component buttonframe
    ## Button Frame
    component autoscrolling
    ## Autoscrolling checkbutton
    component startstoplogging
    ## Start/Stop Logging button
    component clearlog
    ## Clear log window
    component savelog
    ## Save log
    typevariable TrafficMonitorWindow {}
    ## flag to prevent multiple Traffic Monitors.
    option -transport -readonly yes -default {}
    option -debugprint -readonly yes -default {}
    typevariable _menu {
        "[_m {Menu|&File}]" {file:menu} {file} 0 {
            {command "[_m {Menu|File|&Close}]" {file:close} "[_ {Close the editor}]" {Ctrl c} -command "[mymethod _close]"}
        } "[_m {Menu|&Edit}]" {edit} {edit} 0 {
            {command "[_m {Menu|Edit|Cu&t}]" {edit:cut edit:havesel} "[_ {Cut selection to the paste buffer}]" {Ctrl x} -command {StdMenuBar EditCut} -state disabled}
            {command "[_m {Menu|Edit|&Copy}]" {edit:copy edit:havesel} "[_ {Copy selection to the paste buffer}]" {Ctrl c} -command {StdMenuBar EditCopy} -state disabled}
            {command "[_m {Menu|Edit|&Paste}]" {edit:paste} "[_ {Paste selection from the paste buffer}]" {Ctrl c} -command {StdMenuBar EditPaste}}
            {command "[_m {Menu|Edit|C&lear}]" {edit:clear edit:havesel} "[_ {Clear selection}]" {} -command {StdMenuBar EditClear} -state disabled}
            {command "[_m {Menu|Edit|&Delete}]" {edit:delete edit:havesel} "[_ {Delete selection}]" {Ctrl d}  -command {StdMenuBar EditClear} -state disabled}
            {separator}
            {command "[_m {Menu|Edit|Select All}]" {edit:selectall} "[_ {Select everything}]" {} -command {StdMenuBar EditSelectAll}}
            {command "[_m {Menu|Edit|De-select All}]" {edit:deselectall edit:havesel} "[_ {Select nothing}]" {} -command {StdMenuBar EditSelectNone} -state disabled}
        }
    }
    ## Generic menu.
            
    method putdebug {message} {
        ## Print message using debug output, if any.
        #
        # @param message The message to print.
        
        set debugout [$self cget -debugprint]
        if {$debugout ne ""} {
            uplevel #0 [list $debugout "$message"]
        }
    }
    
    constructor {args} {
        ## @publicsection @brief Constructor: create the LCC Traffic
        # Monitor window.  The window is created from the toplevel up.
        #
        # Only one such window is allowed.
        #
        # @param name Widget path.
        # @param ... Options:
        # @arg -transport The transport to display traffic on.
        # @arg -menu  Delegated to the toplevel
        # @arg -class Delegated to the toplevel
        # @arg -debugprint A function to handle debug output.
        # @par
        
        if {$TrafficMonitorWindow ne {}} {
            tk_messageBox \
                  -message [_ "Only one LCC Traffic Monitor Allowed!"] \
                  -type ok -icon error
            destroy $win
            return
        }
        set TrafficMonitorWindow $win
        if {[lsearch $args -transport] < 0} {
            error [_ "The -transport option is required!"]
        }
        $self putdebug "*** $type create $self: win = $win, about to wm protocol $win WM_DELETE_WINDOW ..."
        wm protocol $win WM_DELETE_WINDOW [mymethod _close]
        install main using MainFrame $win.main -menu [subst $_menu] \
              -textvariable [myvar statusline]
        pack $main -expand yes -fill both
        set f [$main getframe]
        install scroll using ScrolledWindow $f.scroll -scrollbar both \
              -auto both
        pack $scroll -expand yes -fill both
        install logwindow using ROText [$scroll getframe].logwindow -wrap none
        $scroll setwidget $logwindow
        install buttonframe using ttk::frame $f.buttonframe
        pack $buttonframe -expand yes -fill x
        install autoscrolling using ttk::checkbutton \
              $buttonframe.autoscrolling \
              -text [_m "Label|Button|Autoscrolling"] -offvalue no -onvalue yes \
              -variable [myvar _autoScroll]
        pack $autoscrolling -side left
        install startstoplogging using ttk::button \
              $buttonframe.startstoplogging \
              -text [_m "Label|Button|Stop Logging"] \
              -command [mymethod _startStopLogging]
        pack $startstoplogging -side left
        install clearlog using ttk::button \
              $buttonframe.clearlog \
              -text [_m "Label|Button|Clear Log Window"] \
              -command [list $logwindow delete 1.0 end]
        pack $clearlog -side left
        install savelog using ttk::button \
              $buttonframe.savelog \
              -text [_m "Label|Button|Save Log Window"] \
              -command [mymethod _savelog]
        pack $savelog -side left
        $self configurelist $args
        wm title $win [_ "LCC Traffic Monitor"]
        $self enablelogging
    }
    method enablelogging {} {
        $options(-transport) configure \
              -logmessagehandler [mymethod _logmessagehandler] \
              -promisciousmode yes
        $startstoplogging configure -text [_m "Label|Button|Stop Logging"]
    }
    method disablelogging {} {
        $self putdebug "*** $self disablelogging: options(-transport) is '$options(-transport)'"
        $options(-transport) configure \
              -logmessagehandler {} -promisciousmode no
        $startstoplogging configure -text [_m "Label|Button|Start Logging"]
    }
    destructor {
        set TrafficMonitorWindow {}
        catch {$self disablelogging}
    }
    method _close {} {
        catch {$self disablelogging}
        wm withdraw $win
    }
    method _savelog {} {
        set outfile [tk_getSaveFile -defaultextension {.log} \
                     -filetypes  { 
                     {{Log files} {.log} }
                     {{All Files} *      } } \
                       -initialfile {lcc.log} \
                       -title "File to save log in"]
        if {$outfile eq {}} {return}
        if {[catch {open $outfile w} fp]} {
            tk_messageBox -type ok -icon error \
                  -message [_ "Could not open %s: %s" $outfile $fp]
            return
        }
        puts $fp [$logwindow get 1.0 end-1c]
        close $fp
    }
    method _startStopLogging {} {
        if {[$options(-transport) cget -logmessagehandler] eq {}} {
            $self enablelogging
        } else {
            $self disablelogging
        }
    }
    typemethod Open {args} {
        if {$TrafficMonitorWindow eq {}} {
            $type {*}$args
        } else {
            wm deiconify $TrafficMonitorWindow
            $TrafficMonitorWindow enablelogging
        }
    }
    variable _autoScroll yes
    method _logmessagehandler {message} {
        #$self putdebug "*** $self _logmessagehandler [$message toString]"
        if {[$message cget -sourcenid] eq [$options(-transport) cget -nid]} {
            $logwindow insert end "S: "
        } else {
            $logwindow insert end "R: "
        }
        $logwindow insert end [$message cget -sourcenid]
        if {[$message cget -destnid] ne {}} {
            $logwindow insert end [format { - %s} [$message cget -destnid]]
        } else {
            $logwindow insert end { - [BROADCAST]}
        }
        $logwindow insert end " [MTI_Name [$message cget -mti]]"
        if {([$message cget -mti] & 0x04) != 0} {
            $logwindow insert end [format { Eventid: %s} [[$message cget -eventid] cget -eventidstring]]
        }
        foreach db [$message cget -data] {
            $logwindow insert end [format { %02x} $db]
        }
        $logwindow insert end "\n"
        if {$_autoScroll} {$logwindow see end}
    }
    proc MTI_Name {mti} {
        switch [format {0x%04X} $mti] {
            0x0100 {return "Initialization complete"}
            0x0488 {return "Verify a Node ID"}
            0x0490 {return "Verify a Node ID globally"}
            0x0170 {return "Respond to a verify Node ID request"}
            0x0068 {return "Rejected request"}
            0x00A8 {return "Terminate due to some error"}
            0x0828 {return "Inquire on supported protocols"}
            0x0668 {return "Reply with supported protocols"}
            0x08F4 {return "Query about consumers"}
            0x04A4 {return "Consumer broadcast about a range of consumers"}
            0x04C7 {return "Consumer broadcast, validity unknown"}
            0x04C4 {return "Consumer broadcast, valid state"}
            0x04C5 {return "Consumer broadcast, invalid state"}
            0x04C6 {return "Reserved for future use"}
            0x0914 {return "Query about producers"}
            0x0524 {return "Producer broadcast about a range of producers"}
            0x0547 {return "Producer broadcast, validity unknown"}
            0x0544 {return "Producer broadcast, valid state"}
            0x0545 {return "Producer broadcast, invalid state"}
            0x0546 {return "Reserved for future use"}
            0x0968 {return "Request identify all of a node's events"}
            0x0970 {return "Request identify all of every node's events"}
            0x0594 {return "Learn event"}
            0x05B4 {return "Event report"}
            0x05EB {return "Traction control command"}
            0x01E9 {return "Traction control reply"}
            0x05EA {return "Traction proxy command"}
            0x01E8 {return "Traction proxy reply"}
            0x09C0 {return "Xpressnet"}
            0x0DE8 {return "Request node identity"}
            0x0A08 {return "Node identity reply"}
            0x1C48 {return "Datagram"}
            0x0A28 {return "Datagram received okay"}
            0x0A48 {return "Datagram rejected by receiver"}
            0x0CC8 {return "Stream initiate request"}
            0x0868 {return "Stream initiate reply"}
            0x1F88 {return "Stream data"}
            0x0888 {return "Stream flow control"}
            0x08A8 {return "Stream terminate connection"}
            default {return [format {Unknown: 0x%04x} $mti]}
        }
    }
}


package provide LCCTrafficMonitor 1.0
            
    
