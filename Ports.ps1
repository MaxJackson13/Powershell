'''
In: get-openports -target localhost -lowerport 22 -upperport 80                                                                                                              
Out:
Port 22 is open
Port 80 is open
'''

function Get-OpenPorts {
    param($Target, $LowerPort, $UpperPort)

    for ($i=$LowerPort; $i -le $UpperPort; $i+=1){                                                                                                                            >
        try { New-Object System.Net.Sockets.TCPClient –Argument $Target,$i | out-null; write-host 'Port' $i 'is open'}
        catch {out-null}                                                                                                                                                      >
    }
}

