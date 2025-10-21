# First enumeration

#Attacking_machine
Use *nmap* to see the services and ports on the victim machine.

```
nmap -A  <MACHINE IP>
```

![[Screenshot_2025-10-20_05-00-20.png]]

## 🔍 **General System Overview**

- **Hostname**: WIN-SERVICES
    
- **Domain**: `services.local`
    
- **Operating System**: Microsoft Windows (likely Server 2019 based on Product Version `10.0.17763`)
    
- **Role**: Most likely an **Active Directory Domain Controller**
    

---

## 🟢 **Open Ports & Services**

|Port|Service|Version/Info|Implications|
|---|---|---|---|
|**53/tcp**|DNS|Simple DNS Plus|Provides name resolution. Could allow zone transfers if misconfigured.|
|**80/tcp**|HTTP|Microsoft IIS 10.0|Web server running. TRACE method is enabled (potential XST vulnerability).|
|**88/tcp**|Kerberos|Windows Kerberos|Used for authentication in AD. Valuable for Kerberoasting.|
|**135/tcp**|MSRPC|Windows RPC|Used for DCOM, WMI. Often abused for lateral movement.|
|**139/tcp**|NetBIOS-SSN|NetBIOS|File/printer sharing. Can be used for SMB enumeration.|
|**389/tcp**|LDAP|AD LDAP|LDAP queries and enumeration of users/computers.|
|**445/tcp**|SMB|Microsoft-DS|Core SMB protocol. Allows authentication, shares, and exploitation (if vulnerable).|
|**464/tcp**|kpasswd5?|-|Kerberos password change. Target in AS-REP roasting scenarios.|
|**593/tcp**|RPC over HTTP|ncacn_http|RPC tunneling (Outlook/Exchange, WMI).|
|**636/tcp**|LDAP over SSL|tcpwrapped|Encrypted LDAP. Service wrapped, might be filtered or not directly reachable.|
|**3268/tcp**|Global Catalog|LDAP|Allows LDAP queries across multiple domains in the forest.|
|**3269/tcp**|Global Catalog (SSL)|tcpwrapped|SSL version of GC LDAP.|
|**3389/tcp**|RDP|Microsoft Terminal Services|Remote Desktop. Can be brute-forced or exploited if vulnerable.|

### 🔒 **Security Findings**

1. **SMB Security**:
    
    - **Signing required** — prevents relay attacks, which is good.
        
    - **SMBv2 in use** — more secure than SMBv1, which is deprecated.
        
2. **HTTP Server (Port 80)**:
    
    - Supports the **TRACE** method, which is risky as it can enable Cross Site Tracing (XST).
        
    - IIS version disclosed (**Microsoft-IIS/10.0**), which can help attackers identify exploits.
        
3. **SSL Certificates**:
    
    - Valid certificate with **CN=WIN-SERVICES.services.local**
        
    - Not valid before `2025-10-18`, expires on `2026-04-19`.
        
4. **RDP Info Leak**:
    
    - Detailed information about domain, host, and OS version leaked through RDP NTLM handshake (`rdp-ntlm-info`).
        

---

## 🛠️ **Potential Attack Surface & Risks**

| Risk Category           | Details                                                                                                               |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Enumeration**         | Ports 389, 3268 allow LDAP/GC enumeration (users, groups, machines).                                                  |
| **Kerberoasting**       | Port 88 (Kerberos) — service accounts with SPNs can be requested and cracked offline.                                 |
| **AS-REP Roasting**     | If any user does not require pre-authentication. Check with Impacket’s `GetNPUsers.py`.                               |
| **RDP Access**          | If weak credentials, RDP could be brute-forced. Also check for BlueKeep (CVE-2019-0708) if patching is not confirmed. |
| **SMB Enumeration**     | With access to 139/445, you can enumerate shares, users, and possibly perform attacks (Pass-the-Hash, etc.).          |
| **Web Vulnerabilities** | TRACE method enabled. IIS version known. Should be checked for known CVEs.                                            |
| **RPC Access**          | Ports 135 and 593 could be used for WMI-based attacks or lateral movement.                                            |

---
# Network & service discovery (nmap)

## Nmap services
Use nmap to confirm services and do light scripting enumeration.

1. Basic service scan:
```
	sudo nmap -sS -p 53,80,88,135,139,389,445,464,593,636,3268,3269,3389 -sV -oA nmap-services <MACHINE IP> -Pn
```

![[Screenshot_2025-10-20_05-18-51.png]]

2. Light service scripts for AD/LDAP/RDP info:
```
sudo nmap -sS -p 88,135,389,445,3389 --script=ldap-search,ldap-rootdse,msrpc-enum,rdp-ntlm-info,smb-protocols -oN nmap-ad-scripts.txt <MACHINE IP>
```


## Notable Observations

### LDAP RootDSE Results

Your Nmap output confirms that anonymous LDAP queries are **partially allowed**, and this provided:

- `defaultNamingContext: DC=services,DC=local`
    
- `dnsHostName: WIN-SERVICES.services.local`
    
- `domainFunctionality`, `forestFunctionality`, etc. → all level 7 (Windows Server 2016+)
    
- Domain Controller is  `WIN-SERVICES`, and it's ready for Global Catalog queries.

Try LDAP user/SPN enumeration. Use this:

```
ldapsearch -x -H ldap://<MACHINE IP> -b "DC=services,DC=local" "(objectClass=user)" sAMAccountName | tee ldap-users.txt
```

![[Screenshot_2025-10-20_06-04-00.png]]

Anonymous LDAP access **is not allowed** for that query — you must **bind with valid credentials** to enumerate objects like users or SPNs.


**Nest step:** [[Web Server]]
