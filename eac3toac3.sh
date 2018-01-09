#!/bin/bash

set -euo pipefail

[ $# -eq 0 ] && echo "Parameter missing. Usage: $0 filename.mkv" && exit -1

MKV_INPUT="$1"
IFILE=$(basename "$MKV_INPUT")
DIR=$(dirname "$MKV_INPUT")

# extension="${FILE##*.}"
IFILE="${IFILE%.*}"

# get E-AC3 audio track ID from MKV container
LINE=$(LANG=C mkvinfo "${MKV_INPUT}" | grep "Codec ID" | grep -n "A_EAC3" | cut -d":" -f1)
AUDIO_ID=$(( $LINE - 1 ))

# extract E-AC3 audio track from MKV container
mkvextract tracks "$MKV_INPUT" ${AUDIO_ID}:"${DIR}/${IFILE}.eac3"

# convert E-AC3 audio file to a standart AC3 file
avconv -i "${DIR}/${IFILE}.eac3" -b 640k -c:a ac3 "${DIR}/${IFILE}.ac3"

# merge AC3 audio file with MKV container
mkvmerge -o "${DIR}/${IFILE}-AC3.mkv" --language 0:eng "${DIR}/${IFILE}.mkv" --language 0:eng "${DIR}/${IFILE}.ac3"

# remove extracted audio files
rm "${DIR}/${IFILE}.ac3" "${DIR}/${IFILE}.eac3"
