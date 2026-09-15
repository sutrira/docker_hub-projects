# OpenJDK 21 on Alpine Linux (`sutrira/openjdk21`)

[![Docker Pulls](https://img.shields.io/docker/pulls/sutrira/openjdk21.svg?logo=docker&style=flat-square)](https://hub.docker.com/r/sutrira/openjdk21)
[![Docker Stars](https://img.shields.io/docker/stars/sutrira/openjdk21.svg?logo=docker&style=flat-square)](https://hub.docker.com/r/sutrira/openjdk21)
[![Platforms](https://img.shields.io/badge/platforms-linux%2Famd64%20%7C%20linux%2Farm64-blue.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/sutrira/openjdk21)
[![GitHub Repository](https://img.shields.io/badge/source-sutrira%2Fdocker__hub--projects-blue?style=flat-square&logo=github)](https://github.com/sutrira/docker_hub-projects)
[![License: GPL-2.0-with-classpath-exception](https://img.shields.io/badge/License-GPL%202.0%20w%2F%20Classpath-blue.svg?style=flat-square)](https://openjdk.org/legal/gplv2+ce.html)

Production-ready, lightweight, multi-architecture container images for **OpenJDK 21 (LTS)** built on **Alpine Linux 3.24.1**. Features modern Java 21 LTS capabilities (Virtual Threads / Project Loom, Generational ZGC, Pattern Matching, Sequenced Collections) packaged inside a minimal Alpine footprint.

---

## Supported Tags & Target Architectures

| Tag | OpenJDK Version | Base Image | Target Architectures | Dockerfile |
| :--- | :--- | :--- | :--- | :--- |
| `21.0.12_p8-r0`, `21`, `latest` | **21.0.12_p8-r0** | Alpine Linux 3.24.1 | `linux/amd64`, `linux/arm64` | [Dockerfile](https://github.com/sutrira/docker_hub-projects/blob/main/openjdk21/Dockerfile) |

---

## How This Image Was Built

- **Multi-Architecture Buildx**: Built and published using Docker Buildx and QEMU for both `linux/amd64` (x86_64) and `linux/arm64` (Apple Silicon, AWS Graviton, etc.).
- **Minimal Footprint**: Built on top of official `alpine:3.24.1` for rapid download and container startup times.
- **Zero Package Cache**: Installed with `--no-cache` to ensure clean layers without lingering package index files.
- **Pinned Package Release**: Pinned strictly to `openjdk21-jdk=21.0.12_p8-r0` from the official Alpine package repository for deterministic builds.
- **Vulnerability Scanned**: Automated vulnerability scanning is performed using [Aqua Security Trivy](https://github.com/aquasecurity/trivy) in GitHub Actions on every commit and release.

---

## How to Use This Image

### 1. Run Java Interactively or Check Version

Launch a container to verify the installed Java runtime:

```bash
docker run --rm sutrira/openjdk21:latest java -version
```

Output:
```text
openjdk version "21.0.12" 2026-04-14
OpenJDK Runtime Environment (build 21.0.12+8)
OpenJDK 64-Bit Server VM (build 21.0.12+8, mixed mode, sharing)
```

Launch an interactive Alpine shell (`/bin/ash`):

```bash
docker run -it --rm sutrira/openjdk21:latest
```

*(Note: Alpine Linux uses `ash` instead of `bash`. Run `/bin/ash` or `/bin/sh` for shell interaction).*

---

### 2. Use as a Base Image in a Dockerfile

Use `sutrira/openjdk21:latest` as the base runtime for Spring Boot 3+, Quarkus, or Micronaut applications:

```dockerfile
FROM sutrira/openjdk21:latest

WORKDIR /app

# Copy application artifact
COPY target/my-application.jar app.jar

# Expose server port
EXPOSE 8080

# Run application with container-aware JVM memory settings
CMD ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
```

---

### 3. Recommended: Running as a Non-Root User

Running containers as a non-root user is a production standard for container security:

```dockerfile
FROM sutrira/openjdk21:latest

# Create a dedicated application group and user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy and assign ownership
COPY --chown=appuser:appgroup target/my-application.jar /app/app.jar

# Switch to non-root user
USER appuser

EXPOSE 8080
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
```

---

### 4. Container JVM Memory Optimization & Virtual Threads

Take advantage of Java 21's modern GC (ZGC/G1) and container RAM limits:

```bash
docker run -m 512m -p 8080:8080 \
  sutrira/openjdk21:latest \
  java -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseZGC -XX:+ZGenerational -jar app.jar
```

---

## Environment Variables

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `JAVA_HOME` | `/usr/lib/jvm/java-21-openjdk` | Location of the OpenJDK installation |
| `PATH` | `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jvm/java-21-openjdk/bin` | System path including Java binaries (`java`, `javac`, etc.) |

---

## GitHub Repository & Automation

- **GitHub Repository (SSH)**: `git@github.com:sutrira/docker_hub-projects.git`
- **GitHub Repository (HTTPS)**: [https://github.com/sutrira/docker_hub-projects](https://github.com/sutrira/docker_hub-projects)
- **Directory Source**: [https://github.com/sutrira/docker_hub-projects/tree/main/openjdk21](https://github.com/sutrira/docker_hub-projects/tree/main/openjdk21)
- **CI/CD Pipeline**: Multi-platform automated builds, vulnerability scanning, and Docker Hub releases via GitHub Actions.

If you encounter any issues or have feature suggestions, please [open an issue on GitHub](https://github.com/sutrira/docker_hub-projects/issues).
