# A set of ARM templates that deploys a hub-spoke VNet environment

## The Design

![VNet Diagram](/ReadmeFiles/Diagram.png)

### Hub-Spoke Architecture

* This solution deploys a single hub VNet along with a number of spoke VNets specified in the parameters file.  The intent is for the spokes to be identical, but there is some flexibility to have different subnet design for each spoke
* The Hub is peered with each spoke and allows gateway transit from the spokes
* There is an NSG attached to each subnet.  The level of NSG rule security restriction is configurable:
  * Low    = only the default NSG rules are deployed
  * Medium = inbound traffic is restricted but intra-subnet (traffic between VMs within the subnet) traffic is allowed
  * High   = microsegmentation, where traffic between VMs within the same subnet is restricted (except for the DCs subnet)

### Hub VNet

The hub VNet could have the following subnets:

* GatewaySubnet for the ExpressRoute and VNet gateways
* AzureFirewallSubnet for the Azure Firewall (optional)
* AzureBastionSubnet for the Azure Bastion (optional)
* A subnet for DCs
* A subnet for JumpHosts (optional)
* An additional subnet 1 (optional)
* An additional subnet 2 (optional)
* An additional subnet 3 (optional)
* An additional subnet 4 (optional)

### Spoke VNet(s)

This soltion deploys spokes that could have the following subnuts:

* AzureBastionSubnet for the Azure Bastion (optional)
* A subnet for the application gateways (optional)
* An additional subnet 1
* An additional subnet 2 (optional)
* An additional subnet 3 (optional)

### Network Security Groups (NSGs)

* Medium security configures three NSG rules on all subnets:
  * Allow intra-subnet traffic
  * Allow inbund RDP from the JumpHosts subnet (if that subnet is deployed)
  * Deny inbound traffic from VirtualNetwork
* High security does not deploy the NSG rule that allows intra-subnet traffic
* Both Medium and High security deploy the following NSG rules:
  * The DCs subnet allows inbound ports and protocols as specified [in the Microsoft documentation](https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#active-directory-local-security-authority)
  * If the AzureBastion is deployed in any VNet an NSG rule is deployed allowing RDP from the Azure Bastion subnet

### Role-Based Access Control (RBAC)

### Resource Locks

### Forced Naming Convention

This solution uses the following naming convention:

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

## Using the Solution

### General Instructions

This solution must be deployed to an existing resource group in an existing subscription(s).  The foreign resource group(s) must exist and be in the same region as the resource group being deployed to.  Also, the the user deploying the solution must have at least contributor access to the remote resource group or the deployment will fail (technically the deployment will not pass validation).

This solution will only deploy the necessary networking components, not any VMs.

### Pre-Requisites

### Subscription and resource groups

Azure deployments must be deployed to an existing resource group in an existing subecription.  The hub VNet will be deployed to this subecription/resource group combination. The spoke VNet(s) can be deployed to any existing subscription/resource group (requires at least contributor access). 







#### Network Security Groups (NSGs)

### Naming convention used by this solution

