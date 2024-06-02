# Use the official Debian image as the base
FROM debian:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary tools and dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    build-essential

# Add NodeSource APT repository for Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# Install Node.js 20.x and npm
RUN apt-get install -y nodejs

# Verify installation
RUN node -v && npm -v

# Setup for Binder
# Copy the requirements for Binder (if any)
COPY .binder/requirements.txt /tmp/

# Install Python and pip (if needed for binder)
RUN apt-get update && \
    apt-get install -y python3 python3-pip

# Install Python dependencies for Binder
RUN pip3 install -r /tmp/requirements.txt

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /home

# Copy the content of the local directory to the container
COPY . .

# Expose the port Binder will use
EXPOSE 8888

# Command to run when the container starts
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
