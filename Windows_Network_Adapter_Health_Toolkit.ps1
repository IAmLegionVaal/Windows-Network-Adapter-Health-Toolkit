#requires -Version 5.1
[CmdletBinding()]
param([string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Network_Adapter_Reports'}
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$adapters=Get-NetAdapter -ErrorAction SilentlyContinue|Select-Object Name,InterfaceDescription,Status,LinkSpeed,MacAddress,DriverDescription,DriverVersion
$configs=Get-NetIPConfiguration -ErrorAction SilentlyContinue|ForEach-Object{[PSCustomObject]@{InterfaceAlias=$_.InterfaceAlias;IPv4Address=($_.IPv4Address.IPAddress -join ', ');IPv4Gateway=($_.IPv4DefaultGateway.NextHop -join ', ');DnsServers=($_.DNSServer.ServerAddresses -join ', ')}}
$adapters|Export-Csv (Join-Path $OutputPath "adapters_$stamp.csv") -NoTypeInformation -Encoding UTF8
$configs|Export-Csv (Join-Path $OutputPath "ip_configuration_$stamp.csv") -NoTypeInformation -Encoding UTF8
@{Computer=$env:COMPUTERNAME;Generated=Get-Date;Adapters=$adapters;Configuration=$configs}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputPath "network_adapter_report_$stamp.json") -Encoding UTF8
$html="<h1>Network Adapter Health - $env:COMPUTERNAME</h1><p>Generated $(Get-Date)</p><h2>Adapters</h2>$($adapters|ConvertTo-Html -Fragment)<h2>IP Configuration</h2>$($configs|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'Network Adapter Health'|Set-Content (Join-Path $OutputPath "network_adapter_report_$stamp.html") -Encoding UTF8
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
