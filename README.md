# component-qemu

SimBricks component repo wrapping the [QEMU](https://www.qemu.org/) full-system
simulator. It bundles the SimBricks-adapted QEMU C sources together with the
thin Python package that integrates QEMU into the SimBricks orchestration
framework, and ships both as conda packages.

## Layout

| Path | Description |
|---|---|
| `qemu/` | Git submodule with the SimBricks fork of the QEMU C sources. |
| `simbricks-qemu-python/` | Python integration package (`simbricks-qemu-python`), exposing `simbricks.components.qemu.simulation`. |
| `conda-recipes/simbricks-qemu-python/` | Conda recipe for the noarch python package. |
| `conda-recipes/simbricks-qemu-bin/` | Conda recipe for the compiled QEMU binary (`simbricks-qemu-bin`), which depends on `simbricks-qemu-python`. |
| `conda-recipes/conda_build_config.yaml` | Shared version / URL variables used by both recipes. |
| `Makefile` | Top-level driver for the builds below. |

## Prerequisites

- Initialize the QEMU submodule: `git submodule update --init`.
- A conda environment with the *other* SimBricks dependencies installed
  (`simbricks-lib`, `simbricks-orchestration`, `simbricks-utils`, …). When
  developing the piece contained in this repo, you install everything else from
  conda and build only the component you are working on locally.
- A C/C++ toolchain plus `meson`, `ninja`, `pkg-config`, `flex`, and `bison`
  for the QEMU build.

## Local development

The Makefile targets are deliberately split so that, while working on this repo,
you can build and test the QEMU binary or the Python package **directly** —
without going through the conda packaging defined here.

### QEMU binary

```sh
# Configure + build QEMU. Point the SimBricks include/lib dirs at your env
# (e.g. your conda prefix) so the --enable-simbricks build can link.
make qemu-build \
    SIMBRICKS_INC_DIR="$CONDA_PREFIX/include" \
    SIMBRICKS_LIB_DIR="$CONDA_PREFIX/lib/simbricks"

# Install the binaries into PREFIX (defaults to /usr/local; override as needed).
make qemu-install PREFIX="$PWD/out"

# Reset the build.
make clean
```

### Python package

```sh
# Editable install — iterate on the python code without reinstalling.
make python-develop

```

## Building the conda packages

```sh
# Build both packages in dependency order: the python package first, then the
# binary package (which depends on it and resolves it from the local channel).
make conda-packages

# Or build them individually.
make python-conda
make qemu-conda

# Redirect conda-build output if desired.
make conda-packages OUTPUT_FOLDER=./conda-out
```

## Make target reference

| Target | Description |
|---|---|
| `all` (default) | Local dev build: `qemu-build` + `python-install`. |
| `qemu-build` | Configure and build QEMU from `qemu/`. |
| `qemu-install` | Install the built QEMU binaries into `$(PREFIX)`. |
| `python-develop` | Editable (`pip install -e`) install of the python package. |
| `python-conda` | Build the `simbricks-qemu-python` conda package. |
| `qemu-conda` | Build the `simbricks-qemu-bin` conda package (builds `python-conda` first). |
| `conda-packages` | Build both conda packages in dependency order. |
| `clean` | Remove the QEMU build stamp and run `make clean` in `qemu/`. |

### Useful variables

| Variable | Default | Purpose |
|---|---|---|
| `PREFIX` | `/usr/local` | Install prefix for `qemu-install`. |
| `SIMBRICKS_INC_DIR` | `$(PREFIX)/include` | SimBricks headers for the QEMU build. |
| `SIMBRICKS_LIB_DIR` | `$(PREFIX)/lib/simbricks` | SimBricks libraries for the QEMU build. |
| `PYTHON` | `python` | Interpreter used for the python install targets. |
| `OUTPUT_FOLDER` | *(unset)* | If set, passed to `conda build --output-folder`. |
