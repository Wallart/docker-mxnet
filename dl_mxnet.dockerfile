ARG NVIDIA_STACK_VERSION=latest
FROM wallart/dl_nvidia:${NVIDIA_STACK_VERSION}
LABEL Author='Julien WALLART'

WORKDIR /tmp

ENV MXNET_VERSION 1.6.0
ENV OPENCV_VERSION 4.1.1

# Download frameworks
RUN git clone --recursive -b ${MXNET_VERSION} https://github.com/apache/incubator-mxnet mxnet-${MXNET_VERSION}
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz; mv ${OPENCV_VERSION}.tar.gz opencv-${OPENCV_VERSION}.tar.gz
RUN tar xf opencv-${OPENCV_VERSION}.tar.gz; rm -rf opencv-${OPENCV_VERSION}.tar.gz

RUN apt update && export DEBIAN_FRONTEND=noninteractive; apt install -y cmake ccache qtdeclarative5-dev pkg-config rsync
# image processing deps
RUN apt install -y libturbojpeg-dev libpng-dev libtiff-dev
# video processing deps
RUN apt install -y libavcodec-dev libavformat-dev libswscale-dev libavresample-dev libv4l-dev libx265-dev
# sound processing deps
RUN apt install -y libsndfile1 libasound2-dev

# Build OpenCV
RUN PYTHON_VERSION=$(/opt/miniconda3/envs/intelpython3/bin/python -c 'import platform; print(platform.python_version()[:-2])'); \
cd opencv-${OPENCV_VERSION}; mkdir build; cd build; cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D ENABLE_FAST_MATH=ON \
-D FORCE_VTK=OFF \
-D WITH_TBB=ON \
-D WITH_V4L=ON \
-D WITH_FFMPEG=ON \
-D WITH_QT=ON \
-D WITH_OPENGL=ON \
-D WITH_GDAL=OFF \
-D WITH_XINE=ON \
-D WITH_MKL=ON \
-D MKL_ROOT_DIR=/opt/intel/mkl \
-D BUILD_EXAMPLES=OFF \
-D BUILD_TESTS=OFF \
-D OPENCV_GENERATE_PKGCONFIG=YES \
-D BUILD_opencv_dnn=OFF \
-D BUILD_opencv_legacy=OFF \
-D BUILD_opencv_python2=OFF \
-D BUILD_opencv_python3=ON \
-D PYTHON3_EXECUTABLE=/opt/miniconda3/envs/intelpython3/bin/python \
-D PYTHON3_PACKAGES_PATH=/opt/miniconda3/envs/intelpython3/lib/python${PYTHON_VERSION}/site-packages \
-D PYTHON3_LIBRARY=/opt/miniconda3/envs/intelpython3/lib/libpython${PYTHON_VERSION}m.so \
-D PYTHON_DEFAULT_EXECUTABLE=/opt/miniconda3/envs/intelpython3/bin/python ..

RUN cd opencv-${OPENCV_VERSION}/build; make -j$(nproc); make install; rm -rf /tmp/opencv-${OPENCV_VERSION}

# MXNet deps
RUN apt install -y liblapack-dev gfortran

# Build MXNet
COPY config.mk mxnet-${MXNET_VERSION}/.
RUN cd mxnet-${MXNET_VERSION} && make -j$(nproc)

SHELL ["/bin/bash", "-c"]

# MKLDNN post-install
RUN cp mxnet-${MXNET_VERSION}/3rdparty/mkldnn/build/install/lib/libmkldnn.so* /usr/local/lib/.

# Prepare env variables for all users
# Docker interactive mode
ENV LD_LIBRARY_PATH /usr/local/lib:${LD_LIBRARY_PATH}
# For interactive login session
RUN echo "LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}" >> /etc/environment

# Install MXNet
RUN source /opt/miniconda3/bin/activate intelpython3; \
    pip install --upgrade pip; \
    pip uninstall --yes mxnet; \
    cd mxnet-${MXNET_VERSION}/python; \
    python setup.py install 2>&1 > /tmp/intelpython3-mxnet.log || echo 'Cannot downgrade numpy'

RUN source /opt/miniconda3/bin/activate intelpython3; \
    pip install mxboard tensorflow matplotlib pandas pillow

# Runit startup
COPY bootstrap.sh /usr/sbin/bootstrap
RUN chmod 755 /usr/sbin/bootstrap

ENTRYPOINT ["/usr/sbin/bootstrap"]
