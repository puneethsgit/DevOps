#!/bin/bash

# Define a function to handle SIGINT (Ctrl+C)
handle_sigint() {
  echo "Caught SIGINT (Ctrl+C)! Cleaning up before exit..."
  # Add cleanup tasks here (e.g., remove temporary files)
  exit 1  # Exit the script
}

# Trap SIGINT (signal 2) and call the handle_sigint function
trap handle_sigint SIGINT

# Simulate a long-running process
echo "Script running. Press Ctrl+C to interrupt."
while true; do
  echo "Working..."
  sleep 2
done
