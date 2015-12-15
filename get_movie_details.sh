#!/bin/bash
# ---------------------------------------------------------------------------
# get_movie_details.sh

# 2015, Mocanu Silviu <johnyc20@gmail.com>

# Usage: get_movie_details.sh [file|directory]

# Require AtomicParsley, avprobe, ffprobe 

# Revision history:
# 2015-12-15  Created

# ---------------------------------------------------------------------------


function get_bitrate () { # use avprobe from libav-tools
    avprobe -show_format "${1}" 2> /dev/null | grep "bit_rate" | sed 's/.*bit_rate=\([0-9]\+\).*/\1/g';
}

function get_resolution () { # use ffprobe from ffmpeg
    eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width ${1})
    size=${streams_stream_0_width}x${streams_stream_0_height}
    echo $size
}

function get_moov () { # use AtomicParsley from atomicparsley
    if $(AtomicParsley ${1} -T | sed -n 2p | grep -q "moov");then
        echo "OK";
    else
        echo "BAD";
    fi

}

function get_all_details () { # get all details for movie
    br=$(get_bitrate ${1});
    rs=$(get_resolution ${1})
    mo=$(get_moov ${1})
    echo "$1, Bitrate: ${br}, Resolution: ${rs}, Moov: ${mo}"
}

# get all details for movie used as argument or for all movies in the directory used as argument to script
if [[ -f $1 ]]; then
    echo "** Checking movie ${1} ...";
    get_all_details ${1};
elif [[ -d $1 ]]; then
    echo "** Checking all movies in the ${1} path ...";
    for f in $(find $1 -type f -name '*.mp4');do
        get_all_details ${f}
    done;
else
    echo "Usage $0 [movie|directory]!"
fi
