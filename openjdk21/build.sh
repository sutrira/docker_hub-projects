#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# Build script for OpenJDK 21 on Alpine Linux
# Reads common configuration from .dockerenv at repository root
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Load environment configuration
if [[ -f "${REPO_ROOT}/.dockerenv" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/.dockerenv"
    set +a
fi

# Variables with fallbacks
NAMESPACE="${DOCKERHUB_NAMESPACE:-sutrira}"
IMAGE_NAME="${OPENJDK21_IMAGE:-openjdk21}"
TAG="${OPENJDK21_TAG:-21.0.12_p8-r0}"
PLATFORMS="${DEFAULT_PLATFORMS:-linux/amd64,linux/arm64}"

FULL_IMAGE="${NAMESPACE}/${IMAGE_NAME}"

echo "============================================================"
echo "Building ${FULL_IMAGE}:${TAG} and ${FULL_IMAGE}:latest"
echo "Target Platforms: ${PLATFORMS}"
echo "Context:          ${SCRIPT_DIR}"
echo "============================================================"

# Default to --push if no flags provided; allow passing arguments like --load or --push
BUILD_ARGS=("$@")
if [[ ${#BUILD_ARGS[@]} -eq 0 ]]; then
    BUILD_ARGS=("--push")
fi

docker buildx build \
    --platform "${PLATFORMS}" \
    --tag "${FULL_IMAGE}:${TAG}" \
    --tag "${FULL_IMAGE}:latest" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${BUILD_ARGS[@]}" \
    "${SCRIPT_DIR}"
