# Use Ubuntu 18.04 as the base image
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Docker
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Jupyter and other necessary packages
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install notebook jupyterhub jupyterlab

# Expose port for Jupyter Notebook
EXPOSE 8888

# Set the default command to start Jupyter Notebook
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root", "--no-browser"]
