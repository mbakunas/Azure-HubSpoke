# connect to Azure
Connect-AzAccount # this is interactive

$defaultSubscriptionId = 'f0bb6c48-80fd-445c-98cb-c38b5f817d52'
$defaultResourceGroup = 'HubSpoke-01'

$parametersFile = "$env:USERPROFILE\Documents\GitHub\Azure-HubSpoke\HubSpoke-Deploy.test.parameters.json"





$context = Get-AzSubscription -SubscriptionId $defaultSubscriptionId
Set-AzContext $context


$dcResourceGroupName = 'DomainControllers01'

#
# load the parameters file and get the VNets
#
$params = Get-Content $parametersFile | Out-String | ConvertFrom-Json

$subRg = [Object[]]::new(($params.parameters.spokeDeploySubscriptionResourceGroup.value).Count)

# get the hub VNet
$hubVnet = Get-AzVirtualNetwork -name $params.parameters.hubVnetName.value -

$spokeVnets = [Object[]]::new(($params.parameters.spokeVnetName.value).Count)
for ($i = 0; $i -lt ($params.parameters.spokeVnetName.value).Count; $i++)
{
    Get-AzVirtualNetwork -name $params.parameters.spokeVnetName.value[$i]
}






$hubDcSubnetName = $params.parameters.hubSubnetDcName.value


# deploy the domain controller


$vmName
$vmSize
# admin name
# admin password
# domain users' password
# subnet ID
# dsc location
# AD DS domain name
# DC IP address

# add PDC to all VNets

# deploy 2nd DC

# add new DC to all VNets

# deploy member servers/app gateway(s)