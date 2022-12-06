Function Find-PsExec {
    <#
        .SYSNOPSIS
            Search for unsigned executables in %SYSTEMROOT% which are also a service executable .
          
         .DESCRIPTION
            Impacket's psexec.py drops an executable in the ADMIN$ share which is mapped to the %SYSTEMROOT% environment variable then
            creates and starts a service to run the executable. This script looks for suspicious binaries and checks the registry to see
            if they're registered as a service executable. It also correlates events from the security log with the executable's creation time.
        
        .PARAMETER Computername
            Return related event logs
        
        .EXAMPLE
            Find-PsExec
            
            Description
            -----------
            Find unsigned executables in %SYSTEMROOT% which are called by a service. Outputs the registry entries for the service.
        
        .EXAMPLE
            Find-PsExec -GetLogs
            
            Description
            -----------
            Query the security log for EIDs 4624 (logon session created) and 4672 (special privileges assigned to logon) 
            close to the time of the executable's creation.
    #>
    [cmdletbinding()]
    Param (
        [parameter()]
        [switch]$GetLogs
    )

    $Executables = Get-ChildItem -Path $env:SYSTEMROOT *.exe

    $Unsigned = $Executables | ForEach-Object { if ((Get-AuthenticodeSignature $_.FullName).Status -eq 'notsigned') {$_}}

    $AllServices = (Get-Service).Name

    $RegEntry = $AllServices | ForEach-Object {Get-ItemProperty -ErrorAction Ignore "HKLM:\SYSTEM\CurrentControlSet\Services\$($_)"}

    $Services = $RegEntry | Where-Object {$_.ImagePath -match "$([Regex]::Escape($env:SYSTEMROOT))\\\w+\.exe$"}

    Write-Host "`n[+] Enumerating Services" -ForegroundColor Cyan

    ForEach ($Exe in $Unsigned) {
        if($Exe.FullName -in $Services.ImagePath) {
            $Service = $Services | Where-Object {$Exe.FullName -eq $_.ImagePath}
            "`n$($Exe.FullName) is an executable for the service $($Service.DisplayName)`n`n"
            ($Service | Out-String).Trim()

        }
    }

    if ($GetLogs) {

        Write-Host "`n[+] Enumerating Log Entries`n" -ForegroundColor Cyan

        ForEach ($Exe in $Unsigned) {
            if($Exe.FullName -in $Services.ImagePath) {
                $CreatedAt = $Exe.CreationTime
                $Before = $CreatedAt.AddSeconds(5)
                $After = $CreatedAt.AddSeconds(-5)
                $Logs = Get-Winevent -FilterHashtable @{LogName='security'; Id=4624,4672; StartTime=$after; EndTime=$before} -ErrorAction Ignore
                $Logs | ForEach-Object {
                            $Event = ([xml]($_).ToXml()).event.eventdata.data | Where-Object {
                                                                                    $_.Name -in
                                                                                    @(
                                                                                    'SubjectUserSid',
                                                                                    'SubjectUsername',
                                                                                    'SubjectDomainName',
                                                                                    'TargetUserSid',
                                                                                    'TargetUsername',
                                                                                    'TargetDomainName',
                                                                                    'IpAddress'
                                                                                    )
                                                                                }

                              (@(
                              [pscustomobject]@{Name='TimeCreated'; '#text'=$_.timecreated}
                              [pscustomobject]@{Name='Id'; '#text'=$_.id}
                              ) + $Event | Select @{N='Property'; E='Name'}, @{N='Value'; E='#text'} | Out-String).Trim()+"`n`n"
                        }
            }
        }
    }
}

# Example Usage
# PS C:\Users\Administrator\Documents> find-psexec -getlogs

# [+] Enumerating Services

# C:\WINDOWS\FDqKZPgQ.exe is an executable for the service kUza

# Type         : 16
# Start        : 3
# ErrorControl : 0
# ImagePath    : C:\WINDOWS\FDqKZPgQ.exe
# DisplayName  : kUza
# ObjectName   : LocalSystem
# PSPath       : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\kUza
# PSParentPath : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services
# PSChildName  : kUza
# PSDrive      : HKLM
# PSProvider   : Microsoft.PowerShell.Core\Registry

# C:\WINDOWS\OCPMQXPa.exe is an executable for the service oTjL

# Type         : 16
# Start        : 3
# ErrorControl : 0
# ImagePath    : C:\WINDOWS\OCPMQXPa.exe
# DisplayName  : oTjL
# ObjectName   : LocalSystem
# PSPath       : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\oTjL
# PSParentPath : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services
# PSChildName  : oTjL
# PSDrive      : HKLM
# PSProvider   : Microsoft.PowerShell.Core\Registry

# [+] Enumerating Log Entries

# Property          Value
# --------          -----
# TimeCreated       12/6/2022 4:47:39 AM
# Id                4624
# SubjectUserSid    S-1-0-0
# SubjectUserName   -
# SubjectDomainName -
# TargetUserSid     S-1-5-21-1791094074-1363918840-4199337083-500
# TargetUserName    Administrator
# TargetDomainName  SECNOTES
# IpAddress         10.10.14.31

# Property          Value
# --------          -----
# TimeCreated       12/6/2022 4:47:39 AM
# Id                4672
# SubjectUserSid    S-1-5-21-1791094074-1363918840-4199337083-500
# SubjectUserName   Administrator
# SubjectDomainName SECNOTES

# Property          Value
# --------          -----
# ...[snip]...

# We can see a login from 10.10.14.31 as administrator at the time FDqKZPgQ.exe was dropped into ADMIN$. This was me psexec-ing into the box.
