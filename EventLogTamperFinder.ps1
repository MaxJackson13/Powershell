$EventLogNames = @('security','system','application')
$Pwsh = Get-WinEvent -ListLog 'windows powershell'
if ($Pwsh -ne $null) {
    $EventLogNames += 'windows powershell'
}

Function Invoke-wevtutilCheck() {
    param(
    [System.IO.FileInfo]$Path=$env:SYSTEMROOT
    )
    $a = Get-ChildItem -Recurse -Path $Path -Include wevtutil.exe -ErrorAction SilentlyContinue | 
                        Select FullName,LastAccessTime | 
                                Sort LastAccessTime
    return $a
}
Function Invoke-EventLogServiceCheck() {
    
    $ServiceDll = Get-ItemPropertyValue HKLM:\System\CurrentControlSet\Services\Eventlog ServiceDll
    $Signature = (Get-AuthenticodeSignature $ServiceDll).Status
    $Status = (Get-Service EventLog).Status
    
    $b = Get-WmiObject win32_service | Where-object {$_.Name -like '*eventlog*'} |
                                              Select-Object @{Name='Name';Expression={$_.Caption}},
                                                            @{Name='Status';Expression={$_.Status,$Status}},
                                                            @{Name='Command Line';Expression={$_.PathName}},
                                                            StartMode,
                                                            @{Name='Service Executable';Expression={$ServiceDll}},
                                                            @{Name='ServiceDll Signature';Expression={$Signature}}
    return $b                                                     
}

Function Format-FileSize() {
    Param ([int64]$size)
    If     ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
    ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
    ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
    ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
    ElseIf ($size -gt 0)   {[string]::Format("{0:0.00} B", $size)}
    Else                   {""}
}

Function Format-CimDate() {
    Param (
    [string]$Date
    )
    [System.Management.ManagementDateTimeConverter]::ToDateTime($Date)
}

Function Invoke-EventLogCheck() {
    param(
    [string]$LogNames=$EventLogNames
    )
    $c = Get-WmiObject -Class Win32_NTEventLogFile | Where-Object {$_.LogFileName -in $LogNames} |
                                                  Select-Object LogFileName, Name, NumberOfRecords,
                                                                @{Name='LastAccessed';Expression={Format-CimDate($_.LastAccessed)}},
                                                                @{Name='LastModified';Expression={Format-CimDate($_.LastModified)}}, 
                                                                @{Name='FileSize';Expression={Format-FileSize($_.FileSize)}}, 
                                                                @{Name='MaxFileSize';Expression={Format-FileSize($_.MaxFileSize)}},
                                                                Archive,
                                                                Compressed,
                                                                Encrypted,
                                                                OverWritePolicy
    return $c                                                            
}

Function Invoke-OutboundFireWallCheck() {
    $Rules = Get-NetFirewallRule -Action Block -Direction Outbound | Select-Object Name,DisplayName,Enabled,Direction,Action
    $d = $Rules | 
                  ForEach-Object {
                        $Rule = $_
                        $Reg = Get-ItemPropertyValue HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules $Rule.Name
                        $Reg |
                             Where-Object {$_  -Match 'RPort=(?<RPort>\d+)'} | 
                                                                             ForEach-Object {
                                                                                    $Rule | Add-Member -MemberType NoteProperty -Name 'RemotePort' -Value $Matches.RPort
                                                                                    $Rule
                                                                             }
                    }
     return $d              
 }
 
 Function Get-MaxTimeBetweenEvents() {
     param(
     parameter(Mandatory)
     [string]$LogName
     )
        $Events = Get-WinEvent -FilterHashTable @{LogName=$LogName} -MaxEvents 200
        $First = $Events[0]
        $Max = 0
        $j = 0
        for ($i=0; $i -lt ($Events.length-1); $i++) {
                $Diff = ($Events[$i].TimeCreated-$Events[$i+1].TimeCreated).ToString("dd'd 'hh'h 'mm'm 'ss's'")
                if ($Diff -gt $Max) {
                        $j = $i
                        $Max = $Diff
                }
        }
    return [pscustomobject]@{EventLogName=$LogName; MostRecentEvent=$First; MaxTime=$Max; Event=$Events[$j]; NextEvent=$Events[$j+1]}
}

$EventLogNames | ForEach-Object { Get-MaxTimeBetweenEvents -LogName $_
                 } | Format-List EventLogName,
                                 @{Name='MostRecentEvent';Expression={$_.MostRecentEvent.TimeCreated}},
                                 @{Name='TimeSinceLastEvent';E={((Get-Date) -$_.MostRecentEvent.TimeCreated).ToString("dd'd 'hh'h 'mm'm 'ss's'")}},
                                 @{Name='MaxTimeBetweenEvents';Expression={$_.MaxTime}}

#$w
write-host "[+] Evaluating the event log service"

$e

write-host "[+] Evaluating the security, system and application logs`n"

$s

write-host "[+] Check wevtutil.exe last access time`n"

$w

write-host "[+] Checking last log records`n"

$t

write-host "[+] Enumerating Outbound Deny Firewall Rules`n"

$out
