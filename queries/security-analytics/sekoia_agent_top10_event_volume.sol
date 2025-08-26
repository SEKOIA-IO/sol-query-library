// name: Sekoia Agent - Top 10 event volume (count last 7 days)
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - sekoia_agent
// query:

let earliestTime = ago(7d);
let lastestTime = now();

events
| where timestamp between (earliestTime .. lastestTime) and sekoiaio.intake.dialect_uuid == "250e4095-fa08-4101-bb02-e72f870fcbd1"
| aggregate count() by host.name
| order by count desc
| limit 10
| render barchart with(x=count, y=host.name)