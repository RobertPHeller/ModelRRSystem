#!/usr/bin/tclsh

# tcl2tex: strip the doc out of an iTcl source file.
# <in> options and the iTcl file(s) to parse; see help information.
# <in> (optional) the output file (LaTeX).
# <auth> Jeroen Hoppenbrouwers

# $Log$
# Revision 1.3  2007/10/22 17:17:27  heller
# 10222007
#
# Revision 1.2  2007/04/19 17:23:22  heller
# April 19 Lock Down
#
# Revision 1.1  2007/02/02 01:15:49  heller
# Lock down for 2.1.7
#
# Revision 1.1  2006/08/04 01:59:25  heller
# Aug 3 Lockdown
#
# Revision 1.5  2006/02/27 15:34:17  heller
# Fix variable bug
#
# Revision 1.4  2004/06/06 13:58:39  heller
# Updated to better handle namespaces.
#
# Revision 1.3  2004/04/27 21:58:59  heller
# Updated to handle citations.
#
# Revision 1.2  2004/04/14 23:22:58  heller
# Misc. updated.
#
# Revision 1.1  2002/11/10 00:40:16  heller
# Time Table Internals Docs
#
# Revision 1.1  2000/11/09 20:14:14  heller
# Update added files...
#
# Revision 1.7  1997/07/18 12:30:35  hoppie
# Copyright changed.
#
# Revision 1.6  1997/06/23 11:06:13  hoppie
# Changed startup sequence for UNIX.
#
# Revision 1.5  1997/02/20 13:18:05  hoppie
# More robust interpreter (comments, quotes...).
#
# Revision 1.4  1997/01/31 08:56:10  hoppie
# Better character escaping to protect TeX specials.
#
# Revision 1.3  1997/01/08 08:51:51  hoppie
# Bug fix in variable processing.
#
# Revision 1.2  1996/12/23 07:07:50  hoppie
# First release.

proc forceExtension {filename extension} {
  # Function; forces the filename to have the extension, either by
  # appending or by replacing a current extendion.  There can be at most
  # one dot in the resulting filename (alas... DOS strikes again).
  # <in> filename = The file name to process.
  # <in> extension = The extension to force upon the file name.
  # <out> The new file name.
 
  # Separate the path and the file name (the path might contain dots).
  set dirname [file dirname $filename]
  set tail [file tail $filename]
 
  # Look for the first occurrence of a dot in the actual file name.
  set dot [string first "." $tail]
  if {$dot!=-1} {
    # Chop off everything from the dot on, including the dot itself.
    set tail [string range $tail 0 [expr $dot-1]]
  }
 
  return $dirname/$tail.$extension
}


proc unTag {l} {
  # Rewrites the tag format into proper LaTeX.
  # <in> l = the line to rewrite.
  # <out> the rewritten line.

  global tagOn o

  # Replace some characters that need TeX escapes.
  regsub -all {\$} $l {\\$} l
  regsub -all {_} $l {\\_} l
  regsub -all {&} $l {\\&} l
  regsub -all {\{} $l {\{} l
  regsub -all {\}} $l {\}} l
  regsub      {\^$} $l {\\\\} l
  while {[regexp {^(.*)@([A-Za-z0-9:_\\-]+)@(.*)$} "$l" => before label after] > 0} {
    regsub -all {\\_} $label {_} label
    set l "$before\\cite{$label}$after"
  }
  while {[regexp {^(.*)\?([A-Za-z0-9:_\\-]+)\?(.*)$} "$l" => before label after] > 0} {
    regsub -all {\\_} $label {_} label
    set l "$before\\ref{$label}$after"
  }
  while {[regexp {^(.*)=([A-Za-z0-9:_\\-]+)=(.*)$} "$l" => before label after] > 0} {
    regsub -all {\\_} $label {_} label
    set l "$before\\pageref{$label}$after"
  }

  if {[regexp {^\[([^]]+)\](.*)$} $l whole word rest] > 0} {
    set rest [string trim $rest " \t"]
    if {[string equal "$word" {label}]} {
      regsub -all {\\$} $rest {\$} rest
      regsub -all {\\_} $rest {_} rest
      regsub -all {\\&} $rest {&} rest
    }
    set l "\\$word{$rest}"
    # Replace the tag if there is one
  } elseif {![string compare [string index $l 0] "<"]} {
    if {! $tagOn} {
      puts $o "\\begin{description}"
      set tagOn 1
    }
    set p [string first ">" $l]; # find the index of ">"
    set tagName [string range $l 1 [expr $p - 1]]
    set tagName [string trim "$tagName"]
    if {[string length "$tagName"] == 0} {
      set l "\\end{description}"
      set tagOn 0
    } else {
      set l "\\item \[$tagName\] [string range $l [expr $p + 1 ] end]"
    }
  }

  return $l
}; # unTag


proc stopTag {} {
  # Close a description environment if it is open
  global tagOn o
  if {$tagOn} {
    puts $o "\\end{description}"
    set tagOn 0
  }
}; # stopTag


proc convert {filename o} {
  # Runs the actual conversion.
  # <in> filename = The file name to convert.
  # <in> o = The output handle.

  # Open the input file (Tcl file)
  set f [open $filename]

  puts $o "% Begin of input file $filename"

  # First, parse the header of the file. Skip the first line if it starts
  # with #! (shell interpreter).
  set line [string trim [gets $f]]
  if {[string range $line 0 1]=="#!"} {gets $f line}

  # Search for the first line starting with a comment sign (#).
  while {[string index $line 0] != "#"} {
    set line [string trim [gets $f]]
  }

  # Skip documentation header
  while {[string range $line 0 1]=="#*"} {
    set line [string trim [gets $f]]
  }

  # Search for the first line starting with a comment sign (#).
  while {[string index $line 0] != "#"} {
    set line [string trim [gets $f]]
  }

  # Print the file header (everything until the first empty line)
  #puts $o "\\vspace{1cm}"
  set fname "[file tail $filename]"
  regsub -all {\$} $fname {\\$} fname
  regsub -all {_} $fname {\\_} fname
  regsub -all {&} $fname {\\&} fname
  regsub -all {\{} $fname {\{} fname
  regsub -all {\}} $fname {\}} fname
  set theChapter "File: `$fname'"
  set theLabel   "$fname"
  set didChapter 0
  while {$line!=""} {
    set line [string trim $line " #\t"]
    if {[string range $line 0 2] == {$Id}} {
      puts $o "\\typeout{Generated from $line}"
    } elseif {[regexp {^@([^:]+):(.*)$} $line whole word rest] > 0} {
      switch -exact -- $word {
	Chapter {
		puts $o "\\chapter{[string trim $rest]}"
		set didChapter 1
		}
	Label {puts $o "\\label{[string trim $rest]}"}
	Typeout {puts $o "\\typeout{[string trim $rest]}"}
      }
    } else {
      if {!$didChapter} {
	puts $o "\\chapter{$theChapter}"
	puts $o "\\label{$theLabel}"
	set didChapter 1
      }
      puts $o [unTag $line]
    }
    gets $f line
  }
  stopTag
  puts $o ""

  # Now enter a loop, in which we process all lines.
  set tryComments 0
  set wasVar 1
  set braces 0
  set environment {}
  while {![eof $f]} {
    set line [string trim [gets $f]]

    # If we just processed an item, print the trailing comments, if there
    # are any.
    if {$tryComments} {
      while {[string range $line 0 0]=="#"} {
        set line [string trim $line "# \t"]
        puts $o [unTag $line]
        set line [string trim [gets $f]]
      }
      set tryComments 0
    }
    stopTag

    # Throw away any double quotes because they may screw up list operations.
    regsub -all \" $line "" line

    # Cut off the line just before the first semicolon.
    if {[set first [string first ";" $line]]!=-1} {
      set line [string range $line 0 [expr $first - 1]]
    }

    if {[regexp {^([^ 	]+)} "[string trim $line]" whole firstWord] < 1} {
      set firstWord {}
    }

    # The keywords "class" and "namespace" (and anything starting with snit::) 
    # should be matched against the braces because these keywords indicate 
    # environments. When we encounter such a word, store it on a stack (LIFO)
    # together with the current brace count.
    if {($firstWord=="namespace")||[string match "snit::*" "$firstWord"]} {
      lappend environment [list $firstWord $braces]
    }

    # Update the brace count. Misuse regsub for this.
    set openBraces [regsub -all {\{} $line {} dummy]
    set closeBraces [regsub -all {\}} $line {} dummy]
    set braces [expr $braces + $openBraces - $closeBraces]

    # When the brace count drops back to the top-of-stack level, we
    # left an environment.
    set currentEnv [lindex $environment end]
    set envBraces [lindex $currentEnv 1]
    if {$braces==$envBraces} {
      # Close the current environment.
      set environment [lrange $environment 0 [expr [llength $environment]-2]]
    }

    # Now process the found line. Use a tmp var to prevent one of the key
    # words to end up as the first word in a line, which would prevent
    # this program to take itself as input...
    set t {proc typemethod method constructor destructor  namespace 
	   snit::widget snit::type snit::macro snit::widgetadaptor}
#    set t [concat $t {public private protected class}]
    if {[lsearch -exact $t $firstWord]!=-1} {

      # Split the line in name (including protection modifiers and type)
      # and parameters. For this, first remove a possible dangling opening
      # brace at the end.
      set line [string trimright $line "\{ "]

      set iseval 0

#      puts stderr "*** line = '$line'"
#      puts stderr "*** \[string first eval $line\] = [string first eval $line]"

      # Set apart the keywords without parameters.
      if {[string first \{ $line]==-1} {
        # No parameters found.
        set procname $line
        set params ""
	if {[string equal "$firstWord" {namespace}] && [string first eval $line] > 0} {
	  set iseval 1
	  set last [llength $line]
	  incr last -1
	  set procname [lindex $line $last]
	}
      } else {
        # There are parameters.
        set last [llength $line]
        incr last -1
        set params [lindex $line $last]
        incr last -1
        set procname [lrange $line 0 $last]
      }

      # Lines appear before every new element, except when the new
      # and previous elements are both variables.
      if {([lsearch -exact $line variable]!=-1) || \
          ([lsearch -exact $line common]!=-1)} {
        # For variables, draw a line only if the previous element was no
        # variable.
        if {!$wasVar} {
          puts $o "\n\n\\noindent\\rule\{\\textwidth\}\{0.4pt\}"
        }
        set wasVar 1
      } else {
        # Non-variable element; always draw a line.
        puts $o "\n\n\\noindent\\rule\{\\textwidth\}\{0.4pt\}"
      }

      # Replace some characters that need TeX escapes.
      regsub -all {\$} $procname {\\$} procname
      regsub -all {_} $procname {\\_} procname
      regsub -all {&} $procname {\\&} procname
      regsub -all {\{} $procname {\{} procname
      regsub -all {\}} $procname {\}} procname
      regsub -all {\$} $params {\\$} params
      regsub -all {_} $params {\\_} params
      regsub -all {&} $params {\\&} params
      regsub -all {\{} $params {\{} params
      regsub -all {\}} $params {\}} params

#      puts stderr "*** firstWord = $firstWord, iseval = $iseval"

      # Classes and namespaces get a subsection, others a section.
      if {(($firstWord=="namespace")&&!$iseval)} {
        puts $o "\\vspace*{0.5cm}"
        puts $o "\\subsection\[$procname\]{$procname \\emph\{$params\}}"
      } elseif {$iseval} {
	puts $o "\\section\[namespace $procname\]{namespace $procname}"
      } else {
#	puts stderr "*** convert: environment = $environment"
	set envdepth [llength $environment]
#	puts stderr "*** convert: envdepth  = $envdepth"
	if {[string match "snit::*" "$firstWord"]} {incr envdepth -1}
	switch $envdepth {
	  0 {
	  puts $o "\\section\[$procname\]{$procname \\emph\{$params\}}"
	  }
	  1 {
	    puts $o "\\vspace*{0.5cm}"
	    puts $o "\\subsection\[$procname\]{$procname \\emph\{$params\}}"
	  }
	  2 {
	    puts $o "\\vspace*{0.5cm}"
	    puts $o "\\subsubsection\[$procname\]{$procname \\emph\{$params\}}"
	  }
	}
      }

      puts $o ""
      set tryComments 1
    } elseif {[string compare "$firstWord" {global}] == 0 && \
	      $braces==0} {
      # saw "global" at the toplevel. 
      set procname "[lindex $line 1]"
      regsub -all {\$} $procname {\\$} procname
      regsub -all {_} $procname {\\_} procname
      regsub -all {&} $procname {\\&} procname
      regsub -all {\{} $procname {\{} procname
      regsub -all {\}} $procname {\}} procname
      puts $o "\n\n\\noindent\\rule\{\\textwidth\}\{0.4pt\}"
      puts $o "\\section{global $procname}"
      puts $o ""
      set tryComments 1
    } elseif {[string compare "$firstWord" {variable}] == 0 && \
	      $braces>0 && \
	      [string equal [lindex [lindex $environment end] 0] {namespace}]} {
      # Split the line in name (including protection modifiers and type)
      # and parameters. For this, first remove a possible dangling opening
      # brace at the end.
      set line [string trimright $line "\{ "]
      # saw "variable" at the toplevel. 
      set procname "[lindex $line 1]"
      regsub -all {\$} $procname {\\$} procname
      regsub -all {_} $procname {\\_} procname
      regsub -all {&} $procname {\\&} procname
      regsub -all {\{} $procname {\{} procname
      regsub -all {\}} $procname {\}} procname
      puts $o "\n\n\\noindent\\rule\{\\textwidth\}\{0.4pt\}"
      puts $o "\\vspace*{0.5cm}"
      puts $o "\\subsection\[variable $procname\]{variable $procname}"
      puts $o ""
      set tryComments 1
    } elseif {[string compare "$firstWord" {image}] == 0 && \
	      $braces==0} {
      # saw "image" at the toplevel.
      if {[string compare "[lindex $line 1]" {create}] == 0} {
	set procname "[lrange $line 2 3]"
	set name "[lindex $procname 1]"
	if {[string index $name 0] != {-}} {
	  regsub -all {\$} $procname {\\$} procname
	  regsub -all {_} $procname {\\_} procname
	  regsub -all {&} $procname {\\&} procname
	  regsub -all {\{} $procname {\{} procname
	  regsub -all {\}} $procname {\}} procname
	  puts $o "\n\n\\noindent\\rule\{\\textwidth\}\{0.4pt\}"
	  puts $o "\\section{image $procname}"
	  puts $o ""
	  set tryComments 1
	}
      }
    }; # if interesting element on line

  }; # while not eof

  puts $o "% End of input file $filename"

  close $f

}; # convert



##### main ###############################################################

global tagOn
set tagOn 0

# Process the options. First set the defaults.
set OPTIONS(forinput) 0
set OPTIONS(stdout)   0

set FILES {}

# Then scan the command line parameters. Assign known options to their
# variable, yell if unknown options are encountered, and append all non-
# option parameters into a list.
foreach a $argv {
  switch -glob -- $a {
    -stdout {
      set OPTIONS(stdout) 1
    }
    -forinput {
      set OPTIONS(forinput) 1
    }
    -* {
      puts "Unknown option $a!"
      exit
    }
    default {
      lappend FILES $a
    }
  }; # switch
}; # foreach

if {$argc == 0} {
  puts "tcl2tex 1.1    (c) KISS 1997"
  puts "Usage: tcl2tex \[-options\] <outputfile\[.tex\]> <inputfile> \[<inputfile>...\]"
  puts "Options:"
  puts "    -stdout     outputs to stdout"
  exit
}

if {$OPTIONS(stdout)} {
  set o stdout
} else {
  set outputFile [forceExtension [lindex $FILES 0] "tex"]
  set o [open $outputFile w]
  set FILES [lrange $FILES 1 end]
}

# If not generating for input, output the LaTeX preamble etc.
if {!$OPTIONS(forinput)} {
  puts $o "\\documentclass{book}"
  puts $o "\\begin{document}"
  puts $o "\\noindent \\emph\{This document was generated on"
  puts $o "[clock format [clock seconds]]"
  puts $o "by the \\texttt{tcl2tex} utility (version 1.4).\}"
  puts $o ""
  puts $o {\tableofcontents\newpage}
  puts $o ""
}

# Convert the files sequentially.
foreach f $FILES {
  if {!$OPTIONS(stdout)} {
    puts "Converting $f..."
  }
  convert $f $o
}; # foreach

# If not generating for input, end the document.
if {!$OPTIONS(forinput)} {
  puts $o {\vfill\centering - o - o - o -\vfill}
  puts $o "\\end{document}"
}

close $o

# end of the program

