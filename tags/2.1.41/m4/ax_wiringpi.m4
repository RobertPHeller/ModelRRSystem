# SYNOPSIS
#
#   AX_WIRINGPI
#
# DESCRIPTION
#
#   This macro searches for a wiringPi installation on your system. If found,
#   HAVE_WIRINGPI is AC_SUBST'd to 1; if not found, then HAVE_WIRINGPI 
#   AC_SUBST'd to 0.  Also, WIRINGPI_CFLAGS is set to -I/path/to/wiringPi.h 
#   and WIRINGPI_LDFLAGS is set to -L/path/to/libwiringPi.so and WIRINGPI_LIBS
#   is set to -lwiringPi
#
#   In configure.in, use as:
#
#     AX_WIRINGPI
#

AC_DEFUN([AX_WIRINGPI],
[
AC_ARG_WITH([wiringPi],
    [AS_HELP_STRING([--with-wiringPi@<:@=ARG@:>@],
     [use wiringPi library from a standard location (ARG=yes),
      from the specified location (ARG=<path>),
      or disable it (ARG=no)
      @<:@ARG=yes@:>@ ])],
     [
      if test "$withval" = "no"; then
        want_wiringPi="no"
      elif test "$withval" = "yes"; then
        want_wiringPi="yes"
        ac_wiringPi_path=""
      else
        want_wiringPi="yes"
        ac_wiringPi_path="$withval"
      fi
      ],
      [want_wiringPi="yes"])
      
AC_ARG_WITH([wiringPi-libdir],
        AS_HELP_STRING([--with-wiringPi-libdir=LIB_DIR],
        [Force given directory for wiringPi libraries. Note that this will override library path detection, so use this parameter only if default library detection fails and you know exactly where your wiringPi libraries are located.]),
        [
        if test -d "$withval"
        then
            ac_wiringPi_lib_path="$withval"
        else
            AC_MSG_ERROR(--with-wiringPi-libdir expected directory name)      
        fi
        ],
        [ac_wiringPi_lib_path=""]
)
if test "x$want_wiringPi" = "xyes"; then
   AC_MSG_CHECKING(for wiringPi lib)
   succeeded=no
   dnl first we check the system location for wiringPi libraries
   if test "$ac_wiringPi_path" != ""; then
       WIRINGPI_CFLAGS="-I$ac_wiringPi_path/include"
       if test -d "$ac_boost_path"/"lib" ; then
          WIRINGPI_LDFLAGS="-L$ac_boost_path/lib"
       fi
   else
       for ac_wiringPi_path_tmp in /usr /usr/local /opt /opt/local ; do
           if test -e "$ac_wiringPi_path_tmp/include/wiringPi.h" &&
              test -e "$ac_wiringPi_path_tmp/lib/libwiringPiDev.so"; then
              WIRINGPI_LDFLAGS="-L$ac_wiringPi_path_tmp/lib"
              WIRINGPI_CFLAGS="-I$ac_wiringPi_path_tmp/include"
              break;
           fi
       done
   fi
   if test "$ac_wiringPi_lib_path" != ""; then
       WIRINGPI_LDFLAGS="-L$ac_wiringPi_lib_path"
   fi
   CFLAGS_SAVED=$CFLAGS
   CFLAGS="$CFLAGS $WIRINGPI_CFLAGS"
   export CFLAGS

   LDFLAGS_SAVED="$LDFLAGS"
   LDFLAGS="$LDFLAGS $WIRINGPI_LDFLAGS"
   export LDFLAGS

   AC_REQUIRE([AC_PROG_CC])
   AC_LANG_PUSH(C)
      AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
      @%:@include <stdio.h>
      @%:@include <wiringPi.h>
   ]], [[int main (void) {wiringPiSetup(); return 0 ;}]])],[
      AC_MSG_RESULT(yes)
   succeeded=yes
   found_system=yes
      ],[
      ])
   AC_LANG_POP([C])
   if test "$succeeded" != "yes" ; then
      AC_MSG_RESULT(no)
      AC_SUBST(HAVE_WIRINGPI,0)
   else
      AC_SUBST(WIRINGPI_CFLAGS)
      AC_SUBST(WIRINGPI_LDFLAGS)
      AC_SUBST(WIRINGPI_LIBS,[-lwiringPi])
      AC_SUBST(HAVE_WIRINGPI,1)
   fi
   CFLAGS="$CFLAGS_SAVED"
   LDFLAGS="$LDFLAGS_SAVED"
fi
])

