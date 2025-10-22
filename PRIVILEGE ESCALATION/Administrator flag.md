#evil-winrm 

1. Go to `C:\Users\Administrator\Desktop`.
2. Modify  `root.txt` file permissions using the legacy Windows utility `cacls`, which is used to view and edit access control lists (ACLs) on files.

```
cacls root.txt /e /p j.rock:f
```

- `cacls`: Displays or modifies access control lists (ACLs) for files.
    
- `root.txt`: The target file whose permissions are being changed.
    
- `/e`: Edit mode — modifies existing ACLs rather than replacing them.
    
- `/p j.rock:f`: Grants **Full Control** (`f`) permission to the user `j.rock`.

## What This Does

This command **grants full access** to the file `root.txt` for the user `j.rock`, without removing existing permissions for other users. Full access includes:

- Read
- Write
- Modify
- Delete

3. Read the `root.txt` file. 

> [!Question] What is the administrator flag?
>THM{S3rv3r_0p3rat0rS}

