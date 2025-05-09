#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Store the original branch
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Loop over all tags, checkout, and generate OpenAPI for each
for TAG in $(git tag --sort=-creatordate); do
  echo "Checking out $TAG"
  git checkout $TAG
  VERSION=$TAG
  chmod +x $PROJECT_ROOT/scripts/generate_openapi.sh
  $PROJECT_ROOT/scripts/generate_openapi.sh "$VERSION"
  mkdir -p $PROJECT_ROOT/docs/public/swagger-ui/$VERSION
  cp $PROJECT_ROOT/docs/swagger-ui/$VERSION/openapi.yaml $PROJECT_ROOT/docs/public/swagger-ui/$VERSION/openapi.yaml
  cp -r $PROJECT_ROOT/docs/swagger-ui/template/* $PROJECT_ROOT/docs/public/swagger-ui/$VERSION/
done

# Checkout back to your original branch
git stash --include-untracked
git checkout "$ORIGINAL_BRANCH"
