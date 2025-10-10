// name: Suspicious process try to connect to abnormal number of public IP - worming ssh behavior
// description:
// author: sekoia.io
// license: mit
// tags:
//   -
// query:

events
| where timestamp >= ago(24h)
| where not sekoiaio.tags.destination.ip in ["rfc1918", "rfc5735"] and destination.port == 22
| where action.properties.syscall == "connect"
| aggregate nb_uniq_dest = count_distinct(destination.ip) by host.name, process.executable, process.command_line
| where nb_uniq_dest > 50
