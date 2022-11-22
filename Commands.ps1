# Commands I frequently use in CTFs collected here so I don't forget the syntax and can quickly copy and paste whenever I need them

# Run commands as another user
$password = ''
$SecurePassword = ConvertTo-SecureString  -AsPlaintext -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username,$SecurePassword)
$Computer = hostname
Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { $Command }

# Base64 encode file outputting to the screen
[System.Convert]::ToBase64String([IO.File]::ReadAllBytes('$filepath'))

# To base64 encode a file from linux for windows do
cat file.txt | iconv -f utf8 -t utf16-le > fileb64.txt

# To mount a remote share on the local machine e.g. for transferring files between Linux and Windows VMs, create a credential block as in the first 3 lines 
# of the first command then do
New-PSDrive -PSProvider FileSystem -Root \\10.10.14.43\share -Credential $Credential
