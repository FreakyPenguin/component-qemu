# component-qemu

SimBricks component repo wrapping the [QEMU](https://www.qemu.org/) full-system
simulator. It bundles the SimBricks-adapted QEMU C sources together with the
thin Python package that integrates QEMU into the SimBricks orchestration
framework, and ships both as conda packages so users can install just the
simulator they need.

## Layout

| Path | Description |
|---|---|
| `qemu/` | Git submodule with the SimBricks fork of the QEMU C sources. |
| `simbricks-qemu-python/` | Python integration package (`simbricks-qemu-python`), exposing `simbricks.components.qemu.simulation`. |
| `conda-recipes/simbricks-qemu-python/` | Conda recipe for the noarch python package. |
| `conda-recipes/simbricks-qemu-bin/` | Conda recipe for the compiled QEMU binary (`simbricks-qemu-bin`), which depends on `simbricks-qemu-python`. |
| `conda-recipes/conda_build_config.yaml` | Shared version / URL variables used by both recipes. |
| `Makefile` | Top-level driver for the builds below. |
| `.devcontainer/conda-build/` | VS Code dev container providing a ready-to-use conda build environment. |

## Conda packages

This repo produces two packages:

- **`simbricks-qemu-python`** — noarch Python integration package.
- **`simbricks-qemu-bin`** — the compiled QEMU binary. It depends on
  `simbricks-qemu-python` (pinned to the same version), so installing the
  simulator also pulls in its orchestration glue.

External dependencies that are *not* built here — most notably `simbricks-lib`
(needed to build the binary) and `simbricks-orchestration` / `simbricks-utils`
(runtime deps of the python package) — are resolved automatically from the
public SimBricks conda channel (`https://conda.simbricks.io/latest`, wired into
the build via the Makefile's `SIMB_CONDA_CHANNEL`). You do **not** need to
install them by hand.

## Prerequisites

- Initialize the QEMU submodule: `git submodule update --init`.
- A conda installation with `conda build` available. The easiest path is the
  bundled dev container (`.devcontainer/conda-build/`), based on the SimBricks
  `conda-build-env` image — "Reopen in Container" in VS Code and everything
  (conda-build, toolchain, channels) is ready.
- If not using the dev container: a C/C++ toolchain plus `meson`, `ninja`,
  `pkg-config`, `flex`, and `bison` for the QEMU build.

## Building the conda packages

```sh
# Build both packages in dependency order: the python package first, then the
# binary package (which depends on it and resolves it from the local channel).
# External deps are pulled from the SimBricks channel automatically.
make conda-packages          # this is also the default `make` target

# Or build them individually.
make python-conda
make qemu-conda

# Redirect conda-build output if desired.
make conda-packages OUTPUT_FOLDER=./conda-out
```

## Local development

The Makefile targets are deliberately split so that, while working on this repo,
you can build and test the QEMU binary or the Python package **directly** —
without going through the conda packaging defined here. Install any *other*
SimBricks dependencies from the conda channel and iterate on just the piece you
are changing.

### QEMU binary

```sh
# Configure + build QEMU. Point the SimBricks include/lib dirs at your env
# (e.g. your conda prefix) so the --enable-simbricks build can link.
make qemu-build \
    SIMBRICKS_INC_DIR="$CONDA_PREFIX/include" \
    SIMBRICKS_LIB_DIR="$CONDA_PREFIX/lib/simbricks"

# Install the binaries into PREFIX (defaults to ./out; override as needed).
make qemu-install PREFIX="$PWD/out"

# Reset the build.
make clean
```

### Python package

```sh
# Editable install — iterate on the python code without reinstalling.
make python-develop
```

## Make target reference

| Target | Description |
|---|---|
| `all` (default) | Build both conda packages (alias for `conda-packages`). |
| `conda-packages` | Build both conda packages in dependency order. |
| `python-conda` | Build the `simbricks-qemu-python` conda package. |
| `qemu-conda` | Build the `simbricks-qemu-bin` conda package (builds `python-conda` first). |
| `qemu-build` | Configure and build QEMU from `qemu/`. |
| `qemu-install` | Install the built QEMU binaries into `$(PREFIX)`. |
| `python-develop` | Editable (`pip install -e`) install of the python package. |
| `clean` | Remove the QEMU build stamp and run `make clean` in `qemu/`. |

### Useful variables

| Variable | Default | Purpose |
|---|---|---|
| `PREFIX` | `$(pwd)/out` | Install prefix for `qemu-install`. |
| `SIMBRICKS_INC_DIR` | `$(PREFIX)/include` | SimBricks headers for the QEMU build. |
| `SIMBRICKS_LIB_DIR` | `$(PREFIX)/lib/simbricks` | SimBricks libraries for the QEMU build. |
| `PYTHON` | `python` | Interpreter used for `python-develop`. |
| `SIMB_CONDA_CHANNEL` | `-c https://conda.simbricks.io/latest` | Channel searched by `conda build` for external SimBricks deps. |
| `OUTPUT_FOLDER` | *(unset)* | If set, passed to `conda build --output-folder`. |
