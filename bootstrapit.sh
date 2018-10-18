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

if [[ ! ${MODULE_NAME} ]]; then
    MODULE_NAME=$( echo "$GIT_REPO_NAME" | sed -E -e 's;-;_;g');
fi

PAGES_DOMAIN="${GIT_REPO_DOMAIN}"

if [[ ${GIT_REPO_DOMAIN} == "github.com" ]]; then
    PAGES_DOMAIN="gitlab.io";
fi

if [[ ${GIT_REPO_DOMAIN} == "github.com" ]]; then
    PAGES_DOMAIN="gitlab.io";
fi

PAGES_URL="https://${GIT_REPO_NAMESPACE}.${PAGES_DOMAIN}/${GIT_REPO_NAME}/"


if [[ -f ${GIT_REPO_NAME}/.git/config ]]; then
    echo "parsing from .git/config"
    AUTHOR_NAME=${AUTHOR_NAME:=$(grep -oP '(?<=name = ).*' ${HOME}/.git/config)}
    AUTHOR_EMAIL=${AUTHOR_EMAIL:=$(grep -oP '(?<=email = ).*' ${HOME}/.git/config)}
fi

if [[ -f ${HOME}/.gitconfig ]]; then
    AUTHOR_NAME=${AUTHOR_NAME:=$(grep -oP '(?<=name = ).*' ${HOME}/.gitconfig)}
    AUTHOR_EMAIL=${AUTHOR_EMAIL:=$(grep -oP '(?<=email = ).*' ${HOME}/.gitconfig)}
fi

if [[ ! -n ${AUTHOR_NAME} ]]; then
    echo "Missing argument -a|--author-name <AUTHOR_NAME>"
    exit 1
fi

if [[ ! -n ${AUTHOR_EMAIL} ]]; then
    echo "Missing argument -e|--author-email <AUTHOR_EMAIL>"
    exit 1
fi

mkdir -p "${GIT_REPO_NAME}";

if [[ -f ${GIT_REPO_NAME}/.git/config ]]; then
    if [[ -z $( cd ${GIT_REPO_NAME} && git diff -s --exit-code ) ]]; then
        echo "Existing repository may not have local changes."
        echo "This is to avoid overwriting non comitted local changes."
        exit 1;
    fi
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

# curl -s ${BOOTSTRAPIT_GIT_URL}/$1.template > ${GIT_REPO_NAME}/$1;


function format_template()
{
    cat $1 \
        | sed "s;\${GIT_REPO_URL};${GIT_REPO_URL};g" \
        | sed "s;\${GIT_REPO_PATH};${GIT_REPO_PATH};g" \
        | sed "s;\${GIT_REPO_NAMESPACE};${GIT_REPO_NAMESPACE};g" \
        | sed "s;\${GIT_REPO_NAME};${GIT_REPO_NAME};g" \
        | sed "s;\${GIT_REPO_DOMAIN};${GIT_REPO_DOMAIN};g" \
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
        dest_path=${GIT_REPO_NAME}/$1;
    else
        dest_path=${GIT_REPO_NAME}/$2;
    fi;
    cat ${BOOTSTRAPIT_GIT_PATH}/$1.template > ${dest_path};

    format_template ${dest_path};
}

mkdir -p "${GIT_REPO_NAME}/test/";
mkdir -p "${GIT_REPO_NAME}/vendor/";
mkdir -p "${GIT_REPO_NAME}/scripts/";
mkdir -p "${GIT_REPO_NAME}/stubs/";
mkdir -p "${GIT_REPO_NAME}/src/";
mkdir -p "${GIT_REPO_NAME}/requirements/";
mkdir -p "${GIT_REPO_NAME}/src/${MODULE_NAME}";

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

copy_template requirements/conda.txt;
copy_template requirements/pypi.txt;
copy_template requirements/development.txt;
copy_template requirements/integration.txt;
copy_template requirements/vendor.txt;

copy_template scripts/update_conda_env_deps.sh;
copy_template scripts/setup_conda_envs.sh;
copy_template scripts/pre-push-hook.sh;

copy_template __main__.py "src/${MODULE_NAME}/__main__.py";
copy_template __init__.py "src/${MODULE_NAME}/__init__.py";
touch "${GIT_REPO_NAME}/test/__init__.py";

chmod +x "${GIT_REPO_NAME}/src/${MODULE_NAME}/__main__.py";
chmod +x "${GIT_REPO_NAME}/scripts/update_conda_env_deps.sh";
chmod +x "${GIT_REPO_NAME}/scripts/setup_conda_envs.sh";
chmod +x "${GIT_REPO_NAME}/scripts/pre-push-hook.sh";

head -n 7 ${GIT_REPO_NAME}/license.header \
    | tail -n +3 \
    | sed -re 's/(^   |^$)/#/g' \
    > .py_license.header;

src_files=${GIT_REPO_NAME}/src/**/*.py

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
