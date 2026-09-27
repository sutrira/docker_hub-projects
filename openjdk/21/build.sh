#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# Build script for OpenJDK 21 JDK on Alpine Linux
# Reads common configuration from .dockerenv at repository root
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Load environment configuration
if [[ -f "${REPO_ROOT}/.dockerenv" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/.dockerenv"
    set +a
fi

# Variables with fallbacks
NAMESPACE="${DOCKERHUB_NAMESPACE:-sutrira}"
REPO_NAME="${REPO_JDK:-openjdk}"
VERSION_TAG="21"
PKG_TAG="${JAVA21_VERSION:-21.0.12_p8-r0}"
BASE_IMG="${BASE_IMAGE:-alpine:3.24.1}"
PLATFORMS="${DEFAULT_PLATFORMS:-linux/amd64,linux/arm64}"

# Default to --push if no flags provided; allow passing arguments like --load or --push
BUILD_ARGS=("$@")
if [[ ${#BUILD_ARGS[@]} -eq 0 ]]; then
    BUILD_ARGS=("--push")
fi

# Check if --load flag is provided
LOAD_REQUESTED=false
for arg in "${BUILD_ARGS[@]}"; do
    if [[ "$arg" == "--load" ]]; then
        LOAD_REQUESTED=true
        break
    fi
done

# Docker daemon cannot load multi-architecture manifest lists directly; fallback to host arch for --load
if [[ "$LOAD_REQUESTED" == "true" && "$PLATFORMS" == *","* ]]; then
    HOST_ARCH="$(uname -m)"
    case "$HOST_ARCH" in
        x86_64)  TARGET_PLATFORM="linux/amd64" ;;
        arm64|aarch64) TARGET_PLATFORM="linux/arm64" ;;
        *) TARGET_PLATFORM="linux/amd64" ;;
    esac
    echo "Detected --load flag: restricting target platform to host native (${TARGET_PLATFORM})"
    PLATFORMS="${TARGET_PLATFORM}"
fi

FULL_IMAGE="${NAMESPACE}/${REPO_NAME}"

echo "============================================================"
echo "Building JDK: ${FULL_IMAGE}:${VERSION_TAG} and ${FULL_IMAGE}:${PKG_TAG}"
echo "Base Image:       ${BASE_IMG}"
echo "Target Platforms: ${PLATFORMS}"
echo "Context:          ${SCRIPT_DIR}"
echo "============================================================"

docker buildx build \
    --platform "${PLATFORMS}" \
    --build-arg BASE_IMAGE="${BASE_IMG}" \
    --build-arg OPENJDK_VERSION="${PKG_TAG}" \
    --tag "${FULL_IMAGE}:${VERSION_TAG}" \
    --tag "${FULL_IMAGE}:${PKG_TAG}" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${BUILD_ARGS[@]}" \
    "${SCRIPT_DIR}"
