# Ansible control container (`ct-ansible`)

The container that runs all fleet-wide automation - VMID 109, label `ct-ansible`.

## What's on it

* `ansible-core` (from the Debian `ansible` package - so `community.general` and
  `ansible.posix` come pinned with it, no Galaxy pulls)
* the playbook repo at `/opt/ansible` (this repo's [`ansible/`](../ansible/) directory)
* [Semaphore](semaphore.md) for the web UI and schedules
* `unattended-upgrades` for its own security patches

## Why it's built the way it is

| Choice | Reason |
|---|---|
| Unprivileged LXC, `nesting=0,keyctl=0` | minimal attack surface |
| Root disk on **`local-lvm`**, not NFS | still runs (and can still patch/rebuild the fleet) during a storage outage |
| HA-managed + on the nightly backup job | it's now critical infrastructure |
| Passphrase-less SSH key, root on every target | it has to run unattended - but every `authorized_keys` entry is `from="<control IP>"`-locked |
| Reachable on the LAN segment only | management traffic stays off the storage/cluster network |

It is the **single most sensitive guest in the lab**: whoever holds it holds root
everywhere. See [security](../docs/security.md).

## What it does today

Patches the containers weekly and the hypervisors monthly, and runs the guarded rolling
hypervisor reboot on demand. See [automation](../docs/automation.md) and
[patching](../docs/patching.md). The operator reference is
[`ansible/README.md`](../ansible/README.md).

## Build

`ansible/bootstrap/01-create-control-node.sh` (creates the container) then
`02-deploy-control-node-key.sh` (authorises its key everywhere), both run on
`pve-node-1`. Then [`ansible/docs/control-node.md`](../ansible/docs/control-node.md) and
[`ansible/docs/semaphore.md`](../ansible/docs/semaphore.md).
