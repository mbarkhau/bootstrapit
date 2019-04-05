# This image is used for temporary stages that set up
# the project specific dependencies, before they
# are copied to the base image of a project.
#
# Generated using:
#   $ git clone git@gitlab.com:mbarkhau/bootstrapit.git
#   $ cd bootstrapit
#   bootstrapit $ make build_docker
#
# pushes to registry.gitlab.com/mbarkhau/bootstrapit/env_builder

FROM registry.gitlab.com/mbarkhau/bootstrapit/root

RUN apt-get --yes install ca-certificates openssh-client;

ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

# The latest version of conda can be newer than the latest
# version for which an installer is available. Further
# down we invoke "conda update --all" to update to the lates
# version. This Marker is incremented when we know such an
# update was published and want to update the image.
ENV MINICONDA_VERSION_MARKER 4.6.11
ENV MINICONDA Miniconda3-latest-Linux-x86_64.sh
ENV MINICONDA_URL https://repo.continuum.io/miniconda/$MINICONDA

RUN curl -L "$MINICONDA_URL" --silent -o miniconda3.sh && \
    /bin/bash miniconda3.sh -f -b -p $CONDA_DIR && \
    rm miniconda3.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    conda update --all --yes && \
    conda config --set auto_update_conda False
