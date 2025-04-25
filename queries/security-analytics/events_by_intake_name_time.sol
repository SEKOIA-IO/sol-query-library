// name: Events by intake
// description: Counts the number of events by each intake over a specified time period
// author: sekoia.io
// license: mit
// tags:
//   - mssp
//	 - linechart
// query:

let earliestTime = ago(24h);
let lastestTime = now();

events
| where timestamp between (earliestTime .. lastestTime)
| aggregate count_of_events = count() by sekoiaio.intake.uuid, bin(timestamp, 1h)
| inner join intakes on sekoiaio.intake.uuid == uuid
| render linechart with (x=timestamp, y=count_of_events, breakdown_by=intake.name)