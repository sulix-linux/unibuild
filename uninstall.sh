#!/bin/bash
if [ -x $DESTDIR/usr/bin/unibuild ]; then
	rm $DESTDIR/usr/bin/unibuild
fi
if [ -d $DESTDIR/usr/lib/unibuild ]; then
	rm -r $DESTDIR/usr/lib/unibuild/
fi