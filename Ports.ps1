'''
Run '. .\Ports.ps1' from the directory Ports.ps1 is located to import the function

In: Get-OpenPorts -Target localhost -Lowerport 22 -Upperport 80                                                                                                              

Out: Port 22 is open
     Port 80 is open
'''

function Get-OpenPorts {
    param($Target, $LowerPort, $UpperPort)

    for ($i=$LowerPort; $i -le $UpperPort; $i+=1){                                                                                                                            >
        try { New-Object System.Net.Sockets.TCPClient –Argument $Target,$i | out-null; write-host 'Port' $i 'is open'}
        catch {out-null}                                                                                                                                                      >
    }
}

