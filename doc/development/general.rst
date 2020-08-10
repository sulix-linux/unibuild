MODDIR
=====
Include order : *api -> modules -> unibuild file -> host -> target -> hooks* All imports are alphabeticaly.

Moddir contains unibuild **modules**, **api**,  **hooks**,  **target** and **host** directories.


Modules
^^^^^
Unibuild modules in here. modules included and called before unibuild files. Defining main functins and detecting target and host functions in here. Also default fallback variables defined here. Unibuild require **_fetch** function for getting sources. Other functions are optional.

Api
^^^
Unibuild helper function defined here. Included before unibuild files. All functions are optional. Modules can use api functions.

Hooks
^^^^
Hook functions included after unibuild files so override unibuild files. you don't have to define unibuild function or variable in here. All hook functions are optional.

Target
^^^^
Target functions are package manager specific functions. More detail : doc/development/target.rst

Host
^^^^
Host functions are distribution specific functions. More detail : doc/development/host.rst

unibuildrc file
========
Firstly imported file. **$HOME/.unibuildrc**
All unibuild functions override unibuildrc file.

