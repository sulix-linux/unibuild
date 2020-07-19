#!/bin/bash
[ "$MODDIR" == "" ] && export MODDIR=/usr/lib/unibuild/modules
set -e
for mod in $(ls $MODDIR) ; do
	echo "Loading: $mod"
	source $MODDIR/$mod
done
if [ -f "$1" ] ; then
	source <(cat $1)
elif echo "$1" | grep "^.*://" &>/dev/null ; then
	source <(curl $1)
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
