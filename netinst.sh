tmpdir=$(mktemp -d)
cd $tmpdir
wget https://gitlab.com/sulix/devel/unibuild/-/archive/master/unibuild-master.tar.gz -O unibuild.tar.gz
tar -xf unibuild.tar.gz
cd unibuild-master
bash install.sh
