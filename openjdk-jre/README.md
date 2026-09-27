# OpenJDK Headless JRE on Alpine Linux (`sutrira/openjdk-jre`)

[![Docker Pulls](https://img.shields.io/docker/pulls/sutrira/openjdk-jre.svg?logo=docker&style=flat-square)](https://hub.docker.com/r/sutrira/openjdk-jre)
[![Platforms](https://img.shields.io/badge/platforms-linux%2Famd64%20%7C%20linux%2Farm64-blue.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/sutrira/openjdk-jre)
[![GitHub Repository](https://img.shields.io/badge/source-sutrira%2Fdocker__hub--projects-blue?style=flat-square&logo=github)](https://github.com/sutrira/docker_hub-projects)
[![License: GPL-2.0-with-classpath-exception](https://img.shields.io/badge/License-GPL%202.0%20w%2F%20Classpath-blue.svg?style=flat-square)](https://openjdk.org/legal/gplv2+ce.html)

Ultra-lean, multi-architecture, production-grade container images providing the **Headless Java Runtime Environment (JRE)** built entirely on **Alpine Linux 3.24.1**. Specifically engineered for running containerized server-side Java applications, Spring Boot 3+, Quarkus, Micronaut, and cloud-native microservices with minimal disk footprint and the highest security posture.

---

## Supported Tags & Architectures

All images are published for both `linux/amd64` (x86_64) and `linux/arm64` (Apple Silicon, AWS Graviton, Ampere).

| Tag | OpenJDK Version | Release Status | Base OS | Dockerfile Source |
| :--- | :--- | :--- | :--- | :--- |
| **`25`**, **`25.0.4_p7-r0`**, **`latest`** | `25.0.4_p7-r0` | **Latest LTS** | Alpine 3.24.1 | [openjdk-jre/25/Dockerfile](https://github.com/sutrira/docker_hub-projects/blob/main/openjdk-jre/25/Dockerfile) |
| **`21`**, **`21.0.12_p8-r0`** | `21.0.12_p8-r0` | Established LTS | Alpine 3.24.1 | [openjdk-jre/21/Dockerfile](https://github.com/sutrira/docker_hub-projects/blob/main/openjdk-jre/21/Dockerfile) |

> [!NOTE]
> **No `-alpine` Tag Suffix Needed**:
> All images in this repository are **100% Alpine Linux based** by design. Tag names are intentionally clean and concise (`21`, `25`, `latest`) without redundant `-alpine` suffixes.

---

## Why 100% Alpine Linux & Headless JRE?

Production backend services do not require heavy compilers, diagnostic daemons, or desktop windowing subsystems. By pairing **Alpine Linux** with **Headless OpenJDK** (`openjdk*-jre-headless`), this image delivers major operational benefits:

1. **Featherweight Footprint (~85 MB Uncompressed)**:
   - At only ~85 MB uncompressed (~30 MB compressed download), this image is **~73% smaller** than a full JDK image and less than half the size of standard glibc-based runtimes.
   - Saves massive bandwidth and storage across container registries and Kubernetes worker node caches.
2. **Hardened Attack Surface (Headless Architecture)**:
   - Installing the **headless** package strictly strips out desktop GUI and audio dependencies like `libX11`, `libXext`, `libXrender`, and `alsa-lib`.
   - Omits build-time compilers (`javac`), headers, and code generators.
   - Built on `musl libc` and `busybox` without lingering Unix daemons or utilities.
3. **Instantaneous Cold-Starts & Pod Autoscaling**:
   - Featherweight layers extract in fractions of a second, enabling near-instant horizontal pod autoscaling (HPA) during high traffic surges.
4. **Deterministic Security Scanning**:
   - Automated Aqua Security Trivy vulnerability scans are performed on every build and push to ensure CVE-free base layers.

---

## Headless JRE vs. Full JDK: Which Should You Use?

- **`sutrira/openjdk-jre` (This Repo)**: Lean, headless production runtime (~85 MB). Contains only `java` and core runtime libraries needed to execute pre-built JARs and WARs.
- **[`sutrira/openjdk`](https://hub.docker.com/r/sutrira/openjdk)**: Complete development kit (~320 MB) containing `javac`, `jlink`, `jstack`, and profiling utilities for compilation and dev environments.

---

## How to Use This Image

### 1. Interactive Shell or Quick Version Check

Verify the installed headless Java runtime:

```bash
# Verify OpenJDK 25 Headless JRE (latest LTS)
docker run --rm sutrira/openjdk-jre:latest java -version

# Notice: javac is intentionally excluded in the lean JRE runtime
docker run --rm sutrira/openjdk-jre:latest javac -version || echo "Javac not installed (expected)"

# Verify OpenJDK 21 Headless JRE (LTS)
docker run --rm sutrira/openjdk-jre:21 java -version
```

Start an interactive Alpine shell (`/bin/ash`):

```bash
docker run -it --rm sutrira/openjdk-jre:latest
```

---

### 2. Deploying a Spring Boot / Quarkus / Microservice Application

Use `sutrira/openjdk-jre:latest` (or `:21`) as the base image for your pre-compiled application:

```dockerfile
FROM sutrira/openjdk-jre:25

# Create a dedicated non-root application user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy application JAR
COPY --chown=appuser:appgroup target/app.jar app.jar

# Switch to non-root user
USER appuser

EXPOSE 8080

# Production-tuned JVM container parameters
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-XX:+ExitOnOutOfMemoryError", \
  "-jar", "app.jar"]
```

---

### 3. Container JVM Memory Tuning & Optimization

When running Java inside containers, always configure JVM container support so the JVM respects cgroup CPU and memory limits:

```bash
docker run -m 512m -p 8080:8080 \
  sutrira/openjdk-jre:25 \
  java -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError -jar app.jar
```

| Flag | Purpose |
| :--- | :--- |
| `-XX:+UseContainerSupport` | Enables container CPU and memory limit auto-detection (enabled by default in modern OpenJDK). |
| `-XX:MaxRAMPercentage=75.0` | Allocates up to 75% of the container's memory limit to the Java heap, reserving 25% for Metaspace, threads, and native memory. |
| `-XX:+ExitOnOutOfMemoryError` | Automatically terminates the JVM process if heap is exhausted so Kubernetes can safely restart the pod. |

---

## Environment Variables

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `JAVA_HOME` | `/usr/lib/jvm/java-25-openjdk` *(or `java-21-openjdk`)* | Root installation directory of the OpenJDK package |
| `PATH` | `${JAVA_HOME}/bin:${PATH}` | System path including the `java` binary |

---

## Migration Guide (From Legacy Repositories)

If you previously used our version-specific repositories (`sutrira/openjdk17`, `sutrira/openjdk21`, or `sutrira/openjdk25`) for production runtimes, upgrade to `sutrira/openjdk-jre`:

| Legacy Reference | Recommended Modern Replacement | Benefit |
| :--- | :--- | :--- |
| `sutrira/openjdk17:*` | **`sutrira/openjdk-jre:21`** or **`:25`** | Modern LTS release + ~73% smaller image footprint |
| `sutrira/openjdk21:*` | **`sutrira/openjdk-jre:21`** | Drops unnecessary compiler and debug tools |
| `sutrira/openjdk25:*` | **`sutrira/openjdk-jre:25`** or **`:latest`** | Leanest production runtime for Java 25 LTS |

---

## Source & Maintenance

- **Source Code**: [https://github.com/sutrira/docker_hub-projects](https://github.com/sutrira/docker_hub-projects)
- **Directory**: [https://github.com/sutrira/docker_hub-projects/tree/main/openjdk-jre](https://github.com/sutrira/docker_hub-projects/tree/main/openjdk-jre)
- **Issue Tracker**: [https://github.com/sutrira/docker_hub-projects/issues](https://github.com/sutrira/docker_hub-projects/issues)
- **CI/CD**: Fully automated multi-architecture builds, Trivy CVE scanning, and Docker Hub synchronization.
