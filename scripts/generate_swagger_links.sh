#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

OUTPUT_FILE="$PROJECT_ROOT/docs/src/content/docs/guides/using_apis.md"

echo "# API Reference by Version" > $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

for tag in $(git tag --sort=-creatordate); do
  echo "- [${tag} Swagger UI](/vjailbreak/swagger-ui/${tag}/)" >> $OUTPUT_FILE
done

echo "Swagger UI links generated in $OUTPUT_FILE"
