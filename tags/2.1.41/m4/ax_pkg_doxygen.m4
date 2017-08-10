# SYNOPSIS
#
#   AX_PKG_DOXYGEN([major.minor.micro], [action-if-found], [action-if-not-found])
#
# DESCRIPTION
#
#   This macro searches for a DOXYGEN installation on your system. If found,
#   then DOXYGEN is AC_SUBST'd; if not found, then $DOXYGEN is empty.
#
#   You can use the optional first argument to check if the version of the
#   available DOXYGEN is greater than or equal to the value of the argument. It
#   should have the format: N[.N[.N]] (N is a number between 0 and 999. Only
#   the first N is mandatory.) If the version argument is given (e.g.
#   1.3.17), AX_PKG_DOXYGEN checks that the doxygen package is this version number
#   or higher.
#
#   As usual, action-if-found is executed if doxygen is found, otherwise
#   action-if-not-found is executed.
#
#   In configure.in, use as:
#
#     AX_PKG_DOXYGEN(1.3.17, [], [ AC_MSG_ERROR([DOXYGEN is required to build..]) ])
#
# LICENSE
#
#   Copyright (c) 2013 Robert Heller <heller@deepsoft.com>
#	(hacked from ax_pkg_swig.m4)
#   Copyright (c) 2008 Sebastian Huber <sebastian-huber@web.de>
#   Copyright (c) 2008 Alan W. Irwin
#   Copyright (c) 2008 Rafael Laboissiere <rafael@laboissiere.net>
#   Copyright (c) 2008 Andrew Collier
#   Copyright (c) 2011 Murray Cumming <murrayc@openismus.com>
#
#   This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation; either version 2 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <http://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.

AC_DEFUN([AX_PKG_DOXYGEN],[
        AC_PATH_PROGS([DOXYGEN],[doxygen])
        if test -z "$DOXYGEN" ; then
                m4_ifval([$3],[$3],[:])
        elif test -n "$1" ; then
                AC_MSG_CHECKING([DOXYGEN version])
                [doxygen_version=`$DOXYGEN -help 2>&1 | grep 'Doxygen version' | sed 's/.*\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/g'`]
                AC_MSG_RESULT([$doxygen_version])
                if test -n "$doxygen_version" ; then
                        # Calculate the required version number components
                        [required=$1]
                        [required_major=`echo $required | sed 's/[^0-9].*//'`]
                        if test -z "$required_major" ; then
                                [required_major=0]
                        fi
                        [required=`echo $required | sed 's/[0-9]*[^0-9]//'`]
                        [required_minor=`echo $required | sed 's/[^0-9].*//'`]
                        if test -z "$required_minor" ; then
                                [required_minor=0]
                        fi
                        [required=`echo $required | sed 's/[0-9]*[^0-9]//'`]
                        [required_patch=`echo $required | sed 's/[^0-9].*//'`]
                        if test -z "$required_patch" ; then
                                [required_patch=0]
                        fi
                        # Calculate the available version number components
                        [available=$doxygen_version]
                        [available_major=`echo $available | sed 's/[^0-9].*//'`]
                        if test -z "$available_major" ; then
                                [available_major=0]
                        fi
                        [available=`echo $available | sed 's/[0-9]*[^0-9]//'`]
                        [available_minor=`echo $available | sed 's/[^0-9].*//'`]
                        if test -z "$available_minor" ; then
                                [available_minor=0]
                        fi
                        [available=`echo $available | sed 's/[0-9]*[^0-9]//'`]
                        [available_patch=`echo $available | sed 's/[^0-9].*//'`]
                        if test -z "$available_patch" ; then
                                [available_patch=0]
                        fi
                        # Convert the version tuple into a single number for easier comparison.
                        # Using base 100 should be safe since DOXYGEN internally uses BCD values
                        # to encode its version number.
                        required_doxygen_vernum=`expr $required_major \* 10000 \
                            \+ $required_minor \* 100 \+ $required_patch`
                        available_doxygen_vernum=`expr $available_major \* 10000 \
                            \+ $available_minor \* 100 \+ $available_patch`

                        if test $available_doxygen_vernum -lt $required_doxygen_vernum; then
                                AC_MSG_WARN([DOXYGEN version >= $1 is required.  You have $doxygen_version.])
                                DOXYGEN=''
                                m4_ifval([$3],[$3],[])
                        fi
                else
                        AC_MSG_WARN([cannot determine DOXYGEN version])
                        DOXYGEN=''
                        m4_ifval([$3],[$3],[])
                fi
        fi
])
