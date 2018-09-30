#!/bin/bash

set -eo pipefail;

BASE_URL="https://raw.githubusercontent.com/mbarkhau/bootstrapit/master/"

# Argument parsing from
# https://stackoverflow.com/a/14203146/62997


POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -n|--package-name)
    PACKAGE_NAME="$2"
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
    echo "    -n --package-name <PACKAGE_NAME>"
    echo "    -a --author-name <AUTHOR_NAME>          Parsed from .gitconfig if available"
    echo "    -e --author-email <AUTHOR_EMAIL>        Parsed from .gitconfig if available"
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
    echo "Invalid argument :" $@
    exit
fi

if [[ ! -n ${PACKAGE_NAME} ]]; then
    echo "Missing argument -n|--package-name <PACKAGE_NAME>"
    exit 1
fi

if [[ -f ${PACKAGE_NAME}/.git/config ]]; then
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

mkdir -p "${PACKAGE_NAME}";

if [[ -f ${PACKAGE_NAME}/.git/config ]]; then
    if [[ -z $( cd ${PACKAGE_NAME} && git diff -s --exit-code ) ]]; then
        echo "Existing repository may not have local changes."
        echo "This is to avoid overwriting non comitted local changes."
        exit 1;
    fi
fi

mkdir -p "${PACKAGE_NAME}/test/";
mkdir -p "${PACKAGE_NAME}/vendor/";
mkdir -p "${PACKAGE_NAME}/stubs/";
mkdir -p "${PACKAGE_NAME}/src/";
mkdir -p "${PACKAGE_NAME}/src/${PACKAGE_NAME}";

touch "${PACKAGE_NAME}/src/${PACKAGE_NAME}/__init__.py";
touch "${PACKAGE_NAME}/test/__init__.py";

exit 0

curl ${BASE_URL}/README.md -O ${PACKAGE_NAME}/README.md
curl ${BASE_URL}/CONTRIBUTING.md -O ${PACKAGE_NAME}/CONTRIBUTING.md
curl ${BASE_URL}/LICENSE -O ${PACKAGE_NAME}/LICENSE

curl ${BASE_URL}/setup.py -O ${PACKAGE_NAME}/setup.py
curl ${BASE_URL}/setup.cfg -O ${PACKAGE_NAME}/setup.cfg

curl ${BASE_URL}/makefile.template -O ${PACKAGE_NAME}/makefile
curl ${BASE_URL}/makefile.config.make.template -O ${PACKAGE_NAME}/makefile.config.make
curl ${BASE_URL}/makefile.extra.make.template -O ${PACKAGE_NAME}/makefile.extra.make
sed -i "s/PACKAGE_NAME/${PACKAGE_NAME}/" ${PACKAGE_NAME}/makefile.config.make

mkdir -p "${PACKAGE_NAME}/requirements/";
curl ${BASE_URL}/requirements/conda.txt -O ${PACKAGE_NAME}/requirements/conda.txt
curl ${BASE_URL}/requirements/pypi.txt -O ${PACKAGE_NAME}/requirements/pypi.txt
curl ${BASE_URL}/requirements/development.txt -O ${PACKAGE_NAME}/requirements/development.txt
curl ${BASE_URL}/requirements/integration.txt -O ${PACKAGE_NAME}/requirements/integration.txt
curl ${BASE_URL}/requirements/vendor.txt -O ${PACKAGE_NAME}/requirements/vendor.txt
