# AWS Resource Monitoring Script

## Overview
This Bash script collects and logs information about AWS resources, including:
- S3 Buckets
- EC2 Instances
- Lambda Functions
- IAM Users

The script runs AWS CLI commands to fetch resource details and stores them in a log file.

## Prerequisites
Ensure you have the following installed and configured:
- **AWS CLI** ([Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html))
- **jq** (for parsing JSON output)
- **Bash** (Linux/macOS environment)
- **Crontab** 
- **Valid AWS credentials** configured using `aws configure`

## Installation
1. Clone this repository or create the script manually:
   ```bash
   git clone <repo-url>
   cd <repo-folder>
   ```
2. Create a new Bash script file:
   ```bash
   nano aws_monitor.sh
   ```
3. Copy and paste the following script:
   ```bash
   #!/bin/bash
   
   LOG_FILE="$HOME/resourcelog.txt"
   TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
   
   echo "=============================" >> $LOG_FILE
   echo "AWS Resource Report - $TIMESTAMP" >> $LOG_FILE
   echo "=============================" >> $LOG_FILE
   
   echo "S3 Buckets:" >> $LOG_FILE
   aws s3 ls >> $LOG_FILE 2>&1
   
   echo "EC2 Instances:" >> $LOG_FILE
   aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId' >> $LOG_FILE 2>&1
   
   echo "Lambda Functions:" >> $LOG_FILE
   aws lambda list-functions >> $LOG_FILE 2>&1
   
   echo "IAM Users:" >> $LOG_FILE
   aws iam list-users >> $LOG_FILE 2>&1
   
   echo "Report saved to $LOG_FILE"
   ```
4. Save and exit (`CTRL + X`, then `Y`, then `Enter`).
5. Make the script executable:
   ```bash
   chmod +x aws_monitor.sh
   ```

## Running the Script Manually
To execute the script manually, run:
```bash
./aws_monitor.sh
```

## Setting Up a Cron Job
To automate script execution, set up a cron job:

### Open the Crontab Editor
```bash
crontab -e
```

### Schedule the Script
Add one of the following lines at the bottom of the file:

**To run every hour:**
```bash
0 * * * * /bin/bash /path/to/aws_monitor.sh
```

**To run every day at midnight:**
```bash
0 0 * * * /bin/bash /path/to/aws_monitor.sh
```


Here's a sample `README.md` for your cron job configurations:

```markdown
# Cron Job Setup

This document explains the configuration for different cron jobs to schedule tasks at specific intervals.

## 1. Run Every 3 Hours

To run a command every 3 hours at the start of the hour, use the following cron job syntax:

```bash
0 */3 * * * command-to-run
```

### Explanation:
- `0`: The job will run at the 0th minute of the hour.
- `*/3`: The job will run every 3 hours.
- `*`: The job will run every day of the month, every month, and every day of the week.

This configuration will execute `command-to-run` every 3 hours at the beginning of each hour.

---

## 2. Run Once Every Month

To run a command once every month, specifically on the 1st day of the month at midnight, use the following cron job syntax:

```bash
0 0 1 * * command-to-run
```

### Explanation:
- `0`: The job will run at the 0th minute of the hour.
- `0`: The job will run at midnight (0th hour).
- `1`: The job will run on the 1st day of the month.
- `*`: The job will run every month.
- `*`: The job will run every day of the week.

This configuration will execute `command-to-run` on the 1st day of every month at midnight.

---

Feel free to modify these cron job schedules according to your needs.
```

This will help document the cron jobs and their explanations clearly in a `README.md` format!
Save and exit the crontab editor.

### Verify Cron Job
To check if the cron job is scheduled correctly, run:
```bash
crontab -l
```

## Log File Location
The script logs AWS resource details in:
```
$HOME/resourcelog.txt
```




## Author
[Puneeth](https://github.com/puneeths11)

## License
This project is licensed under the MIT License.

