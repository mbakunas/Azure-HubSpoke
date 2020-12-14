# Azure-Stuff

## Naming convention used by this solution

| Resource Type | Naming convention | Example |
| --------------| ----------------- | ------- |
| Virtual Network | [Region]-[HUB/SPOKE-PROD/SPOKE-NONPROD]-## | EastUS2-HUB-01 |
| Subnet | [Descriptive Text]-[Address Space] | Infra-10.64.0.192-27 |
| VNet Gateway | [VNet Name]-GW-# | EastUS2-HUB-01-GW-1 |
| Network Security Group | [Subnet Name]-NSG | Infra-10.64.0.192-27-NSG |
| Azure Bastion | [VNet Name]-Bastion | EastUS2-HUB-01-Bastion |
| Azure Firewall | [VNet Name]-Firewall | EastUS2-HUB-01-Firewall |
| IP Groups | [VNet Name]-[Subnet Name] | EastUS2-HUB-01-Infra-10.64.0.192-27 |
| Public IP Address | [Resource Name]-IP | EastUS2-HUB-01-Firewall-IP |
| Route Table |  |  |
| DDOS Protection Plan |  |  |
