#!/bin/bash

input_file="$1"
file_name="${input_file%.*}"
outpt_file="${file_name}-shadow.png"

if [[ ! -f "${input_file}" ]]; then
  echo -e "\033[0;91m File doesn't exist.\033[0m"
  exit 1
fi

type=$(file -b --mime-type "${input_file}" | awk -F/ '{print $1}')

if [[ $type != "image" ]]; then
  echo -e "\033[0;91m Not an\033[0;95m image\033[0;91m file.\033[0m"
  exit 1
fi

command -v magick &>/dev/null || {
  echo -e "\033[0;95m imagemagick\033[0;91m is not installed.\033[0m"
  exit 1
}

# top 30
# right 55
# bottom 80
# left 55

magick convert "$input_file" \
  \( +clone -shadow 55x27.5+0+23 \) \
  +swap \( +clone -background black -shadow 10x24+0+23 \) \
  +swap \( +clone -background black -shadow 20x20+0+23 \) \
  +swap \( +clone -background black -shadow 16x16+0+20 \) \
  +swap \( +clone -background black -shadow 10x12+0+18 \) \
  +swap \( +clone -background black -shadow 4x8+0+16 \) \
  +swap \( +clone -background black -shadow 2x6+0+14 \) \
  +swap -background transparent \
  -layers merge \
  +repage \
  "${outpt_file}"

echo -e "\033[0;92m Shadow completed:\033[0m ${outpt_file}"
