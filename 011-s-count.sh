#!/bin/bash

#################
# Author : Puneeth
# This script print number of s in "mississippi"
##################


x=mississippi

grep -o "s" <<<"$x" | wc -l
