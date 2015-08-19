#!/bin/bash
# Install an App Bundle under MacOSX
# $1 == Application.app
# $2 == $(bindir)
#
for bf in `find $1`; do
   if [ -d $bf ] ; then
      echo "install -d $2/$bf"
      install -d $2/$bf
   elif [ -x $bf ] ; then
      echo "install $bf $2/$bf"
      install $bf $2/$bf
   else
      echo "install -m 644 $bf $2/$bf"
      install -m 644 $bf $2/$bf
   fi
done
  
