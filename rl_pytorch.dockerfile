ARG TORCH_STACK_VERSION=latest
FROM wallart/dl_pytorch:${TORCH_STACK_VERSION}
LABEL Author='Julien WALLART'

# Prepare env variables for all users
# Docker interactive mode
ENV DISPLAY :0
# For interactive login session
RUN echo "export DISPLAY=:0" >> /etc/environment

RUN apt update -y && apt install -y xvfb x11vnc fluxbox
RUN pip install gymnasium

# Adding services to runit
# XVfb service
RUN mkdir -p /etc/service/xvfb/
RUN echo '#!/bin/bash' > /etc/service/xvfb/run
RUN echo 'Xvfb :0 -ac -listen tcp -screen 0 1920x1080x24' >> /etc/service/xvfb/run
RUN chmod 755 /etc/service/xvfb/run

# fluxbox (window manager)
RUN mkdir -p /etc/service/fluxbox/
RUN echo '#!/bin/bash' > /etc/service/fluxbox/run
RUN echo '/usr/bin/fluxbox -display :0 -screen 0' >> /etc/service/fluxbox/run
RUN chmod 755 /etc/service/fluxbox/run

# x11vnc
RUN mkdir -p /etc/service/x11vnc/
RUN echo '#!/bin/bash' > /etc/service/x11vnc/run
RUN echo 'x11vnc -display :0.0 -forever -passwd reinforcement' >> /etc/service/x11vnc/run
RUN chmod 755 /etc/service/x11vnc/run
