#!/bin/bash

while getopts ":d:p:l:o:a:" opt; do
    case $opt in
        d)
            echo "ip is: $OPTARG" >&2
            IP=${OPTARG}
            ;;
        p)
            echo "port is: $OPTARG" >&2
            PORT=${OPTARG}
            ;;
        l)
            echo "login is: $OPTARG" >&2
            LOGIN=${OPTARG}
            ;;
        a)
            echo "ffmpeg bin is: $OPTARG" >&2
            BIN=${OPTARG}
            ;;
        o)
            echo "out dir is: $OPTARG" >&2
            OUTDIR=${OPTARG}
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

echo "    __    __  ________                           __           "
echo "   / /   / / / / ____/___  ____ _   _____  _____/ /____  _____"
echo "  / /   / /_/ / /   / __ \/ __ \ | / / _ \/ ___/ __/ _ \/ ___/"
echo " / /___/ __  / /___/ /_/ / / / / |/ /  __/ /  / /_/  __/ /    "
echo "/_____/_/ /_/\____/\____/_/ /_/|___/\___/_/   \__/\___/_/"
echo "===================================================================="
echo "A script for lowqual music library conversion over ssh - by kokoscript"
echo "===================================================================="
echo "Working on album/folder: ${PWD##*/}"
echo "===================================================================="
echo "${LOGIN}@${IP}, on port ${PORT}"
echo "===================================================================="

# TODO: Have the script go through any subdirectories recursively, so converting an entire library is possible

echo "Creating a temporary mount point..."
sudo mkdir /mnt/ssh
echo "Made mount point at /mnt/ssh"

echo "Now mounting..."
# NOTE: The mount is done using pubkeys, so if there isn't a pubkey setup present, uh... what are you doing?
sudo sshfs -o allow_other,IdentityFile=${HOME}/.ssh/id_rsa "$LOGIN"@"$IP":/ /mnt/ssh -p $PORT
echo "Mounted."

echo  -e "\033[33;5mWARNING\033[0m"
echo "THIS SCRIPT WILL WORK ON ANY FILE THAT IS IN THIS CURRENT FOLDER. MAKE SURE YOU HAVE PLACED IT IN THE ALBUM BEFORE CONTINUING!!"
echo "(Press ENTER to continue)"
read na

echo "Making album/compilation directory on target server..."
mkdir "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}"
echo "All is well"

# actually convert
echo "Now beginning conversion/transfer, fasten your seatbelts..."
# NOTE: The ffmpeg convert commands force stream 0:0 to be converted in order to avoid the album art being interpreted as a video stream... yeah, it happens.

# convert from flac to aac
for i in *.flac;
  do name=`echo $i | cut -d'.' -f1`;
  echo "Now converting: ${name}, in FLAC format to AAC";
  ${BIN} -i "$i" -loglevel panic -map 0:0 -c:a libfdk_aac -b:a 128k "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/${name}.m4a";
  echo "==============================================================";
done

# convert from mp3 to aac OR not if the original file is small enough
for i in *.mp3;
do name=`echo $i | cut -d'.' -f1`;
  echo "Now converting: ${name}, in MPEG3 format to AAC/ORIG";
  FILESIZE=$(stat -c%s "${name}.mp3")
  echo "The file size of the original mp3 is: ${FILESIZE}"
  # check if the mp3 is less than 8MB - if it aint, convert that sucker to aac
  if [ ${FILESIZE} -lt 8000000 ]
  then
    echo "The original mp3 of this audio is less than 8MB, copying that instead of converting to aac..."
    cp "${name}.mp3" "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/"
  else
    echo "The original mp3 of this audio is greater than 8MB, converting to aac to save space"
    ${BIN} -i "${name}.mp3" -loglevel panic -map 0:0 -c:a libfdk_aac -b:a 128k "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/${name}.m4a";
  fi
  echo "==============================================================";
done

# convert from xm to aac OR wav if the initial export by xmp is small enough
for i in *.xm;
do name=`echo $i | cut -d'.' -f1`;
  echo "Now converting: ${name}, in Fasttracker II format to AAC/WAV";
  xmp "$i" -o "${name}.wav" -q;
  FILESIZE=$(stat -c%s "${name}.wav")
  echo "The file size of the wav export is: ${FILESIZE}"
  # check if the initial wav is less than 8MB - if it aint, convert that sucker to aac
  if [ ${FILESIZE} -lt 8000000 ]
  then
    echo "The wav export of this audio is less than 8MB, copying that instead of converting to aac..."
    cp "${name}.wav" "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/"
  else
    echo "The wav export of this audio is greater than 8MB, converting to aac to save space..."
    ${BIN} -i "${name}.wav" -loglevel panic -map 0:0 -c:a libfdk_aac -b:a 128k "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/${name}.m4a";
  fi
  echo "==============================================================";
  rm "${name}.wav"
done

# convert from mod to aac OR wav if the initial export by xmp is small enough
for i in *.mod;
do name=`echo $i | cut -d'.' -f1`;
  echo "Now converting: ${name}, in Amiga MOD format to AAC/WAV";
  xmp "$i" -o "${name}.wav" -q;
  FILESIZE=$(stat -c%s "${name}.wav")
  echo "The file size of the wav export is: ${FILESIZE}"
  # check if the initial wav is less than 8MB - if it aint, convert that sucker to aac
  if [ ${FILESIZE} -lt 8000000 ]
  then
    echo "The wav export of this audio is less than 8MB, copying that instead of converting to aac..."
    cp "${name}.wav" "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/"
  else
    echo "The wav export of this audio is greater than 8MB, converting to aac to save space..."
    ${BIN} -i "${name}.wav" -loglevel panic -map 0:0 -c:a libfdk_aac -b:a 128k "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/${name}.m4a";
  fi
  echo "==============================================================";
  rm "${name}.wav"
done

# convert from it to aac OR wav if the initial export by xmp is small enough
for i in *.it;
do name=`echo $i | cut -d'.' -f1`;
  echo "Now converting: ${name}, in ImpulseTracker format to AAC/WAV";
  xmp "$i" -o "${name}.wav" -q;
  FILESIZE=$(stat -c%s "${name}.wav")
  echo "The file size of the wav export is: ${FILESIZE}"
  # check if the initial wav is less than 8MB - if it aint, convert that sucker to aac
  if [ ${FILESIZE} -lt 8000000 ]
  then
    echo "The wav export of this audio is less than 8MB, copying that instead of converting to aac..."
        cp "${name}.wav" "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/"
    else
        echo "The wav export of this audio is greater than 8MB, converting to aac to save space..."
        ${BIN} -i "${name}.wav" -loglevel panic -map 0:0 -c:a libfdk_aac -b:a 128k "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/${name}.m4a";
    fi
    echo "==============================================================";
    rm "${name}.wav"
done

# convert from s3m to aac OR wav if the initial export by xmp is small enough
for i in *.s3m;
do name=`echo $i | cut -d'.' -f1`;
    echo "Now converting: ${name}, in Screamtracker3 format to AAC/WAV";
    xmp "$i" -o "${name}.wav" -q;
    FILESIZE=$(stat -c%s "${name}.wav")
    echo "The file size of the wav export is: ${FILESIZE}"
    # check if the initial wav is less than 8MB - if it aint, convert that sucker to aac
    if [ ${FILESIZE} -lt 8000000 ]
    then
        echo "The wav export of this audio is less than 8MB, copying that instead of converting to aac..."
        cp "${name}.wav" "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/"
    else
        echo "The wav export of this audio is greater than 8MB, converting to aac to save space..."
        ${BIN} -i "${name}.wav" -loglevel panic -map 0:0 -c:a libfdk_aac -b:a 128k "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/${name}.m4a";
    fi
    echo "==============================================================";
    rm "${name}.wav"
done

# TODO: NSF to aac (SERIOUSLY WHAT TOOL???)

# copy album art imgs
for i in *.jpg;
  do name=`echo $i | cut -d'.' -f1`;
  echo "Copying JPG album art or other image: ${name}";
  cp $i "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/";
done
for i in *.jpeg;
  do name=`echo $i | cut -d'.' -f1`;
  echo "Copying JPG album art or other image: ${name}";
  cp $i "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/";
done
for i in *.png;
  do name=`echo $i | cut -d'.' -f1`;
  echo "Copying PNG album art or other image: ${name}";
  cp $i "/mnt/ssh/home/${LOGIN}/${OUTDIR}/${PWD##*/}/";
done

# unmount and clean up
echo "Unmounting..."
# sudo umount /mnt/ssh
echo "Removing mount point..."
# sudo rm -rf /mnt/ssh
echo "All finished!"
