#!/bin/bash

    # Copyright (C) 2014  Haruka Ma

    # This program is free software: you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation, either version 3 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License
    # along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Script description:
# see $0 -h or $0 --help

# reference cmd line:
# wine avs2yuv 265sc.avs -o - | ffmpeg -i - -i 
# /Volumes/Storage\ 1/\[HorribleSubs\]\ Denki-gai\ no\ Honya-san\ -\ 04\ \[1080p\].mkv
# -map 0:v -map 1:a -c:v libx265 -c:a libfdk_aac -b:a 128k -vf ass=/Users/MrX/Downloads/sc.ass
# -preset veryslow -x265-params crf=26:psy-rd=0.6:psy-rdoq=0.6 -y /Volumes/Storage\ 1/04sc265.mp4


function man {
    echo "SYNPOSIS"
    echo "  $0 -h"
    echo "  $0 -i avs_file [OPTION]... output"
    echo 
    echo "DESCRIPTION"
    echo "  This script is designed for Linux / OS X systems, and can make your encoding"
    echo "  job easier. It can utilize wine to use AviSynth, or if you don't  need  avs,"
    echo "  you can start encoding job faster than ever. It can also  encode  audio  and"
    echo "  add ass subtitles, producing a release-ready output file."
    echo 
    echo "REQUIREMENTS"
    echo "  Currently this script requires following tools to run correctly:"
    echo 
    echo "  o Working wine with AviSynth properly installed ( if you need avs );"
    echo "  o avs2yuv binary ( if you need avs );"
    echo "  o ffmpeg compiled with libx264 or libx265 for video, libfdk_aac  or  libopus"
    echo "    for audio, and libass for subtitles."
    echo 
    echo "  You may need to compile ffmpeg by yourself,  as  libfdk_aac  needs  non-free"
    echo "  configuration so ffmpeg binary will be non-distributable."
    echo 
    echo "OPTIONS"
    echo
    echo "  -h|--help"
    echo "    Show this page."
    echo 
    echo "  -i|--input video_source"
    echo "    Specify video source file without using avs. Cannot use with -avs."
    echo 
    echo "  -v|--avs avs_file"
    echo "    Specify input avs file. Only video will be  used,  and  make  sure  it  is"
    echo "    actually working. Cannot use with -i."
    echo 
    echo "  -x|--vformat video_format"
    echo "    Set video encoding. Valid formats are 'x264' and 'x265'. Defaults to x264."
    echo 
    echo "  -a|--audio audio_source"
    echo "    Specify audio source file. Could be any raw or container format. If avs is"
    echo "    not used, it defaults to video source file."
    echo 
    echo "  -b|--bitrate audio_bitrate"
    echo "    Set audio bitrate, like '128k' or '160k'. Valid only if  audio  source  is"
    echo "    specified. Defaults to 128k."
    echo 
    echo "  -f|--aformat audio_format"
    echo "    Set audio encoding format. Valid formats are  'aac',  'opus'  and  'copy'."
    echo "    Defaults according to video format, x264 defaults to aac and x265 defaults"
    echo "    to opus. Valid only if audio source is specified."
    echo 
    echo "  -s|--subtitle ass_file"
    echo "    Specify subtitle file to encode to the video (hardsubbing). It has to be a"
    echo "    ass file, and you have to make sure you  have  installed  required  fonts."
    echo "    ffmpeg will automatically rebuild the font cache if detected new fonts."
    echo 
    echo "EXAMPLES"
    echo 
    echo "  $0 --avs test.avs -a \"source 1080p.mkv\" test.mp4"
    echo "    Produces x264/aac file with default encoding settings (128k fdk_aac + x264"
    echo "    tingju preset)."
    echo 
    echo "  $0 --avs video.avs -a \"/Volume/Storage 1/04.mkv\" -x x265 -f copy output.mp4"
    echo "    Produces x265/aac file, copies audio track from specified  file  (assuming"
    echo "    audio source is aac) and encodes video with x265 haruka preset."
    echo 
    echo "  $0 -i source.mkv -x x265 -s ~/Documents/sc.ass sc.mkv"
    echo "    Produces x265/opus file with default encoding settings (128k opus  +  x265"
    echo "    haruka preset), and hardsubbing specified subtitle."
    echo 
    echo "ADDITIONAL NOTICE"
    echo 
    echo "  o As opus is not currently in ISO MP4 standard, jobs use opus encoding  will"
    echo "    produce mkv files. Other encoding options will produce  mp4  files.  Those"
    echo "    file types are NOT decided by output  file  extensions.  This  may  change"
    echo "    later as opus makes its way into the standard."
    echo "  o Tingju preset and haruka preset may change as the script updates.  To  see"
    echo "    the exact encoder settings, either read the script source or use mediainfo"
    echo "    on produced files."
    echo "  o You have to make sure that your ffmpeg has the needed libraries  compiled."
    echo "  o Use reasonable audio bitrate, as the script is not checking if your  input"
    echo "    is correct."
    echo "  o Make sure you have written the path correctly. Add quotes if needed."
    echo "  o While ffmpeg is clever enough to detect  some  font  name  fallbacks,  you"
    echo "    should make sure that it has used the correct font, especially on your 1st"
    echo "    use of the script or change of the font used."
    echo "  o The subtitle filter in ffmpeg currently REQUIRES a simple path to the  ass"
    echo "    file. It seems that it won't read the file if its path needs any escaping."
    echo "  o As ffmpeg uses libass to render the subtitles, some  non-standard  effects"
    echo "    won't work. It looks like that all VSFilter effects are supported."
    echo "  o It is NOT recommended to use VSFilter to provide subtitle rendering.  Some"
    echo "    fonts even won't work under wine (while I suspect  it's  related  to  some"
    echo "    specific environment). YMMV."
    echo 
}

function usage {
    echo "Usage: $0 [OPTION]... output"
    echo "See full help (-h) for options and their description."
    echo 
    echo "Make sure you read the full help before actual use!"
}

bitrate="128k"
vformat="x264"
fformat="mp4"
aformat="libfdk_aac"

echo "One-key encoding script version 0.1"
echo "Written by Haruka @ Makari"
echo "Original idea by Zht @ MakariTsukiyo"
echo 

if [ $# = 0 ]; then
    usage
    exit
else
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help )
                man
                exit;;
            -v | --avs )
                if [ -n "$inputfile" ]; then
                    echo "Use either avs or direct input!"
                    exit 1
                fi
                avsfile="$2"
                shift;;
            -i | --input )
                if [ -n "$avsfile" ]; then
                    echo "Use either avs or direct input!"
                    exit 1
                fi
                inputfile="$2"
                audiofile="$2"
                shift;;
            -x | --vformat )
                vformat="$2"
                if [ $vformat = "x264" ]; then
                    aformat="libfdk_aac"
                    fformat="mp4"
                elif [ $vformat = "x265" ]; then
                    aformat="libopus"
                    fformat="mkv"
                else
                    echo "Video format can only be x264 or x265!"
                    echo ""
                    exit 1
                fi
                shift;;
            -a | --audio)
                audiofile="$2"
                shift;;
            -f | --aformat )
                aformat="$2"
                if [ $aformat = "aac" ]; then
                    aformat="libfdk_aac"
                    fformat="mp4"
                elif [ $aformat = "opus" ]; then
                    aformat="libopus"
                    fformat="mkv"
                elif [ $aformat = "copy" ]; then
                    bitrate=
                    fformat="mp4"
                else
                    echo "Audio format can only be aac or opus!"
                    echo ""
                    exit 1
                fi
                shift ;;
            -b | --bitrate)
                bitrate="$2"
                shift;;
            -s | --subtitle )
                subtitle="$2"
                shift;;
            * )
                output="$1"
        esac
        shift
    done
fi

audiocmdline=
bitcmdline=
videocmdline=
subcmdline=
formatcmdline=
audiomap=

if [ -n "$bitrate" ]; then
    bitcmdline="-b:a $bitrate"
fi

if [ -n "$audiofile" ]; then
    audiocmdline="-i \"$audiofile\" -c:a $aformat $bitcmdline"
    if [ -n "$avsfile" ]; then
        audiomap="-map 0:v -map 1:a"
    fi
fi

if [ $vformat = "x265" ]; then
    videocmdline="-c:v libx265 -preset veryslow -x265-params crf=26:psy-rd=0.6:psy-rdoq=0.6"
else
    videocmdline="-c:v libx264 -crf 22 -x264-params deblockalpha=-1:deblockbeta=-1:keyint=720:min-keyint=24:b-pyramid=strict:aq-strength=0.8:qcomp=0.7:aq-mode=2:bframes=8:merange=32:me=umh:direct=auto:subme=10:trellis=2:psy-rd=0.9"
fi

if [ -n "$subtitle" ]; then
    subcmdline="-vf ass=\"$subtitle\""
fi

if [ $fformat = "mkv" ]; then
    formatcmdline="-f matroska"
else
    formatcmdline="-f mp4"
fi

if [ -n "$avsfile" ]; then
    cmdline="wine avs2yuv \"$avsfile\" -o - | ffmpeg -i - $audiocmdline $videocmdline $subcmdline $audiomap $formatcmdline -y \"$output\""
elif [ -n "$inputfile" ]; then
    cmdline="ffmpeg $audiocmdline $videocmdline $subcmdline $formatcmdline -y \"$output\""
fi

# echo "avsfile = $avsfile"
# echo "inputfile = $inputfile"
# echo "audiofile = $audiofile"
# echo "subtitle = $subtitle"
# echo "output = $output"
# echo "bitrate = $bitrate"
# echo "aformat = $aformat"
# echo "vformat = $vformat"
# echo "fformat = $fformat"
# echo 
eval $cmdline 
