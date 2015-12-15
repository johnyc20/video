#!/bin/bash
# ---------------------------------------------------------------------------
# fix_movie_moov.sh

# 2015, Mocanu Silviu <johnyc20@gmail.com>

# Usage: fix_movie_moov.sh [file|directory]

# Require AtomicParsley, MP4Box 

# Revision history:
# 2015-12-15  Created

# ---------------------------------------------------------------------------

function check_movie_moov () { # use AtomicParsley from atomicparsley
    AtomicParsley ${1} -T | sed -n 2p | grep -q "moov";
}

function fix_movie_moov () { # move the moov header to the begining of the moviea, use MP4Box from gpac
    MP4Box -add ${1} -isma ${2};
}

function check_and_fix_movie_moov() { # check moov header and move it, if it is not OK
    if ! check_movie_moov ${1};then
        echo "Movie ${1} has a bad MOOV header, moving it ... ";
        omn="${1%.*}-old.${1#*.}" # old movie name
        mv ${1} ${omn} # renaming movie to "-old"
        fix_movie_moov ${omn} ${1}; # fix it
    else
        echo "Movie ${1} has a good MOOV header, nothing to do ... ";
    fi
}

# get all details for movie used as argument or for all movies in the directory used as argument to script
if [[ -f $1 ]]; then
    echo "** Checking movie ${1} ...";
    check_and_fix_movie_moov ${1}
elif [[ -d $1 ]]; then
    echo "** Checking all movies in the ${1} path ...";
    for f in $(find $1 -type f -name '*.mp4');do
        check_and_fix_movie_moov ${f}
    done;
else
    echo "Usage $0 [movie|directory]!"
fi
