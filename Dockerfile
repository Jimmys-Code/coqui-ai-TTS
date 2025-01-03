# Use NVIDIA CUDA base image
ARG BASE=nvidia/cuda:11.8.0-base-ubuntu22.04
FROM ${BASE}

# Update and upgrade system packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        gcc g++ make python3 python3-dev python3-pip \
        python3-venv python3-wheel espeak-ng \
        libsndfile1-dev libc-dev curl build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install Rust compiler (required for sudachipy)
RUN curl --proto '=https' --tlsv1.2 -sSf "https://sh.rustup.rs" | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Upgrade pip and setuptools to the latest versions
RUN pip3 install --upgrade pip setuptools wheel

# Install Python packages with required versions
RUN pip3 install --upgrade "spacy[ja]<3.8" "sudachipy<0.6.0"
RUN pip3 install llvmlite --ignore-installed

# Install PyTorch and torchaudio with CUDA support
RUN pip3 install torch torchaudio --extra-index-url https://download.pytorch.org/whl/cu118
RUN rm -rf /root/.cache/pip

# Copy TTS repository contents to the container
WORKDIR /root
COPY . /root

# Install the TTS package with all extras
RUN pip3 install -e .[all]

# Set default entrypoint and command
ENTRYPOINT ["tts"]
CMD ["--help"]