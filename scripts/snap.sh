#!/bin/bash
#
# Build a snap.
#
# Arguments:
#   path: The path of the project.

set -ev

cd "$1"
snapcraft clean
snapcraft
