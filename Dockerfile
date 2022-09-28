FROM ubuntu:20.04

# Avoid warnings
# debconf: unable to initialize frontend: Dialog
# debconf: (TERM is not set, so the dialog frontend is not usable.)
# RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#####################################################################
# libgfortran4 is needed to load FMU for FMUZoneAdapterZones1.mo
# libpython3.8-dev is needed for Buildings.Utilities.IO.Python_3_8
RUN apt-get update && \
  apt-get --no-install-recommends install -y \
  ca-certificates \
  wget \
  gnupg2 \
  libgfortran4 \
  libpython3.8-dev \
  curl \
  lsb-release \
  && \
  rm -rf /var/lib/apt/lists/*

#RUN echo "deb https://build.openmodelica.org/apt focal nightly" | tee -a /etc/apt/sources.list
#RUN echo "deb https://build.openmodelica.org/apt focal stable"  | tee -a /etc/apt/sources.list
#RUN echo "deb https://build.openmodelica.org/apt focal release" | tee -a /etc/apt/sources.list
#RUN wget -qO- http://build.openmodelica.org/apt/openmodelica.asc | apt-key add -

RUN curl -fsSL http://build.openmodelica.org/apt/openmodelica.asc | gpg --dearmor -o /usr/share/keyrings/openmodelica-keyring.gpg
# Or replace stable with nightly or release
RUN echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openmodelica-keyring.gpg] https://build.openmodelica.org/apt \
 $(lsb_release -cs) nightly" | tee /etc/apt/sources.list.d/openmodelica.list > /dev/null

# See https://build.openmodelica.org/apt/dists/focal/nightly/binary-amd64/Packages for package version.
RUN apt-get update && \
  apt-get --no-install-recommends install -y \
  omc=1.20.0~dev-314-g3033f43-1 && \
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

# Install MSL
RUN echo \
  "updatePackageIndex(); getErrorString();\ninstallPackage(Modelica, \"4.0.0\"); getErrorString();" >> /tmp/installMSL.mos && \
  omc /tmp/installMSL.mos && \
  rm /tmp/installMSL.mos
##  chown ${uid}:${gid} /home/developer

RUN echo "=== Installation successful"
