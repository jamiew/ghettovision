#!/bin/sh

usage() {
  echo "Usage: $(basename "$0") [-s WIDTHxHEIGHT] [-c] [-r FPS] [directory containing only images]"
  echo "  -s  frame size (default 1280x720). Most phone photos are 4:3, so try 1024x768"
  echo "  -c  crop each image to fill the frame instead of letterboxing it"
  echo "  -r  frames per second (default 7.5); fractions like 25/3 work too"
  exit 1
}

# Options
size="1280x720"
fill=0
# 7 is too slow; 8 is slightly too fast
fps=7.5
while getopts "s:cr:h" opt; do
  case $opt in
    s) size=$OPTARG ;;
    c) fill=1 ;;
    r) fps=$OPTARG ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

dir=$1
if [ -z "$dir" ]; then
  usage
fi

# "1024x768^" resizes to cover the frame, so -extent crops instead of padding
if [ "$fill" = 1 ]; then
  resize="$size^"
else
  resize="$size"
fi

tmpdir="/tmp/movieimgs"
output="output.mp4"

# Setup
rm -rf "$tmpdir"
mkdir -p "$tmpdir"

# Process and crop all source images
# Output them into a perfectly numbered, ffmpeg-friendly sequence
# -auto-orient: phones save portrait photos sideways plus a rotation tag
x=1; for i in "$dir"/*; do
  counter=$(printf %06d $x)
  echo "$counter ..."
  convert "$i" -auto-orient -resize "$resize" -background black -gravity center -extent "$size" "$tmpdir"/img"$counter".jpg
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
