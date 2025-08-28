// name: Sekoia Agent - number of active agents by version and Intake
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
| aggregate count_distinct(host.name) by agent.version, sekoiaio.intake.uuid
| lookup intakes on sekoiaio.intake.uuid == uuid
| order by agent.version asc
| select agent.version, intake.name, count_distinct_host.name