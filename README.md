# Bootstrapit - Python Package Bootstrap Scripts

This repository contains setup code I use to quickly create
new projects.

I use this primarilly to create pure python libraries. It reduces
friction to publishing reusable code.


|                 Name                |    role   |  since  | until |
|-------------------------------------|-----------|---------|-------|
| Manuel Barkhau (mbarkhau@gmail.com) | developer | 2018-10 |       |


## Setup

You only need to do this once.

```
$ mkdir -p $HOME/bin/ && export PATH=$HOME/bin/;
$ curl -s $HOME/bin/bootstrapit "https://raw.githubusercontent.com/mbarkhau/bootstrapit/master/bootstrapit.sh" > $HOME/bin/bootstrapit;
$ chmod +x $HOME/bin/bootstrapit;
```

## Usage

Let's assume you've written a script you would like to package
and publish.

```
$ bootstrapit --package-name myproject
```

## Defaults

These are some of the defaults used by a project created with
`bootstrapit`

 - License: MIT
 - Linting: flake8, pylint, mypy
 - Testing: pytest, travis, codecov.io
 - Environment Setup: Conda
 - Code Formatting: [straitjacket](https://pypi.org/project/straitjacket/)
 - Versioning: Using [PyCalVer](https://pypi.org/project/pycalver/)

