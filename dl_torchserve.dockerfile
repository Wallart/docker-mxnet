ARG PYTORCH_STACK_VERSION=latest
FROM wallart/dl_pytorch:${PYTORCH_STACK_VERSION}
LABEL Author='Julien WALLART'

WORKDIR /root

ENV TORCHSERVE_VERSION 0.9
ENV TORCH_MODEL_ARCHIVER_VERSION 0.9.0
ENV TORCH_WORKFLOW_ARCHIVER_VERSION 0.2.11

EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

RUN apt update && apt install sudo

RUN git clone https://github.com/pytorch/serve.git
RUN cd serve && python ./ts_scripts/install_dependencies.py --cuda=cu121
RUN rm -rf serve

RUN pip install torchserve==${TORCHSERVE_VERSION}
RUN pip install torch-model-archiver==${TORCH_MODEL_ARCHIVER_VERSION}
RUN pip install torch-workflow-archiver==${TORCH_WORKFLOW_ARCHIVER_VERSION}

RUN mkdir model-store
COPY config.properties .

ENTRYPOINT ["torchserve"]
CMD ["--start", "--ncs", "--ts-config", "/root/config.properties", "--foreground"]