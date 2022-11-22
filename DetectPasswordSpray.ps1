# The Windows security event log ID 4771 corresponds to a Kerberos preauthentication failure. Failure code 0x18 means the pre-authentication information   # provided was invalid, the most likely cause for this being a wrong password was supplied. In a password spray attackers will try common passwords, or     # passwords they've found which they know are used in the domain (e.g. default logon passwords) against many valid users accounts. Therefore in the logs   # there'll be many authentication failures against different accounts originating from a single source IP.

$logRecords=(Get-Winevent -FilterHashtable @{ LogName='security'; id=4771 } -MaxEvents 100)

$object=@()

foreach ($record in $logRecords) {
    
    [xml]$evt=$record.toxml()
    
    $data=$evt.event.eventdata.data
    
    $object+=[PSCustomObject] @{
        'TargetUserName' = $data[0].'#text'
        'Status' = $data[4].'#text'
        'SourceIp' = $data[6].'#text'
        'TimeCreated' = $record.timecreated.datetime
    }
}

$groups=($object | Group-Object 'sourceip')

for ($i=0; $i -lt $groups.count; $i++){
  
  $group=$groups[$i].group
  
  $length=$group.count
  
  Write-Host $group
 
  #$start=[DateTime]($g[0].timecreated)
  #$end=[DateTime]($g[$j-1].timecreated)
  #echo ($start-$end).totalseconds
  echo ''
}

