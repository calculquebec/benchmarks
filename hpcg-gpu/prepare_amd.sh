#!/bin/bash

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Check if the HPCG binary is already in the path...
if [ -x "$(command -v rochpcg)" ] ; then
    hpcg_path="$(realpath "$(command -v rochpcg)")"
    echo "rocHPCG binary was found in path here: ${hpcg_path}"
    echo "  -> This version will be preferred over any other"

    # Setting the symbolic link, if necessary
    if [ -e "./rochpcg" ] ; then
        echo "  -> ./rochpcg exists but will be replaced by a symlink to ${hpcg_path}"
        rm -f ./rochpcg
    fi

    echo -n "  -> Creating link ./rochpcg from ${hpcg_path}... "
    ln -s ${hpcg_path} rochpcg
    echo 'done!'
else
        echo -e "Error: unable to find 'rochpcg' in the PATH environment variable.\n"
        echo -e "If not done already, rochHPCG can be downloaded from this page:\n"
        echo -e "\https://github.com/ROCm/rocHPCG/\n"
fi
