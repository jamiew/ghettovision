Ghettovision
===================

Assemble a directory of images into a video of fast-moving images, like
[Pummelvision](http://pummelvision.com) by [@jakelodwick](https://github.com/jakelodwick)

1. read a directory of input images
2. generate letterboxed 1280x720 JPEG intermediates
3. encode intermediates into sexy H.264 video
4. add your own music and enjoy!

Dependencies
------------

* imagemagick (`convert`)
* ffmpeg

On a Mac:

    brew install imagemagick ffmpeg

Usage
-----

    cd ghettovision
    ./pummelize.sh ~/Desktop/madjpgs

Extracting from Google Slides
-----------------------------

Pull slides directly from Google Slides URLs (private or public):

    # One-time setup
    brew install rclone poppler
    pip install -r requirements.txt
    rclone config  # see below

    # Extract slides
    python extract_slides.py "https://docs.google.com/presentation/d/1ABC.../edit"

    # Create video
    ./pummelize.sh slides/

### rclone setup (one-time)

    rclone config

1. `n` - New remote
2. Name: `gdrive`
3. Storage: `drive` (Google Drive)
4. Leave client_id and client_secret blank (press Enter)
5. Scope: `1` (full access)
6. Leave root_folder_id blank
7. Leave service_account_file blank
8. `n` - No advanced config
9. `y` - Auto config (opens browser for OAuth)
10. `n` - Not a shared drive
11. `y` - Confirm

Extracting from PDF/PPTX
------------------------

    python extract_slides.py presentation.pdf
    python extract_slides.py presentation.pptx  # requires LibreOffice

    ./pummelize.sh slides/

License
-------

MIT license

Authors
-------

* [Jamie Dubs](http://jamiedubs.com) ([@jamiew](https://github.com/jamiew))
