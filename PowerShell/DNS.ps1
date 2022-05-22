Login-AzAccount -Tenant 0dedc571-3c56-411b-acad-e2bd5b567394 -Subscription 'Bakunas Sandbox 4'

$resourceGroupName = 'HubSpokeTest01'

Register-AzResourceProvider -ProviderNamespace Microsoft.Network

#page source:
#https://docs.microsoft.com/en-us/azure/dns/dns-private-resolver-get-started-powershell

# DNS resolver
New-AzDnsResolver -Name mydnsresolver -ResourceGroupName myresourcegroup -Location westcentralus -VirtualNetworkId "/subscriptions/<your subs id>/resourceGroups/myresourcegroup/providers/Microsoft.Network/virtualNetworks/myvnet"

$dnsResolver = Get-AzDnsResolver -Name HubSpokeTestResolver01 -ResourceGroupName $resourceGroupName
$dnsResolver.ToJsonString()

#inbound endpoint
$ipconfig = New-AzDnsResolverIPConfigurationObject -PrivateIPAllocationMethod Dynamic -SubnetId /subscriptions/<your sub id>/resourceGroups/myresourcegroup/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/snet-inbound
New-AzDnsResolverInboundEndpoint -DnsResolverName mydnsresolver -Name myinboundendpoint -ResourceGroupName myresourcegroup -Location westcentralus -IpConfiguration $ipconfig

$inboundEndpoint = Get-AzDnsResolverInboundEndpoint -Name myinboundendpoint -DnsResolverName mydnsresolver -ResourceGroupName myresourcegroup
$inboundEndpoint.ToJsonString()

#outbound endpoint
New-AzDnsResolverOutboundEndpoint -DnsResolverName mydnsresolver -Name myoutboundendpoint -ResourceGroupName myresourcegroup -Location westcentralus -SubnetId /subscriptions/<your sub id>/resourceGroups/myresourcegroup/providers/Microsoft.Network/virtualNetworks/myvnet/subnets/snet-outbound

$outboundEndpoint = Get-AzDnsResolverOutboundEndpoint -Name myoutboundendpoint -DnsResolverName mydnsresolver -ResourceGroupName myresourcegroup
$outboundEndpoint.ToJsonString()

#ruleset
New-AzDnsForwardingRuleset -Name myruleset -ResourceGroupName myresourcegroup -DnsResolverOutboundEndpoint $outboundendpoint -Location westcentralus

$dnsForwardingRuleset = Get-AzDnsForwardingRuleset -Name myruleset -ResourceGroupName myresourcegroup
$dnsForwardingRuleset.ToJsonString()

Remove-AzDnsForwardingRuleset -Name 'RuleSet01' -ResourceGroupName $resourceGroupName

#VNet link
$vnet = Get-AzVirtualNetwork -Name myvnet -ResourceGroupName myresourcegroup 
$vnetlink = New-AzDnsForwardingRulesetVirtualNetworkLink -DnsForwardingRulesetName $dnsForwardingRuleset.Name -ResourceGroupName myresourcegroup -VirtualNetworkLinkName "vnetlink" -VirtualNetworkId $vnet.Id -SubscriptionId <your sub id>

$virtualNetworkLink = Get-AzDnsForwardingRulesetVirtualNetworkLink -DnsForwardingRulesetName $dnsForwardingRuleset.Name -ResourceGroupName myresourcegroup 
$virtualNetworkLink.ToJsonString()

#2nd VNet link to ruleset
$vnet2 = New-AzVirtualNetwork -Name myvnet2 -ResourceGroupName myresourcegroup -Location westcentralus -AddressPrefix "12.0.0.0/8"
$vnetlink2 = New-AzDnsForwardingRulesetVirtualNetworkLink -DnsForwardingRulesetName $dnsForwardingRuleset.Name -ResourceGroupName myresourcegroup -VirtualNetworkLinkName "vnetlink2" -VirtualNetworkId $vnet2.Id -SubscriptionId <your sub id>

$vnet2 = Get-AzVirtualNetwork -Name 'Spoke-NonProd-EastUS2-01' -ResourceGroupName $resourceGroupName
$vnetLink2 = New-AzDnsForwardingRulesetVirtualNetworkLink -DnsForwardingRulesetName 'RuleSet01' -ResourceGroupName $resourceGroupName -VirtualNetworkLinkName "$($vnet2.name)-Link" -VirtualNetworkId $vnet2.Id
Get-AzDnsForwardingRulesetVirtualNetworkLink -DnsForwardingRulesetName 'RuleSet01' -ResourceGroupName $resourceGroupName

$virtualNetworkLink2 = Get-AzDnsForwardingRulesetVirtualNetworkLink -DnsForwardingRulesetName $dnsForwardingRuleset.Name -ResourceGroupName myresourcegroup 
$virtualNetworkLink2.ToJsonString()

#forwarding rules
$targetDNS1 = New-AzDnsResolverTargetDnsServerObject -IPAddress 11.0.1.4 -Port 53 
$targetDNS2 = New-AzDnsResolverTargetDnsServerObject -IPAddress 11.0.1.5 -Port 53 
$forwardingrule = New-AzDnsForwardingRulesetForwardingRule -ResourceGroupName myresourcegroup -DnsForwardingRulesetName myruleset -Name "contosocom" -DomainName "contoso.com." -ForwardingRuleState "Enabled" -TargetDnsServer @($targetDNS1,$targetDNS2)
