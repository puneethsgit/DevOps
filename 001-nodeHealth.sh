#!/bin/bash

##############################
# Author : Puneeth S
# Date : 23-01-2025
#
# This Script outputs the node Health
#
# Version : v1
################################


set -x # Debug mode
set -e # exit the script when there is an error
set -o pipefail

# set -exo pipefail

df -h # disksfree disk space info + -h human readable

free -g # system memory usage + -g to display in GB

nproc # number of processor core available on the system

ps -ef | grep amazon | awk -F" " '{print $2}' # print amazon process id
