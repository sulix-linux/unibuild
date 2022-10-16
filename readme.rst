unibuild
========
The universal **build** script system.

Easy install
============

.. code-block:: shell

	curl -s https://gitlab.com/sulix/devel/sources/unibuild/-/raw/master/netinst.sh | bash -s --

for install
===========
Automatic way

.. code-block:: shell

    DESTDIR=*your_DESTDIR* bash install.sh

Manual way

.. code-block:: shell

    NOCONFIGURE bash autogen.sh
    ./configure --prefix=/usr
    make && make install


Simple usage
============
[TARGET=*your_target*] **unibuild** [*file/url*]

Documentation
=============
Visit https://gitlab.com/sulix/devel/unibuild/-/blob/master/doc/building.rst
