# Mission Deploy: Docker + Kubernetes + Terraform

A security-hardened containerized deployment-simulator deployed to a local Kubernetes cluster using Terraform. Built as a hands-on project to practice the Docker-to-Kubernetes pipeline with Infrastructure as Code and container security best practices.

## Technologies Used

- **Docker** - Containerization of a Linux bash script with non-root user
- **Kubernetes** - Orchestration via a local cluster (Docker Desktop)
- **Terraform** - Infrastructure as Code to deploy the K8s Job
- **Alpine Linux** - Lightweight container base image

## Project Structure

Following cloud development best practices, the Terraform configuration is modularized to split provider settings from resource definitions:

```text
k8s-mission-deploy/
├── Dockerfile          # Builds the non-root Alpine image
├── mission.sh          # The core mission script
├── providers.tf        # Terraform provider configuration (Docker Desktop context)
└── main.tf             # Kubernetes Job definition & Security Contexts


## Security Practices

This project applies production-grade container security:

- **Non-root container**: The Docker image runs as user `mission` (UID 1000), never as root
- **Read-only filesystem**: The container filesystem is mounted read-only at runtime to block malicious write operations.
- **Dropped capabilities**: All Linux capabilities are dropped (drop = ["ALL"]) to prevent privilege escalation.
- **Resource limits**: CPU and memory limits prevent the container from consuming excessive resources
- **Minimal base image**: Alpine Linux minimizes the attack surface

## What It Does

The container runs a bash script that simulates a deployment mission sequence while reporting real system information (hostname, OS, memory, disk, network). When deployed to Kubernetes, the Job runs to completion and the logs can be inspected with kubectl.

## How to Run

### Prerequisites

- Docker Desktop with Kubernetes enabled
- Terraform installed

### Steps

1. Build the Docker image:

```bash
docker build -t mission-deploy:1.0 .
```

2. Deploy to Kubernetes with Terraform:

```bash
terraform init
terraform plan
terraform apply
```

3. Check the logs:

```bash
kubectl get pods
kubectl logs <pod-name>
```

4. Verify security context:

```bash
kubectl get pod <pod-name> -o yaml | Select-String -Pattern "securityContext" -Context 0, 6
```

5. Clean up:

```bash
terraform destroy
```

## Sample Output

```
╔══════════════════════════════════════════╗
║    MISSION: SYSTEM DEPLOYMENT v1.0       ║
╚══════════════════════════════════════════╝

[*] Initializing secure connection......... OK
[*] Scanning network targets............... OK
[*] Loading deployment payload............. OK
[*] Verifying system integrity............. OK

    SYSTEM INTEL REPORT
────────────────────────────────────────────
>> Hostname: mission-deploy-job-9cmnf
>> OS:       Alpine Linux v3.21
>> Kernel:   6.6.114.1-microsoft-standard-WSL2
>> User:     mission (non-root)
>> Memory:
   Total: 7.7Gi  Used: 1.2Gi  Free: 4.8Gi
>> Disk:
   Size: 1006.9G  Used: 3.5G  Avail: 952.1G  Use%: 0%
>> Network:
   127.0.0.1/8 on lo
   10.1.0.14/16 on eth0

[*] Deploying to target cluster............ OK
[*] Running post-deploy checks............. OK
[*] Security scan......................... PASSED

╔══════════════════════════════════════════╗
║         MISSION ACCOMPLISHED             ║
║   All systems operational. Status: GO    ║
╚══════════════════════════════════════════╝

```

## Architecture

```
[mission.sh] --> [Docker Image] --> [Kubernetes Job] --> [Pod runs to completion]
                      |                    |
              (non-root user)     (security context:
                                   read-only fs,
                                   drop ALL caps,
                                   resource limits)
                                         ^
                                         |
                                   [Terraform apply]
                                   (providers.tf + main.tf)
```

## Author

Built as part of my Cloud Engineering learning path.