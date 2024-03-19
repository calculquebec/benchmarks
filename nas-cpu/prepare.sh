#!/bin/bash

VERSION="3.4.2"
FLAVOR="3.4-OMP"

if [[ ! -f NPB${VERSION}.tar.gz ]]; then
	wget https://www.nas.nasa.gov/assets/npb/NPB${VERSION}.tar.gz
fi
if [[ ! -d NPB${VERSION} ]]; then
	tar -zxvf NPB${VERSION}.tar.gz
fi

cp suite.def make.def NPB${VERSION}/NPB${FLAVOR}/config/

cd NPB${VERSION}/NPB${FLAVOR}
make suite
