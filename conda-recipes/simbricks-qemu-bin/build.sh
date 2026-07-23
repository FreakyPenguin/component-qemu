#!/bin/bash
set -e

export CPP="${CC} -E"

# Configure, build, and install QEMU via the top-level Makefile, overriding the
# SimBricks include/lib paths to point at the conda build prefix. The
# qemu-install target depends on the build (qemu/ready) stamp, so this single
# invocation configures, compiles, and installs into ${PREFIX}.
make qemu-install
