#* 
#* ------------------------------------------------------------------
#* ax_tcl_libraries.m4 - Checks for Tcl Libraries
#* Created by Robert Heller on Sat Mar  2 15:25:28 2013
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

AC_DEFUN([AX_BWIDGET],[
AC_MSG_CHECKING(bwidget dir)
[searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`]
for dir in $searchdirs ; do
  [dirs="${dir}/bwidget* ${dir}/tcllib*/bwidget*"]
  for i in $dirs ; do 
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      [BWLIB=`cd $i; pwd`]
    fi
  done
done
AC_ARG_WITH(bwlib, [  --with-bwlib=DIR          use BWidget from DIR], [BWLIB=$withval],)
if test x$BWLIB != x -a -d $BWLIB; then
   AC_MSG_RESULT([using BWidget library in $BWLIB])
else
   AC_MSG_ERROR(BWidget library directory not found)
fi
AC_SUBST(BWLIB)
])

AC_DEFUN([AX_SNIT],[
AC_MSG_CHECKING(snit dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/snit* ${dir}/tcllib*/snit*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      SNITLIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(snitlib, [  --with-snitlib=DIR          use snit from DIR], SNITLIB=$withval,)
if test x$SNITLIB != x -a -d $SNITLIB; then
   AC_MSG_RESULT([using snit library in $SNITLIB])
else
   AC_MSG_ERROR(Snit library directory not found)
fi
AC_SUBST(SNITLIB)
])
AC_DEFUN([AX_CSV],[
AC_MSG_CHECKING(csv dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/csv* ${dir}/tcllib*/csv*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      CSVLIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(csvlib, [  --with-csvlib=DIR          use csv from DIR], CSVLIB=$withval,)
if test x$CSVLIB != x -a -d $CSVLIB; then
   AC_MSG_RESULT([using csv library in $CSVLIB])
else
   AC_MSG_ERROR(Csv library directory not found)
fi
AC_SUBST(CSVLIB)
])
AC_DEFUN([AX_STRUCT],[
AC_MSG_CHECKING(struct dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/struct* ${dir}/tcllib*/struct*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      STRUCTLIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(structlib, [  --with-structlib=DIR          use struct from DIR], STRUCTLIB=$withval,)
if test x$STRUCTLIB != x -a -d $STRUCTLIB; then
   AC_MSG_RESULT([using struct library in $STRUCTLIB])
else
   AC_MSG_ERROR(Struct library directory not found)
fi
AC_SUBST(STRUCTLIB)
])


AC_DEFUN([AX_TCLLOG],[
AC_MSG_CHECKING(Tcl log dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/log* ${dir}/tcllib*/log*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      TCLLOGLIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(tclloglib, [  --with-tclloglib=DIR          use Tcl log from DIR], TCLLOGLIB=$withval,)
if test x$TCLLOGLIB != x -a -d $TCLLOGLIB; then
   AC_MSG_RESULT([using Tcl log library in $TCLLOGLIB])
else
   AC_MSG_ERROR(Tcl log library directory not found)
fi
AC_SUBST(TCLLOGLIB)
])

AC_DEFUN([AX_HTML],[
AC_MSG_CHECKING(html dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/html* ${dir}/tcllib*/html*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      HTMLLIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(htmllib, [  --with-htmllib=DIR          use html from DIR], HTMLLIB=$withval,)
if test x$HTMLLIB != x -a -d $HTMLLIB; then
   AC_MSG_RESULT([using html library in $HTMLLIB])
else
   AC_MSG_ERROR(Html library directory not found)
fi
AC_SUBST(HTMLLIB)
])

AC_DEFUN([AX_IMG],[
AC_MSG_CHECKING(Img dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/Img*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      IMGLIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(imglib, [  --with-imglib=DIR          use img from DIR], IMGLIB=$withval,)
if test x$IMGLIB != x -a -d $IMGLIB; then
   AC_MSG_RESULT([using img library in $IMGLIB])
else
   AC_MSG_ERROR(Img library directory not found)
fi
AC_SUBST(IMGLIB)
])

AC_DEFUN([AX_TCLXML],[
AC_MSG_CHECKING(Tclxml dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/Tclxml*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      TCLXMLLIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(tclxmllib, [  --with-tclxmllib=DIR          use tclxml from DIR], TCLXMLLIB=$withval,)
if test x$TCLXMLLIB != x -a -d $TCLXMLLIB; then
   AC_MSG_RESULT([using tclxml library in $TCLXMLLIB])
else
   AC_MSG_ERROR(Tclxml library directory not found)
fi
AC_SUBST(TCLXMLLIB)
])


AC_DEFUN([AX_URI],[
AC_MSG_CHECKING(uri dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/uri* ${dir}/tcllib*/uri*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      URILIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(urilib, [  --with-urilib=DIR          use uri from DIR], URILIB=$withval,)
if test x$URILIB != x -a -d $URILIB; then
   AC_MSG_RESULT([using uri library in $URILIB])
else
   AC_MSG_ERROR(Uri library directory not found)
fi
AC_SUBST(URILIB)
])

AC_DEFUN([AX_NCGI],[
AC_MSG_CHECKING(ncgi dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/ncgi* ${dir}/tcllib*/ncgi*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      NCGILIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(ncgilib, [  --with-ncgilib=DIR          use ncgi from DIR], NCGILIB=$withval,)
if test x$NCGILIB != x -a -d $NCGILIB; then
   AC_MSG_RESULT([using ncgi library in $NCGILIB])
else
   AC_MSG_ERROR(NCGI library directory not found)
fi
AC_SUBST(NCGILIB)
])

AC_DEFUN([AX_FILEUTIL],[
AC_MSG_CHECKING(fileutil dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/fileutil* ${dir}/tcllib*/fileutil*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      FILEUTILLIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(fileutillib, [  --with-fileutillib=DIR          use fileutil from DIR], FILEUTILLIB=$withval,)
if test x$FILEUTILLIB != x -a -d $FILEUTILLIB; then
   AC_MSG_RESULT([using fileutil library in $FILEUTILLIB])
else
   AC_MSG_ERROR(FILEUTIL library directory not found)
fi
AC_SUBST(FILEUTILLIB)
])

AC_DEFUN([AX_CMDLINE],[
AC_MSG_CHECKING(cmdline dir)
searchdirs=`echo 'puts $auto_path'|${HOSTTCLSH}`
for dir in $searchdirs ; do
  dirs="${dir}/cmdline* ${dir}/tcllib*/cmdline*"
  for i in $dirs ; do
    if test -d "$i" -a -f "$i/pkgIndex.tcl"; then
      CMDLINELIB=`cd $i; pwd`
    fi
  done
done
AC_ARG_WITH(cmdlinelib, [  --with-cmdlinelib=DIR          use cmdline from DIR], CMDLINELIB=$withval,)
if test -d $CMDLINELIB; then
   AC_MSG_RESULT([using CMDLINE library in $CMDLINELIB])
else
   AC_MSG_ERROR(CMDLINE library directory $CMDLINELIB doesn't exist)
fi
AC_SUBST(CMDLINELIB)
])
