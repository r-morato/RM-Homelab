# Hive Hub - heating control

The manufacturer hub for the home's Hive smart heating (thermostat + schedule). Powered
from the rack's 6-port USB charger, sat on top of the rack to keep its radio clear of
the metal.

## Role

* Talks to the Hive thermostat and receiver over its own radio.
* Bridged into [Home Assistant](../software/homeassistant.md) via the Hive integration,
  so heating is part of presence- and schedule-driven automations rather than a
  separate app.
