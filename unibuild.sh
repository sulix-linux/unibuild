#!/bin/bash
set -e
[ "$MODDIR" == "" ] && export MODDIR=/usr/lib/unibuild/modules
for mod in $(ls $MODDIR) ; do
	source $MODDIR/$mod
done
if [ -f "$1" ] ; then
	source $1
elif "echo $1" | grep "^.*://" &>/dev/null ; then
	wget $1 -O /tmp/unibuild.file
	source /tmp/unibuild.file
else
	echo "Source not detected or not supported."
	exit 1
fi
source $MODDIR/../target/$TARGET
source $MODDIR/../host/$HOST
_get_build_deps
cd $BUILDDIR
_fetch
cd $WORKDIR
_setup
cd $WORKDIR
_build
cd $WORKDIR
_install
cd $WORKDIR
_create_metadata
cd $WORKDIR
_package
rm -rf $WORKDIR
