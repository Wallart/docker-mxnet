ARG NVIDIA_STACK_VERSION=latest
FROM wallart/dl_nvidia:${NVIDIA_STACK_VERSION}
LABEL Author='Julien WALLART'

WORKDIR /tmp

ENV TORCH_VERSION 1.12
ENV TORCH_VISION_VERSION 0.13.0
ENV TORCH_AUDIO_VERSION 0.12.0

SHELL ["/bin/bash", "-c"]

# Install Intel MKL
ENV MKL_VERSION 2020.4-912
RUN wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB | apt-key add - && \
    wget https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list && \
    apt update && apt install -y intel-mkl-$MKL_VERSION

# Create an intel python3 environment
RUN apt install intelpython3

# Prepare env variables for all users
# Docker interactive mode
ENV PATH /opt/intel/intelpython3/bin:${PATH}
# For interactive login session
RUN echo "export PATH=/opt/intel/intelpython3/bin:${PATH}" >> /etc/bash.bashrc


RUN pip install torch==${TORCH_VERSION} torchvision==${TORCH_VISION_VERSION} torchaudio==${TORCH_AUDIO_VERSION} --extra-index-url https://download.pytorch.org/whl/cu116
RUN pip install tensorboard wandb

# Install Intel extension for PyTorch
RUN git clone --recursive https://github.com/intel/intel-extension-for-pytorch; \
    cd intel-extension-for-pytorch; git checkout v${TORCH_VERSION}; \
    git submodule sync; git submodule update --init --recursive; \
    python setup.py install

# Runit startup
COPY bootstrap.sh /usr/sbin/bootstrap
RUN chmod 755 /usr/sbin/bootstrap

ENTRYPOINT ["/usr/sbin/bootstrap"]
