FROM ubuntu:18.04
MAINTAINER Michael Wetter <mwetter@lbl.gov>

# Avoid warnings
# debconf: unable to initialize frontend: Dialog
# debconf: (TERM is not set, so the dialog frontend is not usable.)
# RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#####################################################################
RUN apt-get update && \
  apt-get --no-install-recommends install -y \
  ca-certificates \
  wget \
  gnupg2 \
  && \
  rm -rf /var/lib/apt/lists/*

RUN echo "deb http://build.openmodelica.org/apt bionic stable" | tee -a /etc/apt/sources.list
RUN echo "deb-src http://build.openmodelica.org/apt bionic stable" | tee -a /etc/apt/sources.list
RUN wget -qO- http://build.openmodelica.org/apt/openmodelica.asc | apt-key add -

## Installing 1.61.1-1 requires
## the command RUN echo "deb https://build.openmodelica.org/omc/builds/linux/releases/1.16.1/ bionic release" | tee -a /etc/apt/sources.list
##RUN apt-get update && \
##  apt-get --no-install-recommends install -y \
##  omc=1.16.1-1 \
##  omlib-modelica-3.2.2

RUN apt-get update && \
  apt-get --no-install-recommends install -y \
  openmodelica && \
  (for PKG in `apt-cache search "omlib-modelica*" | cut -d" " -f1`; do apt-get install -y "$PKG"; done) && \
  rm -rf /var/lib/apt/lists/*

# Set user id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    mkdir -p /etc/sudoers.d && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer && \
    mkdir -m 1777 /tmp/.X11-unix

USER developer
ENV HOME /home/developer
RUN echo "=== Installation successful"
