#!/bin/sh
set -eu
file_uri="$4"
gsutil cat "$file_uri"
