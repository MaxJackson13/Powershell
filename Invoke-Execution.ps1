'''
Quickly execute powershell commands under the context of another user, given their username and password.
Run '. .\Invoke-Execution.ps1' from the directory in which the ps1 file is located.
'''

function Invoke-Execution {
        params($Username, $Password, $Command)
        $SecurePassword = ConvertTo-SecureString $Password -AsPlaintext -Force
        $Credential = New-Object System.Management.Automation.PSCredential($Username,$SecurePassword)
        $Computer = hostname
        $Command = Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock { $Command }
        Write-Host $Command
}
