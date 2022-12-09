Function Invoke-wevtutilCheck() {
    param(
    [Parameter(mandatory)]
    [System.IO.FileInfo]$Path=$env:SYSTEMROOT
    )
    $w = Get-ChildItem -Recurse -Path $Path -Include wevtutil.exe -ErrorAction SilentlyContinue | 
                Get-ItemProperty | 
                        Select FullName,LastAccessTime | 
                                Sort LastAccessTime
    return $w
}
Function Invoke-EventLogServiceCheck() {
    
    $ServiceDll = Get-ItemPropertyValue HKLM:\System\CurrentControlSet\Services\Eventlog ServiceDll
    $Signature = (Get-AuthenticodeSignature $ServiceDll).Status
    
    $Status = (Get-Service EventLog).Status
    
    $e = Get-WmiObject win32_service | Where-object {$_.Name -like '*eventlog*'} |
                                              Select-Object @{Name='Name';Expression={$_.Caption}},
                                                            @{Name='Status';Expression={$_.Status,$Status}},
                                                            @{Name='Command Line';Expression={$_.PathName}},
                                                            StartMode,
                                                            @{Name='Service Executable';Expression={$ServiceDll}},
                                                            @{Name='ServiceDll Signature';Expression={$Signature}}
    return $e                                                     
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
    Param ([string]$Date)
    [System.Management.ManagementDateTimeConverter]::ToDateTime($Date)
}

$EventLogNames = @('security','system','application')
$Pwsh = Get-WinEvent -ListLog 'windows powershell'
if ($Pwsh -ne $null) {
    $EventLogNames += 'windows powershell'
}

Function Invoke-EventLogCheck() {
    param(
    [Parameter(mandatory)]
    [string]$LogNames=$EventLogNames
    )
    $s=Get-WmiObject -Class Win32_NTEventLogFile| Where-Object {$_.LogFileName -in $LogNames} |
                                                  Select-Object LogFileName, Name, NumberOfRecords,
                                                                @{Name='LastAccessed';Expression={Format-CimDate($_.LastAccessed)}},
                                                                @{Name='LastModified';Expression={Format-CimDate($_.LastModified)}}, 
                                                                @{Name='FileSize';Expression={Format-FileSize($_.FileSize)}}, 
                                                                @{Name='MaxFileSize';Expression={Format-FileSize($_.MaxFileSize)}},
                                                                Archive,
                                                                Compressed,
                                                                Encrypted,
                                                                OverWritePolicy
    return $s                                                            
}

Function Get-TimeDiff() {
     param(
     [string]$Log
     )
     $l=get-winevent -filterhashtable @{logname='security'} -max 100
     $max=0
     $j=0
     for ($i=0;$i -lt ($l.length-1); $i++) {
             $diff=($l[$i].timecreated-$l[$i+1].timecreated).ToString("dd' days 'hh' hours 'mm' minutes 'ss' seconds'")
             if ($diff -gt $max) {
                     $j=$i
                     $max=$diff
             }
     }
    return $max,$l[$j],$l[$j+1]

$t=$LogNames | ForEach-Object {Get-WinEvent -LogName $_ -MaxEvents 1} | Select-Object LogName,
                                                                                      @{Name='LastEventRecorded';E={$_.TimeCreated}},
                                                                                      @{Name='TimeDelta';E={((Get-Date) -$_.TimeCreated).ToString("dd' days 'hh' hours 'mm' minutes 'ss' seconds'")}}


Function Invoke-OutboundFireWallCheck() {
    $Rules = Get-NetFirewallRule -Action Block -Direction Outbound | Select-Object Name,DisplayName,Enabled,Direction,Action
    $out = $Rules | ForEach-Object {
                             $Rule = $_
                             $Reg = Get-ItemPropertyValue HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules $Rule.Name
                             $Reg | Where-Object {$_  -Match 'RPort=(?<RPort>\d+)'} | ForEach-Object {
                                                                                                      $Rule | Add-Member -MemberType NoteProperty -Name 'RemotePort' -Value $Matches.RPort
                                                                                                      $Rule
                                                                                      }
                    }
     return $out              
 }
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
