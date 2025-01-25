#!/bin/bash


##################

# Author : puneeth

# Version : v1

# This script print numbers divided by 3 and 5 but not 15

##################


for i in {1..100}; do

if ([ `expr $i % 3` == 0 ] || [ `expr $i % 5` == 0 ]) && [ `expr $i % 15` != 0 ];

then

     echo $i

fi;

done


# this script is working in mobxterm but not on wsl ubuntu terminal because
# The code works in MobXterm because MobXterm uses a Cygwin-like environment on Windows, 
# which might have some compatibility with certain Bash features that behave differently on native Linux environments like WSL (Windows Subsystem for Linux).
