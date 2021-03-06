$Title = "[Hosts] Syslog"
$Header = "[Hosts] Syslog Issues"
$Display = "Table"
$Author = "Jonathan Medd, Dan Barr, Dario Doerflinger"
$PluginVersion = 1.7
$PluginCategory = "vSphere"

# Start of Settings 
# The Syslog server(s) which should be set on your hosts (comma-separated)
$SyslogServer = "udp://FQDNofSYSLOG.domain.com"
# End of Settings

# Update settings where there is an override
$SyslogServer = Get-vCheckSetting $Title "SyslogServer" $SyslogServer

$SyslogResults = @()
foreach ($ESXi in $VMH) {
    if (($ESXi.ExtensionData.Summary.Config.Product.Name -eq "VMware ESXi") -and($ESXi.ConnectionState -match "Connected|Maintenance")) {
        $SyslogESXi = ($ESXi | Get-VMHostSysLogServer).Host -join ','
        $SyslogsettingESXi = (($ESXi | Get-AdvancedSetting -Name Syslog.global.logHost).Value.ToString()).Split(":")[0]

        $SyslogRuntime = New-Object -TypeName PSObject
        $SyslogRuntime | Add-Member -MemberType NoteProperty -Name "ESXi Host" -Value $ESXi.Name
        $SyslogRuntime | Add-Member -MemberType NoteProperty -Name "Syslogserver" -Value $SyslogESXi
        $SyslogRuntime | Add-Member -MemberType NoteProperty -Name "Syslogsetting" -Value $SyslogsettingESXi

        $SyslogResults += $SyslogRuntime | Where-object {((($_.SyslogServer -join ',') -ne $SyslogServer) -and ($_.SyslogSetting -ne $SyslogServer))}
    }
}
$SyslogResults

#@($VMH.Where({{($_.ExtensionData.Summary.Config.Product.Name -eq 'VMware ESXi') -and ($_.ConnectionState -eq 'Connected')} | Select-Object Name,@{Name='SyslogServer';Expression = {($_ | Get-VMHostSysLogServer).Host}},@{Name='SyslogSetting';Expression = {($_ | Get-AdvancedSetting -Name Syslog.Local.DatastorePath).Value| Where-Object {$_ -ne $NULL}}} | Where-Object {($_.SyslogServer -join ',') -ne $SyslogServer -and $_.SyslogSetting -ne $SyslogServer}}))

# Change Log
## 1.2 : Added support for multiple (comma-delimited) syslog servers; only report on connected hosts
## 1.3 : Added setting into comment
## 1.4 : Changed advanced parameter
## 1.5 : changed entire logic (hopefully runs faster)
## 1.6 : added hostname to new logic and removed old logic
## 1.7 : added "-join ',' to sysloghost value"

$Comments = "The following hosts do not have the correct Syslog settings ($($SyslogServer)) which may cause issues if ESXi hosts experience issues and logs need to be investigated"
