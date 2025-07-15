#!/bin/sh

# change directory to the path of the current script
cd "$(dirname "$0")"

## install vunit from pypi
python -m pip uninstall "vunit_hdl" -y # remove existing vunit installations
python -m pip install --force-reinstall vunit_hdl==5.0.0.dev6 # install vunit

## install vunit-helpers from pypi
python -m pip install --force-reinstall VUnit-helpers==1.0.2

# clean vunit and list all tests
cd ./verification
python run.py --clean --list -v # list all tests
cd ../


echo "P2L2 project setup complete"