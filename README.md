# SRE Infrastructure Automation Platform

A small, production-style platform on GCP: Terraform provisions Rocky Linux 9 servers, Ansible configures, hardens and patches them, a Python app is deployed and monitored (Prometheus, Grafana, Alertmanager), and selected failures are remediated automatically. CI/CD runs on GitHub Actions.

See [docs/setup.md](docs/setup.md) for local prerequisites.
