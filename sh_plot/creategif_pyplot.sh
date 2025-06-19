#!/bin/bash
fps=12
figdir="_plots"
if [ ! -d $figdir ]; then echo "Not found: directory $figdir" ; exit 0; fi

gifdir="_gif"
if [ ! -d $gifdir ]; then mkdir $gifdir ; fi

ffmpeg -i $figdir/frame%*fig0.png -vf palettegen palette.png -y
ffmpeg -r $fps -i $figdir/frame%*fig0.png -i palette.png -filter_complex paletteuse  $gifdir/fig0.gif -y
\rm palette.png

