#!/usr/bin/env bash
# Rebuild dist/build-eval-harness.zip for upload to claude.ai.
# The zip holds a folder named exactly like the skill, with SKILL.md inside.
set -euo pipefail
cd "$(dirname "$0")/skills"
mkdir -p ../dist
rm -f ../dist/build-eval-harness.zip
zip -qr ../dist/build-eval-harness.zip build-eval-harness -x '*.DS_Store'
echo "Built dist/build-eval-harness.zip:"
unzip -l ../dist/build-eval-harness.zip
