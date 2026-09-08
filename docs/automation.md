# Automation (Ansible + Semaphore)

All fleet-wide changes - OS patching today, more over time - run from **one dedicated
container** through **Ansible**, with **Semaphore** providing a web UI, schedules, and
run history. The playbooks and roles are version-controlled in
[`../ansible/`](../ansible/); that directory has its own
[operator README](../ansible/README.md).

## Why it exists

The lab used to patch its containers with a weekly cron on a hypervisor:

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/<third-party>/main/.../update-lxcs-cron.sh)"
```

That fetches whatever is at a third-party repo's `main` branch *at that moment* and runs
it as root on the hypervisor - no version pin, no checksum, no local copy, all output
discarded. Anyone who could land a commit in that repo (or intercept the fetch) would
get root on the cluster within a week. It also ran `apt dist-upgrade` in every container
with no pre-backup and no report.

The replacement keeps the convenience (scheduled, hands-off patching) and removes the
sharp edges: **code you control, under version control, with a pre-backup, a result
notification, and a full run log.**

## The control container

`ct-ansible` (VMID 109) - see [`software/ansible.md`](../software/ansible.md):

* **Unprivileged, minimal** Debian 13 LXC, 1 vCPU / 512 MB, `nesting=0,keyctl=0`,
  per-guest firewall on.
* **On `local-lvm`, not NFS** - so it still runs, and can still patch and rebuild the
  fleet, during a storage outage.
* **HA-managed** and on the nightly backup job - it is now important infrastructure.
* Holds a dedicated SSH keypair (`id_ed25519_ansible`, no passphrase - it runs
  unattended) that is authorised as **root** on every guest and on the peer node.
* It is the **single most sensitive guest in the lab**: whoever holds it holds root
  everywhere. Hardening reflects that (see [security](security.md)).

## How access is wired

```
   ct-ansible ──(SSH, key-only, from="<control IP>"-locked)──┬── every guest CT
        │                                                     └── pve-node-2
        └── pct exec (no SSH) ── used only by the bootstrap scripts on pve-node-1
```

* Each target's `authorized_keys` entry is locked with
  `from="<control IP>",no-agent-forwarding,no-port-forwarding,no-x11-forwarding`.
* Some guests shipped `AllowUsers ssh-user` in sshd, which blocks root *before* the key
  is checked. A drop-in (`/etc/ssh/sshd_config.d/20-ansible.conf`) adds
  `root@<control IP>` to the allow-list on those.
* The two bootstrap scripts
  ([`01-create-control-node.sh`](../ansible/bootstrap/01-create-control-node.sh),
  [`02-deploy-control-node-key.sh`](../ansible/bootstrap/02-deploy-control-node-key.sh))
  build the container and distribute the key. They run on a node as root and use
  `pct exec`, so no SSH is needed to bootstrap SSH.

## Repository layout

```
ansible/
├── ansible.cfg              # inventory path, ssh tuning, yaml stdout
├── inventory/
│   ├── hosts.example.yml    # committed - placeholder addresses, the group structure
│   └── hosts.yml            # gitignored - real addresses + webhook URL
├── roles/
│   ├── apt_upgrade/         # idempotent update+upgrade; tolerates a dead 3rd-party repo
│   ├── pve_node_patch/      # dist-upgrade a node in place; flag if a reboot is due
│   ├── pve_node_reboot/     # drain HA → reboot → wait quorum → un-drain (guarded)
│   └── notify_webhook/      # POST a short summary to the push webhook; never fatal
├── playbooks/
│   ├── group_vars/          # NOTE: beside the playbooks, not the inventory (see below)
│   ├── ping.yml
│   ├── patch-guests.yml
│   ├── patch-hosts.yml
│   └── reboot-hosts.yml
└── bootstrap/               # build + authorise the control container; recreate Semaphore objects
```

### Two non-obvious choices

* **`group_vars/` lives next to the playbooks.** Semaphore runs with its *own* static
  inventory path (because the real `hosts.yml` is gitignored and not in the clone), so
  inventory-adjacent `group_vars` wouldn't load. Beside the playbooks, they load whether
  the run comes from the CLI or from Semaphore.
* **No root `requirements.yml`.** `community.general` and `ansible.posix` come from the
  Debian `ansible` package. A root `requirements.yml` would make Semaphore pull newer
  major versions from Galaxy every run - and `community.general` ≥ 12 removed the `yaml`
  stdout callback, which would break the output format. The pinned reference list is
  kept at `ansible/docs/requirements.reference.yml` for a non-Debian control box.

## Semaphore

[Semaphore CE](https://github.com/semaphoreui/semaphore) - a single Go binary - runs in
the same container and gives Ansible:

* **task templates** (one per playbook), run with one click or on a schedule;
* **cron schedules** (see [patching](patching.md) for the specific times);
* **run history** with full per-run stdout, kept indefinitely - this is the run log,
  `ansible.cfg` deliberately sets no `log_path`;
* **failure alerts** for the case where a playbook errors *before* its own notify step.

It uses a SQLite backend (2.19 dropped BoltDB) and a static YAML inventory pasted into
the UI (encrypted at rest with `access_key_encryption` - so the config file and the DB
must be backed up together, which the nightly job does). Full build steps:
[`ansible/docs/semaphore.md`](../ansible/docs/semaphore.md).

## How a run flows

`patch-guests.yml`, end to end:

1. **Play 1** (once, on `pve-node-1`): `vzdump` the `backup_protected` containers in
   snapshot mode - a bad upgrade is one `pct rollback` away. Skippable with
   `-e pre_patch_backup=false`.
2. **Play 2** (all guests, `serial: 50%`): `apt-get update` (tolerating a dead
   third-party repo), simulate the upgrade to count packages, `apt dist-upgrade` with
   `needrestart` in batch mode to bounce affected services. Container reboots are
   **opt-in** (`-e allow_reboot=true`).
3. **Play 3** (localhost): build a compact per-guest summary and POST it to the webhook.

Every step records facts (`apt_changed`, `apt_upgraded_count`, `reboot_pending`,
`apt_repo_warnings`) that feed the summary, so the phone push tells you exactly which
guests changed and which want a reboot.

## Adding a host

1. Add it to `inventory/hosts.yml` under `lxc_guests` (and `backup_protected` if it's on
   the backup job).
2. Paste the updated inventory into Semaphore's static inventory too (the price of
   keeping `hosts.yml` out of git).
3. Authorise the control key on it -    `bootstrap/02-deploy-control-node-key.sh` (add the ID to `GUEST_IDS`), plus the
   `20-ansible.conf` sshd drop-in if the guest uses `AllowUsers`.
4. `ha-manager add ct:<id> --state started` and add it to the node-affinity rule.

A `community.general.proxmox` **dynamic inventory** (auto-discovers guests from the PVE
API, group membership from tags) would remove steps 1-2; it's a roadmap item.
