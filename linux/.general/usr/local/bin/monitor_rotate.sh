#!/bin/sh
rotation=`xrandr -q | grep " connected" | sed  "s/^.*connected.*\(left\) (.*$/\1/"`
echo $rotation
#exit
if [ "$rotation" = "left" ] ;
then
  xrandr -o normal
else
  xrandr -o left
fi