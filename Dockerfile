#FROM ufoym/deepo
FROM continuumio/anaconda3
ARG ENABLE_GPU
# to prevent libdm from rainsing the interactive keyboard prompt
#ENV TERM xterm
## Or alternatively, you can use:
ENV DEBIAN_FRONTEND noninteractive
RUN echo ${ENABLE_GPU}

RUN conda install python==3.6.5

# note: avoid the no `patchef` error
RUN apt-get -y install software-properties-common
#RUN add-apt-repository ppa:jamesh/snap-support && apt-get -y update
RUN apt-get -y update
RUN sleep 10
RUN apt-get -y install \
    ffmpeg \
    libav-tools \
    libpq-dev \
    libjpeg-dev \
    cmake \
    swig \
    python-opengl \
    libboost-all-dev \
    libsdl2-dev \
    xpra

# prep for mpi4py
RUN apt-get -y install git \
    wget \
    python-dev \
    python3-dev \
    libopenmpi-dev \
    python-pip \
    zlib1g-dev \
    cmake

RUN apt -y install patchelf

# prep for mujoco
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    git \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libglew-dev \
    libosmesa6-dev \
    software-properties-common \
    net-tools \
    unzip \
    vim \
    virtualenv \
    wget \
    xpra \
    xserver-xorg-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN yes | pip install --upgrade pip

# add mujoco binary and license file
RUN mkdir -p /root/.mujoco \
    && wget https://www.roboti.us/download/mjpro150_linux.zip -O mujoco.zip \
    && unzip mujoco.zip -d /root/.mujoco \
    && rm mujoco.zip
COPY ./mjkey.txt /root/.mujoco/
ENV LD_LIBRARY_PATH /root/.mujoco/mjpro150/bin:${LD_LIBRARY_PATH}

# this fixes the cannot import 'abs' protobuf error
# Now use gpu wheel for cpu-only because can't find cpu only wheels for python 3.7.
RUN if [ "$ENABLE_GPU" = 'yes' ]; \
then \
    echo "supporting GPU" && \
    echo ${ENABLE_GPU} && \
    yes | pip uninstall tensorflow tensorflow-gpu protobuf && \
    yes | pip install --ignore-installed --upgrade --ignore-installed tensorflow-gpu --user; \
else \
    echo "cpu only version" && \
    echo ${ENABLE_GPU} && \
    yes | pip uninstall tensorflow tensorflow-gpu protobuf && \
    yes | pip install --ignore-installed --upgrade --ignore-installed tensorflow --user; \
fi
#    yes | pip install --ignore-installed --upgrade --ignore-installed --user https://github.com/evdcush/TensorFlow-wheels/releases/download/tf-1.12.0-gpu-10.0/tensorflow-1.12.0-cp36-cp36m-linux_x86_64.whl; \
# yes | pip install --ignore-installed --upgrade --ignore-installed tensorflow-gpu --user; \
# yes | pip install --ignore-installed --upgrade --ignore-installed tensorflow --user; \

# note: for mujoco.py
RUN yes | pip install cffi pip --upgrade

WORKDIR /srv
# note: openai baseline depends on tensorflow. We force --no-deps to avoid this.
# note: which means that we have to uninstall tensorflow (cpu-only version)
# Need to add setup.py because requirements.txt is empty
ADD ./setup.py /srv/setup.py
ADD ./requirements.txt /srv/requirements.txt
RUN pip install -r requirements.txt

COPY vendor/Xdummy /usr/local/bin/Xdummy
RUN chmod +x /usr/local/bin/Xdummy

ENV LANG C.UTF-8

# we mount the project directory under /opt/project.
# This way the image does not have to
#WORKDIR /opt/project
#RUN pip install -e /opt/project

# ENTRYPOINT ["run_server"]
