# Semaphore

[Semaphore CE](https://github.com/semaphoreui/semaphore) - a single Go binary - is the
web UI for the lab's Ansible automation. It runs in [`ct-ansible`](ansible.md) alongside
`ansible-core`.

## What it provides

* **Task templates** - one per playbook (`ping`, `patch-guests`, `patch-guests --check`,
  `patch-hosts`, `reboot-hosts`), runnable with one click.
* **Cron schedules** - containers patched Saturdays 02:00, hypervisors the first Sunday
  of the month 03:00. The reboot job is deliberately unscheduled.
* **Run history** - full stdout of every past run, kept indefinitely. This *is* the run
  log; `ansible.cfg` sets no `log_path` on purpose.
* **Failure alerts** - for the case where a playbook errors before its own notify step.

## Not Terraform

Earlier notes claimed Terraform orchestration - that was never set up. Semaphore here
drives Ansible only.

## How it's wired

* **SQLite** backend (2.19 dropped BoltDB), systemd service, UI on `:3000`.
* **Static YAML inventory** pasted into the UI - because the real `inventory/hosts.yml`
  is gitignored and not in the repo clone. Semaphore encrypts it at rest, so its config
  file and DB are backed up together by the nightly job.
* Repo pulled from `file:///opt/ansible` inside the container.

Full build + configuration steps: [`ansible/docs/semaphore.md`](../ansible/docs/semaphore.md).
Design rationale: [automation](../docs/automation.md).

## Hardening notes

`:3000` is scoped to the management subnet as part of the [firewall](../docs/security.md)
rollout; Semaphore's TOTP 2FA for the admin account is on the list too.
