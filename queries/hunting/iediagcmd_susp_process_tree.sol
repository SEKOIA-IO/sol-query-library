// name: iediagcmd.exe suspicious tree
// description: Identify suspicious iediagcmd abnormal process tree, could indicate successful exploitation of CVE-2025-3305
// author: sekoia.io
// license: mit
// tags:
//   - cve-2025-33053
//   - stealth falcon apt
//   - MEA
// refs:
//   - https://research.checkpoint.com/2025/stealth-falcon-zero-day/
// query:

events
| where timestamp >= (7d)
| where process.parent.executable == "C:\Program Files\Internet Explorer\iediagcmd.exe"
| where not process.executable startswith~ "C:\Windows\System32"
| where process.name in ["route.exe", "ROUTE.EXE", "netsh.exe", "NETSH.EXE", "ipconfig.exe", "IPCONFIG.EXE", "dxdiag.exe", "DXDIAG.EXE"]
| select timestamp, event.code, host.name, user.name, process.parent.pid, process.parent.executable, process.pid, process.executable, process.name, process.command_line
