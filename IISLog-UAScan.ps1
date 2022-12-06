Function Invoke-UserAgentScan {
    <#
        .SYSNOPSIS
            Parses IIS access logs looking for hosts with suspicious user-agent string e.g. nmap, sqlmap, powershell, certutil, office, bits etc.
        .PARAMETER File
            Path to IIS log file
        .PARAMETER Include
            String to search for
        .EXAMPLE
        
            Software: Microsoft Internet Information Services 10.0
            Version: 1.0
            Date: 2022-11-18 02:27:21
            Fields: date time s-ip cs-method cs-uri-stem cs-uri-query s-port cs-username c-ip cs(User-Agent) cs(Referer) sc-status sc-substatus sc-win32-status time-taken
            2022-11-18 02:27:21 10.10.11.168 GET / - 80 - 10.10.14.5 - - 200 0 64 654
            2022-11-18 02:28:15 10.10.11.168 OPTIONS / - 80 - 10.10.14.5 Mozilla/5.0+(compatible;+Nmap+Scripting+Engine;+https://nmap.org/book/nse.html) - 200 0 0 377
            ...[snip]...
          
            PS C:\ Invoke-UserAgentScan -File C:\inetpub\logs\LogFiles\iis.log -Include nmap
            
            Host 10.10.14.5 sent 192 requests containing 'nmap' in the User-Agent                                                                                             >
            Host 10.10.14.8 sent 84 requests containing 'nmap' in the User-Agent
    #>
    [CmdletBinding()]
    param(
        [(parameterMandatory)]
        [System.IO.FileInfo]$File, 
        [(parameterMandatory)]  
        [string]$Include
    )

    $Headers = @((Get-Content -Path $File -TotalCount 4)[3].split(' ') | Where-Object {$_ -ne '#Fields:'})
    $IpIndex = [Array]::IndexOf($headers, 'c-ip')
    $Lines = (Get-Content -Path $File | Select-String $Include)

    $Arr = @()
    ForEach ($Line in $Lines){
        $Arr+=$Line.toString().split(' ')[$IpIndex]
    }

    if (-not $Arr) {Write-Host "No entries were found with $($Entry) in the User-Agent"}
    else {
          $Group = ($Arr | Group-Object -NoElement)
          $Group | ForEach-Object {Write-Host "Host $($_.Name) sent $($_.Count) requests containing $($Include) in the User-Agent"}                                     >
    }
}
