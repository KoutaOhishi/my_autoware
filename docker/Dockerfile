FROM ubuntu:20.04 as intermediate
LABEL maintainer Kota Oishi

#Install時の入力待ちブロックをしないようにする
ENV DEBIAN_FRONTEND=noninteractive

######################
# Install basic apps #
######################
RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y \
	wget \
	curl \
	git \
	build-essential \
	vim \
	sudo \
	lsb-release \
	locales \
	bash-completion \
	tzdata \
	gosu \
	dirmngr \
	gnupg2 \
	lsb-release \
	gedit \
	tzdata \
	iputils-ping && \
	rm -rf /var/lib/apt/lists/*

##############
# Add a user #
##############
# add sudo user
ENV USER_ID=${LOCAL_UID:-1000}
ENV GROUP_ID=${LOCAL_GID:-1000}
RUN apt-get update && \
	apt-get install -y sudo && \
	useradd --create-home --home-dir /home/user --shell /bin/bash --user-group --groups adm,sudo -u ${USER_ID} user && \
	groupmod -g ${GROUP_ID} -o user && \
    echo user:password | chpasswd && \
   	echo "Defaults visiblepw" >> /etc/sudoers && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

########################################
# Copy setup_shell files from local PC #
########################################
COPY setup_shells/ /home/user/setup_shells

#########################################
# Install ROS Noetic & create catkin_ws #
#########################################
RUN apt-get update &&\
    gosu user bash /home/user/setup_shells/install_ros_noetic.sh


###################################
# Environment_variable_preference #
###################################
ENV CUDA_VERSION 11.2.0
ENV NCCL_VERSION 2.8.4
ENV CUDNN_VERSION 8.1.1.33
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.2 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 driver>=450,driver<451"
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs


###################
# Graphic setting #
###################
RUN apt-get update && \
    apt-get install -y \
        pkg-config \
        libxau-dev \
        libxdmcp-dev \
        libxcb1-dev \
        libxext-dev \
        freeglut3-dev \
        libglew-dev \
        mesa-utils \
        x11-apps \
        libx11-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=nvidia/opengl:1.0-glvnd-runtime-ubuntu16.04 \
  /usr/local/lib/x86_64-linux-gnu \
  /usr/local/lib/x86_64-linux-gnu

COPY --from=nvidia/opengl:1.0-glvnd-runtime-ubuntu16.04 \
  /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json \
  /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json

RUN echo '/usr/local/lib/x86_64-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    ldconfig && \
    echo '/usr/local/$LIB/libGL.so.1' >> /etc/ld.so.preload && \
    echo '/usr/local/$LIB/libEGL.so.1' >> /etc/ld.so.preload


#########################
# nvidia driver setting #
#########################
## base ##
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-2=11.2.72-1 \
    cuda-compat-11-2 \
    && ln -s cuda-11.2 /usr/local/cuda 

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf



## runtime ##
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-2=11.2.0-1 \
    libnpp-11-2=11.2.1.68-1 \
    cuda-nvtx-11-2=11.2.67-1 \
    libcublas-11-2=11.3.1.68-1 \
    libcusparse-11-2=11.3.1.68-1 \
    libnccl2=$NCCL_VERSION-1+cuda11.2 && \
    apt-mark hold libcublas-11-2 libnccl2

## devel ##
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-dev-11-2=11.2.72-1 \
    cuda-command-line-tools-11-2=11.2.0-1 \
    cuda-minimal-build-11-2=11.2.0-1 \
    cuda-libraries-dev-11-2=11.2.0-1 \
    cuda-nvml-dev-11-2=11.2.67-1 \
    libnpp-dev-11-2=11.2.1.68-1 \
    libnccl-dev=2.8.4-1+cuda11.2 \
    libcublas-dev-11-2=11.3.1.68-1 \
    libcusparse-dev-11-2=11.3.1.68-1 && \
    apt-mark hold libcublas-dev-11-2 libnccl-dev

## devel/cudnn8 ##
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn8=$CUDNN_VERSION-1+cuda11.2 \
    libcudnn8-dev=$CUDNN_VERSION-1+cuda11.2 \
    && apt-mark hold libcudnn8

RUN echo "export PATH='/usr/local/cuda/bin:$PATH'" >> ~/.bashrc &&\
	echo "export LD_LIBRARY_PATH='/usr/local/cuda/lib64:$LD_LIBRARY_PATH'" >> ~/.bashrc &&\
	apt-get update && apt-get install -y --no-install-recommends nvidia-driver-470


# clean cache
RUN apt-get clean &&\
	apt-get autoremove && \	
    rm -rf /var/lib/apt/lists/




###############
# Install pip #
###############


####################
# Multi stage build #
#####################
FROM ubuntu:20.04
COPY --from=intermediate / /


##################
# Other settings #
##################
# set time zone
ENV TZ Asia/Tokyo

# set Language
RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

# User setting:
ENV USER user
WORKDIR /home/user/ 

# Terminal setting
ENV CONTAINER_NAME=${CNAME:-container}
RUN echo "export PS1='\[\e[1;33;40m\]\$CONTAINER_NAME\[\e[0m\] ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '">> /home/user/.bashrc

# clean cache
RUN apt-get clean &&\
	apt-get autoremove && \	
    rm -rf /var/lib/apt/lists/
