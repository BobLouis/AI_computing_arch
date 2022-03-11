#!/bin/sh

for i in {1..6} 
do
  url=$(sed -n $i\p in)
  wget "$url" -O lec3_$i.png
done