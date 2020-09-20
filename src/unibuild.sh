#!/bin/bash
declare -r unibuild_api_version=2
declare -r inittime=$(date +%s%3N)
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

declare -r begintime=$(date +%s%3N)

msg ">>> Checking dependencies"
_get_build_deps
declare -r checktime=$(date +%s%3N)


cd $BUILDDIR
msg ">>> Getting sources"
_fetch
declare -r fetchtime=$(date +%s%3N)

msg ">>> Running hooks"
for hook in $(ls $MODDIR/../hooks | sort) ; do
	source $MODDIR/../hooks/$hook
done
if fn_exists "_setup" ; then
	cd $WORKDIR
	msg ">>> Running setup function"
	_setup
fi
declare -r setuptime=$(date +%s%3N)

if fn_exists "_build" ; then
	cd $WORKDIR
	msg ">>> Running build function"
	_build
fi
declare -r buildtime=$(date +%s%3N)
[ "$PKGS" == "" ] && PKGS=$name
for package in ${PKGS[@]} ; do
	export PKGDIR=$BUILDDIR/$package/package
	export INSTALLDIR=$BUILDDIR/$package/install
	export DESTDIR=$INSTALLDIR
	mkdir -p $PKGDIR $INSTALLDIR
	if fn_exists "_install" ; then
		cd $WORKDIR
		msg ">>> Running install function for $package"
		_install
	fi
done
declare -r installtime=$(date +%s%3N)
for package in ${PKGS[@]} ; do
	export name=$package
	export PKGDIR=$BUILDDIR/$package/package
	export INSTALLDIR=$BUILDDIR/$package/install
	mkdir -p $PKGDIR $INSTALLDIR
	cd $WORKDIR
	msg ">>> Generating metadata"
	_create_metadata
	cd $WORKDIR
	msg ">>> Creating package"
	_package
done
declare -r packagetime=$(date +%s%3N)

msg ">>> Clearing workdir"
rm -rf $WORKDIR
info ">>> Done"

msg "Unibuild stats (milisec):"
info "    Unibuild init:      $(($begintime-$inittime))"
info "    Package Checking:   $(($checktime-$begintime))"
info "    Source fetching:    $(($fetchtime-$checktime))"
info "    Setup functions:    $(($setuptime-$fetchtime))"
info "    Source Building:    $(($buildtime-$setuptime))"
info "    Source installing:  $(($installtime-$buildtime))"
info "    Package generating: $(($packagetime-$installtime))"
info "    Total time:         $(($packagetime-$inittime))"
