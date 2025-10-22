# Overview

The room walks through common **network services** you’ll encounter on servers and in CTFs (SMB, FTP, Telnet, sometimes NFS and other service misconfigurations). It focuses on **enumeration → identifying misconfigurations or exposed shares/services → exploiting simple service-level issues** to find flags or pivot. The content mixes conceptual explanations with hands-on tasks and Nmap/enum examples.

# Room goal (one line)

Find and abuse exposed **network services** and Kerberos/AD weaknesses to gain access and escalate, using enumeration → credential harvesting → exploitation → post-exploit abuse of privileges (e.g., Server Operators). [TryHackMe+1](https://tryhackme.com/room/networkservices?utm_source=chatgpt.com)

# Typical learning path / flow

1. **Recon & port scan** — discover services (SMB, Kerberos/88, LDAP/389, RDP, FTP, Telnet). Use that to prioritise further enumeration. [Source Code+1](https://blog.davidvarghese.dev/posts/tryhackme-network-services/?utm_source=chatgpt.com)
    
2. **Service enumeration** — enumerate SMB shares, anonymous FTP, service banners; collect any creds/configs in readable files. Tools: `enum4linux`, `smbclient`, `nmap` scripts. [TryHackMe+1](https://tryhackme.com/room/networkservices?utm_source=chatgpt.com)
    
3. **Kerberos attacks & user enumeration** — use `kerbrute` to test usernames/passwords or discover valid principals; use Impacket’s `GetNPUsers.py` to pull AS-REP hashes from accounts without preauth. These provide offline cracking or further access. [hackernfo.com](https://hackernfo.com/hacking/ActiveDirectory/?utm_source=chatgpt.com)
    
4. **Exploit / initial access** — use valid creds or cracked AS-REP passwords with services (SMB, RDP, WinRM). Metasploit may provide modules/exploits for vulnerable services found. [InfoSec Write-ups](https://infosecwriteups.com/thm-attacktive-directory-7db6d7e5b0f5?utm_source=chatgpt.com)
    
5. **Post-exploit / foothold** — `Evil-WinRM` or a Meterpreter shell gives interactive access; enumerate groups, privileges, services, scheduled tasks, and accessible shares.
    
6. **Abuse Server Operators / service permissions** — if the account is in Server Operators or has service-related privileges, manage services, create shares, schedule tasks, or use backup/restore to access sensitive files or escalate. [ronamosa.io](https://ronamosa.io/docs/hacker/tryhackme/attacktive/?utm_source=chatgpt.com)
    
7. **Lateral movement / domain escalation** — use harvested creds, delegation misconfigurations, writable service binaries or weak DACLs to move to other hosts or escalate to domain accounts. [denizhalil.com](https://denizhalil.com/2025/06/10/remote-active-directory-pentesting-guide/?utm_source=chatgpt.com)
    

# How your tools map into that flow

- **kerbrute** — fast username enumeration / password spraying for Kerberos/SMB; finds valid accounts to target.  
    Example:
    
    `kerbrute userenum -d DOMAIN -u users.txt --dc-ip 10.10.XX.XX`
    
- **GetNPUsers.py (Impacket)** — pull AS-REP (no-preauth) responses for offline cracking:
    
    `python3 GetNPUsers.py DOMAIN/ -usersfile users.txt -dc-ip 10.10.XX.XX -format hashcat`
    
    Then crack with hashcat/john (example hashcat mode depends on format). [denizhalil.com](https://denizhalil.com/2025/06/10/remote-active-directory-pentesting-guide/?utm_source=chatgpt.com)
    
- **Metasploit** — useful when a service has a known exploit; otherwise use as a framework for payloads/auxiliary modules. Example: run an SMB/RPC module if nmap shows vulnerable service. [InfoSec Write-ups](https://infosecwriteups.com/thm-attacktive-directory-7db6d7e5b0f5?utm_source=chatgpt.com)
    
- **Evil-WinRM** — post-exploit interactive Windows shell when you have creds:
    
    `evil-winrm -i 10.10.XX.XX -u user -p 'password'`
    
- **Server Operators group** — once membership is confirmed (via `whoami /groups`, `net localgroup "Server Operators"`), check what you can do: manage services, shares, scheduled tasks, backups. These allow privilege actions on the host without full admin. [ronamosa.io](https://ronamosa.io/docs/hacker/tryhackme/attacktive/?utm_source=chatgpt.com)
    

# Paste-ready enumeration & abuse snippets (Windows shell / WinRM)

`# identity & privileges whoami whoami /groups whoami /priv  # list local groups & members net localgroup net localgroup "Server Operators"  # services (what you may be able to manage) sc query state= all sc queryex <ServiceName> sc config <ServiceName> binPath= "C:\temp\payload.exe"   # if permitted sc start <ServiceName> sc stop <ServiceName>  # scheduled tasks (persistence/exec) schtasks /query /fo LIST /v schtasks /create /sc once /tn "pwn" /tr "C:\temp\pwn.ps1" /st 23:59  # shares & files net share dir C:\Users\Public\ /s /b type C:\path\to\interesting.txt`

# Kerberos hash cracking & use

1. Extract AS-REP hashes with `GetNPUsers.py`.
    
2. Crack offline:
    

`# example (adjust mode to AS-REP / RC4 / AES type) hashcat -m 18200 asrep.txt rockyou.txt`

3. Use cracked password with `evil-winrm`, `smbclient`, or RDP. You can also craft tickets with Rubeus if needed. [denizhalil.com](https://denizhalil.com/2025/06/10/remote-active-directory-pentesting-guide/?utm_source=chatgpt.com)
    

# What to look for / high-value findings

- Accounts that **do not require preauth** (AS-REP roastable). [denizhalil.com](https://denizhalil.com/2025/06/10/remote-active-directory-pentesting-guide/?utm_source=chatgpt.com)
    
- **Readable config/backup files** on SMB shares containing creds. [Source Code](https://blog.davidvarghese.dev/posts/tryhackme-network-services/?utm_source=chatgpt.com)
    
- **Membership** in Server Operators or other groups that allow service/share/task management. [ronamosa.io](https://ronamosa.io/docs/hacker/tryhackme/attacktive/?utm_source=chatgpt.com)
    
- **Writable service binary path** or weak DACLs on services/scheduled tasks — immediate escalation vector. [denizhalil.com](https://denizhalil.com/2025/06/10/remote-active-directory-pentesting-guide/?utm_source=chatgpt.com)
    

# Typical CTF escalation example (condensed)

1. Nmap → find ports 88 (Kerberos), 445 (SMB). [Source Code](https://blog.davidvarghese.dev/posts/tryhackme-network-services/?utm_source=chatgpt.com)
    
2. `kerbrute` finds valid user `svc_backup`.
    
3. `GetNPUsers.py` returns AS-REP for `svc_backup` → crack → get password. [denizhalil.com](https://denizhalil.com/2025/06/10/remote-active-directory-pentesting-guide/?utm_source=chatgpt.com)
    
4. `evil-winrm` to host with `svc_backup` → `whoami /groups` shows `Server Operators`.
    
5. Use `sc config` or create scheduled task to run payload or copy `C:\Windows\System32\cmd.exe` substitute → escalate or extract files.