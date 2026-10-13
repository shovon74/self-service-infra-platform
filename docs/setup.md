# Environment Setup

## Runtime Environment

Use Ubuntu 24.04 on WSL2 for local Terraform, Ansible, and Python tooling.
Run application and monitoring services on GCP VMs; Docker Desktop is not
required. Rocky Linux 9 is the target server operating system.

The selected authoritative checkout is `~/self-service-infra-platform` on WSL's
Linux filesystem, for reliable Linux permissions and filesystem performance.
Keep local-only instructions and uncommitted files in this checkout. Do not create
a competing clone or overwrite an existing directory. Keep credentials outside
the checkout.

Select Ubuntu explicitly when calling WSL from Windows, especially if another
distribution is the default:

```powershell
wsl -d Ubuntu-24.04
```

Obtain operator approval before running commands or changing configuration.
Installation commands must be reviewed for the actual environment and approved
separately. Administrative operations and secret entry are performed directly by
the operator, not through chat.

## Required Tools

These are baseline minimum versions, not installation pins or a claim that every
newer combination has been tested. Review compatibility and choose exact supported
versions before installation; later project configuration may raise these floors.

| Tool | Minimum | Preferred installation source |
| --- | --- | --- |
| Git | 2.34.0 | Ubuntu packages |
| Python | 3.10.0 | Ubuntu packages, including matching venv package |
| Terraform | 1.5.0 | Official HashiCorp distribution |
| TFLint | 0.50.0 | Official release binary with integrity verification |
| Ansible core | 2.16.0 | Dedicated Python tools venv |
| ansible-lint | 24.0.0 | Same tools venv with compatible Ansible core |
| Google Cloud CLI | 450.0.0 | Official Google Cloud package repository |
| jq | 1.6.0 | Ubuntu packages |

Do not install Python tools into system Python or use unreviewed remote scripts
piped into a shell. Verify release integrity following the publisher's procedure.
Ensure the selected tools venv's executable directory is on PATH when checking
or using Ansible. Do not create, activate, or change PATH without approval.

From the repository root, approved checks are:

```bash
bash -n scripts/check_tools.sh
bash scripts/check_tools.sh
```

The checker prints each required tool's version or failure and retuns nonzero
when any requirement is unmet. It does not install software or change GCP
resources. It loads the Python venv module but does not prove that an environment
can be created with pip; perform that separate temporary-environment check only
with approval. Tool invocations can have their own normal local cache behavior.

An isolated missing-tool check requires no uninstallations:

```bash
/usr/bin/env PATH=/nonexistent /usr/bin/bash scripts/check_tools.sh
```

Expected result: eight missing-tool messages and exit code 1. Invoke the script
with Bash until Linux executable permissions are deliberately configured; a
future executable-bit Git change requires separate approval.

## GCP Prerequisites

Review these choices with the operator before cloud changes:

- Existing or new project, project ID, and billing linkage. Do not publish
  operator-specific project or billing details in this guide.
- One supported region and zone, resource labels, and intended VM sizes.
- Budget amount and alert recipients. Budgets notify; they do not impose a
  hard spending cap. VMs, disks, IPs, NAT, and storage may incur charges.
- Required services: Compute Engine, IAP, and Cloud Storage. If using OS Login,
  include its API and access configuration. WIF setup is a later CI/CD step.
- Least-privilege permissions for provisioning, service-account attachment,
  inventory discovery, and IAP SSH; select exact roles after the architecture
  and identity model are agreed. Avoid blanket Owner/Editor grants.
- Google Cloud CLI login and Application Default Credentials are separate.
  Authenticate directly in the local tool after approval. Prefer user credentials
  or approved impersonation rather than downloaded service-account keys.
- Verify enabled APIs, billing, identity, and IAM through an approved read-only
  command batch. A login alone does not prove provisioning access.

Keep authentication tokens, ADC files, service-account JSON, real Terraform
variables, and state out of Git. Never paste authentication secrets into chat.
Do not create VMs or a state bucket as part of prerequisites. GCS backend
bootstrap belongs to Terraform setup with separate approval, access controls,
and a retention/cleanup decision.

At the end of sessions with live resources, review cleanup with the operator.
Destruction always needs explicit approval; retained state and bootstrap
resources must be accounted for separately.