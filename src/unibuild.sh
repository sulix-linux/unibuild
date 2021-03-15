#!/bin/bash
$(env | cut -f 1 -d '=' | sed "s/^/unset /")
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export USER=unibuild
export HOME=$(mktemp -d)
export SHELL=/bin/bash
declare -r unibuild_api_version=3
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
if [ -f "$1" ] || [ "$#" == "0" ] ; then
	source <(cat $1)
elif echo "$1" | grep "^.*://" &>/dev/null ; then
	source <(curl $1)
else
	err "Source not detected or not supported."
	exit 1
fi
fail_message() {
	err "$@"
	exit 1
}

source $MODDIR/../target/$TARGET
source $MODDIR/../host/$HOST

declare -r begintime=$(date +%s%3N)

msg ">>> Checking dependencies"
_get_build_deps || warn "Failed to check dependencies."
declare -r checktime=$(date +%s%3N)


cd $BUILDDIR
msg ">>> Getting sources"
_fetch || fail_message "Failed to get sources."
declare -r fetchtime=$(date +%s%3N)

msg ">>> Running hooks"
for hook in $(ls $MODDIR/../hooks | sort) ; do
	source $MODDIR/../hooks/$hook
done
if fn_exists "_setup" ; then
	cd $WORKDIR
	msg ">>> Running setup function"
	_setup || fail_message "Failed to run setup function."
fi
declare -r setuptime=$(date +%s%3N)

if fn_exists "_build" ; then
	cd $WORKDIR
	msg ">>> Running build function"
	_build || fail_message "Failed to run build function."
fi
declare -r buildtime=$(date +%s%3N)

if fn_exists "_check" ; then
	cd $WORKDIR
	msg ">>> Running check function"
	_build || warn "Failed to run check function."
fi
declare -r buildchecktime=$(date +%s%3N)

[ "$PKGS" == "" ] && PKGS=$name
for package in ${PKGS[@]} ; do
	export PKGDIR=$BUILDDIR/$package/package
	export INSTALLDIR=$BUILDDIR/$package/install
	export DESTDIR=$INSTALLDIR
	mkdir -p $PKGDIR $INSTALLDIR
	if fn_exists "_install" ; then
		cd $WORKDIR
		msg ">>> Running install function for $package"
		_install || fail_message "Failed to run install function for $package"
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
info "    Build Checking:     $(($buildchecktime-$buildtime))"
info "    Source installing:  $(($installtime-$buildchecktime))"
info "    Package generating: $(($packagetime-$installtime))"
info "    Total time:         $(($packagetime-$inittime))"
