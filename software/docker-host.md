# Docker host (`ct-docker`)

The one container that runs Docker — VMID 104. It's the only guest with `nesting=1`;
everything else is a plain LXC.

## What runs on it

* [Portainer](portainer.md) — Docker management UI
* [Uptime Kuma](uptimekuma.md) — service monitoring / status page
* a handful of smaller single-container apps

## Docker daemon config

* **Local Unix socket only** — `daemon.json` defines no network listener, so the API is
  reachable only from inside the container.
* **`live-restore: true`** — containers keep running across a daemon restart (which
  matters, because a `daemon.json` change needs one).

## Notes

* **On the nightly backup job** — Portainer stacks and Uptime-Kuma's monitor definitions
  are real hand-built state.
* The rootfs was grown from 4 GB to 8 GB after it filled mid-upgrade once; a disk-space
  pre-check in the patch job is on the roadmap ([patching](../docs/patching.md)).
* Portainer and Uptime-Kuma web UIs are scoped to the management subnet in the
  [firewall](../docs/security.md) rollout.
* HA-managed.
