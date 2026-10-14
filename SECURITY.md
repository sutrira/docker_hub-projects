# Security Policy

The security of the container images published under the [`sutrira`](https://hub.docker.com/orgs/sutrira) namespace is a top priority. This repository enforces proactive security practices, automated vulnerability scanning, and hardened Alpine Linux base environments for all distributed images.

---

## Supported Versions

Security updates, base image rebuilds, and vulnerability patches are actively provided for official Long-Term Support (LTS) Java releases on current Alpine Linux base images.

| Repository | Java Version | Release Tier | Active Tags | Base OS | Supported |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **`sutrira/openjdk`** | **OpenJDK 25** | Latest LTS | `25`, `25.0.4_p7-r0`, `latest` | Alpine 3.24.2 | :white_check_mark: |
| **`sutrira/openjdk-jre`** | **OpenJDK 25** | Latest LTS | `25`, `25.0.4_p7-r0`, `latest` | Alpine 3.24.2 | :white_check_mark: |
| **`sutrira/openjdk`** | **OpenJDK 21** | Established LTS | `21`, `21.0.12_p8-r0` | Alpine 3.24.2 | :white_check_mark: |
| **`sutrira/openjdk-jre`** | **OpenJDK 21** | Established LTS | `21`, `21.0.12_p8-r0` | Alpine 3.24.2 | :white_check_mark: |

> [!NOTE]
> Any version, tag, or repository not explicitly listed in the table above is unsupported. This project exclusively packages and maintains Long-Term Support (LTS) releases.

---

## Scope of Security Responsibility

### In Scope
- Dockerfile layer definitions, build configurations, and OCI metadata.
- Pinned Alpine Linux package definitions and base OS security patch levels (`apk upgrade --no-cache`).
- Headless runtime stripping (elimination of unneeded desktop and windowing libraries in `sutrira/openjdk-jre`).
- Multi-architecture container build reproducibility and CI/CD supply chain hardening.
- Automated vulnerability scanning using Aqua Security Trivy.

### Out of Scope
- **Upstream OpenJDK / Alpine Linux Deficiencies**: Zero-day vulnerabilities in upstream OpenJDK or Alpine core libraries (`musl`, `busybox`) prior to upstream patch releases. These are patched as soon as updated APK packages are made available upstream.
- **Downstream Application Vulnerabilities**: Flaws introduced by user applications, custom libraries, dependencies, or configuration layers built on top of these base images.
- **Unsupported / Retired Images**: Older image tags or deprecated standalone repositories.

---

## Automated Vulnerability Management

All images built by this repository pass through automated security controls integrated into the CI/CD pipeline:

1. **Continuous Vulnerability Scanning**: Every pull request and push to `main` is scanned using [Aqua Security Trivy](https://github.com/aquasecurity/trivy) targeting `HIGH` and `CRITICAL` severity CVEs.
2. **SARIF Integration**: Scan results are automatically reported to the repository's GitHub Code Scanning / Security alerts dashboard.
3. **Fresh Base Patching**: Each build invokes `apk upgrade --no-cache` to ensure newly patched packages in the Alpine 3.24.2 repository are incorporated into published container images.
4. **Supply-Chain Integrity**: Images are published directly via GitHub Actions using tokenized authentication to Docker Hub without manual layer manipulation.

---

## Reporting a Vulnerability

We appreciate the responsible and coordinated disclosure of security vulnerabilities. If you discover a security flaw or unmitigated CVE in our container configurations or published images, please follow the procedure below.

### 1. Preferred Method: GitHub Private Vulnerability Reporting

Please submit reports privately through GitHub's built-in security advisory portal:
👉 **[Report a Vulnerability](https://github.com/sutrira/docker_hub-projects/security/advisories/new)**

> [!CAUTION]
> **Do not open public GitHub issues or discussions for unpatched security vulnerabilities or zero-day exploits.** Coordinated disclosure ensures that fixes can be prepared and released before vulnerabilities can be maliciously exploited.

### 2. Information to Include

To facilitate prompt triage and verification, please include:
- **Image Identifier**: Repository name (e.g., `sutrira/openjdk` or `sutrira/openjdk-jre`), tag (e.g., `25`, `21.0.12_p8-r0`), and image digest (`sha256:...`).
- **Target Architecture**: `linux/amd64` or `linux/arm64`.
- **Vulnerability Details**: Applicable CVE identifier, CWE, or description of the architectural weakness.
- **Proof of Concept / Steps to Reproduce**: Instructions, commands, or Docker run invocations demonstrating the condition.
- **Impact Assessment**: Evaluation of potential attack vectors, privilege escalation, or data exposure.

---

## Response Process & SLAs

When a vulnerability report is submitted, the maintainers adhere to the following response timeline:

| Milestone | Target SLA | Description |
| :--- | :--- | :--- |
| **Initial Acknowledgment** | Within **48–72 hours** | Confirmation that the report was received and initial triage has commenced. |
| **Triage & Validation** | Within **5 business days** | Assessment of reproducibility, exploitability, and scope. |
| **Remediation & Patching** | Within **7–14 days** | Rebuilding base images, updating APK package references, or modifying build arguments. *(Dependent on upstream fix availability for upstream CVEs)*. |
| **Coordinated Disclosure** | Post-release | Once patched images are live on Docker Hub, the advisory will be credited and published. |
