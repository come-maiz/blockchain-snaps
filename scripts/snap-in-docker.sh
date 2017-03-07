#!/bin/bash
#
# Build a snap using a docker container.
#
# Arguments:
#   project: The name of the project. It must be a directory relative to the
#            root of the repo.

set -ev

docker run -v "$(pwd)":/cwd snapcore/snapcraft sh -c "apt update && apt upgrade -y && cd /cwd && ./scripts/snap.sh $1"
