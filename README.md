# A set of ARM templates that deploys a hub-spoke VNet environment.

This solution must be deployed to an existing resource group in an existing subscription.  The remote resource group must exist and be in the same region as the resource group being deployed to.  Also, the the user deploying the solution must have at least contributor access to the remote resource group or the deployment will fail (technically the deployment will not pass validation).

This solution will only deploy the necessary networking components, not any VMs.

![VNet Diagram](/ReadmeFiles/Diagram.png)

## General Instructions



## Hub VNet

### Subnets

The hub virtual that could have the following subnets:
<ol>
<li>GatewaySubnet for the ExpressRoute and VNet gateways</li>
<li>AzureFirewallSubnet for the Azure Firewall (optional)</li>
<li>AzureBastionSubnet for the Azure Bastion (optional)</li>
<li>A subnet for DCs</li>
<li>A subnet for JumpHosts (optional)</li>
<li>An additional subnet 1 (optional)</li>
<li>An additional subnet 2 (optional)</li>
<li>An additional subnet 3 (optional)</li>
<li>An additional subnet 4 (optional)</li>
</ol>

### Network Security Groups (NSGs)

## Spoke VNet(s)

### Subnets

This soltion deploys multiple spokes that could have the following subnuts:

<ol>
<li>AzureBastionSubnet for the Azure Bastion (optional)</li>
<li>A subnet for the application gateways (optional)</li>
<li>An additional subnet 1</li>
<li>An additional subnet 2 (optional)</li>
<li>An additional subnet 3 (optional)</li>
</ol>

### Network Security Groups (NSGs)

## Naming convention used by this solution

| Resource Type | Naming convention | Example |
| --------------| ----------------- | ------- |
| Virtual Network |[HUB/SPOKE-PROD/SPOKE-NONPROD]-[Region]-## | HUB-EastUS2-01 |
| Subnet | [Descriptive Text]-[Address Space] | Infra-10.64.0.192-27 |
| VNet Gateway | [VNet Name]-GW-# | HUB-EastUS2-01-GW-1 |
| Network Security Group | [Subnet Name]-NSG | Infra-10.64.0.192-27-NSG |
| Azure Bastion | [VNet Name]-Bastion | HUB-EastUS2-01-Bastion |
| Azure Firewall | [VNet Name]-Firewall | HUB-EastUS2-01-Firewall |
| IP Groups | [VNet Name]-[Subnet Name] | HUB-EastUS2-01-Infra-10.64.0.192-27 |
| Public IP Address | [Resource Name]-IP | HUB-EastUS2-01-Firewall-IP |
| Route Table |  |  |
| DDOS Protection Plan |  |  |
