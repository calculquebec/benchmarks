#!/bin/bash

namd_version="2.13"
archive_id="1566"    # Linux-x86_64-multicore-CUDA (NVIDIA CUDA acceleration)

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Check if the namd2 binary is already in the path...
if [ -x "$(command -v namd2)" ] ; then
    namd2_path="$(realpath "$(command -v namd2)")"
    echo "namd2 was found in path here: ${namd2_path}"
    echo "This version will be preferred over any other"

    # Setting the symbolic link, if necessary
    if [ -e "./namd2" ] ; then
	    echo "./namd2 exists but will be replaced by a symlink to ${namd2_path}"
	    rm -f ./namd2
    fi

    echo "Linking ${namd2_path} to ./namd2"
    ln -s ${namd2_path} namd2
else
    arch="NAMD_${namd_version}_Linux-x86_64-multicore-CUDA"
    filename="$arch.tar.gz"

    # Untar NAMD binary package if necessary
    if [ -f $filename ]; then 
        echo Extracting $filename...
        tar -xf $filename
	if [ -e "./namd2" ] ; then
            echo "./namd2 exists but will be replaced by a link to ${PWD}/$arch/namd2"
            rm -f ./namd2
        fi
        echo "Linking ${PWD}/$arch/namd2 to ./namd2"
        ln -s ${PWD}/$arch/namd2 namd2
    else
        echo -e "Unable to find 'namd2' in the PATH environment variable or '$filename' in:\n\n\t${PWD}\n"
        echo -e "NAMD $namd_version can be downloaded from this page:\n"
        echo -e "\thttp://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD\n"
        echo -n "You must use version CUDA $namd_version of NAMD. "
        echo -e "You may either use the binary version of NAMD, downloadable from this address:\n"
        echo -e "\thttp://www.ks.uiuc.edu/Development/Download/download.cgi?UserID=&AccessCode=&ArchiveID=${archive_id}\n"
        echo "or compile namd2 CUDA from source files and add it to your PATH environment variable."
    fi
fi
