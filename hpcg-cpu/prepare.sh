#!/bin/bash

HPCG_VERSION="3.1"

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Check if the HPCG binary is already in the path...
if [ -x "$(command -v xhpcg)" ] ; then
    hpcg_path="$(realpath "$(command -v xhpcg)")"
    echo "HPCG binary was found in path here: ${hpcg_path}"
    echo "  -> This version will be preferred over any other"

    # Setting the symbolic link, if necessary
    if [ -e "./xhpcg" ] ; then
        echo "  -> ./xhpcg exists but will be replaced by a symlink to ${hpcg_path}"
        rm -f ./xhpcg
    fi

    echo -n "  -> Creating link ./xhpcg from ${hpcg_path}... "
    ln -s ${hpcg_path} xhpcg
    echo 'done!'
else
    echo -e "Error: unable to find 'xhpcg' in the PATH environment variable.\n"
    echo -e "If not done already, HPCG $HPCG_VERSION can be downloaded from this page:\n"
    echo -e "\thttp://www.hpcg-benchmark.org/downloads/hpcg-${HPCG_VERSION}.tar.gz\n"
    echo -e "Reminder: version $HPCG_VERSION of HPCG is mandatory."
    echo -e "  -> Compile it from the source code and add it to your PATH environment variable."
fi
