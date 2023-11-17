ARG NVIDIA_STACK_VERSION=latest
FROM wallart/dl_nvidia:${NVIDIA_STACK_VERSION}
LABEL Author='Julien WALLART'

WORKDIR /tmp

ENV TORCH_VERSION 2.1.1
ENV TORCH_VISION_VERSION 0.16.1
ENV TORCH_AUDIO_VERSION 2.1.1

SHELL ["/bin/bash", "-c"]

# Create a python3 environment
RUN apt update; \
    apt install -y python3 python3-pip python-is-python3
# Setup compilation environment
RUN apt install -y cmake ninja-build gcc-11 g++-11 pkg-config
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 11

#RUN pip install torch==${TORCH_VERSION} torchvision==${TORCH_VISION_VERSION} torchaudio==${TORCH_AUDIO_VERSION} --extra-index-url https://download.pytorch.org/whl/cu117
# Maybe I should compile PyTorch myself...
RUN pip install torch==${TORCH_VERSION} --extra-index-url https://download.pytorch.org/whl/cu121
RUN pip install tensorboard wandb

# torchvision / torchaudio deps
RUN pip install torchvision==${TORCH_VISION_VERSION}
RUN pip install torchaudio==${TORCH_AUDIO_VERSION}
#RUN git clone -b v${TORCH_VISION_VERSION} https://github.com/pytorch/vision.git
#RUN git clone -b v${TORCH_AUDIO_VERSION} https://github.com/pytorch/audio.git
#RUN cd vision; python setup.py install
#RUN cd audio; python setup.py install
#RUN rm -rf vision; rm -rf audio

# Optimize Pillow for torchvision
RUN apt install -y libjpeg-dev libpng-dev
RUN pip uninstall -y pillow
RUN CC="cc -mavx2" pip install -U --force-reinstall pillow-simd

# Runit startup
COPY bootstrap.sh /usr/sbin/bootstrap
RUN chmod 755 /usr/sbin/bootstrap

ENTRYPOINT ["/usr/sbin/bootstrap"]
