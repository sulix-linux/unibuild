#!/bin/bash
mkdir -p  $DESTDIR/usr/lib/unibuild || true
mkdir -p  $DESTDIR/usr/bin || true
cp -prfv src/* $DESTDIR/usr/lib/unibuild
chmod +x -R $DESTDIR/usr/lib/unibuild/*
mv $DESTDIR/usr/lib/unibuild/unibuild.sh $DESTDIR/usr/bin/unibuild
