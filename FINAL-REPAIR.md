# Network adapter recovery

```powershell
.\Repair-NetworkAdapterHealth.ps1 -Action Diagnose
.\Repair-NetworkAdapterHealth.ps1 -Action StartNetworkServices -WhatIf
.\Repair-NetworkAdapterHealth.ps1 -Action FlushDns -Confirm
```

Created by **Dewald Pretorius**. The workflow starts stopped DHCP, DNS Client and Network Location Awareness services or clears DNS cache. It does not reset adapters or rewrite IP settings.
