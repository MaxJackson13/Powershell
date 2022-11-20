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

