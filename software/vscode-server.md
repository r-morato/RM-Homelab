# VS Code Server

Browser-accessible VS Code for editing the lab's config and automation without a local
checkout.

<!-- TODO(@r-morato): confirm where code-server runs before publishing — this page
     assumes a container on the Docker host. Update if it's elsewhere. -->

## Role

* Edit playbooks, compose files, dashboard config, and notes from any device with a
  browser.
* Runs on the server so the work happens next to the files it touches.

## Hosting

Runs as a container on the [Docker host](docker-host.md) (`ct-docker`).

## Notes

* Convenience tool, not infrastructure — nothing depends on it.
* It can reach the repo and config, so it's access-controlled (login + LAN-only) and
  folded into the [firewall](../docs/security.md) plan like the other web UIs.
