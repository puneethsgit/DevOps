#!bin/bash

# Write a shell script to list all processes

ps -ef

# If we want only the processes id means

ps -ef | awk -F" " '{print $2}'
