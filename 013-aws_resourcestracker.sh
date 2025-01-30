#!/bin/bash


##############################
# Author: Puneeth
# Date: 30 Jan 2025
#
# Version: v1
#
# This script will report the aws report usage
####################################

# set -x
# set -o pipefail
# set -e

# WHAT WE ARE TRACKING
# AWS s3
# AWS EC2
# AWS Lambda
# AWS IAM User


# set -x # Debug mode

# list s3 bucket
echo "Print list of s3 Buckets"
aws s3 ls 

# list ec2 instances
echo "Print list of EC2 instances"
aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId'


# list lambda
echo "Print list of lambda functions"
aws lambda list-functions 

# list IAM user
echo "Print list of IAM Users"
aws iam list-users
