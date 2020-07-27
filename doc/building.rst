Building with unibuild
======================
**Unibuild** need a build spec. Build spec must be bash script. *name* *version* *release* *summary* *description* variables and *_setup* *_build* *_install* functions uses. For example:

.. code-block:: shell

	#!/bin/bash
	name="bash"
	version="5.0"
	summary="bash shell"
	description="The bash shell"
	source=(https://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz)
	_setup(){
		./configure --prefix=/usr
	}

	_build(){
		make
	}

	_install(){
		make install DESTDIR=$INSTALLDIR
	}
	

BUILDDIR
^^^^^^^^
Main directory that uses for all operations. Unibuild create 3 directory for building. **WORKDIR** **INSTALLDIR** **PKGDIR**
All directories in builddir. Unibuild created builddir with **mktemp -d** command.

**1. WORKDIR**

Workdir is building directory. Before running functions, unibuild go workdir. Workdir is changeable variable. If only one source directory in workdir. unibuild automaticaly change workdir as source directory.

**2. INSTALLDIR**

Installdir is package destdir. Spec must store package files in here.

**3. PKGDIR**

Pkgdir is packaging directory required by target packager.

Build functions
^^^^^^^^^^^^^^^
If you dont define functions, unibuild try to detect build method and create automaticaly. Or you can define **BuildType** variable for creating build function as automaticaly. Also you can define **CONFIG_OPTIONS** variable for auto build options. For example:

.. code-block:: shell

	#!/bin/bash
	name="bash"
	version="5.0"
	summary="Bash shell"
	description="The bash shell"
	builddepends=("gcc")
	depends=("readline")
	license="gplv3"
	source=(https://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz)
	BuildType="autotools"
	
This example uses autotools for compiling. autotools define build functions look like this:

.. code-block:: shell

	_setup(){
		./configure --prefix=/usr $CONFIG_OPTIONS
	}

	_build(){
		make -j$(nproc)
	}

	_install(){
		make install DESTDIR=$INSTALLDIR
	}
	
The gnu bash source code has ./configure script so if you dont define build functions, unibuild detect and set **BuildType** variable.

Function calling order: _setup => _build => _install

Build target and host
^^^^^^^^^^^^^^^^^^^^^
Unibuild is universali builder so supported most of distribution. You can define **TARGET** and **HOST** variables.

========    =================================================
VARIABLE    DESCRIPION
========    =================================================
TARGET      Package build target: debian, inary, appimage ...
HOST        Builder distribution: debian, inary ...
========    =================================================

host and target automaticaly detected if you dont define.

Spec variables
^^^^^^^^^^^^^^
Unibuild spec variables and description avaiable here:

========     ============    ========================================================     =======
OPTIONAL     VARIABLE        DESCRIPION                                                   Type
========     ============    ========================================================     =======
no           name            Package name.                                                String
no           version         Package version. Only can use [0-9] or . or -                String
no           release         Package release.                                             Integer
no           sources         Package source code url or path.                             Array
**yes**      executable      Package main executable name. Used by appimage               String
no           description     Package description.                                         String
no           summary         Package summary.                                             String
**yes**      builddepends    Package names that required by compiling.                    Array
**yes**      depends         Package runtime dependencies.                                Array
no           license         Source code license.                                         String
**yes**      partof          Package section or component name.                           String
**yes**      categories      Appilcation categories. Used by appimage                     String
**yes**      icon            Application icon name or path. Used by appimage              String
**yes**      arch            Package architecture. if dont define, auto detected.         String
**yes**      maintainer      Package maintainer name.                                     String
**yes**      email           Packager email.                                              String
**yes**      isa             Package type. Used by inary.                                 Array
========     ============    ========================================================     =======

Unibuild supported different source types. All known source types:

1. name::git://xxxx.git

2. git+https://xxxxx.git

3. name::https://xxxxx

4. /path/to/name/xxx

5. https://xxxxxx

