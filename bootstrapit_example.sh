#!/bin/bash
# Bootstrapit Project Configuration

# Author info is used to populate
#  - License Info
#  - setup.py fields
#  - README.md contributor info
# This can also be a company or organization name and email
AUTHOR_NAME="Vandelay Industries"
AUTHOR_EMAIL="info@vandelay.industries"

KEYWORDS="keywords used on pypi"
DESCRIPTION="Example description."

# Valid Options are "None" or any valid SPDX Identifier:
#   - None (All Rights Reserved)
#   - MIT
#   - GPL-3.0-only
#   - Apache-2.0
#   - GPL-2.0-only
#   - BSD-3-Clause
#   - AGPL-3.0-only
#   - LGPL-3.0-only
#   - MPL-2.0
#
# See: https://choosealicense.com/licenses/
# License text pulled from:
#   https://github.com/spdx/license-list-data/tree/master/text

LICENSE_ID="MIT"

PACKAGE_NAME="mypackagename"
# MODULE_NAME="${PACKAGE_NAME}"
GIT_REPO_NAMESPACE="vandelay"
GIT_REPO_DOMAIN="gitlab.com"

# These must be valid (space separated) conda package names.
# A separate conda environment will be created for each of these.
#
# Some valid options (as of late 2018) are:
# - python=2.7
# - python=3.5
# - python=3.6
# - python=3.7
# - pypy2.7
# - pypy3.5

DEFAULT_PYTHON_VERSION="python=3.6"
# SUPPORTED_PYTHON_VERSIONS="python=3.6 python=3.7"

# GIT_REPO_URL=https://${GIT_REPO_DOMAIN}/${GIT_REPO_NAMESPACE}/${PACKAGE_NAME}


# SPDX_LICENSE_ID="MIT"
# LICENSE_NAME="MIT License"
# LICENSE_CLASSIFIER="License :: OSI Approved :: MIT License"
# LICENSE_CLASSIFIER="License :: Other/Proprietary License"
# COPYRIGHT_STRING="Copyright (c) ${YEAR} ${AUTHOR_NAME} (${AUTHOR_EMAIL}) - ${LICENSE_NAME}"

# Pages are used by the ci runner to host coverage reports
# PAGES_DOMAIN=gitlab.io
# PAGES_DOMAIN=github.io
# PAGES_DOMAIN=bitbucket.io
# PAGES_DOMAIN=gitlab-pages.yourdomain.com

# DOCKER_REGISTRY_DOMAIN=registry.gitlab.com
# DOCKER_REGISTRY_DOMAIN=docker.yourdomain.com
#
# DOCKER_ROOT_IMAGE=debian:stable-slim
# # The alpine-glibc image is a bit smaller than debian,
# # but may be politically less viable in your organization.
# DOCKER_ROOT_IMAGE=frolvlad/alpine-glibc
# DOCKER_REGISTRY_URL=${DOCKER_REGISTRY_DOMAIN}/${GIT_REPO_NAMESPACE}/${PACKAGE_NAME}
# DOCKER_BASE_IMAGE=${DOCKER_REGISTRY_URL}/base:latest

# LICENSE_NAME="Proprietary License"
# classifiers: https://pypi.org/pypi?%3Aaction=list_classifiers

# 1: Disables a failsafe for publishing to pypi
IS_PUBLIC=0


# PAGES_URL="https://${NAMESPACE}.${PAGES_DOMAIN}/${PACKAGE_NAME}/"

## Download and run the actual update script

if [[ $KEYWORDS == "keywords used on pypi" ]]; then
    echo "FAILSAFE! Default bootstrapit config detected.";
    echo "Did you forget to update parameters in your 'bootstrapit.sh' ?"
    exit 1;
fi

PROJECT_DIR=$(dirname "$0");

if ! [[ -f "$PROJECT_DIR/scripts/bootstrapit_update.sh" ]]; then
    mkdir -p "$PROJECT_DIR/scripts/";
    RAW_FILES_URL="https://gitlab.com/mbarkhau/bootstrapit/raw/master";
    curl --silent "$RAW_FILES_URL/scripts/bootstrapit_update.sh" \
        > "$PROJECT_DIR/scripts/bootstrapit_update.sh.tmp";
    mv "$PROJECT_DIR/scripts/bootstrapit_update.sh.tmp" \
        "$PROJECT_DIR/scripts/bootstrapit_update.sh";
fi

source "$PROJECT_DIR/scripts/bootstrapit_update.sh";
