#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Copy the template and LATEST SCRIPTS to a safe place before the loop
TEMP_DIR="/tmp/vjailbreak-scripts"
mkdir -p "$TEMP_DIR"
cp -r "$PROJECT_ROOT/swagger-ui-template" "$TEMP_DIR/"
cp "$SCRIPT_DIR/generate_openapi.sh" "$TEMP_DIR/"

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
    
    # Use the LATEST SCRIPT from /tmp, not the checked-out tag
    chmod +x "$TEMP_DIR/generate_openapi.sh"
    "$TEMP_DIR/generate_openapi.sh" "$TAG" "$PROJECT_ROOT"

    OUTPUT_DIR="$PROJECT_ROOT/docs/public/swagger-ui/$TAG"
    mkdir -p "$OUTPUT_DIR"
    cp -r "$TEMP_DIR/swagger-ui-template/"* "$OUTPUT_DIR/"
    cp "$PROJECT_ROOT/docs/swagger-ui/$TAG/openapi.yaml" "$OUTPUT_DIR/openapi.yaml"
  else
    echo "$TAG: Skipping (no CRDs)"
  fi
done

git checkout "$ORIGINAL_BRANCH"
