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

The hub VNet has the following subnets:

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

This solution deploys spokes that with the following subnets:

* AzureBastionSubnet for the Azure Bastion (optional)
* A subnet for the application gateways (optional)
* An additional subnet 1
* An additional subnet 2 (optional)
* An additional subnet 3 (optional)

### Network Security Groups (NSGs)

* Medium security configures three NSG rules on all subnets:
  * Allow intra-subnet traffic
  * Allow inbound RDP from the JumpHosts subnet (if that subnet is deployed)
  * Deny inbound traffic from VirtualNetwork
* High security does not deploy the NSG rule that allows intra-subnet traffic
* Both Medium and High security deploy the following NSG rules:
  * The DCs subnet allows inbound ports and protocols as specified [in the Microsoft documentation](https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#active-directory-local-security-authority)
  * If the AzureBastion is deployed in any VNet an NSG rule is deployed allowing RDP from the Azure Bastion subnet to the rest of the VNet's subnets
* If the app gateway subnet is deployed in the spoke(s), the following rules are added to subnet 1:
  * Allow 80/443 inbound from the app gateway subnet
  * Allow AzureLoadBalancer inbound from the app gateway subnet

### Edge Security

#### Egress

Outbound edge security is handled by the Azure Firewall.  If deployed, a route table is deployed directing all Internet-bound traffic to the Azure Firewall which has the following default rules:
* Allow AzureCloud
* Allow WindowsUpdate

If the firewall is deployed, there are IP groups deployed that represent the following:
* The entire hub and spoke address space
* The hub address space
* Each spoke address space
* Each hub subnet
* Each spoke subnet

#### Ingress

The intent is that the inbound edge security will be handled by app gateways running WAF, hence the option for an app gateway subnet in the spokes.

### Role-Based Access Control (RBAC)

RBAC is set as follows:
* A specified AAD group has VM contributor to the spoke VNet(s).  The intention is that the application development teams and anyone else needing to deploy VMs to the spoke VNet are members of this group
* A specified AAD group has VM contributor to the hub subnets.  The intention is that the server team or anyone needing to deploy infrastructure to the hub are members of this group
* An optional specified AAD group that has VM contributor to the DCs subnet.  If specified this group, instead of the above group, will have VM contributor to the DCs subnet.  The intention is that the identity team (or whichever team is responsible for the DCs) are members of this group

### DDoS Protection

This solution optionally deploys a DDoS Protection Plan.  Since a [single DDoS Protection Plan can be used across multiple subscriptions in a tenant](https://azure.microsoft.com/en-us/pricing/details/ddos-protection/), the solution can use an existing Plan.

### Resource Locks

The last step in the deployment is to place a DoNotDelete lock on all the resource groups to which this solution deploys resources.  Since only a [single DDOS Protection Plan is required per tenant](https://azure.microsoft.com/en-us/pricing/details/ddos-protection/), this solution can use an existing plan.

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
| IP Groups | [VNet Name]-[Subnet Name]-IpGroup | HUB-EastUS2-01-Infra-10.64.0.192-27-IpGroup |
| Public IP Address | [Resource Name]-IP | HUB-EastUS2-01-Firewall-IP |

## Using the Solution

### Limitations

This set of templates is not truly idempotent in that if VMs are attached to any of the VNets (or the ExpressRoute gateway) a redeployment will fail.  This situation is due to the way the VNets and subnets are deployed.  In order to make some of the subnets optional, the subnets are deployed as separate resources from the VNet; the VNets are deployed without any subnets.  A subsequent redeploy will attempt to delete the subnets, which will fail if anything is attached.

### Pre-Requisites

#### Subscription and resource groups

Azure deployments must be deployed to an existing resource group in an existing subecription.  The hub VNet will be deployed to this subscription/resource group combination. The spoke VNet(s) can be deployed to any existing subscription/resource group (requires at least contributor access). 
