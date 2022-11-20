Function Get-TGS {
  #.SYNOPSIS
  #Retrieves events with event ID 4769 (A Kerberos service ticket was requested) from the Windows security log which have 'TicketEncryptionType' of RC4-     #HMAC. This encryption type is commonly requested in Kerberoasting attacks where a downgrade from the standard AES encryption allows for easier offline     #cracking of the service account hash used to encrypt the server portion of the TGS.
  
  param([int] $Events)
  
  $Logs=Get-WinEvent -FilterHashtable @{LogName='security'; id=4769} -MaxEvent $Events

  ForEach ($Record in $Logs) {
      $Evt=[xml]$Record.toXml()
      $EncryptionType=($Evt.Event.EventData.Data | where {$_.Name -eq 'TicketEncryptionType'}).'#text'
      
      if ($EncryptionType -eq '0x17') {Write-Output $Record | Format-Table -Wrap}
  }
}
