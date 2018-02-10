#!/bin/bash

# Copyright: (C) 2016 iCub Facility - Istituto Italiano di Tecnologia
# Authors: Ugo Pattacini <ugo.pattacini@iit.it>
# CopyPolicy: Released under the terms of the GNU GPL v3.0.

script=$(realpath $0)
abspathtoscript=$(dirname "${script}")

if [ -d build ]; then
  rm -Rf build
fi
mkdir build

wget -O build/git.md          https://raw.githubusercontent.com/vvv18-git/vvv18-git.github.io/master/README.md
wget -O build/yarp.md         https://raw.githubusercontent.com/vvv18-yarp/vvv18-yarp.github.io/master/README.md
wget -O build/kinematics.md   https://raw.githubusercontent.com/vvv18-kinematics/vvv18-kinematics.github.io/master/README.md
wget -O build/vision.md       https://raw.githubusercontent.com/vvv18-vision/vvv18-vision.github.io/master/README.md
wget -O build/dynamics.md     https://raw.githubusercontent.com/vvv18-dynamics/vvv18-dynamics.github.io/master/README.md
wget -O build/event-vision.md https://raw.githubusercontent.com/vvv18-event-based-vision/vvv18-event-based-vision.github.io/master/README.md

file_list=$(ls ./build/*.md)
for entry in $file_list; do  
  cat $entry | grep total_score | sed 's/[^0-9]//g' > build/scores
  mapfile -t scores < build/scores
  
  if [ -z $tot_scores ]; then
    tot_scores=("${scores[@]}") 
  else
    for (( i=0; i<${#tot_scores[@]}; i++ )); do
      let tot_scores[i]+="${scores[i]}"
    done
  fi
done

cat `echo "${file_list}" | head -1` | grep '###' | awk {'print $2'} > build/usernames
mapfile -t usernames < build/usernames
for (( i=0; i<${#tot_scores[@]}; i++ )); do
  echo "${usernames[i]} ${tot_scores[i]}" >> build/unsorted_grades
done

sort -k2,2nr -k1,1 build/unsorted_grades > build/sorted_grades

output_file="${abspathtoscript}"/../final-gradebook.md
if [ -f ${output_file} ]; then
  rm ${output_file}
fi

echo "# Students Final Gradebook" >> ${output_file}
echo "" >> ${output_file}
echo "| students | scores |" >> ${output_file}
echo "| :---: | :---: |" >> ${output_file}
for (( i=1; i<=${#tot_scores[@]}; i++ )); do
  line=$(eval "sed '${i}q;d' build/sorted_grades")
  username=$(echo "$line" | awk {'print $1'})
  score=$(echo "$line" | awk {'print $2'})
  echo "| $username | **$score** |" >> ${output_file}
done

echo "" >> ${output_file}
echo "### [List of Gradebooks](./gradebook.md)" >> ${output_file}
echo "" >> ${output_file}
echo "### [Main Page](./README.md)" >> ${output_file}
