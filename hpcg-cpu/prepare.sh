#!/bin/bash

HPCG_VERSION="3.1"
URL="https://www.hpcg-benchmark.org/downloads/hpcg-${HPCG_VERSION}.tar.gz"

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Check if the HPCG binary is already in the path...
if [ -x "$(command -v xhpcg)" ] ; then
    hpcg_path="$(realpath "$(command -v xhpcg)")"
    echo -e "HPCG binary found from PATH:\n\n  ${hpcg_path}\n"
    echo "  -> This version will be preferred over any other"

    # Setting the symbolic link, if necessary
    if [ -e "./xhpcg" ] ; then
        echo "  -> ./xhpcg exists but will be replaced by a symbolic link"
        rm -f ./xhpcg
    fi

    echo -n "  -> Creating link ./xhpcg ... "
    ln -s ${hpcg_path} xhpcg
    echo 'done!'
else
    echo -e "Error: unable to find 'xhpcg' in the PATH environment variable.\n"
    echo -e "1) If not done already, download HPCG ${HPCG_VERSION}:\n"
    echo -e "\t${URL}\n"
    echo "2) Extract the TAR archive and compile xhpcg from the source code."
    echo "3) Add xhpcg's parent directory to your PATH environment variable."
fi
