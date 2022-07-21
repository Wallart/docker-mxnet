ARG BASE_VERSION=latest
FROM wallart/dl_base:${BASE_VERSION}
LABEL Author 'Julien WALLART'

WORKDIR /tmp

# Add CUDA repository
RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*

# Install CUDA
ENV CUDA_VERSION 11.6.2
RUN apt-get update && apt-get install -y --no-install-recommends \
      cuda-cudart-11-6=11.6.55-1 \
      cuda-compat-11-6 && \
    ln -s cuda-11.6 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Install NCCL and CUDA libs
ENV NCCL_VERSION 2.12.10-1
# Runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-11-6=11.6.2-1 \
        libnpp-11-6=11.6.3.124-1 \
        cuda-nvtx-11-6=11.6.124-1 \
        libcusparse-11-6=11.7.2.124-1 \
        libcublas-11-6=11.9.2.110-1 \
        libnccl2=$NCCL_VERSION+cuda11.6 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-mark hold libcublas-11-6 libnccl2

# Devel
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-dev-11-6=11.6.55-1 \
        cuda-command-line-tools-11-6=$CUDA_VERSION-1 \
        cuda-minimal-build-11-6=$CUDA_VERSION-1 \
        cuda-libraries-dev-11-6=$CUDA_VERSION-1 \
        cuda-nvml-dev-11-6=11.6.55-1 \
        cuda-nvprof-11-6=11.6.124-1 \
        libnpp-dev-11-6=11.6.3.124-1 \
        libcusparse-dev-11-6=11.7.2.124-1 \
        libcublas-dev-11-6=11.9.2.110-1 \
        libnccl-dev=2.12.10-1+cuda11.6 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-mark hold libcublas-dev-11-6 libnccl-dev

# Install CUDNN
ENV CUDNN_VERSION 8.4.0.27
#RUN apt-get update && apt-cache show libcudnn8
# Runtime + Devel
RUN apt-get update && apt-get install -y --no-install-recommends \
      libcudnn8=$CUDNN_VERSION-1+cuda11.6 \
      libcudnn8-dev=$CUDNN_VERSION-1+cuda11.6 && \
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