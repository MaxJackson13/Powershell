Function Get-TGS {
  # .SYNOPSIS
  # Retrieves events with event ID 4769 (A Kerberos service ticket was requested) from the Windows security log 
  # which have 'TicketEncryptionType' of RC4-HMAC. This encryption type is commonly requested in Kerberoasting attacks 
  # where a downgrade from AES encryption allows for easier offline cracking of the service account password 
  # whose hash is used to encrypt the server portion of the TGS.
  ###################################################################################################################
  
  param([int] $Events)
  
  $Logs=Get-WinEvent -FilterHashtable @{LogName='security'; id=4769} -MaxEvent $Events

  ForEach ($Record in $Logs) {
      $Evt=[xml]$Record.toXml()
      $EncryptionType=($Evt.Event.EventData.Data | where {$_.Name -eq 'TicketEncryptionType'}).'#text'
      
      if ($EncryptionType -eq '0x17') {Write-Output $Record | Format-Table -Wrap}
  }
}

#Example usage: Get-TGS -Events 100

#Example Output:

#   ProviderName: Microsoft-Windows-Security-Auditing
#
#TimeCreated                     Id LevelDisplayName Message                                                            
#-----------                     -- ---------------- -------                                                            
#20/11/2022 08:50:52           4769 Information      A Kerberos service ticket was requested.                           
#                                                                                                                       
#                                                    Account Information:                                               
#                                                        Account Name:           ksimpson@SCRM.LOCAL                                
#                                                        Account Domain:         SCRM.LOCAL                                       
#                                                       Logon GUID:             {0831b86c-a343-d791-7766-9ccfa6eedd42}               
# 
#                                                    Service Information:                                               
#                                                        Service Name:           sqlsvc                                             
#                                                        Service ID:             S-1-5-21-2743207045-1827831105-2542523200-1613       
#                                                                                                                       
#                                                    Network Information:                                               
#                                                        Client Address:         ::ffff:10.10.14.11                               
#                                                        Client Port:            43330                                               
#                                                                                                                       
#                                                    Additional Information:                                            
#                                                        Ticket Options:         0x40810010                                       
#                                                        Ticket Encryption Type: 0x17                                      
#                                                        Failure Code:           0x0                                                
#                                                         Transited Services:     -                                             
#                                                                                                                       
#                                                    This event is generated every time access is requested to a        
#                                                    resource such as a computer or a Windows service.  The service     
#                                                    name indicates the resource to which access was requested.         
#                                                                                                                       
#                                                    This event can be correlated with Windows logon events by          
#                                                    comparing the Logon GUID fields in each event.  The logon event    
#                                                    occurs on the machine that was accessed, which is often a          
#                                                    different machine than the domain controller which issued the      
#                                                    service ticket.                                                    
#                                                                                                                       
#                                                    Ticket options, encryption types, and failure codes are defined in 
#                                                    RFC 4120.                                                          
#
#
#
#
#   ProviderName: Microsoft-Windows-Security-Auditing
#
#TimeCreated                     Id LevelDisplayName Message                                                            
#-----------                     -- ---------------- -------                                                            
#19/11/2022 05:59:19           4769 Information      A Kerberos service ticket was requested.                           
#                                                                                                                       
#                                                    Account Information:                                               
#                                                        Account Name:           ksimpson@SCRM.LOCAL                                
#                                                        Account Domain:         SCRM.LOCAL                                       
#                                                        Logon GUID:             {947d4385-6390-ad21-1dd3-e9e0f9f1fe57}               
#                                                                                                                       
#                                                    Service Information:                                               
#                                                        Service Name:           sqlsvc                                             
#                                                        Service ID:             S-1-5-21-2743207045-1827831105-2542523200-1613       
#                                                                                                                       
#                                                    Network Information:                                               
#                                                        Client Address:         ::ffff:10.10.14.12                               
#                                                        Client Port:            47812                                               
#                                                                                                                       
#                                                    Additional Information:                                            
#                                                        Ticket Options:         0x40810010                                       
#                                                        Ticket Encryption Type: 0x17                                      
#                                                        Failure Code:           0x0                                                
#                                                        Transited Services:     -                                             
#                                                                                                                       
#                                                    This event is generated every time access is requested to a        
#                                                    resource such as a computer or a Windows service.  The service     
#                                                    name indicates the resource to which access was requested.         
#                                                                                                                       
#                                                    This event can be correlated with Windows logon events by          
#                                                    comparing the Logon GUID fields in each event.  The logon event    
#                                                    occurs on the machine that was accessed, which is often a          
#                                                    different machine than the domain controller which issued the      
#                                                    service ticket.                                                    
#                                                                                                                       
#                                                    Ticket options, encryption types, and failure codes are defined in 
#                                                    RFC 4120.

