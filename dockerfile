# Dockerfile

# Start with the base code-server image
FROM codercom/code-server:latest

# Switch to the root user to install new software
USER root

# Install Node.js, npm, Python, and other essentials
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    git \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create symlinks for python and pip
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip

# Install essential Python packages only
RUN pip install --no-cache-dir \
    requests \
    python-dotenv

# Use npm to install the Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Switch back to the standard, non-root user
USER coder