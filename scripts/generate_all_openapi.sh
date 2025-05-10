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

  # Debug: Print directory and files
  echo "Checking for CRD YAMLs in: $CRD_DIR"
  ls -l "$CRD_DIR" 2>/dev/null || echo "Directory does not exist"
  ls "$CRD_DIR"/*.yaml 2>/dev/null || echo "No YAML files found"

  # Robust check for YAML files
  if [ -d "$CRD_DIR" ] && compgen -G "$CRD_DIR/*.yaml" > /dev/null; then
    echo "$TAG: Folder exists and has YAML files."

    # Generate OpenAPI YAML for this tag
    chmod +x "$PROJECT_ROOT/scripts/generate_openapi.sh"
    "$PROJECT_ROOT/scripts/generate_openapi.sh" "$TAG"

    # Prepare output directory
    OUTPUT_DIR="$PROJECT_ROOT/docs/public/swagger-ui/$TAG"
    mkdir -p "$OUTPUT_DIR"

    # Copy Swagger UI template and OpenAPI YAML
    cp -r /tmp/swagger-ui-template/* "$OUTPUT_DIR/"
    cp "$PROJECT_ROOT/docs/swagger-ui/$TAG/openapi.yaml" "$OUTPUT_DIR/openapi.yaml"
    echo "$TAG: Copied Swagger UI template and openapi.yaml to $OUTPUT_DIR"
  else
    echo "$TAG: Skipping (no CRD YAMLs found)"
  fi
done

git checkout "$ORIGINAL_BRANCH"
