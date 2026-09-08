# Provisioning & configuration

How a new service goes from "I want to run X" to "X is running, backed up, HA-managed,
and patched on schedule."

## Guest defaults

Every guest is an **unprivileged LXC container**. VMs are avoided unless something needs
its own kernel — containers are lighter, boot in a second, and share the host's patched
kernel.

| Setting | Default | Notes |
|---|---|---|
| Type | unprivileged LXC | UID-remapped; a root break-out lands as an unprivileged host UID |
| `onboot` | `1` | HA starts it anyway, but this covers a single-node boot |
| `features` | `nesting=0,keyctl=0` | **only** the Docker host gets `nesting=1` |
| Root disk | raw image on `PROX-NFS` | so either node can start it — except the control container, which is on `local-lvm` |
| Network | static on `vmbr0`, `10.0.0.<vmid>` | address matches the VMID |
| Firewall | `firewall=1` | per-guest firewall enabled (rules come with the firewall rollout) |

The current fleet is a mix of Debian 13 / 12 and Ubuntu 24.04. New guests are Debian 13.

## Steps to add a service

1. **Create the container** — from the Debian 13 template, with the defaults above.
   `ct-dashboard`-style config lives in the container; nothing about the app goes in the
   Proxmox guest config except a Notes reference (see below).
2. **Put it under HA** — `ha-manager add ct:<id> --state started`, then add `ct:<id>` to
   the node-affinity rule so it prefers `pve-node-1` with `pve-node-2` as failover. See
   [high availability](high-availability.md).
3. **Add it to backups if it holds unique state** — add the VMID to the nightly `vzdump`
   job and to the `backup_protected` group in the Ansible inventory. Streaming /
   download / indexer containers are deliberately left off — see [backups](backups.md).
4. **Wire up the automation** — add it to `inventory/hosts.yml` (and the Semaphore static
   inventory), authorise the control-container key, add the `20-ansible.conf` sshd
   drop-in if the guest uses `AllowUsers`. Full steps in [automation](automation.md).
5. **Harden its SSH** — key-only root, `PasswordAuthentication no`, `fail2ban`. See
   [security](security.md).

## The Notes-field convention

Each guest's Proxmox **Notes** field carries a short plaintext reference — the service
URL and port, the config path inside the container, and a pointer to where credentials
are kept (a password manager). It does **not** carry the credentials themselves.

Notes fields are visible through the web UI and API and are included in every config
backup, so anything written there should be treated as non-secret. The rule: Notes
describe *where things are*, never *what the secrets are*.

## GPU passthrough (media containers)

`ct-media-a` (Jellyfin) and `ct-media-b` (Plex) share the host's integrated GPU for
hardware transcoding: the render device is bind-mounted into the container and the
container's media user is put in the right group. Both containers can use it at once
(it's shared, not exclusive-passthrough), which is fine for a couple of simultaneous
transcodes.

## Bind mounts

The media containers bind-mount the bulk media library from the (currently offline)
media NAS. A bind mount is host-path → container-path and is set on the guest config,
so it has to exist on **whichever node runs the guest** — worth remembering for HA
failover.

## Configuration management, honestly

Application configuration inside the containers is currently **hand-managed** — set up
once, then patched in place. Ansible manages the *fleet* (patching, SSH, soon firewall
rules) but not per-app config. Bringing individual services under a role
(`deploy_docker_service`-style) is a direction, not a current state.
