#!/bin/bash
#
#++++++++++++++++++++++++++++++++++++++++
# this script converts format ass to lrc
#++++++++++++++++++++++++++++++++++++++++

input_file="$1"
outpt_file="${input_file%.*}.lrc"
file_extension=$(echo ${input_file##*.} | awk '{print tolower($0)}')

if [ ! -f "${input_file}" ]; then
  echo -e "\033[0;91m File doesn't exist.\033[0m"
  exit 1
elif [ "${file_extension}" != "ass" ]; then
  echo -e "\033[0;91m Not an\033[0;95m ass\033[0;91m document.\033[0m"
  exit 1
fi


# lrc file content
content="\
[ti:Lyrics (song) title]
[ar:Lyrics artist]
[al:Album where the song is from]
[au:Creator of the Songtext]
[by:Creator of the LRC file]
[offset:+/- Overall timestamp adjustment in milliseconds, + shifts time up, - shifts down]
"

# Example
# -------
# Dialogue: 0,0:00:00.40,0:00:09.00,Default,,0,0,0,,*
regex='Dialogue:[[:space:]]*[0-9]+,([0-9]+:([0-9]{2}:[0-9]{2}\.[0-9]{2})),([0-9]+:([0-9]{2}:[0-9]{2}\.[0-9]{2})),.*,.*,.*,.*,.*,.*,(.*)'

# read ass file, convert
while IFS='' read -r line || [[ -n "${line}" ]]; do
  if [[ "${line}" =~ ${regex} ]]; then
    time_start=${BASH_REMATCH[2]}
    time_stop=${BASH_REMATCH[4]}
    context=${BASH_REMATCH[5]}

    content+="\n[${time_start}]${context}"
  fi
done < "${input_file}"

# write to file
echo -e "${content}" > "${outpt_file}"
