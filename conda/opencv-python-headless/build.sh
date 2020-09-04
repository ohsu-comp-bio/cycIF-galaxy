#!/bin/bash

if [ `uname` == Darwin ]; then
    pip install https://files.pythonhosted.org/packages/b8/46/adc2e1e0e94c8a61a70f6be25237ff01d5e97bcc292f15756f11ea75e405/opencv_python-4.4.0.42-cp37-cp37m-macosx_10_13_x86_64.whl
fi

if [ `uname` == Linux ]; then
    pip install https://files.pythonhosted.org/packages/fa/e3/7ed67a8f3116113a364671fb4142c446dd804c63f3d9df5c11168a1e4dbb/opencv_python-4.4.0.42-cp37-cp37m-manylinux2014_x86_64.whl
fi
