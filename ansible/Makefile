.PHONY: help deps lint ping check-guests patch-guests patch-hosts reboot-hosts

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'

deps:            ## (only needed on a non-Debian control node) install Galaxy collections
	ansible-galaxy collection install -r docs/requirements.reference.yml

lint:            ## syntax-check every playbook
	for p in playbooks/*.yml; do ansible-playbook "$$p" --syntax-check; done

ping:            ## connectivity + privilege check
	ansible-playbook playbooks/ping.yml

check-guests:    ## dry-run the container patch
	ansible-playbook playbooks/patch-guests.yml --check

patch-guests:    ## patch all containers (pre-backup + notify)
	ansible-playbook playbooks/patch-guests.yml

patch-hosts:     ## patch both hypervisors, no reboot
	ansible-playbook playbooks/patch-hosts.yml

reboot-hosts:    ## rolling reboot of the hypervisors (run when you can watch)
	ansible-playbook playbooks/reboot-hosts.yml
