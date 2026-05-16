# Mission Deploy: Docker + Kubernetes + Terraform

A security-hardened containerized deployment-simulator deployed to a local Kubernetes cluster using Terraform. Built as a hands-on project to practice the Docker-to-Kubernetes pipeline with Infrastructure as Code and container security best practices.

## Technologies Used

- **Docker** - Containerization of a Linux bash script with non-root user
- **Kubernetes** - Orchestration via a local cluster, utilizing **Jobs** for single executions and **CronJobs** for scheduled tasks.
- **Terraform** - Infrastructure as Code to deploy the K8s Job
- **Alpine Linux** - Lightweight container base image

## Project Structure

Following cloud development best practices, the Terraform configuration is modularized to split provider settings from resource definitions:

```text
k8s-mission-deploy/
├── Dockerfile          # Builds the non-root Alpine image
├── mission.sh          # The core mission script
├── providers.tf        # Terraform provider configuration (Docker Desktop context)
└── main.tf             # Kubernetes Job & CronJob definitions with Security Contexts
```


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

3. Check the CronJob and active execution logs:

```bash
# Verify the CronJob is created and check its schedule
kubectl get cronjobs

# Watch the pods being created every 2 minutes
kubectl get pods --watch

# Check the logs of the latest completed job
kubectl logs <pod-name-generated-by-cronjob>
```

4. Verify the active runtime Security Context (PowerShell / Windows)

```bash
kubectl get pod <pod-name> -o yaml | Select-String -Pattern "securityContext" -Context 0, 6
kubectl get cronjob mission-deploy-cronjob -o yaml | Select-String -Pattern "securityContext" -Context 0, 6
```

5. Clean up:

```bash
terraform destroy
```

## Sample Output

```
>>Run Timestamp: 2026-05-16T16:04:02+00:00

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

## Architecture

```text
[mission.sh] --> [Docker Image] ──> [Kubernetes Job] ────> [Pod runs once to completion]
                      |        └──> [Kubernetes CronJob] ──> [Generates Pods every 2 min]
                      |                      |
               (non-root user)       (security context:
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