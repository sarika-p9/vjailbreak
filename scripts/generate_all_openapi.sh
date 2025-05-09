#!/bin/bash
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
CRD_DIR="k8s/migration/config/crd/bases"
# Updated template directory path to root swagger-ui-template folder
TEMPLATE_DIR="$REPO_ROOT/swagger-ui-template"

ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

for TAG in $(git tag --sort=-creatordate); do
  git stash --include-untracked
  git checkout $TAG
  if [ -d "$CRD_DIR" ] && [ "$(ls -A $CRD_DIR/*.yaml 2>/dev/null)" ]; then
    echo "$TAG: Folder exists and has YAML files."

    OUTPUT_DIR="$REPO_ROOT/docs/public/swagger-ui/$TAG"
    mkdir -p "$OUTPUT_DIR"
    cp -r "$TEMPLATE_DIR/"* "$OUTPUT_DIR/"
    echo "$TAG: Copied Swagger UI template to $OUTPUT_DIR"
  else
    echo "$TAG: Folder missing or empty."
  fi
done

git checkout "$ORIGINAL_BRANCH"
