FROM nvidia/cuda:11.1-cudnn8-devel-ubuntu18.04

# Use New Zealand mirrors
RUN sed -i 's/archive/nz.archive/' /etc/apt/sources.list

RUN apt update

# Set timezone to Auckland
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y locales tzdata
RUN locale-gen en_NZ.UTF-8
RUN dpkg-reconfigure locales
RUN echo "Pacific/Auckland" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
ENV LANG en_NZ.UTF-8
ENV LANGUAGE en_NZ:en

# Create user 'kaimahi' to create a home directory
RUN useradd kaimahi
RUN mkdir -p /kaimahi/
WORKDIR /kaimahi/

# These two lines are needed to run unoconv
RUN chown -R kaimahi:kaimahi /kaimahi
ENV HOME /kaimahi

# Install LibGL + openCV dependencies
RUN apt-get update && \
  apt-get install -y \
  libboost-all-dev \
  cmake \
  ffmpeg \
  libsm6 \
  libxext6 \
  unzip

# Install python + other things
RUN apt update
RUN apt install -y python3.8-dev python3-pip
RUN rm /usr/bin/python3 && ln -s /usr/bin/python3.8 /usr/bin/python3

RUN python3 -m pip install --upgrade pip setuptools wheel
COPY Requirements.txt /root/requirements.txt
RUN pip3 install -r /root/requirements.txt

# Install Torch for cuda11.1
RUN pip3 install torch==1.8.0+cu111 torchvision==0.9.0+cu111 torchaudio==0.8.0 -f https://download.pytorch.org/whl/torch_stable.html
