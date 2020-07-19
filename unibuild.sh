#!/bin/bash
[ "$MODDIR" == "" ] && export MODDIR=/usr/lib/unibuild/modules
for mod in $(ls $MODDIR) ; do
	source $MODDIR/$mod
done
source $1
source $MODDIR/../target/$TARGET
source $MODDIR/../host/$HOST
set -e
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
