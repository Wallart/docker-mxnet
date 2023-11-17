ARG BASE_VERSION=latest
FROM wallart/dl_base:${BASE_VERSION}
LABEL Author 'Julien WALLART'

WORKDIR /tmp

# Add CUDA repository
RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSLO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*

# Install CUDA
ENV CUDA_VERSION 12.1.1
RUN apt-get update && apt-get install -y --no-install-recommends \
      cuda-cudart-12.1=12.1.105-1 \
      cuda-compat-12-1 && \
    rm -rf /var/lib/apt/lists/*

# Install NCCL and CUDA libs
ENV NCCL_VERSION 2.17.1-1
# Runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-12-1=$CUDA_VERSION-1 \
        libnpp-12-1=12.1.0.40-1 \
        cuda-nvtx-12-1=12.1.105-1 \
        libcusparse-12-1=12.1.0.106-1 \
        libcublas-12-1=12.1.3.1-1 \
        libnccl2=$NCCL_VERSION+cuda12.1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-mark hold libcublas-12-1 libnccl2


# Devel
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-dev-12-1=12.1.105-1 \
        cuda-command-line-tools-12-1=$CUDA_VERSION-1 \
        cuda-minimal-build-12-1=$CUDA_VERSION-1 \
        cuda-libraries-dev-12-1=$CUDA_VERSION-1 \
        cuda-nvml-dev-12-1=12.1.105-1 \
        cuda-nvprof-12-1=12.1.105-1 \
        libnpp-dev-12-1=12.1.0.40-1 \
        libcusparse-dev-12-1=12.1.0.106-1 \
        libcublas-dev-12-1=12.1.3.1-1 \
        libnccl-dev=$NCCL_VERSION+cuda12.1 \
        cuda-nsight-compute-12-1=12.1.1-1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-mark hold libcublas-dev-12-1 libnccl-dev

# Install CUDNN
ENV CUDNN_VERSION 8.9.0.131
#RUN apt-get update && apt-cache show libcudnn8
# Runtime + Devel
RUN apt-get update && apt-get install -y --no-install-recommends \
      libcudnn8=$CUDNN_VERSION-1+cuda12.1 \
      libcudnn8-dev=$CUDNN_VERSION-1+cuda12.1 && \
    apt-mark hold libcudnn8 && \
    rm -rf /var/lib/apt/lists/*

# Prepare env variables for all users
# Docker interactive mode
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64:/usr/local/cuda/lib64
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs
# For interactive login session
RUN echo "export PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}" >> /etc/bash.bashrc
RUN echo "LD_LIBRARY_PATH=/usr/local/nvidia/lib64:/usr/local/cuda/lib64" >> /etc/environment
RUN echo "LIBRARY_PATH=/usr/local/cuda/lib64/stubs" >> /etc/environment

WORKDIR /
ENTRYPOINT ["/usr/sbin/bootstrap"]