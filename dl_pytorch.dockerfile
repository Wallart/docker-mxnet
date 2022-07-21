ARG NVIDIA_STACK_VERSION=latest
FROM wallart/dl_nvidia:${NVIDIA_STACK_VERSION}
LABEL Author='Julien WALLART'

WORKDIR /tmp

ENV TORCH_VERSION 1.12
ENV TORCH_VISION_VERSION 0.13.0
ENV TORCH_AUDIO_VERSION 0.12.0

SHELL ["/bin/bash", "-c"]

# Create a python3 environment
RUN apt update; \
    apt install -y python3 python3-pip

RUN pip install torch==${TORCH_VERSION} torchvision==${TORCH_VISION_VERSION} torchaudio==${TORCH_AUDIO_VERSION} --extra-index-url https://download.pytorch.org/whl/cu116
RUN pip install tensorboard wandb

# Runit startup
COPY bootstrap.sh /usr/sbin/bootstrap
RUN chmod 755 /usr/sbin/bootstrap

ENTRYPOINT ["/usr/sbin/bootstrap"]
