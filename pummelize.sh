#!/bin/sh

dir=$1
if [ -z "$dir" ]; then
  echo "Usage: $(basename $0) [directory containing only images]"
  exit 1
fi

# Options
# 7 is too slow; 8 is slightly too fast
fps=7.5

tmpdir="/tmp/movieimgs"
output="output.mp4"

# Setup
rm -rf "$tmpdir"
mkdir -p "$tmpdir"

# Process and crop all source images
# Output them into a perfectly numbered, ffmpeg-friendly sequence
x=1; for i in "$dir"/*; do
  counter=$(printf %06d $x)
  echo "$counter ..."
  convert -gravity center -resize '1280x720' -extent '1280x720>' -background black "$i" "$tmpdir"/img"$counter".jpg
  x=$(($x+1))
done

# Generate video with ffmpeg
# -framerate: input fps
# -c:v libx264: H.264 codec (widely compatible)
# -pix_fmt yuv420p: pixel format for compatibility
# -crf 18: quality (lower = better, 18 is visually lossless)
ffmpeg -y -framerate "$fps" -i "$tmpdir/img%06d.jpg" \
  -c:v libx264 -pix_fmt yuv420p -crf 18 \
  "$output"

# Open the file
which -s open && open "$output"

exit 0
