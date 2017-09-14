#!/bin/bash
#
# Build a snap using a docker container.
#
# Arguments:
#   project: The name of the project. It must be a directory relative to the
#            root of the repo.

set -ev

if [ -z "$ONLY_EDGE"]; then

  # Check if the latest tag is in the beta channel.
  source="$(cat $1/snap/snapcraft.yaml | grep source: | head -n 1 | awk '{printf $2}')"
  repo="$(echo $source | sed 's|^.*github\.com/||')"
  wget https://api.github.com/repos/$repo/git/refs/tats
  last_released_tag_ref="$(jq --raw-output .[-1].ref tags)"
  last_released_tag="{last_released_tag_ref##*/}"
  docker run -v "${HOME}":/root -v $(pwd):$(pwd) snapcore/snapcraft sh -c "cd $(pwd)/$1 && ((snapcraft status $1 || echo "none") > status)"
  last_released_snap="$(awk '$1 == "beta" { print $2 }' $1/status)"

  if [ "${last_released_tag}" != "${last_released_snap}" ]; then
    # Build using the latest tag.
    sed -i "0,/source-tag/s/source-tag:.*$/source-tag: '"$last_released_tag"'/g" $1/snap/snapcraft.yaml
    sed -i "s/version:.*$/version: '"$last_released_tag"'/g" $1/snap/snapcraft.yaml
    # Set the stable grade to be able to move it to the candidate and stable channels.
    sed -i "s/grade:.*$/grade: stable/g" $1/snap/snapcraft.yaml
  fi

fi

docker run -e LC_ALL=en_US.UTF-8 -v "$(pwd)":/cwd snapcore/snapcraft sh -c "apt update && apt install -y locales && locale-gen en_US.UTF-8 && cd /cwd && ./scripts/snap.sh $1"
