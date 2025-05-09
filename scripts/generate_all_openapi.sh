#!/bin/bash
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
CRD_DIR="k8s/migration/config/crd/bases"

ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

for TAG in $(git tag --sort=-creatordate); do
  git stash --include-untracked
  git checkout $TAG
  if [ -d "$CRD_DIR" ] && [ "$(ls -A $CRD_DIR/*.yaml 2>/dev/null)" ]; then
    echo "$TAG: Folder exists and has YAML files."
  else
    echo "$TAG: Folder missing or empty."
  fi
done

git checkout "$ORIGINAL_BRANCH"
