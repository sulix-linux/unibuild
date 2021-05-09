#!/bin/bash
if [ "$UID" != "0" ] ; then
    if which fakeroot &>/dev/null ; then
        exec fakeroot $0 $@
    else
        echo "Fakeroot not found."
        echo "Please install fakeroot or use root."
        exit 1
    fi
else
    if [ "$FAKEROOTKEY" == "" ] ; then
        echo "Do you want to continue building with root user? [y/N]"
        read -s -n 1 c
        if [ "$c" != "Y" ] || [ $c != "y" ] ; then
            echo "Operation canceled."
            exit 1
        fi
    fi
fi
export UNIBUILDRC="$HOME/.unibuildrc"
$(env | cut -f 1 -d '=' | grep -v "TARGET" | grep -v "UNIBUILDRC" | grep -v "HOST" | grep -v "DISTRO" | sed "s/^/unset /")
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export USER=unibuild
export HOME=$(mktemp -d)
export SHELL=/bin/bash
declare -r unibuild_api_version=4
declare -r inittime=$(date +%s%3N)
[ -f "$UNIBUILDRC" ] && source "$UNIBUILDRC"
[ "$MODDIR" == "" ] && export MODDIR=/usr/lib/unibuild/modules
set -e
for api in $(ls $MODDIR/../api | sort) ; do
	source $MODDIR/../api/$api
done
for mod in $(ls $MODDIR) ; do
	source $MODDIR/$mod
done
import_source "$1"

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

run_function setup
declare -r setuptime=$(date +%s%3N)

run_function build
declare -r buildtime=$(date +%s%3N)

run_function check
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
msg ">>> Running post hooks"
export INSTALLDIR=$BUILDDIR/$package/install
for hook in $(ls $MODDIR/../posthooks | sort) ; do
	source $MODDIR/../posthooks/$hook
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
