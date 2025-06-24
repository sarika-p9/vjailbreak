#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

OUTPUT_FILE="$PROJECT_ROOT/docs/src/content/docs/guides/using_apis.md"

cat <<EOF > $OUTPUT_FILE
---
title: "API Reference by Version"
---

EOF

for tag in $(git tag --sort=-creatordate | head -n 3); do
  cat <<EOL >> $OUTPUT_FILE

## Swagger UI for \\`${tag}\\`

<iframe src="/vjailbreak/swagger-ui/${tag}/" width="100%" height="700" style="border:1px solid #ccc; border-radius:8px; margin-bottom:2rem;"></iframe>

EOL
done

echo "Swagger UI links generated in $OUTPUT_FILE"
