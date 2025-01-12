#* 
#* ------------------------------------------------------------------
#* Role PlayingDB V3.0 by Deepwoods Software
#* ------------------------------------------------------------------
#* ZipArchive.tcl - Create a Zip Archive using zlib
#* Created by Robert Heller on Sun Aug 30 20:45:47 2009
#* ------------------------------------------------------------------
#* $Id$
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Role Playing DB -- A database package that creates and maintains
#* 		       a database of RPG characters, monsters, treasures,
#* 		       spells, and playing environments.
#* 
#*     Copyright (C) 2009  Robert Heller D/B/A Deepwoods Software
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
#* Lifted from http://wiki.tcl.tk/15158
#* Converted from Artur Trzewik XOTcl code to a snit::type
#*

#@Chapter:ZipArchive.tcl -- Code to create a Zip archive
#$Id$
# This is a port of Artur Trzewik's code that creates a Zip archive
# written in XOTcl to a snit::type.  It has been modified to handle
# directories and includes code to recursively traverse a directory.
#

package require vfs::zip
package require vfslib
package require snit

snit::type ZipArchive {
  variable files {}
  variable cdOffset 0 
  variable cdLength 0
  variable written 0
  method addFile {inputFile fileName} {
    lappend files $inputFile $fileName
  }

  method addToStream {stream fin fout} {
    set offset $written
    if {[file isdirectory $fin]} {
      set data ""
      append fout "/"
      set datacompresed [string range [::vfs::zip -mode compress $data] 2 end-4]
    } else {
      set fdata [open $fin r]
      fconfigure $fdata -encoding binary -translation binary
      set data [read $fdata]
      set datacompresed [string range [::vfs::zip -mode compress $data] 2 end-4]
      close $fdata
    }

    binary scan \x04\x03\x4B\x50 I LFH_SIG
    $self writeLong $stream $LFH_SIG

    incr written 4

    $self writeShort $stream 20
    # java implementation make 8
    # but tools (WinZip) leave it 0
    $self writeShort $stream 0
    incr written 4

    $self writeShort $stream 8
    incr written 2

    # last mod. time and date
    set dosTime [$self toDosTime $fin]

    $self writeLong $stream $dosTime
    incr written 4

    set crc [::vfs::crc $data]
    set csize [string length $datacompresed]
    set size [string length $data]

    $self writeLong $stream $crc
    $self writeLong $stream $csize
    $self writeLong $stream $size
    incr written 12

    # file name length
    $self writeShort $stream [string length $fout]
    incr written 2

    # extra field length
    set extra ""
    $self writeShort $stream [string length $extra]
    incr written 2

    # file name
    puts -nonewline $stream $fout
    incr written [string length $fout]

    puts -nonewline $stream $extra
    incr written [string length $extra]

    set dataStart $written
    puts -nonewline $stream $datacompresed
    incr written $csize

    return [list $offset $dosTime $crc $csize $size]
  }

  method createFile {file args} {
    set fout [open $file w]
    fconfigure $fout -encoding binary -translation binary
    eval [list $self createToStream $fout] $args
    close $fout
  }

  method createToStream {ostream args} {
    set descriptionList [list]
    foreach {fin fout} $files {
      lappend descriptionList [$self addToStream $ostream $fin $fout]
    }
    set cdOffset $written

    foreach {fin fout} $files desc $descriptionList {
      foreach {offset dosTime crc csize size} $desc {}
      $self writeCentralFileHeader $ostream $fin $fout $offset $dosTime $size $csize $crc
    }

    set cdLength [expr {$written - $cdOffset}]
    # wirte header

    # EOCD 0X06054B50L scan 0X06054B50L %x s set s
    binary scan \x06\x05\x4B\x50 I EOCD
    $self writeLong $ostream $EOCD

    # disk numbers
    $self writeShort $ostream 0
    $self writeShort $ostream 0

    # number of entries
    set filenum [expr {[llength $files]>>1}]
    $self writeShort $ostream $filenum
    $self writeShort $ostream $filenum

    # length and location of CD
    $self writeLong $ostream $cdLength
    $self writeLong $ostream $cdOffset

    # zip file comment
    set comment [from args -comment ""]
    # comment lenght
    $self writeShort $ostream [string bytelength $comment]

    puts -nonewline $ostream $comment
  }
  constructor {} {
    set files [list]
    set cdLength 0
    set cdOffset 0
    set written 0
  }
  method toDosTime {file} {
    set sec [file mtime $file]
    if {$sec == 0} {;#		broken metakit VFS directory implementation???
      set sec [clock scan now];# temp hack to keep the vfs::zip implementation happy.
    }

    foreach {year month day hour minute secound} \
	[clock format $sec -format "%Y %m %e %k %M %S"] {}

    set month [string trimleft $month 0]
    set year [string trimleft $year 0]
    set minute [string trimleft $minute 0]
    if {$minute eq ""} {
      set minute 0
    }
    set secound [string trimleft $secound 0]
    if {$secound eq ""} {
      set secound 0
    }

    set hour  [string trimleft $hour]
    if {$hour eq ""} {set hour 0}
    set value [expr {(($year - 1980) << 25) | \
		     ($month << 21) | ($day << 16) | ($hour << 11) | \
		     ($minute << 5) | ($secound >> 1)}]
    return $value
  }
  method writeCentralFileHeader {ostream fin fout offset dosTime size csize crc} {
    # CFH 0X02014B50L
    binary scan \x02\x01\x4B\x50 I CFH_SIG
    $self writeLong $ostream $CFH_SIG
    incr written 4

    if {$::tcl_platform(platform) eq "windows"} {
        # unix
        set pid 5
    } else {
        # windows
        set pid 11
    }
    $self writeShort $ostream [expr { (($pid << 8) | 20)}]
    incr written 2

    # version needed to extract
    # general purpose bit flag

    $self writeShort $ostream 20
    $self writeShort $ostream 0
    incr written 4

    # compression method
    $self writeShort $ostream 8
    incr written 2

    # last mod. time and date
    $self writeLong $ostream $dosTime
    incr written 4

    # CRC
    # compressed length
    # uncompressed length
    $self writeLong $ostream $crc
    $self writeLong $ostream $csize
    $self writeLong $ostream $size
    incr written 12;

    set comment ""
    set extra ""

    # file name length

    $self writeShort $ostream [string bytelength $fout]
    incr written 2;

    # extra field length
    $self writeShort $ostream [string bytelength $extra]
    incr written 2;

    # file comment length
    $self writeShort $ostream [string bytelength $comment]
    incr written 2;

    # disk number start
    $self writeShort $ostream 0
    incr written 2

    # internal file attributes
    $self writeShort $ostream 0
    incr written 2

    # external file attributes
    $self writeLong $ostream 0
    incr written 4

    # relative offset of LFH
    $self writeLong $ostream $offset
    incr written 4

    # file name
    puts -nonewline $ostream $fout
    incr written [string bytelength $fout]

    # extra field
    puts -nonewline $ostream $extra
    incr written [string bytelength $extra]

    # file comment
    puts -nonewline $ostream $comment
    incr written [string bytelength $comment]
  }
  method writeLong {stream short} {
    puts -nonewline $stream [binary format i $short]
  }
  method writeShort {stream short} {
    puts -nonewline $stream [binary format s $short]
  }
  proc find {directory} {
    set result [list]
    foreach file [glob -nocomplain [file join $directory *]] {
      if {[file isdirectory $file]} {
	eval [list lappend result $file/] [find $file]
      } else {
	lappend result $file
      }
    }
    return $result
  }
  proc stripdir {file directory} {
    set dlen [string length $directory]; incr dlen -1
    if {"[string range $file 0 $dlen]" eq "$directory"} {
      return [string range "$file" [expr {$dlen + 2}] end]
    } else {
      return "$file"
    }
  }
  typemethod createZipFromDirtree {zipfile directory args} {
  # This type method creates a Zip archive from a directory tree.
  #
  # Args:
  # <in> zipfile The name of the zip file to create.
  # <in> directory The name of the directory to recursively traverse.
  # <in> args Any remaining args to pass to the createFile method.

    set ziparchive [$type create %AUTO%]
    foreach f [find $directory] {
      $ziparchive addFile $f [stripdir $f $directory]
    }
    eval [list $ziparchive createFile $zipfile] $args
    $ziparchive destroy
    return $zipfile
  }
}

package provide ZipArchive 1.0







    
