#!/bin/bash
[ "$MODDIR" == "" ] && export MODDIR=/usr/lib/unibuild/modules
for mod in $(ls $MODDIR) ; do
	source $MODDIR/$mod
done
source $1
source $MODDIR/../target/$TARGET
echo $TARGET
set -e
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
