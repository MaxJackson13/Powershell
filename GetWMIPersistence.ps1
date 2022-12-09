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
    Get-WmiObject -NameSpace $Namespace -Class __NAMESPACE -ComputerName $Computername | 
    ForEach-Object {
            ($ns = "$($_.__NAMESPACE)\$($_.Name)")
            Get-WmiNamespace -NameSpace $ns
    }
}

Function Get-WmiPersistence {
    <#
        .SYSNOPSIS
            Returns information on eventfilters, eventconsumers and associated bindings related to 'activescript' or 'commandline' event consumers
        .PARAMETER Computername
            Computername to perform query on
        .PARAMETER Namespace
            Namespace to use to query for additional namespaces
        .PARAMETER Credential
            Optional credentials for remote systems
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
    $NameSpaces = Get-WmiNamespace -NameSpace $Namespace -ComputerName $Computername -Credential $Credential

    $NameSpaces |
    ForEach-Object {
            $NameSpace = $_
            Get-WmiObject -NameSpace $NameSpace -Class __FilterToConsumerBinding
    } |
    Where-Object {$_.Consumer -Match '^(CommandLine|ActiveScript)'} |
            ForEach-Object {
                    $Binding = $_
                    $Consumer = Get-WmiObject -NameSpace $NameSpace -Class __EventConsumer | Where-Object {$_.__RELPATH -eq $Binding.Consumer}
                    $Filter = Get-WmiObject -NameSpace $NameSpace -Class __EventFilter | Where-Object {$_.__RELPATH -eq $Binding.Filter}

                    [PSCustomObject]@{
                    Type = $Consumer.__SUPERCLASS
                    Name = $Consumer.__RELPATH
                    Namespace = $Consumer.__NAMESPACE
                    ExecutablePath = $Consumer.ExecutablePath
                    CommandLineTemplate = $Consumer.CommandLineTemplate
                    ComputerName = $Consumer.PSComputerName
                    CreatorSid = (New-Object System.Security.Principal.SecurityIdentifier($Consumer.CreatorSid, 0)).toString()
                    }

                    [PSCustomObject]@{
                    Type = $Filter.__CLASS
                    Name = $filter.__RELPATH
                    Namespace = $Filter.__NAMESPACE
                    Query = $Filter.Query
                    ComputerName = $Filter.PSComputerName
                    CreatorSid = (New-Object System.Security.Principal.SecurityIdentifier($Filter.CreatorSid, 0)).toString()
                    }

                    [PSCustomObject]@{
                    Type = $Binding.__CLASS
                    Namespace = $Binding.__NAMESPACE
                    Consumer = $Binding.Consumer
                    Filter = $Binding.Filter
                    ComputerName = $Binding.PSComputerName
                    CreatorSid = (New-Object System.Security.Principal.SecurityIdentifier($Binding.CreatorSid, 0)).toString()
                    }
            }
}


# Example Usage

# PS C:\Users\Administrator\Documents> get-wmipersistence

# Type                : __EventConsumer
# Name                : CommandLineEventConsumer.Name="PentestLab"
# Namespace           : ROOT\subscription
# ExecutablePath      : C:\Windows\System32\pentestlab.exe
# CommandLineTemplate : C:\Windows\System32\pentestlab.exe
# ComputerName        : SECNOTES
# CreatorSid          : S-1-5-18

# Type         : __EventFilter
# Name         : __EventFilter.Name="PentestLab"
# Namespace    : ROOT\subscription
# Query        : SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System'
# ComputerName : SECNOTES
# CreatorSid   : S-1-5-18

# Type         : __FilterToConsumerBinding
# Namespace    : ROOT\subscription
# Consumer     : CommandLineEventConsumer.Name="PentestLab"
# Filter       : __EventFilter.Name="PentestLab"
# ComputerName : SECNOTES
# CreatorSid   : S-1-5-18

# PS C:\Users\Administrator\Documents>
