#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

OUTPUT_FILE="$PROJECT_ROOT/docs/src/content/docs/guides/using_apis.md"

cat <<EOF > $OUTPUT_FILE
---
title: "API Reference by Version"
---

EOF

for tag in $(git tag --sort=-v:refname | tail -n 3); do
  echo "- [Swagger UI for \`${tag}\`](/docs/guides/using_apis/${tag})" >> $OUTPUT_FILE
done

echo "Swagger UI links generated in $OUTPUT_FILE"
