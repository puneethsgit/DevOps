#!/bin/bash  # Shebang: Indicates that this is a Bash script.

# Define a function to handle SIGINT (Ctrl+C)
handle_sigint() {
  # This function will be executed when SIGINT (Ctrl+C) is detected.
  echo "Caught SIGINT (Ctrl+C)! Cleaning up before exit..."
  # You can add cleanup tasks here, such as removing temporary files or releasing resources.
  exit 1  # Exit the script with a non-zero status code (1).
}

# Trap SIGINT (signal 2) and call the handle_sigint function
# This line tells the script to listen for SIGINT (Ctrl+C) and call the 'handle_sigint' function when it occurs.
trap handle_sigint SIGINT

# Simulate a long-running process
echo "Script running. Press Ctrl+C to interrupt."
# Print a message to indicate that the script is running and waiting for a Ctrl+C interruption.

# Infinite loop that simulates a long-running process
while true; do
  # Inside the loop, it continuously prints "Working..." every 2 seconds.
  echo "Working..."
  sleep 2  # Sleep for 2 seconds before the next iteration of the loop.
done
