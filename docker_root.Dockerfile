# This is the image used both by env_builder and also for the
# base images of a project, which contain all of its
# dependencies.
#
# Generated using:
#   $ git clone git@gitlab.com:mbarkhau/bootstrapit.git
#   $ cd bootstrapit
#   bootstrapit $ make build_docker
#
# pushes to registry.gitlab.com/mbarkhau/bootstrapit/root
FROM debian:stretch-slim

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV LANGUAGE en_US.UTF-8

ENV SHELL /bin/bash

RUN apt-get update && \
    apt-get install --yes bash make sed grep gawk curl git bzip2 unzip;

CMD [ "/bin/bash" ]
