#* 
#* ------------------------------------------------------------------
#* ParseXML.tcl - XML parser class
#* Created by Robert Heller on Mon Mar 11 12:55:33 2013
#* ------------------------------------------------------------------
#* Modification History: $Log: headerfile.text,v $
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Generic Project
#*     Copyright (C) 2010  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#* 

## @file ParseXML.tcl Parse XML and create a simple DOM tree.
#
# Contains two SNI types, one of which is a simple DOM element, used to
# hold XML elements.
#

## @addtogroup TclCommon
# @{


package require xml
package require snit

snit::type SimpleDOMElement {
## @brief A simple DOM element coded in Tcl using SNIT.
# This class implements a simplified DOM element, that implements the
# getElementsByTagName and getElementsById methods, along with accessors
# to get data, attributes, and children of XML elements.
#
# @param name Element name.  Generally \%\%AUTO\%\% is passed.
# @param _ Options:
# @arg -tag The element's tag.
# @arg -attributes The element's attributes.
# @arg -opts The element's options.
#
# @author Robert Heller \<heller\@deepsoft.com\>.
#

  option -tag
  option -attributes
  option -opts
  variable _data {}
  ## @privatesection The element's data.
  variable _children {}
  ## The element's children.

  constructor {args} {
    ## @publicsection The constructor. Just sets the options.
    $self configurelist $args
  }
  method children {} {
    ## Method to return the elements children.
    # @return The children.
    return $_children
  }
  method addchild {childnode} {
    ## Method to add a child node.
    # @param childnode The child node to add.
    lappend _children $childnode
  }
  method length {} {
    ## Method to return the number of children.
    # @return The number of children.
    return [llength $_children]
  }
  method data {} {
    ## Method to return the element's data.
    # @return The data.
    return $_data
  }
  method setdata {d} {
  ## Method to set the element's data.
  # @param d The new data.
    set _data $d
  }
  method display {{fp stdout} {indent {}}} {
  ## Method to display a node, along with its children, and a proper XML 
  # document.
  # @param fp Channel to write the display to.
  # @param indent The indentation to use.
  #

#    puts stderr "*** $self display $indent"
    if {[llength $_children] > 0} {
      puts $fp "$indent<$options(-tag)[_formattrlist $options(-attributes)]>"
#      puts stderr "*** $self display: \[lindex \$_children 0\] = [lindex $_children 0]"
      foreach child $_children {
#        puts stderr "*** $self display: child = $child"
	$child display $fp "$indent  "
      }
      puts $fp "$indent</$options(-tag)>"
    } elseif {$_data ne ""} {
      puts $fp "$indent<$options(-tag)[_formattrlist $options(-attributes)]>[_quoteXML $_data]</$options(-tag)>"
    } else {
      puts $fp "$indent<$options(-tag)[_formattrlist $options(-attributes)]/>"
    }
  }
  method attribute {attrname} {
    ## Method to return a selected attribute's value.
    # @param attrname The name of the attribute.
    # @return The attribute's value or the empty string.
    foreach {name value} $options(-attributes) {
      if {$attrname eq $name} {return $value}
    }
    return {}
  }
  method setAttribute {attrname {value {}}} {
      ## Method to set a selected attribute's value.
      # @param attrname The name of the attribute.
      # @param value The value to set. Default is the empty string.
      set ai [lsearch -exact $options(-attributes) $attrname]
      if {$ai < 0} {
          lappend options(-attributes) $attrname "$value"
      } else {
          incr ai
          lset options(-attributes) $ai "$value"
      }
  }
  method getElementsByTagName {thetag args} {
    ## Method to return all of the elements under this element with the 
    # specified tag name.
    # @param thetag The tag to match.
    # @return A list of element object with the matching tag.
    set result {}
    set depth [from args -depth -1]
    if {"$thetag" eq $options(-tag)} {
      lappend result $self
    }
    if {$depth == 0} {return $result}
    if {$depth > 0} {incr depth -1}
    foreach child $_children {
      set elts [$child getElementsByTagName $thetag -depth $depth]
      foreach e $elts {lappend result $e}
    }
    return $result
  }
  method getElementsById {theid} {
    ## Method to return all of the elements under this element with the
    # specified value of their id attribute.
    # @param theid The id value match.
    # @return A list of element object with the matching id value.
    set result {}
    if {[$self attribute id] eq $theid} {lappend result $self}
    foreach child $_children {
      set elts [$child  getElementsById $theid]
      foreach e $elts {lappend result $e}
    }
    return $result
  }
  method isChild {item} {
      ## Method to check if the item is a child of this node.
      # @param item The possible child.
      # @return True if item is a child, false otherwise.
      
      set i [lsearch -exact $_children $item]
      return [expr {$i >= 0}]
  }
  method getParent {item} {
      ## Method to get the parent of the item.
      # @param item The item to get the parent of.
      # @return The parent node or {} if none found.
      
      if {[$self isChild $item]} {
          return $self
      } else {
          foreach c $_children {
              set p [$c getParent item]
              if {$p ne {}} {return $p}
          }
          return {}
      }
  }
  method removeChild {item} {
      ## Method to remove item from the children of this node.
      # @param item The item to remove.
      
      set i [lsearch -exact $_children $item]
      if {$i < 0} {return {}}
      set _children [lreplace $_children $i $i]
      return {}
  }
  proc _formattrlist {attrs} {
    ## @provatesection Format a attribute list for inclusion in displayed XML.
    # @param attrs The attribute list as a alterning list of names and values.
    # @return A formatted and escaped attribute list string.
    set result {}
    foreach {name value} $attrs {
      append result " $name="
      append result {"}
      append result [_quoteXML $value]
      append result {"}
    }
    return $result
  }
  proc _quoteXML {text} {
    ## Escape text for inclusion in displayed XML.
    # @param text Unescaped string.
    # @return A properly escaped XML string.
    regsub -all {&} $text   {\&amp;} quoted
    regsub -all {<} $quoted {\&lt;} quoted
    regsub -all {>} $quoted {\&gt;} quoted
    regsub -all {'} $quoted {\&apos;} quoted
    regsub -all {"} $quoted {\&quot;} quoted
    return "$quoted"
  }
  typemethod validate {object} {
      ## @brief Validation typemethod.
      # Raises an error if its argument is not a SimpleDOMElement object.
      #
      # @param object The object to typecheck.
      # @return The object or raise an error.
      if {[catch {$object info type} thetype]} {
          error [_ "Not a %s: %s" $type $object]
      } elseif {$type ne $thetype} {
          error [_ "Not a %s: %s" $type $object]
      } else {
          return $object
      }
  }
}

snit::type ParseXML {
  ## @brief Class to hold an XML tree.
  # This class parses an XML string and stores the result as a DOM Element 
  # tree.
  #
  # @param name Generally \%\%AUTO\%\% is passed.
  # @param xml  The XML string.
  # @param _ Options. None at present.
  delegate method getElementsByTagName to rootnode
  delegate method getElementsById to rootnode
  component rootnode
  ## @privatesection The (dummy) root node.
  variable nodeStack [list]
  ## Temp variable used during parsing.
  constructor {xml args} {
    ## @publicsection The constructor parses the XML string and stores it as a child of the
    # rootnode component.
    # @param xml  The XML string.
    # @param _ Options. None at present.
    set p [xml::parser	-elementstartcommand [mymethod _elementstart] \
			-elementendcommand   [mymethod _elementend] \
			-characterdatacommand [mymethod _characterdata]]
    install rootnode using SimpleDOMElement %%AUTO%%
    set nodeStack [list $rootnode]
    if {[catch {$p parse $xml} errormessage]} {
        error "Cannot parse $xml: $errormessage"
    }
    $p free
  }
  method _elementstart {tag attrlist args} {
    ## @privatesection Callback called at the start of of XML element.
    # @param tag The element's tag.
    # @param attrlist The element's attribute list.
    # @param _ The element's options.
    
#    puts stderr "*** [list $self _elementstart $tag $attrlist $args]"
    set parent [lindex $nodeStack end]
    set node [SimpleDOMElement %%AUTO%% -tag $tag -attributes $attrlist \
					-opts $args]
    lappend nodeStack $node
    $parent addchild $node
  }
  method _elementend {tag args} {
    ## Callback called at the end of an XML element.
    # @param tag The element's tag.
    # @param _ The element's options.
    
#   puts stderr "*** $self _elementend $tag $args"
    set nodeStack [lrange $nodeStack 0 [expr {[llength $nodeStack] -2}]]
#   puts stderr "*** $self _elementend: nodeStack = $nodeStack"
  }
  method _characterdata {data} {
    ## Callback called with the text enclosed by an element.
    # @param data The text enclosed by an element.
#    puts stderr "*** $self _characterdata: nodeStack = $nodeStack"
    set curnode [lindex $nodeStack end]
    $curnode setdata $data
  }
  method displayTree {{fp stdout}} {
      ## @publicsection Display the XML tree.
      # @param fp The channel to write the display to.
    foreach child [$rootnode children] {
      $child display $fp
    }
  }
  typemethod validate {object} {
      ## @brief Validation typemethod.
      # Raises an error if its argument is not a ParseXML object.
      #
      # @param object The object to typecheck.
      # @return The object or raise an error.
      if {[catch {$object info type} thetype]} {
          error [_ "Not a %s: %s" $type $object]
      } elseif {$type ne $thetype} {
          error [_ "Not a %s: %s" $type $object]
      } else {
          return $object
      }
  }
}

## @}

package provide ParseXML 1.0.1
