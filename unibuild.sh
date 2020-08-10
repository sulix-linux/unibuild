#!/bin/bash
[ -f $HOME/.unibuildrc ] && source $HOME/.unibuildrc
[ "$MODDIR" == "" ] && export MODDIR=/usr/lib/unibuild/modules
set -e
for api in $(ls $MODDIR/../api | sort) ; do
	source $MODDIR/../api/$api
done
for mod in $(ls $MODDIR) ; do
	source $MODDIR/$mod
done
if [ -f "$1" ] ; then
	source <(cat $1)
elif echo "$1" | grep "^.*://" &>/dev/null ; then
	source <(curl $1)
else
	err "Source not detected or not supported."
	exit 1
fi
source $MODDIR/../target/$TARGET
source $MODDIR/../host/$HOST

msg ">>> Checking dependencies"
_get_build_deps
cd $BUILDDIR
msg ">>> Getting sources"
_fetch
msg ">>> Running hooks"
for hook in $(ls $MODDIR/../hooks | sort) ; do
	source $MODDIR/../hooks/$hook
done
if fn_exists "_setup" ; then
	cd $WORKDIR
	msg ">>> Running setup function"
	_setup
fi
if fn_exists "_build" ; then
	cd $WORKDIR
	msg ">>> Running build function"
	_build
fi
if fn_exists "_install" ; then
	cd $WORKDIR
	msg ">>> Running install function"
	_install
fi
cd $WORKDIR
msg ">>> Generating metadata"
_create_metadata
cd $WORKDIR
msg ">>> Creating package"
_package
msg ">>> Clearing workdir"
rm -rf $WORKDIR
info ">>> Done"
