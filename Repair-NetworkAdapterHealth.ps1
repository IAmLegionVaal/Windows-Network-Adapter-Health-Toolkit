#requires -Version 5.1
<# Created by Dewald Pretorius. Guarded local network service and DNS recovery. #>
[CmdletBinding(SupportsShouldProcess=$true)]
param([ValidateSet('Diagnose','StartNetworkServices','FlushDns')][string]$Action='Diagnose',[string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Network_Adapter_Repair'))
$ErrorActionPreference='Stop';$services=@('Dhcp','Dnscache','NlaSvc');New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null;$stamp=Get-Date -Format yyyyMMdd_HHmmss
$before=[ordered]@{Adapters=@(Get-NetAdapter|Select-Object Name,Status,LinkSpeed,MacAddress,InterfaceDescription);Services=@($services|ForEach-Object{Get-Service $_|Select-Object Name,Status,StartType})};$before|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputPath "before_$stamp.json")
if($Action-eq'Diagnose'){exit 0}
try{if($Action-eq'StartNetworkServices'-and$PSCmdlet.ShouldProcess(($services-join', '),'Start stopped services')){foreach($n in $services){$svc=Get-Service $n;if($svc.Status-eq'Stopped'){Start-Service $n}}}elseif($Action-eq'FlushDns'-and$PSCmdlet.ShouldProcess('DNS client cache','Clear')){Clear-DnsClientCache}}catch{Write-Error $_;exit 5}
$after=@(Get-NetAdapter|Select-Object Name,Status,LinkSpeed);$after|ConvertTo-Json|Set-Content (Join-Path $OutputPath "after_$stamp.json");if(@($after|Where-Object Status -eq 'Up').Count-eq 0){exit 6};exit 0
