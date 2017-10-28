#!/bin/sh
set -e
set -o pipefail

gsutil cp $1 -
