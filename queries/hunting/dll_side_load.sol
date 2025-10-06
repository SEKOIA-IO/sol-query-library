// name: Suspicious dll loading - possibly side load
// description:
// author: sekoia.io
// license: mit
// tags:
//   -
// query:

events
| where timestamp >= ago(24h)
| where event.code == 7
| where process.executable contains~ "temp" or process.executable contains~ "appdata"
| where dll.path contains~ "temp" or dll.path~ "appdata"
| where action.properties.SignatureStatus != "Valid"
| select timestamp, host.name, user.name, process.pid, process.executable, dll.path, dll.hash.sha256, action.properties.SignatureStatus, action.propertiesCompany, action.properties.Description
