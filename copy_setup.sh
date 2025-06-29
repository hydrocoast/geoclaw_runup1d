#!/bin/bash
if [ "$#" -lt 2 ]; then
    echo "invalid number of the argument"
    echo "usage: $0 [sim directory ORG] [sim directory NEW] "
    exit 0
fi

rsync -av "$1/" "$2/" --exclude="_output*/" --exclude="_plots/" \
	              --exclude="_jld2/" --exclude="_mat/" \
		      --exclude="_grd/" --exclude="*.data" \
	              --exclude=".*" --exclude="*.swp" \
		      --exclude="*.kml" --exclude="*.log" \
		      --exclude="xgeoclaw" --exclude="*.out" \
		      --exclude="*.mod" --exclude="*.o" \
		      --exclude="__pycache__/" --exclude="*.html" \
		      --exclude="_gif/" \
		      --exclude="*.sh.*" --exclude="*.png"
