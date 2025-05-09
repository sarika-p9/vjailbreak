#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Copy the template to a safe place before the loop
cp -r "$PROJECT_ROOT/swagger-ui-template" /tmp/swagger-ui-template

ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

for TAG in $(git tag --sort=-creatordate); do
  git stash --include-untracked
  git checkout $TAG

  # Recalculate paths after checkout
  PROJECT_ROOT=$(git rev-parse --show-toplevel)
  CRD_DIR="$PROJECT_ROOT/k8s/migration/config/crd/bases"

  if [ -d "$CRD_DIR" ] && [ "$(ls -A $CRD_DIR/*.yaml 2>/dev/null)" ]; then
    echo "$TAG: Folder exists and has YAML files."

    OUTPUT_DIR="$PROJECT_ROOT/docs/public/swagger-ui/$TAG"
    mkdir -p "$OUTPUT_DIR"
    cp -r /tmp/swagger-ui-template/* "$OUTPUT_DIR/"
    echo "$TAG: Copied Swagger UI template to $OUTPUT_DIR"
  else
    echo "$TAG: Folder missing or empty."
  fi
done

git checkout "$ORIGINAL_BRANCH"
