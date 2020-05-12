#!/bin/sh
set -e
install_python() {
	VERSION=$1
	echo "Installing python version: $VERSION...!!!"
	pyenv install $VERSION
	pyenv global $VERSION
}

for i in "$@"
do
case $i in
    -v=*|--python_version=*)
    PYTHON_VERSION="${i#*=}"
    shift # past argument=value
    ;;
    *)
          # unknown option
    ;;
esac
done

if [ -z $PYTHON_VERSION ]; then
	echo "=========================__WARNING__========================="
	echo "No python_version specified....! Using python 2.7.x "
	echo "============================================================="
fi
if [ ! -z $PYTHON_VERSION ] && [ $PYTHON_VERSION == 2.7.0 ] || [ $PYTHON_VERSION == 2.7 ]; then
	echo "Using python_version: 2.7.x"
else
	echo "Preparing to install python $PYTHON_VERSION"
	install_python $PYTHON_VERSION
fi
SYS_PY_VER=$(python --version 2>&1)
echo "System python version: $SYS_PY_VER"
