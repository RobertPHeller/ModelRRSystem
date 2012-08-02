#* 
#* ------------------------------------------------------------------
#* BWHelp.tcl - BWidget based Hierarchical Hyper Help Dialog
#* Created by Robert Heller on Wed Feb  8 22:07:30 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2007/02/01 20:00:53  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.1  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.3  2006/02/10 01:01:26  heller
#* Modification History: Final lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/02/09 14:55:00  heller
#* Modification History: Lockdown / transfer
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#* Copyright (c) 2006, Robert Heller
#* All rights reserved.
#* 
#* Redistribution and use in source and binary forms, with or without
#* modification, are permitted provided that the following conditions are
#* met:
#* 
#*     * Redistributions of source code must retain the above copyright
#*       notice, this list of conditions and the following disclaimer.
#*     * Redistributions in binary form must reproduce the above copyright
#*       notice, this list of conditions and the following disclaimer in the
#*       documentation and/or other materials provided with the distribution.
#*     * Neither the name of the Deepwoods Software nor the names of its
#*       contributors may be used to endorse or promote products derived from
#*       this software without specific prior written permission.
#* 
#* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
#* IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
#* TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
#* PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#* OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#* 
#* 

#@Chapter:BWHelp.tcl--BWidget based Hierarchical Hyper Help Dialog
#@Label:BWHelp.tcl
# $Id$
# This file contains code that implements a BWidget based Hierarchical Hyper 
# Help Dialog, sort of a cross between simple HTML and VMS Help.
#

package require BWidget

global HelpDir
# This is the path to the help file directory.  It is computed from
# the script library directory.
# [index] HelpDir!global variable

namespace eval BWHelp {
  Widget::define BWHelp BWHelp -classonly Dialog Tree ScrolledWindow \
		PanedWindow LabelEntry Label

  Widget::tkinclude BWHelp text .frame.panes.f1.frame.textscroll.text \
	rename {-width -textwidth} \
	remove {-relief -borderwidth -bd -height -background} \
	initialize {-relief sunken -borderwidth 2} \

  Widget::bwinclude BWHelp ScrolledWindow .frame.panes.f1.frame.textscroll \
       remove {-scrollbar -auto -sides -size -relief -borderwidth -bd 
		-background} \
       initialize {-relief sunken -borderwidth 2 
		   -scrollbar vertical -auto vertical} \

  Widget::bwinclude BWHelp Tree .frame.panes.f0.frame.treescroll.tree \
	rename {-width -treewidth} \
	remove {-closecmd -crossfill -crossclosebitmap -crosscloseimage
		-crossopenbitmap -crossopenimage -deltax -deltay -dragenabled
		-dragendcmd -dragevent -draginitcmd -dragtype -dropcmd
		-dropenabled -dropovercmd -dropovermode -droptypes -height
		-linesfill -linestipple -opencmd -padx -redraw -selectcommand
		-selectfill -showlines -background} \

  Widget::bwinclude BWHelp ScrolledWindow .frame.panes.f0.frame.treescroll \
	remove {-scrollbar -auto -sides -size -relief -borderwidth -bd 
		-background} \
	initialize {-relief sunken -borderwidth 2
		    -scrollbar both -auto both} \

  Widget::bwinclude BWHelp PanedWindow .frame.panes \
  	include {-width} \
	remove {-side -background} \
	initialize {-side top} \

  Widget::bwinclude BWHelp Label .frame.status \
	remove {-width -justify -anchor -relief -borderwidth -bd -background} \
	initialize {-relief flat -borderwidth 2 -anchor w -justify left} \

#  Widget::bwinclude BWHelp Dialog  \
#	remove {-modal -parent -transient -side -place -homogeneous -cancel 
#		-default -image -bitmap -title -separator} \
#	initialize {-modal 1 -parent . -transient 1 
#		    -side bottom -place center -homogeneous 1 -separator 0
#		    -title {Help}} \
#

	

  proc use {} {}


  

  variable _helpWindow ".helpWindow"

  Widget::init BWHelp $_helpWindow {}

  variable _helpWindow_TopicTree
  variable _helpWindow_Text
  variable _helpWindow_ModeStatus
  variable _helpWindow_Command


  variable _hLinePattern
  # This is the help file pattern to pick up a help header line.

  set _hLinePattern {^([0-9]+)[ 	](.*)$}

  variable _helpHistoryList
  # This is the help history list.

  set _helpHistoryList {}

  variable _helpHistoryListIndex
  # This is the help history index.

  set _helpHistoryListIndex -1

  variable _helpWindowInput 0

  variable _xmTrackingLocateInfo

  namespace export HelpTopic
  namespace export HelpContext
  namespace export HelpWindow
  namespace export GetTopLevelOfFocus

  bind HelpText <1> {
    tk::TextButton1 %W %x %y
    %W tag remove sel 0.0 end
  }
  bind HelpText <B1-Motion> {
    set tk::Priv(x) %x
    set tk::Priv(y) %y
    tk::TextSelectTo %W %x %y
  }
  bind HelpText <Double-1> {
    set tk::Priv(selectMode) word
    tk::TextSelectTo %W %x %y
    catch {%W mark set insert sel.first}
  }
  bind HelpText <Triple-1> {
    set tk::Priv(selectMode) line
    tk::TextSelectTo %W %x %y
    catch {%W mark set insert sel.first}
  }
  bind HelpText <Shift-1> {
    tk::TextResetAnchor %W @%x,%y
    set tk::Priv(selectMode) char
    tk::TextSelectTo %W %x %y
  }
  bind HelpText <Double-Shift-1>	{
    set tk::Priv(selectMode) word
    tk::TextSelectTo %W %x %y
  }
  bind HelpText <Triple-Shift-1>	{
    set tk::Priv(selectMode) line
    tk::TextSelectTo %W %x %y
  }
  bind HelpText <B1-Leave> {
    set tk::Priv(x) %x
    set tk::Priv(y) %y
    tk::TextAutoScan %W
  }
  bind HelpText <B1-Enter> {
    tk::CancelRepeat
  }
  bind HelpText <ButtonRelease-1> {
    tk::CancelRepeat
  }
  bind HelpText <Control-1> {
    %W mark set insert @%x,%y
  }
  bind HelpText <Left> {
    tk::TextSetCursor %W insert-1c
  }
  bind HelpText <Right> {
    tk::TextSetCursor %W insert+1c
  }
  bind HelpText <Up> {
    tk::TextSetCursor %W [tk::TextUpDownLine %W -1]
  }
  bind HelpText <Down> {
    tk::TextSetCursor %W [tk::TextUpDownLine %W 1]
  }
  bind HelpText <Shift-Left> {
    tk::TextKeySelect %W [%W index {insert - 1c}]
  }
  bind HelpText <Shift-Right> {
    tk::TextKeySelect %W [%W index {insert + 1c}]
  }
  bind HelpText <Shift-Up> {
    tk::TextKeySelect %W [tk::TextUpDownLine %W -1]
  }
  bind HelpText <Shift-Down> {
    tk::TextKeySelect %W [tk::TextUpDownLine %W 1]
  }
  bind HelpText <Control-Left> {
    tk::TextSetCursor %W [tk::TextPrevPos %W insert tcl_startOfPreviousWord]
  }
  bind HelpText <Control-Right> {
    tk::TextSetCursor %W [tk::TextNextWord %W insert]
  }
  bind HelpText <Control-Up> {
    tk::TextSetCursor %W [tk::TextPrevPara %W insert]
  }
  bind HelpText <Control-Down> {
    tk::TextSetCursor %W [tk::TextNextPara %W insert]
  }
  bind HelpText <Shift-Control-Left> {
    tk::TextKeySelect %W [tk::TextPrevPos %W insert tcl_startOfPreviousWord]
  }
  bind HelpText <Shift-Control-Right> {
    tk::TextKeySelect %W [tk::TextNextWord %W insert]
  }
  bind HelpText <Shift-Control-Up> {
    tk::TextKeySelect %W [tk::TextPrevPara %W insert]
  }
  bind HelpText <Shift-Control-Down> {
    tk::TextKeySelect %W [tk::TextNextPara %W insert]
  }
  bind HelpText <Prior> {
    tk::TextSetCursor %W [tk::TextScrollPages %W -1]
  }
  bind HelpText <Shift-Prior> {
    tk::TextKeySelect %W [tk::TextScrollPages %W -1]
  }
  bind HelpText <Next> {
    tk::TextSetCursor %W [tk::TextScrollPages %W 1]
  }
  bind HelpText <Shift-Next> {
    tk::TextKeySelect %W [tk::TextScrollPages %W 1]
  }
  bind HelpText <Control-Prior> {
    %W xview scroll -1 page
  }
  bind HelpText <Control-Next> {
    %W xview scroll 1 page
  }

  bind HelpText <Home> {
    tk::TextSetCursor %W {insert linestart}
  }
  bind HelpText <Shift-Home> {
    tk::TextKeySelect %W {insert linestart}
  }
  bind HelpText <End> {
    tk::TextSetCursor %W {insert lineend}
  }
  bind HelpText <Shift-End> {
    tk::TextKeySelect %W {insert lineend}
  }
  bind HelpText <Control-Home> {
    tk::TextSetCursor %W 1.0
  }
  bind HelpText <Control-Shift-Home> {
    tk::TextKeySelect %W 1.0
  }
  bind HelpText <Control-End> {
    tk::TextSetCursor %W {end - 1 char}
  }
  bind HelpText <Control-Shift-End> {
    tk::TextKeySelect %W {end - 1 char}
  }
  bind HelpText <Tab> {
  focus [tk::_focusNext %W]
  }
  bind HelpText <Control-Tab> {
    focus [tk::_focusNext %W]
  }
  bind HelpText <Control-Shift-Tab> {
    focus [tk::_focusPrev %W]
  }
  bind HelpText <Control-i> {
    focus [tk::_focusNext %W]
  }
  bind HelpText <Control-space> {
    %W mark set anchor insert
  }
  bind HelpText <Select> {
    %W mark set anchor insert
  }
  bind HelpText <Control-Shift-space> {
    set tk::Priv(selectMode) char
    tk::TextKeyExtend %W insert
  }
  bind HelpText <Shift-Select> {
    set tk::Priv(selectMode) char
    tk::TextKeyExtend %W insert
  }
  bind HelpText <Control-slash> {
    %W tag add sel 1.0 end
  }
  bind HelpText <Control-backslash> {
    %W tag remove sel 1.0 end
  }
  bind HelpText <<Copy>> {
    tk::_textCopy %W
  }
  # Additional emacs-like bindings:

  bind HelpText <Control-a> {
    if {!$tk::_strictMotif} {
	tk::TextSetCursor %W {insert linestart}
    }
  }
  bind HelpText <Control-b> {
    if {!$tk::_strictMotif} {
	tk::TextSetCursor %W insert-1c
    }
  }
  bind HelpText <Control-d> {
    if {!$tk::_strictMotif} {
	%W delete insert
    }
  }
  bind HelpText <Control-e> {
    if {!$tk::_strictMotif} {
	tk::TextSetCursor %W {insert lineend}
    }
  }
  bind HelpText <Control-f> {
    if {!$tk::_strictMotif} {
	tk::TextSetCursor %W insert+1c
    }
  }
  bind HelpText <Control-n> {
    if {!$tk::_strictMotif} {
	tk::TextSetCursor %W [tk::TextUpDownLine %W 1]
    }
  }
  bind HelpText <Control-o> {
    if {!$tk::_strictMotif} {
	%W insert insert \n
	%W mark set insert insert-1c
    }
  }
  bind HelpText <Control-p> {
    if {!$tk::_strictMotif} {
	tk::TextSetCursor %W [tk::TextUpDownLine %W -1]
    }
  }
  if {$tcl_platform(platform) != "windows"} {
	bind HelpText <Control-v> {
	    if {!$tk::_strictMotif} {
		tk::TextScrollPages %W 1
	    }
	}
  }
  bind HelpText <Meta-b> {
    if {!$tk::_strictMotif} {
	tk::TextSetCursor %W [tk::TextPrevPos %W insert tcl_startOfPreviousWord]
    }
  }
  bind HelpText <Meta-f> {
    if {!$tk::_strictMotif} {
	tk::TextSetCursor %W [tk::TextNextWord %W insert]
    }
  }
  bind HelpText <Meta-less> {
    if {!$tk::_strictMotif} {
	tk::TextSetCursor %W 1.0
    }
  }
  bind HelpText <Meta-greater> {
    if {!$tk::_strictMotif} {
	tk::TextSetCursor %W end-1c
    }
  }
  # Macintosh only bindings:

  # if text black & highlight black -> text white, other text the same
  if {$tcl_platform(platform) == "macintosh"} {
	bind HelpText <FocusIn> {
	    %W tag configure sel -borderwidth 0
	    %W configure -selectbackground systemHighlight -selectforeground systemHighlightText
	}
	bind HelpText <FocusOut> {
	    %W tag configure sel -borderwidth 1
	    %W configure -selectbackground white -selectforeground black
	}
	bind HelpText <Option-Left> {
	    tk::TextSetCursor %W [tk::TextPrevPos %W insert tcl_startOfPreviousWord]
	}
	bind HelpText <Option-Right> {
	    tk::TextSetCursor %W [tk::TextNextWord %W insert]
	}
	bind HelpText <Option-Up> {
	    tk::TextSetCursor %W [tk::TextPrevPara %W insert]
	}
	bind HelpText <Option-Down> {
	    tk::TextSetCursor %W [tk::TextNextPara %W insert]
	}
	bind HelpText <Shift-Option-Left> {
	    tk::TextKeySelect %W [tk::TextPrevPos %W insert tcl_startOfPreviousWord]
	}
	bind HelpText <Shift-Option-Right> {
	    tk::TextKeySelect %W [tk::TextNextWord %W insert]
	}
	bind HelpText <Shift-Option-Up> {
	    tk::TextKeySelect %W [tk::TextPrevPara %W insert]
	}
	bind HelpText <Shift-Option-Down> {
	    tk::TextKeySelect %W [tk::TextNextPara %W insert]
	}

  # End of Mac only bindings
  }


  # Hyperhelp bindings

  bind HelpText <g> {
    BWHelp::_helpTextHHGoto %W %x %y
  }

  bind HelpText <G> {
    BWHelp::_helpTextHHGoto %W %x %y
  }

  bind HelpText <s> {
    BWHelp::_helpTextHHSearch %W %x %y
  }

  bind HelpText <S> {
    BWHelp::_helpTextHHSearch %W %x %y
  }

  bind HelpText <r> {
    BWHelp::_helpTextHHRSearch %W %x %y
  }

  bind HelpText <R> {
    BWHelp::_helpTextHHRSearch %W %x %y
  }
}

proc BWHelp::_create_help_dialog {} {
  variable _helpWindow
  variable _helpWindow_Text
  variable _helpWindow_ModeStatus
  variable _helpWindow_Command
  variable _helpWindow_TopicTree

  if {[winfo exists $_helpWindow]} {return}

  Dialog $_helpWindow \
      -homogeneous 1 \
      -separator 0 \
      -modal none \
      -parent . \
      -place center \
      -side bottom \
      -title {Help} \
      -transient 1 \
      -anchor e -class HelpDialog

#  puts stderr "*** BWHelp::_create_help_dialog: Built base dialog"

  set uframe [$_helpWindow getframe]
#  puts stderr "*** BWHelp::_create_help_dialog: uframe = $uframe"
  pack [PanedWindow $uframe.panes \
	-side [Widget::getoption $_helpWindow -side]] -fill both -expand yes
#  puts stderr "*** BWHelp::_create_help_dialog: PanedWindow created"
  
  set left [$uframe.panes add -weight 1]
  set treescroll [ScrolledWindow $left.treescroll \
	-relief sunken -borderwidth 2 -scrollbar both -auto both]
  pack $treescroll -fill both -expand yes
  set _helpWindow_TopicTree [Tree $treescroll.tree]
  pack $_helpWindow_TopicTree -fill both -expand yes
  $treescroll setwidget $_helpWindow_TopicTree
  $_helpWindow_TopicTree bindText <Double-1> BWHelp::_topicFromTree
#  puts stderr "*** BWHelp::_create_help_dialog: left pane (_helpWindow_TopicTree) created"

  set right [$uframe.panes add -weight 2]
  set textscroll [ScrolledWindow $right.textscroll \
	-relief sunken -borderwidth 2 -scrollbar vertical -auto vertical]
  pack $textscroll -fill both -expand yes
  set _helpWindow_Text [text $textscroll.text -relief sunken -borderwidth 2]
  pack $_helpWindow_Text -fill both -expand yes
  set bts [bindtags $_helpWindow_Text]
#  puts stderr "*** BWHelp::_create_help_dialog: bts = $bts"
  set ti  [lsearch  $bts {Text}]
#  puts stderr "*** BWHelp::_create_help_dialog: ti = $ti"
  if {$ti >= 0} {
    set bts [lreplace $bts $ti $ti HelpText]
  } else {
    set bts [linsert $bts 1 HelpText]
  }
#  puts stderr "*** BWHelp::_create_help_dialog: bts = $bts"
  bindtags $_helpWindow_Text $bts
  $textscroll setwidget $_helpWindow_Text
#  puts stderr "*** BWHelp::_create_help_dialog: right pane (_helpWindow_Text) created"

  pack [set _helpWindow_ModeStatus [label $uframe.status \
	 -relief flat \
	 -borderwidth 2 \
	 -anchor w \
	 -justify left]] -fill x -expand yes
#  puts stderr "*** BWHelp::_create_help_dialog: _helpWindow_ModeStatus created"

  pack [set _helpWindow_Command [LabelEntry $uframe.modeStatus]] \
		-fill x -expand yes
  $_helpWindow_Command bind <Return> {incr BWHelp::_helpWindowInput}
#  puts stderr "*** BWHelp::_create_help_dialog: _helpWindow_Command created"

  set close [$_helpWindow add -name close -text Close -underline 0 -command [list $_helpWindow withdraw]]
  $_helpWindow configure -cancel 0
  $_helpWindow add -name back -text Back -underline 0 -command {BWHelp::_helpBackTopic}
  $_helpWindow add -name forward -text Forward -underline 0 -command {BWHelp::_helpForwardTopic}
  set help [$_helpWindow add -name help -text Help -underline 0 -command {BWHelp::HelpTopic Help}]
  $_helpWindow configure -default 3
#  puts stderr "*** BWHelp::_create_help_dialog: Buttons added"
  _initialize_helpIndex
}

proc BWHelp::_initialize_helpIndex {} {
  variable _helpList
  variable _helpIndex
  variable _helpWindow_TopicTree

  global HelpDir
  set index [file join $HelpDir hh.index]
#  puts stderr "*** BWHelp::_initialize_helpIndex index = $index"
  if {[file readable $index]} {
    variable _helpList
    variable _helpIndex
    set _helpList {}
    set ifp [open $index r]
    while {[gets $ifp line] >= 0} {
      set indexKey [lindex $line 0]
      set fileInfo [lindex $line 1]
      set _helpIndex($indexKey) "$fileInfo"
      lappend _helpList "$indexKey"
      set topicPath [split $indexKey {>}]
      set parent [join [lrange $topicPath 0 [expr [llength $topicPath] - 2]] {>}]
      if {[string equal "$parent" {}]} {set parent root}
      set indexKeyText [lindex $topicPath end]
      $_helpWindow_TopicTree insert end $parent $indexKey -text $indexKeyText \
	-open 1
#      puts stderr "*** BWHelp::_initialize_helpIndex: parent = $parent, indexKey = $indexKey, indexKeyText = $indexKeyText"
    }
    close $ifp
  }
}

proc BWHelp::_topicFromTree {node} {
#  puts stderr "*** BWHelp::_topicFromTree $node"

  set topic [lindex [split "$node" {>}] end]
  HelpTopic "$topic" 1 "$node"  

}  

proc BWHelp::HelpTopic {{topic {}} {updateHistory 1} {key {}}} {
#  puts stderr "*** BWHelp::HelpTopic $topic $updateHistory $key"

  variable _helpWindow
  global HelpDir
  variable _helpList
  variable _helpIndex
  variable _hLinePattern
  variable _helpHistoryList
  variable _helpHistoryListIndex
  variable _helpWindow_Text
  variable _helpWindow_ModeStatus
  variable _helpWindow_Command
  variable _helpWindow_TopicTree
  

  _create_help_dialog

#  puts stderr "*** BWHelp::HelpTopic: $_helpWindow created..."

  if {$updateHistory == 1} {
    if {$_helpHistoryListIndex >= 0} {
      set _helpHistoryList [lrange $_helpHistoryList 0 $_helpHistoryListIndex]
      lappend _helpHistoryList "$topic"
      incr _helpHistoryListIndex      
    } else {
      set _helpHistoryList [list "$topic"]
      set _helpHistoryListIndex 0
    }
  }

#  puts stderr "*** BWHelp::HelpTopic: _helpHistoryList = $_helpHistoryList, _helpHistoryListIndex = $_helpHistoryListIndex"

  if {[string length "$key"] == 0} {
    set an [array names _helpIndex "*$topic"]
    if {[string length "$an"] == 0} {
      $_helpWindow_ModeStatus configure -text "$topic not found"
      if {![winfo ismapped $_helpWindow]} {$_helpWindow draw}
      return
    } else {
      if {[llength $an] > 1} {
 	set ai [lsearch -exact $an "$topic"]
	if {$ai >= 0} {
	  set key [lindex $an $ai]
	} else {
	  set ai [lsearch -glob $an "*>$topic"]
	  if {$ai >= 0} {
	    set key [lindex $an $ai]
	  } else {
	    set key [lindex [lsort -dictionary $an] 0]
	  }
	}
      } else {
      	set key [lindex $an 0]
      }
    }
  }

#  puts stderr "*** BWHelp::HelpTopic: key = $key"  

  $_helpWindow_Text delete 1.0 end
  set index [lsearch -exact $_helpList $key]
  $_helpWindow_TopicTree see $key
  $_helpWindow_TopicTree selection clear
  $_helpWindow_TopicTree selection set $key
  set fileInfo [set _helpIndex($key)]
  set file [file join $HelpDir [lindex $fileInfo 0]]
  set fpos [lindex $fileInfo 1]
  set buffer {}
  if {[catch [list open $file r] fp]} {
    $_helpWindow_Text  insert end "Can't load $topic: $fp"
    if {![winfo ismapped $_helpWindow]} {$_helpWindow draw}
    return
  }
  seek $fp $fpos start
  set headline [gets $fp]
  if {[regsub {^[0-9]+} "$headline" {} newheadline] > 0} {
    set headline [string trim "$newheadline"]
  }
  while {[gets $fp line] >= 0} {
    if {[regexp "$_hLinePattern" "$line" whole d1 d2] > 0} {break}
    append buffer "\n$line"
  }
  close $fp
    
  _headerFormat $_helpWindow_Text "$headline"
  _bodyFormat $_helpWindow_Text "$buffer"
  $_helpWindow_Text mark set insert 1.0
  $_helpWindow_Text see 1.0
  focus $_helpWindow_Text
  if {![winfo ismapped $_helpWindow]} {$_helpWindow draw}
}  

proc BWHelp::_headerFormat {text hline} {
# Procedure to format a header line.
  
  global tk_version
  if {$tk_version < 8.0} {
    regsub -nocase medium [$text cget -font] bold x
  } else {
    regsub -nocase normal [font actual [$text cget -font]] bold x
  }
  $text tag configure header -font "$x"
  $text insert end "$hline" header
}

proc BWHelp::_bodyFormat {text body} {
# Procedure to format the body.

  global HelpDir
  $text tag configure link -foreground blue -underline 1
  set abspos 0
  while {[regexp -indices "\[<\{\[\]" "$body" ii] > 0} {
    set i [lindex $ii 0]
    set prefix [string range "$body" 0 [expr $i - 1]]
    if {[string compare "[string index $body $i]" {<}] == 0} {
      set j [string first {>} "$body"]
      $text insert end "$prefix" normal
      set link [string range "$body" [expr $i + 1] [expr $j - 1]]
      set body [string range "$body" [expr $j + 1] end]
      set pos [expr $abspos + $i]
      incr abspos [expr $j + 1]
      $text insert end "$link" [list link link$pos]
      $text tag bind link$pos <1> [list BWHelp::HelpTopic "$link"]
    } elseif {[string compare "[string index $body $i]" {[}] == 0} {
      set j [string first {]} "$body"]
      $text insert end "$prefix" normal
      set head [string range "$body" [expr $i + 1] [expr $j - 1]]
      set body [string range "$body" [expr $j + 1] end]
      set pos [expr $abspos + $i]
      incr abspos [expr $j + 1]
      $text insert end "$head" header
    } else {
      set j [string first "\}" "$body"]
      $text insert end "$prefix" normal
      set imagefile [file join $HelpDir \
			[string range "$body" [expr $i + 1] [expr $j - 1]]]
      set body [string range "$body" [expr $j + 1] end]
      set pos [expr $abspos + $i]
      image create photo himg$pos -file $imagefile
      incr abspos [expr $j + 1]
      $text image create end -image himg$pos -align top
    }
  }
  $text insert end "$body" normal
}
    
proc BWHelp::_helpTextHHGoto {widget x y} {
# Function to implement the g/G key binding.

  variable _helpWindowInput
  set _helpWindowInput 0
  variable _helpWindow_Command
  variable _helpWindow
  $_helpWindow_Command configure -label  "Goto:"
  set oldFocus [focus]
  set oldGrab [grab current $_helpWindow]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  $_helpWindow_Command configure -text {}
  grab $_helpWindow_Command
  focus $_helpWindow_Command
  tkwait variable BWHelp::_helpWindowInput
  catch {focus $oldFocus}
  grab release $_helpWindow_Command
  if {$oldGrab != ""} {  
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  HelpTopic "[$_helpWindow_Command cget -text]"
}

proc BWHelp::_helpTextHHSearch {widget x y} {
# Function to implement the s/S key binding.

  variable _helpWindowInput
  set _helpWindowInput 0
  variable _helpWindow_Command
  variable _helpWindow
  variable _helpWindow_Text
  variable _helpWindow_ModeStatus
  $_helpWindow_Command configure -label "Search forward:"
  set oldFocus [focus]
  set oldGrab [grab current $_helpWindow]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  $_helpWindow_Command configure -text {}
  grab $_helpWindow_Command
  focus $_helpWindow_Command
  tkwait variable BWHelp::_helpWindowInput
  catch {focus $oldFocus}
  grab release $_helpWindow_Command
  if {$oldGrab != ""} {  
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  set string "[$_helpWindow_Command cget -text]"
  set found [$_helpWindow_Text search -forwards -nocase -- \
    $string insert end]
  if {[string length "$found"] == 0} {
    $_helpWindow_ModeStatus configure -text "'$string' not found!"
  } else {
    $_helpWindow_Text mark set insert $found
    $_helpWindow_Text see $found
  }
}

proc BWHelp::_helpTextHHRSearch {widget x y} {
# Function to implement the r/R key binding.

  variable _helpWindowInput
  set _helpWindowInput 0
  variable _helpWindow_Command
  variable _helpWindow
  variable _helpWindow_Text
  variable _helpWindow_ModeStatus
  $_helpWindow_Command configure -label "Search backward:"
  set oldFocus [focus]
  set oldGrab [grab current $_helpWindow]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  $_helpWindow_Command configure -text {}
  grab $_helpWindow_Command
  focus $_helpWindow_Command
  tkwait variable BWHelp::_helpWindowInput
  catch {focus $oldFocus}
  grab release $_helpWindow_Command
  if {$oldGrab != ""} {  
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  set string "[$_helpWindow_Command cget -text]"
  set found [$_helpWindow_Text search -backwards -nocase -- \
    $string insert 1.0]
  if {[string length "$found"] == 0} {
    $_helpWindow_ModeStatus configure -text "'$string' not found!"
  } else {
    $_helpWindow_Text mark set insert $found
    $_helpWindow_Text see $found
  }
}

proc BWHelp::_helpBackTopic {} {
# Procedure to go ``back'' in the history list.

  variable _helpHistoryList
  variable _helpHistoryListIndex
  if {$_helpHistoryListIndex > 0} {
    incr _helpHistoryListIndex -1
    HelpTopic [lindex $_helpHistoryList $_helpHistoryListIndex] 0
  }
}

proc BWHelp::_helpForwardTopic {} {
# Procedure to go ``forward'' in the history list.

  variable _helpHistoryList
  variable _helpHistoryListIndex
  if {$_helpHistoryListIndex < [expr [llength $_helpHistoryList] - 1]} {
    incr _helpHistoryListIndex
    HelpTopic [lindex $_helpHistoryList $_helpHistoryListIndex] 0
  }
}

proc BWHelp::GetTopLevelOfFocus {menu} {
# Procedure to get the toplevel that presently has focus.  This is used when
# generic pulldown menus are activated to determine which object the menu
# refers to.
# <in> menu -- this is the menu that was selected.  This is used to select
# which display to search on.
# [index] GetTopLevelOfFocus!procedure

  if {[catch [list winfo toplevel [focus -displayof $menu]] tl]} {
    return {}
  } elseif {[string length "$tl"] > 0} {
    return $tl
  } else {
    return {}
  }
}

proc BWHelp::_bindTagsAll {} {
# Procedure to set up the XmTrackingLocate bind tag.

  _bindTagsW .
}

proc BWHelp::_bindTagsW {w} {
# Helper procedure to set up the _xmTrackingLocate bind tag.

  if {[lsearch -exact [bindtags $w] _xmTrackingLocateTag] < 0} {
    bindtags $w [concat _xmTrackingLocateTag [bindtags $w]]
  }
  foreach c [winfo children $w] {
    _bindTagsW $c
  }
}
  


proc BWHelp::_xmTrackingLocate {widget cursor} {
# Procedure to implement Motif's XmTrackingLocate function.

  variable _xmTrackingLocateInfo
  _bindTagsAll
  set tl [winfo toplevel $widget]
  set _xmTrackingLocateInfo(cursor) "[$tl cget -cursor]"
  set _xmTrackingLocateInfo(widget) {}
  set _xmTrackingLocateInfo(grab) "[grab current $tl]"
  if {[string length "$_xmTrackingLocateInfo(grab)"] > 0} {
    set _xmTrackingLocateInfo(grabType) "[grab status $_xmTrackingLocateInfo(grab)]"
  }
  $tl configure -cursor "$cursor"
  bind _xmTrackingLocateTag <ButtonPress-1> "BWHelp::_xmTrackingLocateClick $tl %X %Y;break"
  grab -global $tl
  tkwait variable BWHelp::_xmTrackingLocateInfo(widget)
  grab release $tl
  if {[string length "$_xmTrackingLocateInfo(grab)"] > 0} {
    if {"$_xmTrackingLocateInfo(grabType)" == "global"} {
      grab set -global $_xmTrackingLocateInfo(grab)
    } else {
      grab set $_xmTrackingLocateInfo(grab)
    }
  }
  return $_xmTrackingLocateInfo(widget)  
}

proc BWHelp::_xmTrackingLocateClick {tl X Y} {
# _xmTrackingLocate binding function.

  variable _xmTrackingLocateInfo 
  bind _xmTrackingLocateTag <ButtonPress-1> {}
  $tl configure -cursor "$_xmTrackingLocateInfo(cursor)"
  set _xmTrackingLocateInfo(widget) "[winfo containing $X $Y]"
}
  


proc BWHelp::HelpContext {{widget .}} {
# This procedure pops up an ``On Context'' help dialog.

  set widget "[_xmTrackingLocate $widget question_arrow]"
  if {[string length "$widget"] > 0} {
    HelpWindow $widget
  }
}

proc BWHelp::HelpWindow {{widget .}} {
# This procedure pops up help for the current toplevel.

  _create_help_dialog

  set tl [winfo toplevel $widget]
  set tlClass [winfo class $tl]

  regsub \\$tl $widget tl$tlClass. widgetCL

  while {[regsub -all {\.\.} $widgetCL {.} widgetCL1] > 0} {
    set widgetCL $widgetCL1
  }
  while {[regsub -all {\.$}  $widgetCL {}  widgetCL1] > 0} {
    set widgetCL $widgetCL1
  }

#  puts stderr "*** BWHelp::HelpWindow: widgetCL = $widgetCL"

  variable _helpIndex

  set topicL [split $widgetCL {.}]
  while {[llength $topicL] > 0} {
    set topic [join $topicL {.}]
    set an [array names _helpIndex "*$topic"]
    if {[string length "$an"] > 0} break;
    set topicL [lrange $topicL 0 [expr [llength $topicL] - 2]]
  }
  if {[llength $topicL] > 0} {
    HelpTopic $topic
  } else {
    HelpTopic $widgetCL
  }
}


package provide BWHelp 1.0.0
