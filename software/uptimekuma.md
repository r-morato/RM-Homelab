# Uptime Kuma

Self-hosted uptime monitoring and status page. Runs as a container on the
[Docker host](docker-host.md) (`ct-docker`).

## Role

* Polls every key service (Proxmox web UI, the media servers, the dashboard, Pi-hole,
  Home Assistant, the gateway) on an interval and records availability + response time.
* Sends a notification when something goes down or recovers.
* Provides an at-a-glance status dashboard.

## Notes

* Monitor definitions are hand-built state → `ct-docker` is on the nightly backup job.
* It's a useful cross-check on the automation: a patch run that breaks a service shows
  up here even if the playbook reported success.
