# Semaphore project bootstrap scripts

Run **on the control container**, after Semaphore is installed and the admin user exists
(`../../docs/semaphore.md` steps 1–4). They drive the Semaphore API on `127.0.0.1:3000`.

```bash
./01-configure-project.sh '<admin-password>'   # project, keys, repo, inventory, env, templates
python3 02-templates.py    '<admin-password>'  # (re)create the 4 non-ping templates — idempotent
python3 03-schedules.py     '<admin-password>' # the 2 cron schedules + a validation Ping run
```

They assume project id `1` (the first project). Re-running `01` will error on objects
that already exist — read past those. `02` skips templates that already exist.

These are a record of how the live instance was built; the canonical description is the
table in `docs/semaphore.md` §6, which you can also click through by hand.
