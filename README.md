Ghettovision
===================

This script will assemble a directory of images into a video of
fast-moving images, like <http://pummelvision.com> by [@jakelodwick](https://github.com/jakelodwick)

1. read a directory of input images
2. generate letterboxed 1280x720 JPEG intermediates
3. encode intermediates into sexy MPEG4 video
4. add your own music and enjoy!

Dependencies
------------

* imagemagick (`convert`)
* mplayer (`mencoder`)

On a Mac, install [Homebrew](http://mxcl.github.com/homebrew/) and run:

    brew install imagemagick mplayer

Usage
-----

    cd ghettovision
    ./pummelize.sh ~/Desktop/madjpgs


License
-------

This source code released under an MIT license


Authors
-------

* [Jamie Dubs](http://jamiedubs.com) ([@jamiew](https://github.com/jamiew))
