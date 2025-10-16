#!/bin/bash
usage_exit() {
        echo "Usage: $0 [-r fps] " 1>&2
        exit 1
}

## optional arg
while getopts r:h OPT
do
    case $OPT in
        r)  fps=$OPTARG
            ;;
        h)  usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done
if [ -z "$fps" ]; then
    fps=6
fi
shift $((OPTIND - 1))

figdir="_plots"
if [ ! -d $figdir ]; then echo "Not found: directory $figdir" ; exit 0; fi

gifdir="_gif"
if [ ! -d $gifdir ]; then mkdir $gifdir ; fi

ffmpeg -i $figdir/frame%*fig0.png -vf palettegen palette.png -y
ffmpeg -r $fps -i $figdir/frame%*fig0.png -i palette.png -filter_complex paletteuse  $gifdir/fig0.gif -y
\rm palette.png

