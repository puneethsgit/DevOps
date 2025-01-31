#!/bin/bash

##############################
# Author: Puneeth
# Date: 30 Jan 2025
#
# Version: v1
#
# This script will report AWS resource usage and store it in a log file.
####################################

# Set the time zone to Asia/Kolkata (IST)
export TZ="Asia/Kolkata"


# Define the log file path
LOG_FILE="$HOME/resourcelog.txt"

# Get the current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Append headers to the log file
echo "=============================" >> $LOG_FILE
echo "AWS Resource Report - $TIMESTAMP" >> $LOG_FILE
echo "=============================" >> $LOG_FILE

# List all S3 buckets and log the output
echo "S3 Buckets:" >> $LOG_FILE
aws s3 ls >> $LOG_FILE 2>&1
# `aws s3 ls` lists all S3 buckets in the AWS account.
# `>> $LOG_FILE` appends the output to the log file.
# `2>&1` redirects error messages (stderr) to the same file as standard output (stdout).

# List all running EC2 instances and log the output
echo "EC2 Instances:" >> $LOG_FILE
aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId' >> $LOG_FILE 2>&1
# `aws ec2 describe-instances` fetches details about EC2 instances.
# `jq '.Reservations[].Instances[].InstanceId'` extracts only the instance IDs for readability.
# `>> $LOG_FILE 2>&1` saves both stdout and stderr to the log file.

# List all AWS Lambda functions and log the output
echo "Lambda Functions:" >> $LOG_FILE
aws lambda list-functions >> $LOG_FILE 2>&1
# `aws lambda list-functions` retrieves all Lambda functions in the AWS account.
# `>> $LOG_FILE 2>&1` saves the output and any errors to the log file.

# List all IAM users and log the output
echo "IAM Users:" >> $LOG_FILE
aws iam list-users >> $LOG_FILE 2>&1
# `aws iam list-users` lists all IAM users in the AWS account.
# `>> $LOG_FILE 2>&1` ensures output and errors are written to the log file.

# Print confirmation message
echo "Report saved to $LOG_FILE"
