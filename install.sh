#!/bin/bash
NOCONFIGURE=1 ./autogen.sh
./configure --prefix=/usr
make
make install
