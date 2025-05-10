#!/bin/bash
set -e

VERSION="${1:-v0.0.0}"
PROJECT_ROOT="${2:-$(git rev-parse --show-toplevel)}"  # Use passed root or fallback

CRD_DIR="$PROJECT_ROOT/k8s/migration/config/crd"
CRD_BASES="$CRD_DIR/bases"

SWAGGER_OUT_DIR="$PROJECT_ROOT/docs/swagger-ui/$VERSION"
mkdir -p "$SWAGGER_OUT_DIR"

OUTPUT_OPENAPI="$SWAGGER_OUT_DIR/openapi.yaml"

echo "Using version: $VERSION"
echo "Building OpenAPI document for CRDs in: $CRD_BASES"

# Rest of your existing script remains the same...
