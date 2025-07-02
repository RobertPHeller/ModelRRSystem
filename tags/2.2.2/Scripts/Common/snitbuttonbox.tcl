##############################################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Mon May 20 10:03:07 2013
#  Last Modified : <220426.0947>
#
#  Description	
#
#  Notes
#
#  History
#	
##############################################################################
#
#  Copyright (c) 2013 Deepwoods Software.
# 
#  All Rights Reserved.
# 
#  This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
#  reproduced,  translated,  or  reduced to any  electronic  medium or machine
#  readable form without prior written consent from Deepwoods Software.
#
##############################################################################


snit::widget ButtonBox {
    hulltype ttk::frame
    widgetclass ButtonBox
    typeconstructor {
        ttk::style layout $type [ttk::style layout TFrame]
    }
    delegate option * to hull except {-class -style}
    variable buttons -array {}
    option -default -default {} -configuremethod _configDefault
    method _configDefault {option value} {
        if {[info exists options($option)] &&
            [winfo exists $win.$options($option)]} {
            $win.$options($option) configure -default normal
        }
        set options($option) $value
        if {[winfo exists $win.$options($option)]} {
            $win.$options($option) configure -default active
        }
    }
                                                    
    option -orient -default horizontal \
          -type {snit::enum -values {horizontal vertical}}
    option -buttonalignment -default center \
          -type {snit::enum -values {left center right}}
    constructor {args} {
        $hull configure -style $type
        $self configurelist $args
    }
    option -state -default normal \
          -type {snit::enum -values {normal disabled}} \
          -configuremethod _configState
    method _configState {option value} {
        set options($option) $value
        foreach b [array names buttons] {
            catch {$buttons($b) configure -state $value}
        }
    }
    method add {const name args} {
        switch $options(-orient) {
            horizontal {
                set side left
                switch $options(-buttonalignment) {
                    left {
                        set anchor w
                    }
                    center {
                        set anchor center
                    }
                    right {
                        set anchor e
                    }
                }
            }
            vertical {
                set side top
                switch $options(-buttonalignment) {
                    left {
                        set anchor n
                    }
                    center {
                        set anchor center
                    }
                    right {
                        set anchor s
                    }
                }
            }
        }
        set buttons($name) [eval [list $const $win.$name] $args]
        pack $buttons($name) -side $side -anchor $anchor
        #$buttons($name) configure -state $options(-state)
        if {$options(-default) eq $name} {
            $buttons($name) configure -default active
        }
        return $buttons($name)
    }
    method itemconfigure {name args} {
        if {[winfo exists $win.$name]} {
            return [eval [list $win.$name configure] $args]
        }
        return {}
    }
    method itemcget {name option} {
        if {[winfo exists $win.$name]} {
            return [$win.$name cget $option]
        }
        return {}
    }
    method invoke {name} {
        if {[winfo exists $win.$name]} {
            return [$win.$name invoke]
        } elseif {$name eq "default" &&
            [info exists options(-default)] &&
            [winfo exists $win.$options(-default)]} {
            return [$win.$options(-default) invoke]
        }
        return {}
    }
    method setfocus {name} {
        if {[winfo exists $win.$name]} {
            focus $win.$name
        } elseif {$name eq "default" &&
            [info exists options(-default)] &&
            [winfo exists $win.$options(-default)]} {
            focus $win.$options(-default)
        }
    }
}

package provide ButtonBox 1.0
        
