# Commands I frequently use in CTFs collected here so I don't forget the syntax and can quickly copy and paste whenever I need them

# Run commands as another user
$password = ''
$SecurePassword = ConvertTo-SecureString  -AsPlaintext -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username,$SecurePassword)
$Computer = hostname
Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { $Command }


[System.Convert]::ToBase64String([IO.File]::ReadAllBytes('$filepath'))

