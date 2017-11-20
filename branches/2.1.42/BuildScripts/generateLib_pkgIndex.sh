#!/bin/sh

cd $2
export LD_LIBRARY_PATH=`pwd`
echo "pkg_mkIndex -verbose -lazy . $3"|$1


