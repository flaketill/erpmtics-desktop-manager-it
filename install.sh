#!/usr/bin/env bash
#===================================================================================
# -*- coding: utf-8 -*-

#Author: Ing. Armando Ibarra
#Email: armandoibarra1@gmail.com
#Date: 27/03/2014 

#variables
THIS_SCRIPT_PATH=`readlink -f $0`
THIS_SCRIPT_DIR=`dirname ${THIS_SCRIPT_PATH}`

WINE_TARBALL=${THIS_SCRIPT_DIR}/wine.tar.gz

#dependences
#bbfreeze


#function wine for linux
wine_linux(){


if [ "$WINEPREFIX" = "" ]; then
    echo "WINEPREFIX is not set. This script freezes WINEPREFIX to ${WINE_TARBALL}"
    exit 1
fi

echo "Freezing $WINEPREFIX to ${WINE_TARBALL}"

cd ${WINEPREFIX}
tar -czf "${WINE_TARBALL}" .
}

if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'

  #Check permission
  sudo chown $USER -R ${THIS_SCRIPT_DIR}/build/
  sudo chown $USER -R ${THIS_SCRIPT_DIR}/dist/

  sudo chmod 775 -R ${THIS_SCRIPT_DIR}/build/
  sudo chmod 775 -R ${THIS_SCRIPT_DIR}/dist/

  #sudo python2 setup.py install
  #import site; site.getsitepackages()
  python2 -c "import site; print(site.getsitepackages())"
  #python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"
  if [ -n "$1" ]; then
  	mkdir tmp
  	curl https://raw.github.com/erpmtics/master/$1/erpmtics-desktop.zip -o tmp/erpmtics-desktop.zip
  	rm -fr app/vendor/erpmtics
  	unzip tmp/erpmtics.zip -d app/vendor
  	mv app/vendor/erpmtics-$1 app/vendor/erpmtics
  	rm -fr app/vendor/erpmtics/docs
  else
	  echo "Usage: update-erpmtics <version>"
  fi

  #run pyinstaller
  #python2 pyinstaller --windowed main.py
  pyinstaller --windowed main.py

  sudo python2 setup.py build
  sudo python2 setup.py install
  sudo python2 setup.py bdist_esky

elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
  OS='Cygwin'
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

#
