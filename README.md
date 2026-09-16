# Docker Hub Projects

[![Docker Hub Organization](https://img.shields.io/badge/Docker%20Hub-sutrira-blue.svg?logo=docker&style=flat-square)](https://hub.docker.com/orgs/sutrira)
[![GitHub Repository](https://img.shields.io/badge/GitHub-sutrira%2Fdocker__hub--projects-blue?style=flat-square&logo=github)](https://github.com/sutrira/docker_hub-projects)
[![CI/CD Pipeline](https://github.com/sutrira/docker_hub-projects/actions/workflows/docker-build-publish.yml/badge.svg)](https://github.com/sutrira/docker_hub-projects/actions)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](LICENSE)

Source repository for multi-architecture, production-ready container images published to [Docker Hub (`sutrira`)](https://hub.docker.com/orgs/sutrira).

All images in this repository are based on **Alpine Linux 3.24.1** for minimal disk footprint, fast pull times, and developer agility across both `linux/amd64` (x86_64) and `linux/arm64` (Apple Silicon, ARM servers).

---

## Published Images & Repositories

| Repository | OpenJDK Version | Base Image | Supported Platforms | Docker Hub | Directory & Docs |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`sutrira/openjdk17`** | `17.0.20_p8-r0` (LTS) | Alpine 3.24.1 | `linux/amd64`, `linux/arm64` | [![Docker Pulls](https://img.shields.io/docker/pulls/sutrira/openjdk17?style=flat-square&label=pulls)](https://hub.docker.com/r/sutrira/openjdk17) | [openjdk17](openjdk17) |
| **`sutrira/openjdk21`** | `21.0.12_p8-r0` (LTS) | Alpine 3.24.1 | `linux/amd64`, `linux/arm64` | [![Docker Pulls](https://img.shields.io/docker/pulls/sutrira/openjdk21?style=flat-square&label=pulls)](https://hub.docker.com/r/sutrira/openjdk21) | [openjdk21](openjdk21) |
| **`sutrira/openjdk25`** | `25.0.4_p7-r0` (LTS) | Alpine 3.24.1 | `linux/amd64`, `linux/arm64` | [![Docker Pulls](https://img.shields.io/docker/pulls/sutrira/openjdk25?style=flat-square&label=pulls)](https://hub.docker.com/r/sutrira/openjdk25) | [openjdk25](openjdk25) |

---

## Repository Architecture

```text
.
├── .dockerenv                    # Central environment configuration (registry, tags, architectures)
├── .github/
│   └── workflows/
│       └── docker-build-publish.yml # Production-grade CI/CD pipeline with change detection
├── openjdk17/
│   ├── Dockerfile                # OpenJDK 17 on Alpine 3.24.1
│   ├── build.sh                  # Local multi-arch build script
│   └── README.md                 # Docker Hub repository description & usage guide
├── openjdk21/
│   ├── Dockerfile                # OpenJDK 21 on Alpine 3.24.1
│   ├── build.sh                  # Local multi-arch build script
│   └── README.md                 # Docker Hub repository description & usage guide
├── openjdk25/
│   ├── Dockerfile                # OpenJDK 25 on Alpine 3.24.1
│   ├── build.sh                  # Local multi-arch build script
│   └── README.md                 # Docker Hub repository description & usage guide
├── LICENSE
└── README.md
```

---

## Centralized Configuration (`.dockerenv`)

All repeated variables and environment properties are externalized in [`.dockerenv`](.dockerenv). This includes:
- **`DOCKERHUB_NAMESPACE`**: Organization namespace (`sutrira`).
- **`BASE_IMAGE`**: Upstream base OS (`alpine:3.24.1`).
- **`DEFAULT_PLATFORMS`**: Multi-arch targets (`linux/amd64,linux/arm64`).
- **`OPENJDK*_PKG_VERSION` / `OPENJDK*_TAG`**: Pinned package versions from Alpine mirrors.
- **`TRIVY_SEVERITY`**: Security threshold for CI vulnerability scanning.

Both local `build.sh` scripts and the GitHub Actions CI/CD pipeline source `.dockerenv`, ensuring exact parity between local development and production releases.

---

## Local Development & Testing

You can build any image locally using the provided `build.sh` script in each directory.

### Build and Load Locally (Dry-run without pushing)

```bash
# Build and load into local Docker daemon
./openjdk21/build.sh --load
```

### Build and Push Multi-Architecture to Docker Hub

```bash
# Builds both linux/amd64 and linux/arm64 and pushes to Docker Hub
./openjdk21/build.sh --push
```

---

## Production CI/CD Pipeline (GitHub Actions)

The workflow defined in [`.github/workflows/docker-build-publish.yml`](.github/workflows/docker-build-publish.yml) automates the entire build, scan, and release lifecycle:

1. **Selective Change Detection**:
   - Uses `dorny/paths-filter` to detect file changes in each subfolder (`openjdk17/**`, `openjdk21/**`, `openjdk25/**`).
   - Rebuilds and publishes **only** the updated image. If only `openjdk21` is modified, `openjdk17` and `openjdk25` are not rebuilt.
   - If common configuration (`.dockerenv` or workflow files) is modified, all images are rebuilt.
2. **Manual Dispatch (`workflow_dispatch`)**:
   - Allows triggering manual builds with options to build all or a specific image, and toggle pushing (`true`/`false`).
3. **Multi-Architecture Emulation**:
   - Configures QEMU and Docker Buildx for cross-compiling `linux/amd64` and `linux/arm64`.
4. **Vulnerability Scanning**:
   - Scans images using [Aqua Security Trivy](https://github.com/aquasecurity/trivy) for `HIGH` and `CRITICAL` vulnerabilities.
   - Generates and uploads SARIF security reports to the GitHub repository Security tab.
5. **Automated Docker Hub Sync**:
   - Uses `peter-evans/dockerhub-description` to automatically synchronize the folder-level `README.md` directly to each image's Docker Hub overview page.

### Required GitHub Secrets & Variables

| Secret / Variable | Description |
| :--- | :--- |
| `DOCKERHUB_USERNAME` | Docker Hub username / account (e.g. `sutrira`) |
| `DOCKERHUB_TOKEN` | Docker Hub Personal Access Token (PAT) with Read & Write permissions |

---

## License

This repository is licensed under the [Apache License 2.0](LICENSE). The OpenJDK binaries distributed inside the containers are licensed under the GNU General Public License v2 with the Classpath Exception (GPLv2+CE).
