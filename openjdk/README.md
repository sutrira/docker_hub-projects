# OpenJDK on Alpine Linux (`sutrira/openjdk`)

[![Docker Pulls](https://img.shields.io/docker/pulls/sutrira/openjdk.svg?logo=docker&style=flat-square)](https://hub.docker.com/r/sutrira/openjdk)
[![Platforms](https://img.shields.io/badge/platforms-linux%2Famd64%20%7C%20linux%2Farm64-blue.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/sutrira/openjdk)
[![GitHub Repository](https://img.shields.io/badge/source-sutrira%2Fdocker__hub--projects-blue?style=flat-square&logo=github)](https://github.com/sutrira/docker_hub-projects)
[![License: GPL-2.0-with-classpath-exception](https://img.shields.io/badge/License-GPL%202.0%20w%2F%20Classpath-blue.svg?style=flat-square)](https://openjdk.org/legal/gplv2+ce.html)

Multi-architecture, production-ready container images for the **Java Development Kit (JDK)** built entirely on **Alpine Linux 3.24.1**. Provides modern, fully-featured LTS JDK runtimes including compilers (`javac`), modular linkers (`jlink`), diagnostic utilities (`jstack`, `jmap`, `javap`), and developer tools packaged inside a hardened, ultra-lean Alpine footprint.

---

## Supported Tags & Architectures

All images are published for both `linux/amd64` (x86_64) and `linux/arm64` (Apple Silicon, AWS Graviton, Ampere).

| Tag | OpenJDK Version | Release Status | Base OS | Dockerfile Source |
| :--- | :--- | :--- | :--- | :--- |
| **`25`**, **`25.0.4_p7-r0`**, **`latest`** | `25.0.4_p7-r0` | **Latest LTS** | Alpine 3.24.1 | [openjdk/25/Dockerfile](https://github.com/sutrira/docker_hub-projects/blob/main/openjdk/25/Dockerfile) |
| **`21`**, **`21.0.12_p8-r0`** | `21.0.12_p8-r0` | Established LTS | Alpine 3.24.1 | [openjdk/21/Dockerfile](https://github.com/sutrira/docker_hub-projects/blob/main/openjdk/21/Dockerfile) |

> [!NOTE]
> **No `-alpine` Tag Suffix Needed**:
> All images in this repository are **100% Alpine Linux based** by design. Tag names are intentionally clean and concise (`21`, `25`, `latest`) without redundant `-alpine` suffixes.

---

## Why 100% Alpine Linux?

Rather than providing fragmented variants across Debian, Ubuntu, and Alpine, all images in `sutrira/openjdk` standardize exclusively on Alpine Linux. This provides distinct architectural benefits:

1. **Minimized Attack Surface**: Alpine Linux replaces glibc with `musl libc` and ships with `busybox`. It eliminates thousands of unnecessary system packages, utilities, and background daemons found in conventional distributions, drastically decreasing vulnerability surface area.
2. **Lean Layer Footprint**: The complete JDK image on Alpine consumes only ~320 MB uncompressed (compared to 650 MB+ on Ubuntu or Debian). This slashes container registry storage, cuts network transfer costs, and accelerates CI/CD pipeline cache hydration.
3. **Rapid Cold Starts**: Smaller image sizes yield near-instantaneous container provisioning in CI runner nodes, local dev environments, and autoscaled clusters.
4. **Deterministic Security Patching**: Pinned strictly to verified Alpine package repositories with automated Trivy vulnerability scanning on every build.

---

## JDK vs. Headless JRE: Which Should You Use?

This repository (`sutrira/openjdk`) provides the complete **Java Development Kit**. If you only need to run pre-compiled applications in production, use our companion runtime repository:

- **`sutrira/openjdk` (This Repo)**: Full JDK including compiler (`javac`), headers, build tools, and debugging utilities. Ideal for build environments, CI/CD runners, dev containers, and applications compiling code dynamically.
- **[`sutrira/openjdk-jre`](https://hub.docker.com/r/sutrira/openjdk-jre)**: Ultra-lean **Headless JRE** (~85 MB uncompressed, ~73% smaller) omitting compilers, X11, and audio subsystems. Recommended for production deployment of Spring Boot, Quarkus, Micronaut, and containerized microservices.

---

## How to Use This Image

### 1. Interactive Shell or Quick Version Check

Verify the installed Java compiler and runtime:

```bash
# Verify OpenJDK 25 (latest LTS)
docker run --rm sutrira/openjdk:latest java -version
docker run --rm sutrira/openjdk:latest javac -version

# Verify OpenJDK 21 (LTS)
docker run --rm sutrira/openjdk:21 java -version
```

Start an interactive Alpine shell (`/bin/ash`):

```bash
docker run -it --rm sutrira/openjdk:latest
```

*(Note: Alpine Linux uses `ash` instead of `bash`. Launch `/bin/ash` or `/bin/sh`).*

---

### 2. Multi-Stage Build Pattern (Recommended for Production)

Use `sutrira/openjdk` to compile and package your application, then copy the resulting artifact into `sutrira/openjdk-jre` for an ultra-lean production container:

```dockerfile
# ------------------------------------------------------------------------------
# Stage 1: Build & Package (using JDK)
# ------------------------------------------------------------------------------
FROM sutrira/openjdk:25 AS builder

WORKDIR /build

# Copy Maven / Gradle wrappers and source
COPY . .

# Build application artifact (e.g. Maven)
RUN ./mvnw clean package -DskipTests

# ------------------------------------------------------------------------------
# Stage 2: Lean Production Runtime (using Headless JRE)
# ------------------------------------------------------------------------------
FROM sutrira/openjdk-jre:25

# Create a dedicated non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy JAR from builder stage
COPY --from=builder --chown=appuser:appgroup /build/target/*.jar app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
```

---

### 3. Running as a Non-Root User

Running containers as a non-root user is a security standard in Kubernetes and cloud environments:

```dockerfile
FROM sutrira/openjdk:25

# Create non-root group and user
RUN addgroup -S devgroup && adduser -S devuser -G devgroup

WORKDIR /workspace
RUN chown devuser:devgroup /workspace

USER devuser

CMD ["/bin/ash"]
```

---

## Environment Variables

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `JAVA_HOME` | `/usr/lib/jvm/java-25-openjdk` *(or `java-21-openjdk`)* | Root installation directory of the OpenJDK package |
| `PATH` | `${JAVA_HOME}/bin:${PATH}` | System path including Java binaries (`java`, `javac`, etc.) |

---

## Migration Guide (From Legacy Repositories)

If you previously pulled from our version-specific repositories (`sutrira/openjdk17`, `sutrira/openjdk21`, or `sutrira/openjdk25`), update your references:

| Legacy Reference | Recommended Modern Replacement | Note |
| :--- | :--- | :--- |
| `sutrira/openjdk17:*` | **`sutrira/openjdk:21`** or **`sutrira/openjdk:25`** | OpenJDK 17 is deprecated; upgrade to active LTS |
| `sutrira/openjdk21:latest` | **`sutrira/openjdk:21`** | Pinned to OpenJDK 21 LTS |
| `sutrira/openjdk25:latest` | **`sutrira/openjdk:25`** or **`sutrira/openjdk:latest`** | Latest LTS release |
| *Runtime-only containers* | **`sutrira/openjdk-jre:21`** or **`:25`** | Cut container footprint by over ~70% |

---

## Source & Maintenance

- **Source Code**: [https://github.com/sutrira/docker_hub-projects](https://github.com/sutrira/docker_hub-projects)
- **Directory**: [https://github.com/sutrira/docker_hub-projects/tree/main/openjdk](https://github.com/sutrira/docker_hub-projects/tree/main/openjdk)
- **Issue Tracker**: [https://github.com/sutrira/docker_hub-projects/issues](https://github.com/sutrira/docker_hub-projects/issues)
- **CI/CD**: Fully automated multi-architecture builds, Trivy CVE scanning, and Docker Hub synchronization.
