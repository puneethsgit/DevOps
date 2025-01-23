#!/bin/bash

x=7
y=5
z=3

# Compare x, y, and z
if [ $z -gt $y ]; then
  echo "z is greater than y"
elif [ $x -gt $y ]; then
  echo "x is greater than y"
else
  echo "y is the greatest"
fi
