Function Find-PsExec {
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

    ForEach ($Exe in $Unsigned) {
        if($Exe.FullName -in $Services.ImagePath) {
            $Service = $Services | Where-Object {$Exe.FullName -eq $_.ImagePath}
            Write-Host "`n$($Exe.FullName) is an executable for the service $($Service.DisplayName)`n"
            ($Service | Out-String).Trim()

        }
    }
    
    if ($GetLogs) {
        ForEach ($Exe in $Unsigned) {
            if($Exe.FullName -in $Services.ImagePath) {
                $CreatedAt = $Exe.CreationTime
                $Before = $CreatedAt.AddSeconds(5)
                $After = $CreatedAt.AddSeconds(-5)
                Get-Winevent -FilterHashtable @{LogName='security'; Id=4624; StartTime=$after; EndTime=$before} -ErrorAction Ignore
                
    }

}
