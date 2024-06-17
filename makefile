# Makefile for docker that contains Dymola.
#
#
# mwetter@lbl.gov                                    2019-01-08
###############################################################

# Version, such as 1.22.0-1 (for release) or 1.22.0~dev-41-g8a5b18f-1 (for stable)
# See https://build.openmodelica.org/apt/dists/focal/nightly/binary-amd64/Packages for package version.
#OPENMODELICA_VERSION=1.23.0~dev.beta.1-1-g379f714-1
OPENMODELICA_VERSION=1.23.0-1
# Use stable, nightly or release
#TYPE=stable
TYPE=release


OPENMODELICA_VERSION_NOTILDE=$(subst ~,-,$(OPENMODELICA_VERSION))
TOP_PACKAGE=Buildings

# Top level package name, and location of the library to be tested
BUILDINGS_LIB=~/proj/ldrd/bie/modeling/github/lbl-srg/modelica-buildings
IBPSA_LIB=~/proj/ldrd/bie/modeling/github/ibpsa/modelica-ibpsa

ifeq ($(TOP_PACKAGE), Buildings)
MODELICA_LIB=${BUILDINGS_LIB}
else
MODELICA_LIB=${IBPSA_LIB}
endif

LIB_VERSION=`grep -Po ^version=\".+\" ${MODELICA_LIB}/${TOP_PACKAGE}/package.mo | \
  sed -s 's/version=\"//g' | \
  sed -s 's/\",//g'`


MO_ROOT=$(shell basename ${MODELICA_LIB})

NAME=lbnlblum/ubuntu-2204-omc:${OPENMODELICA_VERSION_NOTILDE}

#DISPLAY=$(shell echo ${DOCKER_HOST} | sed -e 's|tcp://||' | sed -e 's|:.*||')
UNAME := $(shell uname)

DOCKER_FLAGS=\
	--detach=false \
	--rm \
	--user=developer \
	-v ${MODELICA_LIB}:/mnt/modelica_lib \
	-v `pwd`/shared:/mnt/shared \
	${NAME}

COMMAND_RUN=docker run ${DOCKER_FLAGS} /bin/bash -c

COMMAND_START=docker run -t --interactive ${DOCKER_FLAGS} /bin/bash -c -i


print_version:
	@echo ${OPENMODELICA_VERSION_NOTILDE}


start_bash:
	$(COMMAND_START) \
	   "ln -s /mnt/modelica_lib/${TOP_PACKAGE} /home/developer/.openmodelica/libraries/${TOP_PACKAGE}\ ${LIB_VERSION} && \
            cd /mnt/shared && bash"

test:
	rm -f shared/*
	mkdir -p shared
	cp test.mos shared/
	$(COMMAND_RUN) \
	  "ln -s /mnt/modelica_lib/${TOP_PACKAGE} /home/developer/.openmodelica/libraries/${TOP_PACKAGE}\ ${LIB_VERSION} && \
	  cd /mnt/shared && \
	  omc test.mos"
	rm shared/*

remove:
	docker rm $(docker ps -a -q)

remove-image:
	docker rmi ${NAME}


build:
	@echo Building docker image ${NAME}
	docker build --build-arg OPENMODELICA_VERSION=${OPENMODELICA_VERSION} --build-arg TYPE=${TYPE} --no-cache -t ${NAME} .

push:
	@echo "**** Pushing image ${NAME}"
	docker push ${NAME}
