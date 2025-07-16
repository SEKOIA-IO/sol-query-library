// name: Show sum of message size per community over time
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
| aggregate total_message_volume_kb = sum(total_message_size) / 1024 by community_uuid, date = bin(bucket_start_date, 1h)
| inner join communities on community_uuid == uuid
| render linechart with(x=date, y=total_message_volume_kb, breakdown_by=community.name)