Introduction
------------

I made this script so I could download World Junior games 
and watch them on my media centre which can't handle playing 
video with a flash player in a browser.

Requirements
------------

This script requries K-S-V's AdobeHDS tool. K-S-V/Scripts@eeee6439bd2d7be5d9c35f302ae87623640c5b6b

You will also need avconv, which is part of the Libav package. 
Apparently this is the successor to ffmpeg.

Configurations
-------------

Before running, you should set few options.

1. The script will only download games from one country. Set it here:

        COUNTRY="Canada"

2. Once you have install K-S-V's tool, you need to tell the script where to find it:

        ADOBEHDS="/usr/local/bin/AdobeHDS.php"

3. And last but not least, you must define where you want the game files to be store.

        DIR="/shared/server/Videos/Hockey"
