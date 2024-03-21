#!/bin/bash

namd_version="3.0b6"
archive_id="1694"    # Linux-x86_64-multicore-CUDA (NVIDIA CUDA acceleration)

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Check if the namd3 binary is already in the path...
if [ -x "$(command -v namd3)" ] ; then
    namd3_path="$(realpath "$(command -v namd3)")"
    echo "namd3 was found in path here: ${namd3_path}"
    echo "This version will be preferred over any other"

    # Setting the symbolic link, if necessary
    if [ -e "./namd3" ] ; then
	    echo "./namd3 exists but will be replaced by a symlink to ${namd3_path}"
	    rm -f ./namd3
    fi

    echo "Linking ${namd3_path} to ./namd3"
    ln -s ${namd3_path} namd3
else
    arch="NAMD_${namd_version}_Linux-x86_64-multicore-CUDA"
    filename="$arch.tar.gz"

    # Untar NAMD binary package if necessary
    if [ -f $filename ]; then 
        echo Extracting $filename...
        tar -xf $filename
	if [ -e "./namd3" ] ; then
            echo "./namd3 exists but will be replaced by a link to ${PWD}/$arch/namd3"
            rm -f ./namd3
        fi
        echo "Linking ${PWD}/$arch/namd3 to ./namd3"
        ln -s ${PWD}/$arch/namd3 namd3
    else
        echo -e "Unable to find 'namd3' in the PATH environment variable or '$filename' in:\n\n\t${PWD}\n"
        echo -e "NAMD $namd_version can be downloaded from this page:\n"
        echo -e "\thttp://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD\n"
        echo -n "You must use version CUDA $namd_version of NAMD. "
        echo -e "You may either use the binary version of NAMD, downloadable from this address:\n"
        echo -e "\thttp://www.ks.uiuc.edu/Development/Download/download.cgi?UserID=&AccessCode=&ArchiveID=${archive_id}\n"
        echo -e "or compile namd3 with CUDA or ROCM support from source files and add it to your PATH environment variable."
	echo  "At the time of publication, NAMD binaries with ROCM support are not available and NAMD must be compile from source on AMD GPU platforms"
    fi
fi

STMV="stmv_gpu.tar.gz"
if [ -f $STMV ]; then
	echo Extracting some benchmark files from $STMV
	tar -zxf stmv_gpu.tar.gz stmv_gpu/par_all27_prot_na.inp stmv_gpu/stmv.pdb stmv_gpu/stmv.psf
	cp stmv_gpures_npt.namd stmv_gpu/stmv_gpures_cq.namd
else 
	echo -e "Unable to find stmv benchmark file archive '$STMV' in:\n\n\t${PWD}\n"
	echo -e "The archive can be downloaded from this link: \n"
	echo -e "\thttps://www.ks.uiuc.edu/Research/namd/benchmarks/systems/stmv_gpu.tar.gz"
fi
