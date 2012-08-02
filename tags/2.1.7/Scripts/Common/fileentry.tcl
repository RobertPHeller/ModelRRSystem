#* 
#* ------------------------------------------------------------------
#* BWExtras.tcl -- Assorted extra composite widgets
#* ------------------------------------------------------------------
#* fileentry.tcl - File Entry Widget
#* Created by Robert Heller on Wed Feb 15 19:19:24 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.1.1.1  2006/02/16 14:58:07  heller
#* Modification History: Imported sources
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
#  $Id$
# ------------------------------------------------------------------------------
#  Index of commands:
#     - FileEntry::create
#     - FileEntry::configure
#     - FileEntry::cget
#     - FileEntry::bind
# ------------------------------------------------------------------------------

namespace eval FileEntry {
    Widget::define FileEntry fileentry Entry LabelFrame Button
    Widget::declare FileEntry {
	{-filebitmap String "" 1}
	{-fileimage  String "" 1}
	{-filedialog Enum open 0 {open save directory}}
	{-defaultextension String "" 0}
	{-filetypes String {} 0}
	{-title String "" 0}
    }

    Widget::bwinclude FileEntry LabelFrame .labf \
        remove {-relief -borderwidth -focus} \
        rename {-text -label} \
        prefix {label -justify -width -anchor -height -font -textvariable}

    Widget::bwinclude FileEntry Entry .e \
        remove {-fg -bg} \
        rename {-foreground -entryfg -background -entrybg}

    Widget::bwinclude FileEntry Button .b \
        remove {-anchor -bg -bitmap -borderwidth -bd -cursor -font
		-fg -highlightthickness -image -justify -padx -pady 
		-repeatdelay -repeatinterval -takefocus -text -textvariable 
		-wraplength -armcommand -command -default -disarmcommand 
		-height -helptext -helptype -helpvar -name -relief -state 
		-underline -width} \
	rename {-foreground -buttonfg -background -buttonbg
		-activebackground -buttonactivebg 
		-activeforeground -buttonactivefg
		-disabledforeground -buttondisabledfg
		-highlightbackground -buttonhighlightbg
		-highlightcolor -buttonhighlightcolor}

    Widget::addmap FileEntry "" :cmd {-background {}}

    Widget::syncoptions FileEntry Entry .e {-text {}}
    Widget::syncoptions FileEntry LabelFrame .labf {-label -text -underline {}}

    ::bind BwFileEntry <FocusIn> [list focus %W.labf]
    ::bind BwFileEntry <Destroy> [list FileEntry::_destroy %W]

    
}


# ------------------------------------------------------------------------------
#  Command FileEntry::create
# ------------------------------------------------------------------------------
proc FileEntry::create { path args } {
    array set maps [list FileEntry {} :cmd {} .labf {} .e {} .b {}]
    array set maps [Widget::parseArgs FileEntry $args]

    eval [list frame $path] $maps(:cmd) -class FileEntry \
	    -relief flat -bd 0 -highlightthickness 0 -takefocus 0
    Widget::initFromODB FileEntry $path $maps(FileEntry)
    
	
    set labf  [eval [list LabelFrame::create $path.labf] $maps(.labf) \
                   [list -relief flat -borderwidth 0 -focus $path.e]]
    set subf  [LabelFrame::getframe $labf]
    set entry [eval [list Entry::create $path.e] $maps(.e)]
    set button [eval [list Button::create $path.b] $maps(.b)]
    set filebitmap "[Widget::getoption $path -filebitmap]"
    set fileimage  "[Widget::getoption $path -fileimage]"
    if {[string equal "$filebitmap" {}] &&
	[string equal "$fileimage"  {}]} {
      set fileimage [image create photo -file [file join $::BWIDGET::LIBRARY images openfold.gif]]
      $button configure -image "$fileimage"
    } elseif {![string equal "$filebitmap" {}]} {
      $button configure -bitmap @$filebitmap
    }  elseif {![string equal "$fileimage"  {}]} {
      $button configure -image "$fileimage"
    }
    $button configure -command [list FileEntry::OpenFile $path]
    
    pack $entry -in $subf -fill both -expand yes -side left
    pack $button -in $subf -side right
    pack $labf  -fill both -expand yes

    bindtags $path [list $path BwFileEntry [winfo toplevel $path] all]

    return [Widget::create FileEntry $path]
}


# ------------------------------------------------------------------------------
#  Command FileEntry::configure
# ------------------------------------------------------------------------------
proc FileEntry::configure { path args } {
    return [Widget::configure $path $args]
}


# ------------------------------------------------------------------------------
#  Command FileEntry::cget
# ------------------------------------------------------------------------------
proc FileEntry::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command FileEntry::bind
# ------------------------------------------------------------------------------
proc FileEntry::bind { path args } {
    return [eval [list ::bind $path.e] $args]
}


#------------------------------------------------------------------------------
#  Command FileEntry::_path_command
#------------------------------------------------------------------------------
proc FileEntry::_path_command { path cmd larg } {
    if { [string equal $cmd "configure"] ||
         [string equal $cmd "cget"] ||
         [string equal $cmd "bind"] } {
        return [eval [list FileEntry::$cmd $path] $larg]
    } else {
        return [eval [list $path.e:cmd $cmd] $larg]
    }
}


proc FileEntry::_destroy { path } {
    Widget::destroy $path
}

#---------------------------------
# Bound to the button -- open a file select dialog
#---------------------------------

proc FileEntry::OpenFile { path } {
  set dialogType [Widget::getoption $path -filedialog]
  set defaultextension [Widget::getoption $path -defaultextension]
  set filetypes [Widget::getoption $path -filetypes]
  set title [Widget::getoption $path -title]
#  puts stderr "*** FileEntry::OpenFile: path = $path, dialogType = $dialogType, defaultextension = $defaultextension, filetypes = $filetypes, title = $title"

  set currentfile "[$path.e cget -text]"
  switch $dialogType {
    open {
	set newfile [tk_getOpenFile \
			 -defaultextension "$defaultextension" \
			 -filetypes "$filetypes" \
			 -title "$title" \
			 -initialdir [file dirname "$currentfile"] \
			 -initialfile "$currentfile" \
			 -parent $path]
	if {![string equal "$newfile" {}]} {
	  $path.e configure -text "$newfile"
	}
    }
    save {
	set newfile [tk_getSaveFile \
			 -defaultextension "$defaultextension" \
			 -filetypes "$filetypes" \
			 -title "$title" \
			 -initialdir [file dirname "$currentfile"] \
			 -initialfile "$currentfile" \
			 -parent $path]
	if {![string equal "$newfile" {}]} {
	  $path.e configure -text "$newfile"
	}
    }
    directory {
	set newdirectory [tk_chooseDirectory \
		-initialdir "$currentfile" \
		-title "$title" \
		-parent $path]
	if {![string equal "$newdirectory" {}]} {
	  $path.e configure -text "$newdirectory"
	}
    }
  }

}

package provide BWFileEntry 1.0.0
