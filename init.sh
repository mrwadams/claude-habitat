#!/bin/bash
# Initialize directories with proper permissions for code-server

# Create directories if they don't exist
mkdir -p project cli-config

# Set ownership to UID 1000 (coder user in container)
# This ensures the container can write to these directories
if [ "$EUID" -eq 0 ]; then
  # If running as root (e.g., with sudo)
  chown -R 1000:1000 project cli-config
else
  # If not root, try to set permissions if we own the files
  if [ -w project ] && [ -w cli-config ]; then
    chmod -R 755 project cli-config
  fi
fi

echo "✅ Directories initialized with proper permissions"