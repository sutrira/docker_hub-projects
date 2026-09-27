# Docker Hub Projects

[![Docker Hub Organization](https://img.shields.io/badge/Docker%20Hub-sutrira-blue.svg?logo=docker&style=flat-square)](https://hub.docker.com/orgs/sutrira)
[![GitHub Repository](https://img.shields.io/badge/GitHub-sutrira%2Fdocker__hub--projects-blue?style=flat-square&logo=github)](https://github.com/sutrira/docker_hub-projects)
[![CI/CD Pipeline](https://github.com/sutrira/docker_hub-projects/actions/workflows/docker-build-publish.yml/badge.svg)](https://github.com/sutrira/docker_hub-projects/actions)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](LICENSE)

Source repository for multi-architecture, enterprise-grade Java container images published to [Docker Hub (`sutrira`)](https://hub.docker.com/orgs/sutrira).

All images in this repository are consolidated into **2 purpose-built repositories** based 100% on **Alpine Linux 3.24.1** for minimal disk footprint, zero bloat, and maximum developer agility across both `linux/amd64` (x86_64) and `linux/arm64` (Apple Silicon, ARM servers).

---

## Published Images & Repositories

| Repository | Role | Supported LTS Versions | Docker Hub Tags | Docker Hub Link | Source Directory |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`sutrira/openjdk`** | **Full JDK** (Compiler, Dev & Build Tools) | **Java 25** (Latest LTS)<br>**Java 21** (LTS) | `25`, `25.0.4_p7-r0`, `latest`<br>`21`, `21.0.12_p8-r0` | [![Docker Pulls](https://img.shields.io/docker/pulls/sutrira/openjdk?style=flat-square&label=pulls)](https://hub.docker.com/r/sutrira/openjdk) | [openjdk](openjdk) |
| **`sutrira/openjdk-jre`** | **Headless JRE** (Lean Production Runtime) | **Java 25** (Latest LTS)<br>**Java 21** (LTS) | `25`, `25.0.4_p7-r0`, `latest`<br>`21`, `21.0.12_p8-r0` | [![Docker Pulls](https://img.shields.io/docker/pulls/sutrira/openjdk-jre?style=flat-square&label=pulls)](https://hub.docker.com/r/sutrira/openjdk-jre) | [openjdk-jre](openjdk-jre) |

> [!NOTE]
> **No `-alpine` Tag Suffix Needed**:
> All container images published by this project are **100% Alpine Linux based** by default. To maintain clean, ergonomic identifiers, tag names are kept simple (`21`, `25`, `latest`) without adding redundant `-alpine` suffixes.

---

## Why 100% Alpine Linux?

Instead of maintaining fragmented variants across multiple Linux distributions, this repository standardizes exclusively on Alpine Linux. This provides distinct architectural benefits:

1. **Ultra-Lean Base Footprint**:
   - The Alpine Linux base image is only ~5 MB.
   - The headless JRE runtime (`sutrira/openjdk-jre`) is only **~85 MB uncompressed** (~30 MB compressed download), representing a **~73% size reduction** compared to full JDK containers.
   - Drastically cuts storage costs in container registries and accelerates image pulls across Kubernetes worker nodes.
2. **Minimized Attack Surface & Hardened Security**:
   - Powered by `musl libc` and `busybox`.
   - Strips thousands of legacy Unix binaries, system utilities, and background daemons found in Ubuntu or Debian images.
   - The headless JRE strictly eliminates unneeded desktop windowing and audio subsystems (`libX11`, `libXrender`, `libXext`, `alsa-lib`).
3. **Blazing-Fast Cold Starts & Pod Autoscaling**:
   - Featherweight layers extract in fractions of a second, enabling near-instantaneous Horizontal Pod Autoscaling (HPA) during high traffic spikes.
4. **Predictable, Pinned Patching**:
   - Directly sourced from official Alpine package mirrors with version-pinned APK packages.
   - Scanned on every build using Aqua Security Trivy for high and critical vulnerabilities.

---

## Deprecation Notice: OpenJDK 17 Sunset

As OpenJDK 25 has been released as the new Long-Term Support (LTS) version, **support for OpenJDK 17 has been officially retired** in this repository. 
- Active maintenance and security patches focus exclusively on **OpenJDK 21 (LTS)** and **OpenJDK 25 (Latest LTS)**.
- Legacy standalone repositories (`sutrira/openjdk17`, `sutrira/openjdk21`, `sutrira/openjdk25`) are deprecated in favor of the consolidated `sutrira/openjdk` and `sutrira/openjdk-jre` repositories.

### Quick Migration Guide

| Legacy Image Reference | Modern Replacement | Notes |
| :--- | :--- | :--- |
| `sutrira/openjdk17:*` | **`sutrira/openjdk:21`** or **`sutrira/openjdk:25`** | Upgrade from sunsetted Java 17 to modern LTS |
| `sutrira/openjdk21:latest` | **`sutrira/openjdk:21`** | Full JDK 21 |
| `sutrira/openjdk25:latest` | **`sutrira/openjdk:25`** or **`sutrira/openjdk:latest`** | Full JDK 25 |
| *Any runtime container* | **`sutrira/openjdk-jre:21`** or **`sutrira/openjdk-jre:25`** | **~73% smaller** production runtime |

---

## Repository Architecture

```text
.
├── .dockerenv                           # Centralized configuration (registry, LTS versions, APK tags)
├── .github/
│   └── workflows/
│       └── docker-build-publish.yml    # CI/CD matrix build, CVE scanning & Docker Hub sync
├── openjdk/                             # sutrira/openjdk (Full JDK)
│   ├── README.md                        # Synced to sutrira/openjdk Docker Hub description
│   ├── 21/
│   │   ├── Dockerfile                   # OpenJDK 21 JDK on Alpine 3.24.1
│   │   ├── .dockerignore
│   │   └── build.sh                     # Local multi-arch build script for 21
│   └── 25/
│       ├── Dockerfile                   # OpenJDK 25 JDK on Alpine 3.24.1
│       ├── .dockerignore
│       └── build.sh                     # Local multi-arch build script for 25
├── openjdk-jre/                         # sutrira/openjdk-jre (Headless JRE)
│   ├── README.md                        # Synced to sutrira/openjdk-jre Docker Hub description
│   ├── 21/
│   │   ├── Dockerfile                   # OpenJDK 21 Headless JRE on Alpine 3.24.1
│   │   ├── .dockerignore
│   │   └── build.sh                     # Local multi-arch build script for 21 JRE
│   └── 25/
│       ├── Dockerfile                   # OpenJDK 25 Headless JRE on Alpine 3.24.1
│       ├── .dockerignore
│       └── build.sh                     # Local multi-arch build script for 25 JRE
├── LICENSE
└── README.md
```

---

## Local Development & Testing

You can build and test any image locally using the provided `build.sh` script in each subfolder:

### Build and Load Locally (Single-Arch Dry Run)

```bash
# Build and load OpenJDK 25 Headless JRE into local Docker daemon
./openjdk-jre/25/build.sh --load

# Verify Java runtime
docker run --rm sutrira/openjdk-jre:latest java -version

# Build and load OpenJDK 21 JDK into local Docker daemon
./openjdk/21/build.sh --load
```

### Build and Push Multi-Architecture to Docker Hub

```bash
# Builds both linux/amd64 and linux/arm64 and pushes to Docker Hub
./openjdk-jre/25/build.sh --push
```

---

## Production CI/CD Pipeline (GitHub Actions)

The workflow defined in [`.github/workflows/docker-build-publish.yml`](.github/workflows/docker-build-publish.yml) automates the entire lifecycle:

1. **Selective Change Detection**:
   - Uses `dorny/paths-filter` to detect changes in `openjdk/21/**`, `openjdk/25/**`, `openjdk-jre/21/**`, and `openjdk-jre/25/**`.
   - Rebuilds and publishes **only** the modified target.
   - If common configuration (`.dockerenv` or workflow files) is changed, all targets are rebuilt.
2. **Flexible Manual Dispatch**:
   - Trigger manual builds for `all`, `openjdk-all`, `openjdk-jre-all`, or specific individual targets with push toggles.
3. **Multi-Architecture Emulation**:
   - Sets up QEMU and Docker Buildx for native cross-compiling on `linux/amd64` and `linux/arm64`.
4. **Vulnerability Scanning**:
   - Scans images using [Aqua Security Trivy](https://github.com/aquasecurity/trivy) for `HIGH` and `CRITICAL` CVEs.
   - Generates and uploads SARIF security reports to the GitHub repository Security tab.
5. **Automated Docker Hub Sync**:
   - Uses `peter-evans/dockerhub-description` to automatically synchronize `openjdk/README.md` to `sutrira/openjdk` and `openjdk-jre/README.md` to `sutrira/openjdk-jre`.

---

## License

This repository is licensed under the [Apache License 2.0](LICENSE). The OpenJDK binaries distributed inside the containers are licensed under the GNU General Public License v2 with the Classpath Exception (GPLv2+CE).
