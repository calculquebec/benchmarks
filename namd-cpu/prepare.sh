#!/bin/bash

namd_version="3.0b6"
#archive_id="1695"    # Linux-x86_64-multicore (64-bit Intel/AMD single node)
#archive_id="1699"    # Linux-x86_64-multicore-AVX512 (x86_64 AVX-512)

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Check if the namd3 binary is already in the path...
if [ -x "$(command -v namd3)" ] ; then
    namd3_path="$(realpath "$(command -v namd3)")"
    echo "namd3 was found in path here: ${namd3_path}"
    echo "This version will be preferred over any other"

    # Setting the symbolic link, if necessary
    if [ -e "./namd3" ] ; then
        echo "./namd3 exists but will be replaced by a symbolic link"
        rm -f ./namd3
    fi

    echo "Linking ${namd3_path} to ./namd3"
    ln -s ${namd3_path} namd3
else
    arch_base="NAMD_${namd_version}_Linux-x86_64-multicore"
    arch_avx512="NAMD_${namd_version}_Linux-x86_64-multicore-AVX512"
    filename=""
    if [ -f $arch_avx512.tar.gz ] ; then
      filename=$arch_avx512.tar.gz
      arch=$arch_avx512
    elif [ -f $arch_base.tar.gz ] ; then
      filename=$arch_base.tar.gz
      arch=$arch_base
    fi

    # Untar NAMD binary package if necessary
    if [ -f $filename ]; then
        if [[ ! -d $arch ]]; then
            echo Extracting $filename...
            tar -xf $filename
        fi
        if [ -e "./namd3" ] ; then
            echo "./namd3 exists but will be replaced by a new symbolic link"
            rm -f ./namd3
        fi
        echo "Linking ${PWD}/$arch/namd3 to ./namd3"
        ln -s ${PWD}/$arch/namd3 namd3
    else
        echo -e "Unable to find 'namd3' with the PATH environment variable."
        echo -e "Unable to find '$filename' in:\n\n\t${PWD}\n"
        echo -e "NAMD $namd_version can be downloaded from this page:\n"
        echo -e "    https://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD\n"
        echo -n "You must use version ${namd_version} of NAMD. "
        echo -n "You may either use the binary version of NAMD, or compile "
        echo "namd3 from the source code and add its location to your PATH."
    fi
fi

STMV="stmv.tar.gz"
if [ -f $STMV ]; then
	echo Extracting some benchmark files from $STMV
	tar -zxf stmv.tar.gz stmv/par_all27_prot_na.inp stmv/stmv.pdb stmv/stmv.psf
	cp stmv_cq.namd stmv/stmv_cq.namd
else 
	echo -e "Unable to find stmv benchmark file archive '$STMV' in:\n\n\t${PWD}\n"
	echo -e "The archive can be downloaded from this link: \n"
	echo -e "\thttps://www.ks.uiuc.edu/Research/namd/utilities/stmv.tar.gz"
fi
