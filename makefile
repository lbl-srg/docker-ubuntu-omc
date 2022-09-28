# Makefile for docker that contains Dymola.
#
#
# mwetter@lbl.gov                                    2019-01-08
###############################################################

OPENMODELICA_VERSION=1.20.0_dev-314-g3033f43-1
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

NAME=michaelwetter/ubuntu-2004-omc:${OPENMODELICA_VERSION}

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
	docker build --no-cache -t ${NAME} .

push:
	@echo "**** Pushing image ${NAME}"
	docker push ${NAME}
