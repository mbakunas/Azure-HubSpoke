$parametersFile = "$env:USERPROFILE\Documents\GitHub\Azure-HubSpoke\Archived\JSON.json"
$defaultSubscriptionId = 'f0bb6c48-80fd-445c-98cb-c38b5f817d52'
$defaultResourceGroup = 'HubSpoke-01'

$deliverableDataFilePath = "$env:USERPROFILE\Documents\GitHub\Azure-HubSpoke\PowerShell\deliverableData.csv"

# load the output file
$output = Get-Content $parametersFile | Out-String | ConvertFrom-Json

# build the output object
# hub

$csvOutput = @(
    [PSCustomObject]@{
        Column1 = 'VNet Name'
        Column2 = 'VNet Address Space'
        Column3 = 'Subscription ID'
        Column4 = 'Resource Group'
    }
)

$csvOutput += [PSCustomObject]@{
        Column1 = $output[0].name
        Column2 = $output[0].addressSpace
        Column3 = $output[0].subscriptionId
        Column4 = $output[0].resourceGroup
    }

$csvOutput += [PSCustomObject]@{
        Column1 = $null
    }
$csvOutput += [PSCustomObject]@{
        Column1 = $null
    }

# hub subnets
$csvOutput += @(
    [PSCustomObject]@{
        Column1 = 'Subnet Name'
        Column2 = 'Subnet Address Space'
        Column3 = 'Subnet Address Range'
        Column4 = 'Subnet Description'
    }
)
foreach ($subnet in ($output[0].subnets | Get-Member -MemberType NoteProperty)) {
    $name = $subnet.Name
    $tmpOutput = [PSCustomObject]@{
        Column1 = $output[0].subnets.$name.name
        Column2 = $output[0].subnets.$name.addressSpace
        Column3 = Get-IPrangeStartEnd -ip ($output[0].subnets.$name.addressSpace).Split('/')[0] -cidr ($output[0].subnets.$name.addressSpace).Split('/')[1]
    }
    $csvOutput += $tmpOutput
}

$csvOutput += [PSCustomObject]@{
        Column1 = $null
    }
$csvOutput += [PSCustomObject]@{
        Column1 = $null
    }


# spoke(s)

for ($i = 1; $i -lt $output.Count; $i++) {
    $csvOutput += @(
        [PSCustomObject]@{
            Column1 = 'VNet Name'
            Column2 = 'VNet Address Space'
            Column3 = 'Subscription ID'
            Column4 = 'Resource Group'
        }
    )
    $csvOutput += @(
        [PSCustomObject]@{
            Column1 = $output[$i].name
            Column2 = $output[$i].addressSpace
            Column3 = $output[$i].subscriptionId
            Column4 = $output[$i].resourceGroup
        }
    )
    $csvOutput += [PSCustomObject]@{
            Column1 = $null
        }

    #spoke subnets
    $csvOutput += @(
        [PSCustomObject]@{
            Column1 = 'Subnet Name'
            Column2 = 'Subnet Address Space'
            Column3 = 'Subnet Address Range'
            Column4 = 'Subnet Description'
        }
    )
    foreach ($subnet in ($output[$i].subnets | Get-Member -MemberType NoteProperty)) {
        $name = $subnet.Name
        $tmpOutput = [PSCustomObject]@{
            Column1 = $output[$i].subnets.$name.name
            Column2 = $output[$i].subnets.$name.addressSpace
            Column3 = Get-IPrangeStartEnd -ip ($output[$i].subnets.$name.addressSpace).Split('/')[0] -cidr ($output[$i].subnets.$name.addressSpace).Split('/')[1]
        }
        $csvOutput += $tmpOutput
    }
    $csvOutput += [PSCustomObject]@{
        Column1 = $null
    }
    $csvOutput += [PSCustomObject]@{
            Column1 = $null
        }
}

# write output to file

$csvOutput | Export-Csv -Path $deliverableDataFilePath -NoTypeInformation





function Get-IPrangeStartEnd 
{ 
    <#  
      .SYNOPSIS   
        Get the IP addresses in a range  
      .EXAMPLE  
       Get-IPrangeStartEnd -start 192.168.8.2 -end 192.168.8.20  
      .EXAMPLE  
       Get-IPrangeStartEnd -ip 192.168.8.2 -mask 255.255.255.0  
      .EXAMPLE  
       Get-IPrangeStartEnd -ip 192.168.8.3 -cidr 24  
    #>  
      
    param (  
      [string]$start,  
      [string]$end,  
      [string]$ip,  
      [string]$mask,  
      [int]$cidr  
    )  
      
    function IP-toINT64 () {  
      param ($ip)  
      
      $octets = $ip.split(".")  
      return [int64]([int64]$octets[0]*16777216 +[int64]$octets[1]*65536 +[int64]$octets[2]*256 +[int64]$octets[3])  
    }  
      
    function INT64-toIP() {  
      param ([int64]$int)  
 
      return (([math]::truncate($int/16777216)).tostring()+"."+([math]::truncate(($int%16777216)/65536)).tostring()+"."+([math]::truncate(($int%65536)/256)).tostring()+"."+([math]::truncate($int%256)).tostring() ) 
    }  
      
    if ($ip) {$ipaddr = [Net.IPAddress]::Parse($ip)}  
    if ($cidr) {$maskaddr = [Net.IPAddress]::Parse((INT64-toIP -int ([convert]::ToInt64(("1"*$cidr+"0"*(32-$cidr)),2)))) }  
    if ($mask) {$maskaddr = [Net.IPAddress]::Parse($mask)}  
    if ($ip) {$networkaddr = new-object net.ipaddress ($maskaddr.address -band $ipaddr.address)}  
    if ($ip) {$broadcastaddr = new-object net.ipaddress (([system.net.ipaddress]::parse("255.255.255.255").address -bxor $maskaddr.address -bor $networkaddr.address))}  
      
    if ($ip) {  
      $startaddr = IP-toINT64 -ip $networkaddr.ipaddresstostring  
      $endaddr = IP-toINT64 -ip $broadcastaddr.ipaddresstostring  
    } else {  
      $startaddr = IP-toINT64 -ip $start  
      $endaddr = IP-toINT64 -ip $end  
    }  
      
     #$temp=""|Select start,end 
     #$temp.start=INT64-toIP -int $startaddr 
     #$temp.end=INT64-toIP -int $endaddr
     $tempStart = INT64-toIP -int $startaddr
     $tempEnd = INT64-toIP -int $endaddr
     return "$tempStart - $tempEnd"
}