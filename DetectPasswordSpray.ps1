# The Windows security event log ID 4771 corresponds to a Kerberos preauthentication failure. Failure code 0x18 means the pre-authentication information   # provided was invalid, the most likely cause for this being a wrong password was supplied. In a password spray attackers will try common passwords, or     # passwords they've found which they know are used in the domain (e.g. default logon passwords) against many valid users accounts. Therefore, in the logs   # there'll be many authentication failures against different accounts originating from a single source IP. This script retrieves 4771 events from the log
# and groups them by source ip. It runs through the events and looks for three failures within 1800 seconds (30 minutes).

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
  
  $len=$group.count
  
  for ($j=0; $j -lt $len-2; $j+=3){
    if (([DateTime]($group[$j].timecreated)-[DateTime]($group[$j+2].timecreated)).totalseconds -lt 1800) {
       echo "Detected 3 failed logons starting at $([DateTime]($group[$j].timecreated)). May be related to previous events"
    }
}

