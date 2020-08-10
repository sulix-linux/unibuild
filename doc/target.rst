Create new target
=================

Target functions must be within **target/** directory in source code.
for adding automaticaly detecting target you should edit **modules/autotarget** file.
Target functions override unibuild files functions so you don't have to define unibuild function or variable in target file.
We need two functions. **_create_metadata** and **_package**. You can create helper functions.
Target functions run in **$PKGDIR**. 

__create_metadata
^^^^^^^^^^^^^^^^^

This function generate package info file. You should write package information and files list.
for example:

.. code-block:: shell

	_create_metadata(){
		mkdir $PKGDIR/info/
		echo "Name: $name" >> $PKGDIR/info/$name
		echo "Version: $version" >> $PKGDIR/info/$name
		echo "Summary: $summary" >> $PKGDIR/info/$name
		echo "Description: $description" >> $PKGDIR/info/$name
		cd $INSTALLDIR
		find >> $PKGDIR/info/$name.files
	}
	
_package
^^^^^^^^

This function create binary package file. You should compress or archive build files.
Installed files avaiable in **$INSTALLDIR**. You can copy all files in **$INSTALLDIR** to **$PKGDIR**.
for example:

.. code-block:: shell

	cp -prfv $INSTALLDIR/* $PKGDIR/
	cd $PKGDIR
	tar -cf $CURDIR/$name-$version.tar *
