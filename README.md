# Bootstrapit - Python Package Bootstrap Scripts

This repository contains setup code I use to quickly create
new projects.

Some of the things taken care of:

 - Task runner using makefile
 - License files and headers
 - Versioning
 - Linting/Testing
 - CI setup to work with gitlab
 - Python Packaging using setuptools and setup.py


|                 Name                |    role   |  since  | until |
|-------------------------------------|-----------|---------|-------|
| Manuel Barkhau (mbarkhau@gmail.com) | developer | 2018-10 |       |


## Setup

You only need to do this once.

```
$ mkdir -p $HOME/bin/ && export PATH=$HOME/bin/:$PATH;
$ curl -s $HOME/bin/bootstrapit "https://gitlab.com/mbarkhau/bootstrapit/raw/master/bootstrapit.sh" > $HOME/bin/bootstrapit;
$ chmod +x $HOME/bin/bootstrapit;
```


## Usage

Let's assume you've written a script you would like to package
and publish.

```
$ bootstrapit --help
$ bootstrapit -g https://github.com/yourusername/yourpackagename \
    --path yourpackagedir \
    --module yourmodulename \
    --author-name "Vandelay Industries" \
    --author-email "info@vandelay.industries"
```


## Defaults

These are some of the defaults used by a project created with
`bootstrapit`

 - License: MIT
 - Linting: flake8, pylint, mypy
 - Testing: pytest, travis
 - Environment Setup: Conda
 - Code Formatting: [straitjacket](https://pypi.org/project/straitjacket/)
 - Versioning: Using [PyCalVer](https://pypi.org/project/pycalver/)

