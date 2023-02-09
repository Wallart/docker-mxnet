ARG NVIDIA_STACK_VERSION=latest
FROM wallart/dl_nvidia:${NVIDIA_STACK_VERSION}
LABEL Author='Julien WALLART'

WORKDIR /tmp

ENV TORCH_VERSION 1.13.1
ENV TORCH_VISION_VERSION 0.14.1
ENV TORCH_AUDIO_VERSION 0.13.1

SHELL ["/bin/bash", "-c"]

# Create a python3 environment
RUN apt update; \
    apt install -y python3 python3-pip python-is-python3

RUN pip install torch==${TORCH_VERSION} torchvision==${TORCH_VISION_VERSION} torchaudio==${TORCH_AUDIO_VERSION} --extra-index-url https://download.pytorch.org/whl/cu117
RUN pip install tensorboard wandb

# Runit startup
COPY bootstrap.sh /usr/sbin/bootstrap
RUN chmod 755 /usr/sbin/bootstrap

ENTRYPOINT ["/usr/sbin/bootstrap"]