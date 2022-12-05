Function Get-WmiNamespace {
    Param (
        $Namespace='root'
    )
    Get-WmiObject -Namespace $Namespace -Class __NAMESPACE | ForEach-Object {
            ($ns = "$($_.__NAMESPACE)\$($_.Name)")
            Get-WmiNamespace $ns
    }
}

$Namespaces = Get-WmiNamespace
$Namespaces | ForEach-Object {
        $Namespace = Get-WmiObject -Namespace $_ -Class __EventConsumer
        $EventConsumer=( $Namespace | Where-Object { $_.CommandLineTemplate -ne $null } )
        $EventConsumer | ForEach-Object {
                @{
                        Type=$_.__SUPERCLASS
                        Namespace=$_.__NAMESPACE
                        Computer=$_.PSComputerName
                        CommandLineTemplate=$_.commandlinetemplate
                } | Format-Table @{ N='Property'; E={ $_.Name } }, @{ N='Value'; E={ $_.Value } } -Wrap
        }

}
