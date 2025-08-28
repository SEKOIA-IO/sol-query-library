// name: Sekoia Agent - number of active agents by Intake
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
| aggregate count_distinct(host.name) by sekoiaio.intake.uuid, bin(timestamp, 1d)
| lookup intakes on sekoiaio.intake.uuid == uuid
| render linechart with(x=timestamp, y=count_distinct_host.name, breakdown_by=intake.name)