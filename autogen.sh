#!/bin/bash
autoreconf --install
[[ -n $NOCONFIGURE ]] || ./configure
