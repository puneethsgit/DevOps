#!/bin/bash

##################
# Author : puneeth
# Version : v1
# This script print numbers divided by 3 and 5 but not 15
##################


# Logic
# divisible by 3, divisible by 5, not 3*5 = 15

# Range 1..100 (1to100)

# The command chsh -s /bin/bash is used to change the default shell for your user account in a Linux-based system (or WSL, in your case).


for i in {1..100}; do
        if (( (i % 3 == 0 || i % 5 == 0) && i % 15 != 0 )); then
                echo $i
        fi;
done
