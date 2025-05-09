#!/bin/bash
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
CRD_DIR="k8s/migration/config/crd/bases"
TEMPLATE_DIR="$REPO_ROOT/docs/swagger-ui/template"

ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

for TAG in $(git tag --sort=-creatordate); do
  git stash --include-untracked
  git checkout $TAG

  if [ -d "$CRD_DIR" ] && [ "$(ls -A $CRD_DIR/*.yaml 2>/dev/null)" ]; then
    echo "$TAG: Folder exists and has YAML files."
    VERSION=$TAG

    # Generate OpenAPI YAML
    chmod +x $REPO_ROOT/scripts/generate_openapi.sh
    $REPO_ROOT/scripts/generate_openapi.sh "$VERSION"

    # Prepare output folder
    OUTPUT_DIR="$REPO_ROOT/docs/public/swagger-ui/$VERSION"
    mkdir -p "$OUTPUT_DIR"

    # Copy OpenAPI YAML
    cp "$REPO_ROOT/docs/swagger-ui/$VERSION/openapi.yaml" "$OUTPUT_DIR/openapi.yaml"

    # Copy Swagger UI template files
    cp -r "$TEMPLATE_DIR/"* "$OUTPUT_DIR/"
  else
    echo "$TAG: Folder missing or empty."
  fi
done

git checkout "$ORIGINAL_BRANCH"
