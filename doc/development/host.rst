Create new host
=================

Host file must be within **host/** directory. For auto detecting host, you should edit **modules/autohost** file.

Only **_get_build_deps** function needed. We must use **builddepends** array con check and install build dependencies.

for example:

.. code-block:: shell

	_get_build_deps(){
		needed="" #missing package list
		for i in ${builddepends[@]}
		do
			[ -f /info/$i ] || needed="$needed $i"
		done
		if [ "$needed" != "" ] ; then
		    err "Missing: $needed" 
		    .... # package installation command or exit
		fi
	}
