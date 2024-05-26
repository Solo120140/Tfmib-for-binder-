# First stage: build the miner and set up Jupyter environment
FROM debian:latest as builder

# Install dependencies for the miner and Jupyter
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    python3 \
    python3-pip \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create the user
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}
RUN adduser --disabled-password --gecos "Default user" --uid ${NB_UID} ${NB_USER}

# Download and setup the miner
WORKDIR /miner
RUN curl -L -o miner.tar.gz https://github.com/mintme-com/miner/releases/download/v2.8.0/webchain-miner-2.8.0-linux-amd64.tar.gz \
    && tar -xvf miner.tar.gz \
    && rm miner.tar.gz

# Copy supervisord configuration file
COPY supervisord.conf /etc/supervisord.conf

# Copy contents to the user's home directory and set permissions
COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME}

# Script to restart the miner if it stops
COPY start_miner.sh /usr/local/bin/start_miner.sh
RUN chmod +x /usr/local/bin/start_miner.sh

# Second stage: Final image
FROM debian:latest

# Copy files from the builder stage
COPY --from=builder / /

# Expose the port for Jupyter Notebook
EXPOSE 8888

# Specify the user for running Jupyter Notebook
USER ${NB_USER}

# Start supervisord to manage processes
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
