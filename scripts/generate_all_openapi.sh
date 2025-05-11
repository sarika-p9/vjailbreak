#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

cp -r "$PROJECT_ROOT/swagger-ui-template" /tmp/swagger-ui-template

ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

for TAG in $(git tag --sort=-creatordate); do
  git stash --include-untracked
  git checkout $TAG

  # Recalculate paths after checkout
  PROJECT_ROOT=$(git rev-parse --show-toplevel)
  CRD_DIR="$PROJECT_ROOT/k8s/migration/config/crd/bases"

  # Debug output
  echo "Checking CRD directory: $CRD_DIR"
  ls -l "$CRD_DIR" 2>/dev/null || echo "Directory missing"

  if [ -d "$CRD_DIR" ] && compgen -G "$CRD_DIR/*.yaml" >/dev/null; then
    echo "$TAG: Generating OpenAPI..."
    
    # Pass PROJECT_ROOT to generate_openapi.sh
    chmod +x "$PROJECT_ROOT/scripts/generate_openapi.sh"
    # Inside the loop:
    "$PROJECT_ROOT/scripts/generate_openapi.sh" "$TAG" "$PROJECT_ROOT"


    OUTPUT_DIR="$PROJECT_ROOT/docs/public/swagger-ui/$TAG"
    mkdir -p "$OUTPUT_DIR"
    cp -r /tmp/swagger-ui-template/* "$OUTPUT_DIR/"
    cp "$PROJECT_ROOT/docs/swagger-ui/$TAG/openapi.yaml" "$OUTPUT_DIR/openapi.yaml"
  else
    echo "$TAG: Skipping (no CRDs)"
  fi
done

git checkout "$ORIGINAL_BRANCH"
