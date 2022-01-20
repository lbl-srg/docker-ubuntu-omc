FROM ubuntu:20.04

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

RUN echo "deb http://build.openmodelica.org/apt bionic nightly" | tee -a /etc/apt/sources.list
RUN echo "deb http://build.openmodelica.org/apt bionic stable" | tee -a /etc/apt/sources.list
RUN echo "deb-src http://build.openmodelica.org/apt bionic nightly" | tee -a /etc/apt/sources.list
RUN wget -qO- http://build.openmodelica.org/apt/openmodelica.asc | apt-key add -

RUN apt-get update && \
  apt-get --no-install-recommends install -y \
  omc=1.19.0~dev-531-g72aca4f-1 \
  omlib-modelica-4.0.0=4.0.0~20210622~131817~git~OM~maint~4.0.x-1 \
  omlib-modelica-3.2.3=3.2.3~20210516~174036~git~OM~maint~3.2.3-1 && \
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
