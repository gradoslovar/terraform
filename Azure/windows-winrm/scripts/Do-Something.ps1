# Disable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $true

# # RDP HTTPS
# New-NetFirewallRule -DisplayName "443 for RDP" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
# Set-ItemProperty -Path 'HKLM:\system\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber -Value 443

New-Item -Path 'C:\Nenad' -ItemType Directory