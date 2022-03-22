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
ENV CUDA_VERSION 11.3.1
RUN apt-get update && apt-get install -y --no-install-recommends \
      cuda-cudart-11-3=11.3.109-1 \
      cuda-compat-11-3 && \
    ln -s cuda-11.3 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Install NCCL and CUDA libs
ENV NCCL_VERSION 2.9.9-1
# Runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-11-3=11.3.1-1 \
        libnpp-11-3=11.3.3.95-1 \
        cuda-nvtx-11-3=11.3.109-1 \
        libcusparse-11-3=11.6.0.109-1 \
        libcublas-11-3=11.5.1.109-1 \
        libnccl2=$NCCL_VERSION+cuda11.3 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-mark hold libcublas-11-3 libnccl2

# Devel
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-dev-11-3=11.3.109-1 \
        cuda-command-line-tools-11-3=$CUDA_VERSION-1 \
        cuda-minimal-build-11-3=$CUDA_VERSION-1 \
        cuda-libraries-dev-11-3=$CUDA_VERSION-1 \
        cuda-nvml-dev-11-3=11.3.58-1 \
        libnpp-dev-11-3=11.3.3.95-1 \
        libcusparse-dev-11-3=11.6.0.109-1 \
        libcublas-dev-11-3=11.5.1.109-1 \
        libnccl-dev=2.9.9-1+cuda11.3 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-mark hold libcublas-dev-11-3 libnccl-dev

# Install CUDNN
ENV CUDNN_VERSION 8.2.0.53
#RUN apt-get update && apt-cache show libcudnn8
# Runtime + Devel
RUN apt-get update && apt-get install -y --no-install-recommends \
      libcudnn8=$CUDNN_VERSION-1+cuda11.3 \
      libcudnn8-dev=$CUDNN_VERSION-1+cuda11.3 && \
    apt-mark hold libcudnn8 && \
    rm -rf /var/lib/apt/lists/*

# Install Intel MKL
ENV MKL_VERSION 2020.4-912
RUN wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB | apt-key add - && \
    wget https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list && \
    apt update && apt install -y intel-mkl-$MKL_VERSION

# Create an intel python3 environment
RUN apt install intelpython3

# Prepare env variables for all users
# Docker interactive mode
ENV PATH /opt/intel/intelpython3/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64:/usr/local/cuda/lib64
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs
# For interactive login session
RUN echo "export PATH=/opt/intel/intelpython3/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}" >> /etc/bash.bashrc
RUN echo "LD_LIBRARY_PATH=/usr/local/nvidia/lib64:/usr/local/cuda/lib64" >> /etc/environment
RUN echo "LIBRARY_PATH=/usr/local/cuda/lib64/stubs" >> /etc/environment

WORKDIR /
ENTRYPOINT ["/usr/sbin/bootstrap"]