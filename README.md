GHETTO PUMMELVISION
===================

This script will assemble a directory of images into a video of
fast-moving images, just like <http://pummelvision.com> by [@jakelodwick](https://github.com/jakelodwick)

The script will read a directory of input images, generate letterboxed 1280x720 JPEG copies,
then encode them all into an MPEG4 video.

Dependencies
============

* imagemagick (`convert`)
* mplayer (`mencoder`)

On a Mac, install [Homebrew](http://mxcl.github.com/homebrew/) and run:

  brew install imagemagick mplayer

Usage
=====

  ./pummelize.sh ~/Desktop/madjpgs


License
=======

Source code released under an MIT License


Authors
============

* [Jamie Dubs](http://jamiedubs.com) ([@jamiew](https://github.com/jamiew))