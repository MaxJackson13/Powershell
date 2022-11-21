#define password spray as more than 3 or more failed logins to different users from the same ip in short time (30 min)

$r=(get-winevent -filterhashtable @{logname='security';id=4771} -maxevents 100)
$obj=@()
foreach ($record in $r) {
    [xml]$evt=$record.toxml()
    $data=$evt.event.eventdata.data
    $obj+=[PSCustomObject] @{
        'TargetUserName' = $data[0].'#text'
        'Status' = $data[4].'#text'
        'SourceIp' = $data[6].'#text'
        'TimeCreated' = $record.timecreated.datetime
    }
}
$obj

-group by ip
-define start as most recent timecreated
-check next, if different user and time within 30 mins of previous, move to next
-otherwise update start

$g=$groups[$i].group
$start=[DateTime]($g[0].timecreated)
$j=1
while ($j -lt $g.count){
  if (($start-[DateTime]($g[$j].timecreated)).seconds -lt 1800)
  {$j+=1}
  else {
  $start=[DateTime]($g[$j].timecreated
  
  }
  
}




eventid 4678 A Kerberos authentication ticket (TGT) was requested
result code 0x6	KDC_ERR_C_PRINCIPAL_UNKNOWN if invalid user

eventid 4771 Kerberos pre-authentication failed if valid user invalid pass


get-aduser -filter * -searchbase 'DC=SCRM,DC=LOCAL' | select samaccountname 2>&1

samaccountname
--------------
administrator 
Guest         
krbtgt        
tstar         
asmith        
sjenkins      
sdonington    
backupsvc     
jhall         
rsmith        
ehooker       
khicks        
sqlsvc        
miscsvc       
ksimpson      

Get-ADRootDSE | select *naming* 

configurationNamingContext : CN=Configuration,DC=scrm,DC=local
defaultNamingContext       : DC=scrm,DC=local
namingContexts             : {DC=scrm,DC=local, CN=Configuration,DC=scrm,DC=local, 
                             CN=Schema,CN=Configuration,DC=scrm,DC=local, DC=DomainDnsZones,DC=scrm,DC=local...}
rootDomainNamingContext    : DC=scrm,DC=local
schemaNamingContext        : CN=Schema,CN=Configuration,DC=scrm,DC=local

