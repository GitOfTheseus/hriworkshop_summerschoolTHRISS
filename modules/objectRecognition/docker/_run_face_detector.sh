#!/bin/bash
if [ "$#" -eq 0 ]
then
  W=680
  H=480
else
  W=${1}
  H=${2}
fi
object_recognition --task face_detection --width ${W} --height ${H}