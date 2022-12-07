Function Get-WmiNamespace {
    <#
        .SYSNOPSIS
            Performs a recursive query for all WMI Namespaces
        .PARAMETER Computername
            Computername to perform query on
        .PARAMETER Namespace
            Namespace to use to query for additional namespaces
        .PARAMETER Credential
            Optional credentials for remote systems
        .EXAMPLE
            Get-WmiNamespace
            Description
            -----------
            Lists all WMI namespaces on local computer
    #>
    [cmdletbinding()]
    Param (
        [parameter()]
        $Namespace='root',
        [parameter()]
        [string[]]$Computername = $env:COMPUTERNAME,
        [parameter()]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )
    Get-WmiObject -NameSpace $Namespace -Class __NAMESPACE -ComputerName $Computername | ForEach-Object {
            ($ns = "$($_.__NAMESPACE)\$($_.Name)")
            Get-WmiNamespace -NameSpace $ns
    }
}

Function Get-WmiPersistence {
    <#
        .SYSNOPSIS
            Queries all WMI namespaces for event consumers with a 'CommandLineTemplate' attribute
        .PARAMETER Computername
            Computername to perform query on
        .PARAMETER Namespace
            Namespace to use to query for additional namespaces
        .PARAMETER Credential
            Optional credentials for remote systems
        .EXAMPLE
            Get-WmiPersistence
            Description
            -----------
            Returns information on event consumers with a 'CommandLineTemplate' attribute
    #>
    [cmdletbinding()]
    Param (
        [parameter()]
        $Namespace='root',
        [parameter()]
        [string[]]$Computername = $env:COMPUTERNAME,
        [parameter()]
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )
    $Namespaces = Get-WmiNamespace -NameSpace $Namespace -ComputerName $Computername -Credential $Credential

    $Namespaces | ForEach-Object {
            $Namespace = Get-WmiObject -Namespace $_ -Class __EventConsumer
            $EventConsumer = ( $Namespace | Where-Object { $_.CommandLineTemplate -ne $null } )
            $EventConsumer | ForEach-Object {
                    @{
                            Type = $_.__SUPERCLASS
                            Namespace = $_.__NAMESPACE
                            Computer = $_.PSComputerName
                            CommandLineTemplate = $_.CommandLineTemplate
                            Path = $_.__PATH
                            CreatorSid = (New-Object System.Security.Principal.SecurityIdentifier($_.CreatorSid, 0)).toString()
                    } | Format-Table @{ N = 'Property'; E = { $_.Name } }, @{ N = 'Value'; E = { $_.Value } } -Wrap
            }

    }
}

# Example Usage

# *Evil-WinRM* PS C:\Users\Administrator\Documents> Get-WmiPersistence -NameSpace root -ComputerName secnotes -Credential $cred

# Property            Value
# --------            -----
# Path                \\SECNOTES\ROOT\subscription:CommandLineEventConsumer.Name="PentestLab"
# CommandLineTemplate C:\Windows\System32\pentestlab.exe
# Namespace           ROOT\subscription
# Computer            SECNOTES
# Type                __EventConsumer
# CreatorSid          S-1-5-21-1791094074-1363918840-4199337083-500



# Property            Value
# --------            -----
# Path                \\SECNOTES\ROOT\DEFAULT:CommandLineEventConsumer.Name="Persistence ftw"
# CommandLineTemplate C:\Temp\nice.exe
# Namespace           ROOT\DEFAULT
# Computer            SECNOTES
# Type                __EventConsumer
# CreatorSid          S-1-5-21-1791094074-1363918840-4199337083-500



# Property            Value
# --------            -----
# Path                \\SECNOTES\ROOT\DEFAULT:CommandLineEventConsumer.Name="PentestLab"
# CommandLineTemplate C:\Windows\System32\pentestlab.exe
# Namespace           ROOT\DEFAULT
# Computer            SECNOTES
# Type                __EventConsumer
# CreatorSid          S-1-5-21-1791094074-1363918840-4199337083-500


# *Evil-WinRM* PS C:\Users\Administrator\Documents>
