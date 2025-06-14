# Network Diagram

This diagram illustrates the logical network topology and interconnections of the main components within the homelab.

```mermaid
graph TD
    subgraph Internet
        ISP --> Router[Eero Mesh 6 Router];
    end

    subgraph Home Network
        Router --> Switch[TP-Link SG108S Switch];
        Router --> WiFiClients(Wireless Clients);
    end

    subgraph Homelab Rack
        Switch --> ThinkCentre(ThinkCentre M720q<br>_Proxmox Host_);
        Switch --> QNAP[QNAP TS-230 NAS];
        Switch --> MacMini(Mac Mini<br>_Jump Server_);
        Switch --> Pihole(Pi-hole<br>_DNS/Adblock_);
        Switch --> UptimeKuma(UptimeKuma<br>_Monitoring_);
        Switch --> Portainer(Portainer<br>_Container Mgmt_);
        Switch --> VSCodeServer(VS Code Server<br>_Remote IDE_);
        Switch --> Plex(Plex Media Server);
        Switch --> QBittorrent(QBittorrent);

        ThinkCentre -- "SATA/PCIe" --> Oimaster(Oimaster HE-2006<br>_SSD Enclosure_);
        Oimaster -- "SSDs" --> MSI_SSDs[MSI Spatium SSDs];

        Pi4(Raspberry Pi 4<br>_Home Assistant_) -- "USB" --> ZigbeeDongle[Sonoff Zigbee Dongle];
        Pi4 -- "Ethernet" --> Switch;

        HiveHub(Hive Hub) -- "Ethernet" --> Switch;

        ESP32(ESP32 eInk Display) -- "WiFi" --> Router;

        USBCharger(6-Port USB Charger) --> Pi4;
        USBCharger --> HiveHub;
        USBCharger --> ESP32;

        UPS(APC Back-UPS) -- Power --> ThinkCentre;
        UPS -- Power --> Switch;
        UPS -- Power --> Router;
        UPS -- Power --> QNAP;
        UPS -- Power --> PDUs(Rack PDUs);
    end

    subgraph Services & Access
        Router -- "DNS Queries" --> Pihole;
        WiFiClients -- "Access" --> Router;
        MacMini -- "SSH/Web" --> ThinkCentre;
        MacMini -- "SSH/Web" --> Pihole;
        MacMini -- "SSH/Web" --> UptimeKuma;
        MacMini -- "SSH/Web" --> Portainer;
        MacMini -- "SSH/Web" --> VSCodeServer;
        MacMini -- "Web Access" --> Plex;
        MacMini -- "Web Access" --> QBittorrent;
        MacMini -- "Web Access" --> HomeAssistant[Home Assistant];
        HomeAssistant -- "Control" --> ZigbeeDongle;
        HomeAssistant -- "Control" --> HiveHub;
        HomeAssistant -- "Control" --> Ecovacs[Ecovacs Integration];
        HomeAssistant -- "Control" --> Ring[Ring Integration];
        HomeAssistant -- "Control" --> OctopusEnergy[Octopus Energy Integration];
        HomeAssistant -- "Control" --> LGWebOS[LG webOS TV Integration];
        HomeAssistant -- "Control" --> Tuya[Tuya Integration];
        Plex -- "Read Media" --> QNAP;
        QBittorrent -- "Write Media" --> QNAP;
        ThinkCentre -- "Run VMs/LXCs" --> Pihole;
        ThinkCentre -- "Run VMs/LXCs" --> UptimeKuma;
        ThinkCentre -- "Run VMs/LXCs" --> Portainer;
        ThinkCentre -- "Run VMs/LXCs" --> VSCodeServer;
        ThinkCentre -- "Run VMs/LXCs" --> Plex;
        ThinkCentre -- "Run VMs/LXCs" --> QBittorrent;
    end

    classDef hardware fill:#f9f,stroke:#333,stroke-width:2px;
    class ThinkCentre,QNAP,MacMini,Pi4,Router,Switch,Oimaster,MSI_SSDs,UPS,USBCharger,ZigbeeDongle,HiveHub,ESP32,PDUs hardware;

    classDef software fill:#9cf,stroke:#333,stroke-width:2px;
    class Pihole,UptimeKuma,Portainer,VSCodeServer,Plex,QBittorrent,HomeAssistant,Ecovacs,Ring,OctopusEnergy,LGWebOS,Tuya software;
