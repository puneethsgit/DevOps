```bash
#!/bin/bash

##############################
# Author: Puneeth
# Date: 30 Jan 2025
#
# Version: v2
#
# This script will monitor a MERN stack containerized application on an EC2 instance.
####################################

# Set the time zone to Asia/Kolkata (IST)
export TZ="Asia/Kolkata"

# Define the log file path
LOG_FILE="$HOME/mern_monitor_log.txt"

# Get the current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Append headers to the log file
echo "=============================" >> $LOG_FILE
echo "MERN Stack Monitoring Report - $TIMESTAMP" >> $LOG_FILE
echo "=============================" >> $LOG_FILE

# Check running containers
echo "Running Containers:" >> $LOG_FILE
docker ps --format "table {{.Names}}\t{{.Status}}" >> $LOG_FILE 2>&1

# Check if Node.js container is running
NODE_CONTAINER="mern-backend"
if docker ps --format '{{.Names}}' | grep -q "$NODE_CONTAINER"; then
    echo "✅ Node.js backend container ($NODE_CONTAINER) is running." >> $LOG_FILE
else
    echo "❌ ALERT: Node.js backend container ($NODE_CONTAINER) is NOT running!" >> $LOG_FILE
fi

# Check if MongoDB container is running
MONGO_CONTAINER="mern-mongodb"
if docker ps --format '{{.Names}}' | grep -q "$MONGO_CONTAINER"; then
    echo "✅ MongoDB container ($MONGO_CONTAINER) is running." >> $LOG_FILE
else
    echo "❌ ALERT: MongoDB container ($MONGO_CONTAINER) is NOT running!" >> $LOG_FILE
fi

# Check CPU and Memory usage of the EC2 instance
echo "EC2 Instance Resource Usage:" >> $LOG_FILE
echo "CPU Usage:" >> $LOG_FILE
top -bn1 | grep "Cpu(s)" | awk '{print "CPU Load: " $2 + $4 "%"}' >> $LOG_FILE
echo "Memory Usage:" >> $LOG_FILE
free -m | awk 'NR==2{printf "Memory Usage: %s/%s MB (%.2f%%)\n", $3,$2,$3*100/$2 }' >> $LOG_FILE

# Check Docker container logs for errors (last 20 lines)
echo "Node.js Backend Logs (Last 20 lines):" >> $LOG_FILE
docker logs --tail 20 $NODE_CONTAINER >> $LOG_FILE 2>&1

# Check MongoDB logs (last 20 lines)
echo "MongoDB Logs (Last 20 lines):" >> $LOG_FILE
docker logs --tail 20 $MONGO_CONTAINER >> $LOG_FILE 2>&1

# Print confirmation message
echo "Monitoring report saved to $LOG_FILE"
```

---

### **How to Use This Script?**
1. **Save the script** as `mern_monitor.sh`
2. **Make it executable**:
   ```bash
   chmod +x mern_monitor.sh
   ```
3. **Run the script manually**:
   ```bash
   ./mern_monitor.sh
   ```

### **Automate with a Cron Job (Run Every 5 Minutes)**
To automate monitoring, add it to a cron job:
```bash
crontab -e
```
Add this line at the end:
```bash
*/5 * * * * /path/to/mern_monitor.sh
```
This will run the script every **5 minutes**.

---

### **What This Script Does**
✅ Checks if the **Node.js backend** and **MongoDB containers** are running.  
✅ Monitors **CPU and memory usage** of the EC2 instance.  
✅ Logs the **last 20 lines of Docker logs** for both containers.  
✅ Saves everything in a log file (`$HOME/mern_monitor_log.txt`).  

Would you like to integrate this with **AWS CloudWatch Logs** for centralized monitoring? 🚀
