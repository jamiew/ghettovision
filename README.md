Ghettovision
===================

Assemble a directory of images into a video of fast-moving images, like
[Pummelvision](https://techcrunch.com/2010/12/23/pummelvision/) by [@jakelodwick](https://github.com/jakelodwick)

1. read a directory of input images, turning phone photos the right way up
2. generate letterboxed 1280x720 JPEG intermediates (or cropped to fill, at any size)
3. encode intermediates into sexy H.264 video
4. add your own music and enjoy!

Example: [our dog Ollie growing up, set to Spoon](https://jamiedubs.com/ghettovision/)

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

Options:

    ./pummelize.sh -s 1024x768 ~/Desktop/madjpgs  # 4:3 frames, like most phone photos
    ./pummelize.sh -c ~/Desktop/madjpgs            # crop to fill the frame, no black bars
    ./pummelize.sh -r 25/3 ~/Desktop/madjpgs       # 25/3 fps is 5 frames per beat at 100 BPM

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
