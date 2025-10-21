Once you have connected the machine you can look for the user's (`j.rock`) services.

#evil-winrm
```
whoami /all
```

![[Screenshot_2025-10-21_06-26-14.png]]

## Group Server Operators

On **Windows**, the **“Server Operators”** group is a **built-in local group** that exists **on Windows Server editions** (not usually on Windows 10/11).

### 🧩 What the “Server Operators” group is

- **Built-in group** on Windows Server.
    
- Members can **perform administrative tasks on the server** without being full Administrators.
    
- Common privileges:
    
    - Start/stop system services
        
    - Manage shared resources (create/delete network shares)
        
    - Back up and restore files
        
    - Log on locally to the server
        
    - Shut down the system
        

> 🧠 They **can’t change security settings or install software** that affects all users — those actions require full Administrators.

