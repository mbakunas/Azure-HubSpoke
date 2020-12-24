$parametersFile = "$env:USERPROFILE\Documents\GitHub\Azure-HubSpoke\Archived\JSON.json"
$defaultSubscriptionId = 'f0bb6c48-80fd-445c-98cb-c38b5f817d52'
$defaultResourceGroup = 'HubSpoke-01'

$deliverableDataFilePath = "$env:USERPROFILE\Documents\GitHub\Azure-HubSpoke\PowerShell\deliverableData.csv"

# load the output file
$output = Get-Content $parametersFile | Out-String | ConvertFrom-Json

# hub
$csvOutput = '"' + $output[0].name + '","' + $output[0].addressSpace + '"'
Add-Content -Path $deliverableDataFilePath -Value $csvOutput
foreach ($subnet in ($output[0].subnets | Get-Member -MemberType NoteProperty)) {
    $name = $subnet.Name
    $output[0].subnets.$name
    
}
