// name: Powershell add persistence by adding lnk to the startup dir
// description:
// author: sekoia.io
// license: mit
// tags:
//   -
// query:

events
| where timestamp >= (7d)
| where process.name == "powershell.exe"
| where file.path contains~ "startup" and file.path endswith ".lnk"
| aggregate dc_shortcut_by_host = count_distinct(host.name) by file.name
| where dc_shortcut_by_host < 5
