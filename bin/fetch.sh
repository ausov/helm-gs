#!/usr/bin/env sh
set -euo pipefail

file_uri="$4"
gsutil cat "$file_uri"
