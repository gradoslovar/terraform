## Challenge

- Deploy Azure VM and Azure Storage File Share,
- Use Custom Script Extension to:
    - Mount file share persistently
    - Create Symbolic link

## Solution

Following approach is taken to workaround this problem.

Creating batch file that comprises two commands:
- Store file share credentials in Windows Credentials with **cmdkey**
- Mount file share using stored credentials and **net use**

and placing it in *C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp* so it can be executed on every reboot.