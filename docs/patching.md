# Automated patching

The model is **"patch on schedule, notify-to-reboot"**: package updates land
automatically and without disruption; anything that needs a reboot is always a
deliberate, hands-on action.

This runs on the [Ansible + Semaphore](automation.md) control container. Three playbooks,
two schedules, one manual job.

## Schedule at a glance

| Job | Playbook | When | Reboots? |
|---|---|---|---|
| Patch containers | `patch-guests.yml` | weekly — **Sat 02:00** (`0 2 * * 6`) | no (opt-in) |
| Patch hypervisors | `patch-hosts.yml` | monthly — **1st Sun 03:00** (`0 3 1-7 * 0`) | **never** |
| Reboot hypervisors | `reboot-hosts.yml` | **manual only** | yes, one node at a time |
| Connectivity check | `ping.yml` | on demand | no |

Plus `unattended-upgrades` on each host and the control container for the security
pocket between scheduled runs.

## Patching the containers (`patch-guests.yml`)

Weekly. In order:

1. **Pre-backup.** `vzdump` the stateful containers (the `backup_protected` group) in
   snapshot mode, from `pve-node-1`. Rollback for a bad upgrade is then one command.
2. **Upgrade**, 50% of the fleet at a time (`serial: 50%`, `max_fail_percentage: 30`):
   `apt-get update` → simulate to count packages → `apt dist-upgrade` (with
   `force-confdef,force-confold` so it never blocks on a config prompt) →
   `needrestart -b` to restart services touched by a library bump.
3. **Notify.** A compact per-guest summary to the phone:
   `LXC patch — 3 updated, 1 reboot-pending` and a line per container.

Container "reboots" are almost always just a service needing a bounce after a
glibc/openssl update — `needrestart` handles that live. A true `pct reboot` is a
seconds-long operation and is **opt-in**: `-e allow_reboot=true`.

### A dead third-party repo doesn't stop the run

`apt-get update` returns `100` when *some* repos fail but others succeed. The
`apt_upgrade` role treats `100` as non-fatal, patches everything the working repos
provide, and flags `[repo warnings]` in the summary with the failing lines. Any other
failure (network down, dpkg lock) is still fatal. This came from a container whose
database vendor deleted a short-term-release repo out from under it — the fix was that
tolerance plus moving that container onto the vendor's LTS repo.

## Patching the hypervisors (`patch-hosts.yml`)

Monthly, `serial: 1` (one node at a time), `any_errors_fatal`. Per node it does
**exactly one thing: `apt dist-upgrade` in place.**

* **No reboot.** If the upgrade pulls a new kernel or sets `/var/run/reboot-required`,
  the run *reports* it — `PVE host patch — 1 node(s) need a reboot` — and stops there.
* **No HA drain.** Installing packages on a running node doesn't disturb its guests, and
  draining every guest to the other node and back just to run `apt` is both disruptive
  and self-defeating: the control container is itself an HA guest, so "evacuate this
  node" would migrate the playbook out from under itself. (This is exactly how the first
  version of this job hung. The drain logic moved to `reboot-hosts.yml` where it
  belongs.)

## Rebooting the hypervisors (`reboot-hosts.yml`, manual)

Run by hand, watching it, after `patch-hosts.yml` flags a reboot. `serial: 1`,
`any_errors_fatal`. Per node:

1. **Guard.** Find which node hosts the control container (`ha-manager status`). If it's
   *this* node, **fail immediately** with instructions — rebooting it would kill the
   run. Override only with `-e control_node_relocated=true` after moving it yourself.
2. **Decide.** Reboot only if `/var/run/reboot-required` exists or the running kernel is
   older than the newest installed one (`-e reboot_only_if_required=false` to force).
3. **Drain.** `ha-manager crm-command node-maintenance enable <node>`, then poll until
   no HA service is left on the node.
4. **Reboot**, wait for SSH + the pmxcfs socket.
5. **Wait for health.** Poll `pvecm status` for `Quorate: Yes`, then `wait_for` port
   8006 (the web UI / API).
6. **Un-drain.** `node-maintenance disable`; on the preferred node, poll until the
   guests have migrated back.

On this 2-node cluster the safe full-cluster reboot is:

```bash
ha-manager status | grep ct:109                              # where's the control container?
ansible-playbook playbooks/reboot-hosts.yml --limit <other>  # reboot the other node first
ha-manager migrate ct:109 <other>                            # move the control container
ansible-playbook playbooks/reboot-hosts.yml --limit <first> -e control_node_relocated=true
```

This is the by-hand kernel-upgrade procedure from a real maintenance window, turned into
code — including the part where you must not strand yourself.

## What a normal month looks like

* **Every Saturday 02:00** — containers patched, phone push: "N updated, 0
  reboot-pending". Nothing to do.
* **1st Sunday 03:00** — both nodes patched in place. Phone push either "0 nodes need a
  reboot" (done) or "1 node needs a reboot".
* **If a reboot was flagged** — pick a evening, run `reboot-hosts.yml` against each node
  in turn, watch the phone for the "rolling reboot complete" push. ~10 minutes,
  guests never all down at once.

## Verifying

```bash
# from the control container
ansible-playbook playbooks/ping.yml                     # everything reachable
ansible-playbook playbooks/patch-guests.yml --check     # dry-run the container patch
```

Or the equivalent template in Semaphore, whose run history holds the full log of every
past run.
