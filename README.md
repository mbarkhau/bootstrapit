# Bootstrapit - Python Package Bootstrap Scripts

This repository contains setup code to bootstrap new python
projects.


|                 Name                |    role   |  since  | until |
|-------------------------------------|-----------|---------|-------|
| Manuel Barkhau (mbarkhau@gmail.com) | developer | 2018-10 |       |


## Usage

The entry point is a script called `bootstrapit.sh`, which you can add
to your project like this:

```shell
$ cd myproject
$ curl -s "https://gitlab.com/mbarkhau/bootstrapit/raw/master/bootstrapit_example.sh" \
    > bootstrapit.sh
$ vim bootstrapit.sh
```

Update `bootstrapit.sh` with your project specific info.

```bash
AUTHOR_NAME="Vandelay Industries"
AUTHOR_EMAIL="info@vandelay.industries"

KEYWORDS="keywords used on pypi"
DESCRIPTION="Example description."

LICENSE_ID="MIT"

PACKAGE_NAME="mypackagename"
GIT_REPO_NAMESPACE="vandelay"
GIT_REPO_DOMAIN="gitlab.com"

DEFAULT_PYTHON_VERSION="python=3.6"
SUPPORTED_PYTHON_VERSIONS="python=3.6 python=3.7"

...

PROJECT_DIR=$(dirname "$0");
source "$PROJECT_DIR/scripts/bootstrapit_update.sh";
```

Running this file will modify files in your project directory, so
be sure to commit any changes first. This way you can see what the
script has changed by running git diff.

```session
$ bash bootstrapit.sh
```

## Project Files and Defaults

The following files and configurations are applied by `bootstrapit.sh`.

|               -                |                                                                  Description                                                                   |
|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| `bootstrapit.sh`               | Entry point for bootstrapit, containing project configuration.                                                                                 |
| `Makefile`                     | Configuration (package name and python versions) and project specific make targets.                                                            |
| `Makefile.bootstrapit.make`    | General make targets to setup project and python environment.                                                                                  |
| `$ make conda`                 | Create conda environments for all configured python versions and install requirements.                                                         |
| `$ make lint`                  | Linting using flake8                                                                                                                           |
| `$ make fmt`                   | Code Formatting [straitjacket](https://pypi.org/project/straitjacket/)                                                                         |
| `$ make mypy`                  | Type checking using [mypy](http://mypy-lang.org/)                                                                                              |
| `$ make test`                  | Run tests using [pytest](https://docs.pytest.org/en/latest/) with [pytest-cov](https://pytest-cov.readthedocs.io/en/latest/) for code coverage |
| `$ make bump_version`          | Versioning using [PyCalVer](https://pypi.org/project/pycalver/)                                                                                |
| `.gitignore`                   | ...                                                                                                                                            |
| `setup.py`                     | ...                                                                                                                                            |
| `setup.cfg`                    | Configuration for `lint`, `test`, `mypy` and `bump_version`.                                                                                   |
| `src/`                         | Project source files.                                                                                                                          |
| `test/`                        | Test files.                                                                                                                                    |
| `vendor/`                      | Vendored dependencies.                                                                                                                         |
| `stubs/`                       | Stub files used by mypy.                                                                                                                       |
| `scripts/`                     | Shell scripts (git hooks and dependencies of the `Makefile`).                                                                                  |
| `requirements/`                | Python dependencies from conda, pypi and git repositories                                                                                      |
| `requirements/pypi.txt`        | The main file for library and project dependencies, when in doubt, add your dependency here.                                                   |
| `requirements/conda.txt`       | For project dependencies installed from anaconda and conda-forge. Don't use this if you're project is a library which is installed by others.  |
| `requirements/development.txt` | Dependencies for local development, such as ipython and pudb.                                                                                  |
| `requirements/integration.txt` | Dependencies for testing and linting.                                                                                                          |
| `requirements/vendor.txt`      | Dependencies which are installed to `vendor/`.                                                                                                 |
| `README.md`                    | Default readme including various badges.                                                                                                       |
| `CHANGELOG.md`                 | Changelog template                                                                                                                             |
| `CONTRIBUTING.md`              | Documentation for new users.                                                                                                                   |
| `LICENSE`                      | License text based on `LICENSE_ID` chosen in `bootstrapit.sh` (default: MIT).                                                                  |
| `license.header`               | Short license text to be included in the header of source files.                                                                               |
| `.gitlab-ci.yml`               | Default Gitlab CI build, performing `make lint` and `make test`                                                                                |
| `$ make docker_build`          | Build the docker image and push it, to the configured docker regestry.                                                                         |
| `docker_base.Dockerfile`       | Dockerfile for image referenced by `.gitlab-ci.yml`.                                                                                           |

