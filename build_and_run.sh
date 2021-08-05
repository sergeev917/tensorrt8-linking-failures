#!/bin/bash
set -o errexit
cd "$(dirname "${BASH_SOURCE[0]}")"

export DOCKER_BUILDKIT=1
docker build --progress=plain --tag tensorrt8-reproducer --target test_case_1 . || true
docker build --progress=plain --tag tensorrt8-reproducer --target test_case_2 . || true
