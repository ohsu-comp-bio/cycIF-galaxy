#!/bin/bash

spacing=0.325

while getopts "p:v" opt; do
    case $opt in
        p)
            echo "pixel spacing will be: $OPTARG" >&2
            spacing=$OPTARG
            ;;
        v)
            echo "Verbose mode is enabled" >&2
            verbose=1
            ;;
        \?)
            echo "Invalid option -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument" >&2
            exit 1
            ;;
     esac
done
shift "$(($OPTIND -1))"

anyopts="-p ${spacing} "
if [[ $verbose = 1 ]]; then anyopts="${anyopts} -v "; fi

for arg in "$@"
do
	echo "Processing directory: ${arg}"
	# create output directory
	[ ! -d "$arg/OMETIFF" ] && mkdir ${arg}/OMETIFF
	name=`basename ${arg}`

	# determine name and location of exposure times file
	realbase=`echo $name | sed 's/-Scene.*//g'`
	expfilebase="${realbase}_ExposureTimes.csv"
	expfile="${arg}/../../${expfilebase}"
        if [ -f ${expfile} ]; then
                echo "     Using exposure times file: ${expfile}"
		anyopts="${anyopts} -e ${expfile} "
	fi
	python3 /usr/local/bin/cycif2ometiff.py ${anyopts} ${arg} ${arg}/OMETIFF/${name}
	echo "Done with: ${arg}"
done

echo "Done with all"

