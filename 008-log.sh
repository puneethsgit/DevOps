#!bin/bash

# write a script to print only error from a remote log file

curl https://raw.githubusercontent.com/iam-veeramalla/sandbox/refs/heads/main/log/dummylog01122022.log | grep ERROR
