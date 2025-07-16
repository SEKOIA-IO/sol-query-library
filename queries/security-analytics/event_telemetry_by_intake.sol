// name: Show sum of message size per intake over time
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - barchart
// query:

let earliestTime = ago(7d);
let lastestTime = now();

event_telemetry
| where bucket_start_date between (earliestTime .. lastestTime)
| aggregate total_message_volume_kb = sum(total_message_size) / 1024 by intake_uuid, date = bin(bucket_start_date, 1h)
| lookup intakes on intake_uuid == uuid
| order by date asc
| render linechart with(x=date, y=total_message_volume_kb, breakdown_by=intake.name)