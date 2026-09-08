# Portainer

Web UI for managing Docker. Runs as a container on the [Docker host](docker-host.md)
(`ct-docker`).

## Role

* Deploy and manage the other Docker containers, images, volumes, and networks on
  `ct-docker` through a browser.
* Manage stacks (compose files) with their definitions kept in Portainer.

## Notes

* Talks to Docker over the **local socket**, not a TCP port — unaffected by the daemon
  lockdown described in [`docker-host.md`](docker-host.md).
* Its stack definitions are part of why `ct-docker` is on the backup job.
* Web UI access is scoped to the management subnet as part of the
  [firewall](../docs/security.md) work.
