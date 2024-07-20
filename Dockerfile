# Use the official Debian image as the base
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary tools and dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    build-essential \
    wget

#RUN mkdir OtohitsApp
# Add NodeSource APT repository for Node.js 20.x and necessary confirmations
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
#RUN wget https://www.otohits.net/dl/OtohitsApp_5068_linux_portable.tar.gz
#RUN echo "/login:e730873c-8513-456b-9c0a-ce01dea573f3" > otohits.ini
#RUN echo "/autoupdate" >> otohits.ini
#RUN tar -xzf OtohitsApp_5068_linux_portable.tar.gz

# Install Node.js 20.x and npm
RUN apt-get install -y nodejs

# Verify installation
RUN node -v && npm -v


# Install Python and pip (if needed for binder)
RUN apt-get update && \
    apt-get install -y python3 python3-pip

# Install Python dependencies for Binder
RUN pip3 install jupyterlab notebook --break-system-packages


# Set the working directory
WORKDIR /home

# Copy the content of the local directory to the container
COPY . .

# Expose the port Binder will use
EXPOSE 8888

# Command to run when the container starts

