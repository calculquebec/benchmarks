#!/bin/bash

if [[ ! -f NPB3.4.1.tar.gz ]]; then
	wget https://www.nas.nasa.gov/assets/npb/NPB3.4.1.tar.gz
fi
if [[ ! -d NPB3.4.1 ]]; then
	tar xzvf NPB3.4.1.tar.gz
fi

cp suite.def NPB3.4.1/NPB3.4-OMP/config
cp make.def NPB3.4.1/NPB3.4-OMP/config

cd NPB3.4.1/NPB3.4-OMP
make suite


