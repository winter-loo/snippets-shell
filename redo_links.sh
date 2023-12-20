#!/bin/bash

if [ $# -ne 2 ]; then
  echo "usage $0 source_dir target_dir"
  exit 0
fi

source_dir="$1"
target_dir="$2"


get_relative_directory() {
  link_from_dir="$1"
  link_to_dir="$2"

  # split into array
  OLDIFS=$IFS
  IFS='/'
  read -ra dir1 <<< "$link_from_dir"
  read -ra dir2 <<< "$link_to_dir"
  IFS="$OLDIFS"

  # get minimum length of two arrays
  min_len_dir=${#dir1[@]}
  if [ ${#dir2[@]} -lt $min_len_dir ]; then
    min_len_dir=${#dir2[@]}
  fi

  idx=0
  for ((i=1; i<$min_len_dir; i++))
  do
    if [ ${dir1[$i]} != ${dir2[$i]} ]; then
      break;
    fi
    ((idx=$idx+1))
  done

  ((idx=$idx+1))

  relative_dir="."
  for ((i=$idx; i<${#dir1[@]}; i++))
  do
    relative_dir="$relative_dir/.."
  done

  for ((i=$idx; i<${#dir2[@]}; i++))
  do
    relative_dir="$relative_dir/${dir2[$i]}"
  done
  
  echo $relative_dir
}


for f in `find $source_dir`
do
  if [ -h "$f" ]; then
    relative_cur_dir=$(dirname $f)
    link_from_dir=$(readlink -f $relative_cur_dir)
    link_from_name=`basename $f`
    link_to=`readlink -f $f`
    link_to_dir=`dirname $link_to`
    link_to_name=`basename $link_to`

    # echo "link from <$link_from_dir/$link_from_name> to <$link_to>"
    relative_dir=$(get_relative_directory $link_from_dir $link_to_dir)

    redo_link_dir=${target_dir%/}/${relative_cur_dir#$source_dir/}
    cmd="cd $redo_link_dir && ln -s $relative_dir/$link_to_name $link_from_name"
    echo $cmd
    eval $cmd
  fi
done
