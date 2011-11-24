#!/bin/sh
# GHETTO PUMMELVISION.COM
# BY JAMIE DUBS & THE FRIGGIN INTERNET

if [ -z $1 ]; then
  echo "Usage: $(basename $0) [directory containing only images]"
  exit 1
fi

dir=$1

fps=7.5
bitrate="800k"

tmpdir="/tmp/movieimgs"
output="output.mp4"

# Setup
rm -rf $tmpdir
mkdir -p $tmpdir

# Process and crop all source images
# Output them into a perfectly numbered, ffmpeg-friendly sequenced
x=1; for i in $dir/*; do
  counter=$(printf %03d $x)
  echo $counter ...
  # ln "$i" "$tmpdir"/img"$counter".jpg
  convert -gravity center -resize '1280x720' -extent '1280x720>' -background black $i "$tmpdir"/img"$counter".jpg
  x=$(($x+1))
done

# Generate video

### ffmpeg
# ffmpeg -f image2 -i $tmpdir/img%03d.jpg $output
# ffmpeg -y -r $fps -f image2 -b 1800k -i $tmpdir/img%03d.jpg $output
# ffmpeg -y -r $fps -f image2 -vcodec libx264 -b "$bitrate" -i $tmpdir/img%03d.jpg $output
# ffmpeg -y -r $fps -vcodec libx264 -b "$bitrate" -i $tmpdir/img%03d.jpg $output

### mencoder
# mencoder mf://*.jpg -mf w=1280:h=720:fps=8:type=jpg -ovc lavc -lavcopts vcodec=mpeg4:mbd=2:trell -oac copy -o output.avi
# *** QUALITY WINNER ***
mencoder -mc 0 -noskip -skiplimit 0 -ovc lavc -lavcopts vcodec=mpeg4:vhq:trell:mbd=2:vmax_b_frames=1:v4mv:vb_strategy=0:vlelim=0:vcelim=0:cmp=6:subcmp=6:precmp=6:predia=3:dia=3:vme=4:vqscale=1 "mf://*.jpg" -mf type=jpg:fps=8 -o output.avi


# Cleanup after ourselves
#rm -rf $tmpdir

# Open the file
# TODO only launch if `open` exists
open $output

exit 0
