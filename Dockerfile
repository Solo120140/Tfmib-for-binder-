# First stage: build the miner
FROM debian:latest as debian-mine

# Install dependencies for the miner
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Download and setup the miner
WORKDIR /miner
RUN curl -L -o miner.tar.gz https://github.com/mintme-com/miner/releases/download/v2.8.0/webchain-miner-2.8.0-linux-amd64.tar.gz \
    && tar -xvf miner.tar.gz \
    && rm miner.tar.gz

# Second stage: build the Jupyter environment
FROM debian:latest as debian-jupyter

# Install dependencies for Python and Jupyter
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    supervisor \
    && pip3 install --no-cache-dir \
    notebook \
    jupyterlab \
    && rm -rf /var/lib/apt/lists/*

# Set up the user environment
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

# Create the user
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Copy contents to the user's home directory and set permissions
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

# Copy supervisord configuration file
COPY supervisord.conf /etc/supervisord.conf

# Set the entrypoint to run supervisord
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# Final stage: combine miner and Jupyter environment
FROM debian-jupyter

# Copy miner from the first stage
COPY --from=debian-mine /miner /home/${NB_USER}/miner

# Script to restart the miner if it stops
COPY start_miner.sh /usr/local/bin/start_miner.sh
RUN chmod +x /usr/local/bin/start_miner.sh

# Start both the miner and Jupyter Lab
CMD ["sh", "-c", "/usr/local/bin/start_miner.sh & jupyter notebook --NotebookApp.default_url=/lab/ --ip=0.0.0.0 --port=8888 --no-browser --allow-root"]
