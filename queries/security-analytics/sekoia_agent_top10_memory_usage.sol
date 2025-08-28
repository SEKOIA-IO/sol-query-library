// name: Sekoia Agent - Top 10 Memory usage (max MB)
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - sekoia_agent
// query:

let earliestTime = ago(7d);
let lastestTime = now();

events
| where timestamp between (earliestTime .. lastestTime) and sekoiaio.intake.dialect_uuid == "250e4095-fa08-4101-bb02-e72f870fcbd1" and event.action == "stats"
| aggregate max(sekoiaio.agent.memory_usage) by host.name
| order by max_sekoiaio.agent.memory_usage desc
| limit 10
| extend max_sekoia_agent_memory_usage_mb = max_sekoiaio.agent.memory_usage / 1000 / 1000
| render barchart with(x=max_sekoia_agent_memory_usage_mb, y=host.name)