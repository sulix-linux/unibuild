Building with unibuild
======================
**Unibuild** need a build spec. Build spec must be bash script. *name* *version* *release* *summary* *description* variables and *_setup* *_build* *_check* *_install* functions uses. For example:

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

Function calling order: _setup => _build => _check => _install

Build target and host
^^^^^^^^^^^^^^^^^^^^^
Unibuild is universal builder so supported most of distribution. You can define **TARGET** and **HOST** variables.

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
no           description     Package description.                                         String
no           license         Source code license.                                         String
no           name            Package name.                                                String
no           source          Package source code url or path.                             Array
no           summary         Package summary.                                             String
no           version         Package version. Only can use [0-9] or . or -                String
**yes**      arch            Package architecture. if dont define, auto detected.         String
**yes**      backup          Package backup names.                                        Array
**yes**      builddepends    Package names that required by compiling.                    Array
**yes**      categories      Appilcation categories. Used by appimage                     String
**yes**      checkdepends    Package check dependencies.                                  Array 
**yes**      conflicts       Package conflict names.                                      Array
**yes**      depends         Package runtime dependencies.                                Array
**yes**      email           Packager email.                                              String
**yes**      executable      Package main executable name. Used by appimage               String
**yes**      groups          Package group names.                                         Array
**yes**      homepage        Project homepage.                                            String
**yes**      icon            Application icon name or path. Used by appimage              String
**yes**      isa             Package type. Used by inary.                                 Array
**yes**      maintainer      Package maintainer name.                                     String
**yes**      optdepends      Package optional dependencies.                               Array
**yes**      partof          Package section or component name.                           String
**yes**      PKGS            Main and splited package names list.                         Array
**yes**      priority        Package priority.                                            String
**yes**      provides        Package provide names.                                       Array
**yes**      release         Package release. Used by inary.                              Integer
**yes**      replaces        Package replace names.                                       Array
========     ============    ========================================================     =======

Unibuild supported different source types. All known source types:

1. name::git://xxxx.git::branch

2. git+https://xxxxx.git::branch

3. name::https://xxxxx

4. /path/to/name/xxx

5. https://xxxxxx

Split package
^^^^^^^^^^^^^

Unibuild uses **PKGS** array for getting package names. We have *main* package and *splited* packages. Main package is first **PKGS** array item. If you did not define this aray unibuild use **name** value main package name and do not splite.

Unibuild define and create **INSTALLDIR** and **PKGDIR** directories for every *splited* and *main* packages and run **_install** functions.

Unibuild change **package** value when run **_install** function.

You can split package like this:

.. code-block:: shell

	PKGS=("main" "splited")
	_install(){
		if is_pkg "splited" ; then
			takedir "main" "/path/to/stuff"
    			return
		fi
		make install DESTDIR=$INSTALLDIR
	}
	
**takedir** function move files or directories from main package.

**is_package** function return true if current package is splited package.

**return** for stop function block 
