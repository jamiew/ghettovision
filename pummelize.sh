#!/bin/sh

dir=$1
if [ -z $dir ]; then
  echo "Usage: $(basename $0) [directory containing only images]"
  exit 1
fi


# Options
fps=8

tmpdir="/tmp/movieimgs"
output="output.avi"

# Setup
rm -rf $tmpdir
mkdir -p $tmpdir

# Process and crop all source images
# Output them into a perfectly numbered, ffmpeg-friendly sequenced
x=1; for i in $dir/*; do
  counter=$(printf %06d $x)
  echo -n "$counter ..."
  # ln "$i" "$tmpdir"/img"$counter".jpg
  convert -gravity center -resize '1280x720' -extent '1280x720>' -background black $i "$tmpdir"/img"$counter".jpg
  x=$(($x+1))
done

# Generate video
# ** Attempts:
# ffmpeg -f image2 -i $tmpdir/img%06d.jpg $output
# ffmpeg -y -r $fps -f image2 -b 1800k -i $tmpdir/img%06d.jpg $output
# ffmpeg -y -r $fps -f image2 -vcodec libx264 -b "2000k" -i $tmpdir/img%06d.jpg $output
# ffmpeg -y -r $fps -vcodec libx264 -b "2000k" -i $tmpdir/img%06d.jpg $output
# mencoder mf://*.jpg -mf w=1280:h=720:fps=8:type=jpg -ovc lavc -lavcopts vcodec=mpeg4:mbd=2:trell -oac copy -o output.avi
# ** Winner:
mencoder -mc 0 -noskip -skiplimit 0 -ovc lavc -lavcopts \
  vcodec=mpeg4:vhq:trell:mbd=2:vmax_b_frames=1:v4mv:vb_strategy=0:vlelim=0:vcelim=0:cmp=6:subcmp=6:precmp=6:predia=3:dia=3:vme=4:vqscale=1 \
  "mf://$tmpdir/*.jpg" -mf type=jpg:fps=$fps -o $output


# Open the file
which -s open && open $output

exit 0
