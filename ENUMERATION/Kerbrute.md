`kerbrute_linux_amd64` is a **compiled Linux binary** (for 64-bit systems using the AMD64 architecture) of **Kerbrute**, a tool used for **enumerating valid Active Directory (AD) accounts** and performing **Kerberos pre-authentication brute-force attacks**.

---

## 🔍 What is Kerbrute?

**Kerbrute** is an open-source tool written in Go by **Ronnie Flathers (@ropnop)**. It interacts with the Kerberos protocol to:

- **Enumerate usernames** against a Kerberos service without triggering account lockouts.
    
- **Brute-force passwords** for known usernames via Kerberos pre-authentication.
    
- **Discover domain configuration**, such as the domain controller, realm, etc.
    

GitHub repo: [https://github.com/ropnop/kerbrute](https://github.com/ropnop/kerbrute)

## 🛠️ `kerbrute_linux_amd64` – Details

- **File**: `kerbrute_linux_amd64`
    
- **Platform**: Linux
    
- **Architecture**: x86_64 (aka AMD64)
    
- **Type**: Static binary — doesn't need installation, just `chmod +x` and run.
    
- **Usage Example**:

```
./kerbrute_linux_amd64 userenum -d example.com usernames.txt
```

This would test usernames from `usernames.txt` against the domain `example.com`.


---

## Running kerbrute

#Attacking_machine 
Use `kerbrute` to see whether the users from the previous step are valid or not. 


```
~/tools/kerbrute_linux_amd64 userenum --dc <MACHINE IP> -d services.local users.txt
```

![[Screenshot_2025-10-21_05-23-20.png]]

The four usernames are valid.

**Next step:** [[Gaining initial access]]

