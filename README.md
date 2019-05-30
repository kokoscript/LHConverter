**LHConverter - "Large Hadron Converter"**

by kokoscript

LHConverter makes it simple to take "mastered" audio files from one PC, convert them to AAC\*, and send it all to a server that is designed to host smaller-sized audio files. This all takes place over a ssh server.

\*small mp3/converted wav files will be accepted and will skip the conversion step, however over a certain size they will be converted to aac

***Prerequisites***
- ffmpeg (compiled with support for libfdk_aac)
- xmp 4.1 (or greater)
- a ssh setup configured for use with pubkey authentication

***Source file format support***
- FLAC
- MP3 (converted to aac only if the MP3 is >= 8MB)
- XM/MOD/IT/S3M (converted to wav first by xmp - if the wav is >= 8MB, it will be converted to aac - otherwise, the wav is copied
- NSF (to be added - are there any utilities that can convert NSF on the command line?)

Almost every other format supported by xmp should be easily added to the script - check the other formats to see how they may be added.

***Usage***

`./LargeHadronConverter -d {destination ip} -l {destination login name} -p {destination port} -o {destination folder (relative to /home/LOGIN/} -a {location of ffmpeg bin}`
