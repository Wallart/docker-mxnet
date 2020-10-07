ARG BASE_VERSION=latest
FROM wallart/dl_base:${BASE_VERSION}
LABEL Author 'Julien WALLART'

WORKDIR /tmp

# Add CUDA repository
RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*

# Install CUDA
ENV CUDA_VERSION 11.1.0
#ENV CUDA_PKG_VERSION 11.1.74-1

RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-11-1=11.1.74-1 \
        cuda-compat-11-1 && \
    ln -s cuda-11.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Install NCCL and CUDA libs
ENV NCCL_VERSION 2.7.8
# Runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-11-1=11.1.0-1 \
        libnpp-11-1=11.1.1.269-1 \
        cuda-nvtx-11-1=11.1.74-1 \
        libcublas-11-1=11.2.1.74-1 \
        libnccl2=$NCCL_VERSION-1+cuda11.1 && \
    apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/*
# Devel
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-nvml-dev-11-1=11.1.74-1 \
        cuda-command-line-tools-11-1=11.1.0-1 \
        cuda-nvprof-11-1=11.1.69-1 \
        libnpp-dev-11-1=11.1.1.269-1 \
        cuda-libraries-dev-11-1=11.1.0-1 \
        cuda-minimal-build-11-1=11.1.0-1 \
        libnccl-dev=2.7.8-1+cuda11.1 \
        libcublas-dev-11-1=11.2.1.74-1 \
        libcusparse-11-1=11.2.0.275-1 \
        libcusparse-dev-11-1=11.2.0.275-1 && \
    apt-mark hold libnccl-dev && \
    rm -rf /var/lib/apt/lists/*

# Install CUDNN
ENV CUDNN_VERSION 8.0.4.30
# Runtime + Devel
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn8=$CUDNN_VERSION-1+cuda11.1 \
    libcudnn8-dev=$CUDNN_VERSION-1+cuda11.1 && \
    apt-mark hold libcudnn8 && \
    rm -rf /var/lib/apt/lists/*

# Install Intel MKL
ENV MKL_VERSION 2020.0-088
RUN wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB | apt-key add - && \
    wget https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list && \
    apt update && apt install -y intel-mkl-$MKL_VERSION

# Install miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN chmod +x Miniconda3-latest-Linux-x86_64.sh && ./Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 && rm -rf ./Miniconda3-latest-Linux-x86_64.sh

RUN yes y | /opt/miniconda3/bin/conda update conda; /opt/miniconda3/bin/conda config --add channels intel

# Create an intel python3 environment
RUN /opt/miniconda3/bin/conda create -n intelpython3 intelpython3_core python=3

# Prepare env variables for all users
# Docker interactive mode
ENV PATH /opt/miniconda3/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64:/usr/local/cuda/lib64
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs
# For interactive login session
RUN echo "export PATH=/opt/miniconda3/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}" >> /etc/bash.bashrc
RUN echo "LD_LIBRARY_PATH=/usr/local/nvidia/lib64:/usr/local/cuda/lib64" >> /etc/environment
RUN echo "LIBRARY_PATH=/usr/local/cuda/lib64/stubs" >> /etc/environment

# Intel Python 3 auto sourcing
RUN echo "source activate intelpython3" >> /etc/bash.bashrc

WORKDIR /
ENTRYPOINT ["/usr/sbin/bootstrap"]