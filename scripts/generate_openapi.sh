#!/bin/bash
set -e

VERSION="${1:-v0.0.0}"
PROJECT_ROOT="${2:-$(git rev-parse --show-toplevel)}"  # Use passed root or fallback

CRD_DIR="$PROJECT_ROOT/k8s/migration/config/crd"
CRD_BASES="$CRD_DIR/bases"

# Debug: Print paths and files
echo "PROJECT_ROOT: $PROJECT_ROOT"
echo "CRD_BASES: $CRD_BASES"
ls -l "$CRD_BASES" 2>/dev/null || echo "CRD_BASES directory does not exist"

SWAGGER_OUT_DIR="$PROJECT_ROOT/docs/swagger-ui/$VERSION"
mkdir -p "$SWAGGER_OUT_DIR"

OUTPUT_OPENAPI="$SWAGGER_OUT_DIR/openapi.yaml"

echo "Using version: $VERSION"
echo "Cleaning previous OpenAPI file..."
rm -f "$OUTPUT_OPENAPI"
echo "Building OpenAPI document..."
cat > "$OUTPUT_OPENAPI" <<EOF
openapi: 3.0.0
info:
  title: vJailbreak API's
  version: $VERSION
paths:
EOF

# Loop through CRD YAML files using absolute paths
for file in "$CRD_BASES"/*.yaml; do
  if [ ! -f "$file" ]; then
    echo "⚠️  Skipping $file (not found)"
    continue
  fi

  PLURAL=$(yq '.spec.names.plural' "$file")
  KIND=$(yq '.spec.names.kind' "$file" | sed 's/-//g')
  GROUP=$(yq '.spec.group' "$file")

  echo "  Adding REST paths for: $PLURAL"

  cat >> "$OUTPUT_OPENAPI" <<EOF
  /apis/$GROUP/v1alpha1/namespaces/{namespace}/$PLURAL:
    get:
      summary: List $KIND
      operationId: list$KIND
      responses:
        '200':
          description: Successful response
    post:
      summary: Create $KIND
      operationId: create$KIND
      requestBody:
        required: true
        content:
          application/json:
            schema:
              \$ref: "#/components/schemas/$PLURAL"
      responses:
        '201':
          description: Created

  /apis/$GROUP/v1alpha1/namespaces/{namespace}/$PLURAL/{name}:
    get:
      summary: Get $KIND
      operationId: get$KIND
      responses:
        '200':
          description: Found
    delete:
      summary: Delete $KIND
      operationId: delete$KIND
      responses:
        '204':
          description: Deleted

EOF
done

# schemas
echo "components:" >> "$OUTPUT_OPENAPI"
echo "  schemas:" >> "$OUTPUT_OPENAPI"

for file in "$CRD_BASES"/*.yaml; do
  if [ ! -f "$file" ]; then
    continue
  fi

  NAME=$(yq '.metadata.name' "$file" | cut -d'.' -f1 | sed 's/-//g')
  SCHEMA=$(yq -o=json '.spec.versions[0].schema.openAPIV3Schema' "$file")

  if [ -z "$SCHEMA" ] || [ "$SCHEMA" == "null" ]; then
    echo "⚠️  Skipping $file (no schema)"
    continue
  fi

  echo "  📦 Adding schema: $NAME"
  echo "    $NAME:" >> "$OUTPUT_OPENAPI"
  echo "$SCHEMA" | yq -P | sed 's/^/      /' >> "$OUTPUT_OPENAPI"
done

echo "OpenAPI written to $OUTPUT_OPENAPI"
