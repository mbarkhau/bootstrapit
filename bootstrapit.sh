#!/bin/bash

set -Ee -o pipefail;
shopt -s globstar extglob;

BOOTSTRAPIT_GIT_URL="https://gitlab.com/mbarkhau/bootstrapit.git/"

# Argument parsing from
# https://stackoverflow.com/a/14203146/62997

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -g|--git-repo-url)
    GIT_REPO_URL="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--module)
    MODULE_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--path)
    LOCAL_REPO_PATH="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--author-name)
    AUTHOR_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--author-email)
    AUTHOR_EMAIL="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done


set -- "${POSITIONAL[@]}" # restore positional parameters


function usage()
{
    echo "bootstrapit - python project bootstrapping script"
    echo ""
    echo "Usage: "
    echo ""
    echo "    -h --help"
    echo "    -g --git-repo-url <GIT_REPO_URL>    e.g. https://github.com/<username>/<package_name>"
    echo "    -p --path <LOCAL_REPO_PATH>         e.g. <package_name>"
    echo "    -m --module <MODULE_NAME>           e.g. <module_name>"
    echo "    -a --author-name <AUTHOR_NAME>      Parsed from .gitconfig if available"
    echo "    -e --author-email <AUTHOR_EMAIL>    Parsed from .gitconfig if available"
    echo ""
}

while [ "$1" != "" ]; do
    FLAG=`echo $1 | awk -F= '{print $1}'`
    case $FLAG in
        -h | --help)
            usage
            exit
            ;;

        *)
            echo "ERROR: unknown parameter \"$FLAG\""
            usage
            exit 1
            ;;
    esac
    shift
done


if [[ -n $1 ]]; then
    echo "ERROR: Unknown argument :" $1;
    exit 1;
fi

if [[ ! ${GIT_REPO_URL} ]]; then
    echo "ERROR: Missing argument -g|--git-repo-url <GIT_REPO_URL>";
    exit 1;
fi

if [[ ! ${GIT_REPO_URL} =~ ^https?://[^/]+/[^/]+/[^/]+(/|.git)?$ ]]; then
    echo "ERROR: Invalid argument '${GIT_REPO_URL}'";
    exit 1;
fi

# TODO: if repo url is not gitlab.com github.com bitbucket.com
#   then assume a private repo and make the license propriatary
#   /all rights reserved

YEAR=$(date +%Y)
MONTH=$(date +%m)

GIT_REPO_DOMAIN=$( echo "${GIT_REPO_URL}" | sed -E -e 's;https?://;;g' | sed -E 's;/.*$;;g' )
GIT_REPO_PATH=$( echo "${GIT_REPO_URL}" | sed -E -e 's;https?://[^/]+/;;g' | sed -E 's;(/|.git)$;;g' )
GIT_REPO_NAMESPACE=$( echo "${GIT_REPO_PATH}" | sed -E -e 's;/[A-Za-z_-]+$;;g' )
GIT_REPO_NAME=$( echo "${GIT_REPO_PATH}" | sed -E -e 's;^[A-Za-z_-]+/;;g' )

if [[ ! ${LOCAL_REPO_PATH} ]]; then
    LOCAL_REPO_PATH=$(GIT_REPO_NAME)
fi

if [[ ! ${MODULE_NAME} ]]; then
    MODULE_NAME=$( echo "$GIT_REPO_NAME" | sed -E -e 's;-;_;g');
fi

PAGES_DOMAIN="pages.${GIT_REPO_DOMAIN}"
DOCKER_REGISTRY_DOMAIN="registry.${GIT_REPO_DOMAIN}";

if [[ ${GIT_REPO_DOMAIN} == "github.com" ]]; then
    PAGES_DOMAIN="github.io";
fi

if [[ ${GIT_REPO_DOMAIN} == "gitlab.com" ]]; then
    PAGES_DOMAIN="gitlab.io";
fi

if [[ ${GIT_REPO_DOMAIN} == "git2.fastbill.com" ]]; then
    PAGES_DOMAIN="gitlab-pages.fastbill.com";
    DOCKER_REGISTRY_DOMAIN="docker.fastbill.com"
fi

PAGES_URL="https://${GIT_REPO_NAMESPACE}.${PAGES_DOMAIN}/${GIT_REPO_NAME}/"


if [[ -f "${LOCAL_REPO_PATH}/.git/config" ]]; then
    echo "parsing author info from ${LOCAL_REPO_PATH}/.git/config"
    AUTHOR_NAME=${AUTHOR_NAME:=$(grep -oP '(?<=name = ).*' ${LOCAL_REPO_PATH}/.git/config)} || true;
    AUTHOR_EMAIL=${AUTHOR_EMAIL:=$(grep -oP '(?<=email = ).*' ${LOCAL_REPO_PATH}/.git/config)} || true;
fi

if [[ -f "${HOME}/.gitconfig" ]]; then
    echo "parsing author info from ${HOME}/.gitconfig";
    AUTHOR_NAME=${AUTHOR_NAME:=$(grep -oP '(?<=name = ).*' ${HOME}/.gitconfig)};
    AUTHOR_EMAIL=${AUTHOR_EMAIL:=$(grep -oP '(?<=email = ).*' ${HOME}/.gitconfig)};
fi

if [[ ! -n ${AUTHOR_NAME} ]]; then
    echo "Missing argument -a|--author-name <AUTHOR_NAME>"
    exit 1
fi

if [[ ! -n ${AUTHOR_EMAIL} ]]; then
    echo "Missing argument -e|--author-email <AUTHOR_EMAIL>"
    exit 1
fi

mkdir -p "${LOCAL_REPO_PATH}";

if [[ -f ${LOCAL_REPO_PATH}/.git/config ]]; then
    OLD_PWD=${PWD}
    cd ${LOCAL_REPO_PATH};
    if [[ $( git diff -s --exit-code || echo $? ) -gt 0 ]]; then
        echo "Not updating existing repository with uncomitted changes."
        echo "This is to avoid overwriting non comitted local changes."
        exit 1;
    fi
    cd $OLD_PWD;
fi

BOOTSTRAPIT_GIT_PATH=/tmp/bootstrapit;

if [[ ! -e $BOOTSTRAPIT_GIT_PATH ]]; then
    git clone ${BOOTSTRAPIT_GIT_URL} ${BOOTSTRAPIT_GIT_PATH};
else
    OLD_PWD=${PWD};
    cd ${BOOTSTRAPIT_GIT_PATH};
    git pull --quiet;
    cd $OLD_PWD;
fi

function format_template()
{
    cat $1 \
        | sed "s;\${GIT_REPO_URL};${GIT_REPO_URL};g" \
        | sed "s;\${GIT_REPO_PATH};${GIT_REPO_PATH};g" \
        | sed "s;\${GIT_REPO_NAMESPACE};${GIT_REPO_NAMESPACE};g" \
        | sed "s;\${GIT_REPO_NAME};${GIT_REPO_NAME};g" \
        | sed "s;\${GIT_REPO_DOMAIN};${GIT_REPO_DOMAIN};g" \
        | sed "s;\${DOCKER_REGISTRY_DOMAIN};${DOCKER_REGISTRY_DOMAIN};g" \
        | sed "s;\${PAGES_DOMAIN};${PAGES_DOMAIN};g" \
        | sed "s;\${PAGES_URL};${PAGES_URL};g" \
        | sed "s;\${AUTHOR_EMAIL};${AUTHOR_EMAIL};g" \
        | sed "s;\${AUTHOR_NAME};${AUTHOR_NAME};g" \
        | sed "s;\${MODULE_NAME};${MODULE_NAME};g" \
        | sed "s;\${YEAR};${YEAR};g" \
        | sed "s;\${MONTH};${MONTH};g" \
        > $1.tmp;
    mv $1.tmp $1;
}

function copy_template()
{
    if [[ -z ${2} ]]; then
        dest_path=${LOCAL_REPO_PATH}/$1;
    else
        dest_path=${LOCAL_REPO_PATH}/$2;
    fi;
    cat ${BOOTSTRAPIT_GIT_PATH}/$1.template > ${dest_path};

    format_template ${dest_path};
}

mkdir -p "${LOCAL_REPO_PATH}/test/";
mkdir -p "${LOCAL_REPO_PATH}/vendor/";
mkdir -p "${LOCAL_REPO_PATH}/scripts/";
mkdir -p "${LOCAL_REPO_PATH}/stubs/";
mkdir -p "${LOCAL_REPO_PATH}/src/";
mkdir -p "${LOCAL_REPO_PATH}/requirements/";
mkdir -p "${LOCAL_REPO_PATH}/src/${MODULE_NAME}";

copy_template README.md;
copy_template CONTRIBUTING.md;
copy_template CHANGELOG.md;
copy_template LICENSE;
copy_template license.header;
copy_template stubs/README.md;

copy_template setup.py;
copy_template setup.cfg;

copy_template makefile;
copy_template makefile.config.make;
copy_template makefile.extra.make;
copy_template docker_base.Dockerfile;

copy_template requirements/conda.txt;
copy_template requirements/pypi.txt;
copy_template requirements/development.txt;
copy_template requirements/integration.txt;
copy_template requirements/vendor.txt;

copy_template .gitlab-ci.yml;
copy_template scripts/update_conda_env_deps.sh;
copy_template scripts/setup_conda_envs.sh;
copy_template scripts/pre-push-hook.sh;

copy_template __main__.py "src/${MODULE_NAME}/__main__.py";
copy_template __init__.py "src/${MODULE_NAME}/__init__.py";
touch "${LOCAL_REPO_PATH}/test/__init__.py";

chmod +x "${LOCAL_REPO_PATH}/src/${MODULE_NAME}/__main__.py";
chmod +x "${LOCAL_REPO_PATH}/scripts/update_conda_env_deps.sh";
chmod +x "${LOCAL_REPO_PATH}/scripts/setup_conda_envs.sh";
chmod +x "${LOCAL_REPO_PATH}/scripts/pre-push-hook.sh";

head -n 7 ${LOCAL_REPO_PATH}/license.header \
    | tail -n +3 \
    | sed -re 's/(^   |^$)/#/g' \
    > .py_license.header;

src_files=${LOCAL_REPO_PATH}/src/**/*.py

for src_file in $src_files; do
    if grep -q -E '^# SPDX-License-Identifier' $src_file; then
        continue;
    fi
    offset=0
    if grep -z -q -E '^#![/a-z ]+?python' $src_file; then
        let offset+=1;
    fi
    if grep -q -E '^# .+?coding: [a-zA-Z0-9_\-]+' $src_file; then
        let offset+=1;
    fi
    rm -f ${src_file}.with_header;
    if [[ $offset -gt 0 ]]; then
        head -n $offset ${src_file} > ${src_file}.with_header;
    fi
    let offset+=1;
    cat .py_license.header >> ${src_file}.with_header;
    tail -n +$offset ${src_file} >> ${src_file}.with_header;
    mv ${src_file}.with_header $src_file;
done

rm .py_license.header
