// name: New alerts by community name over time
// description: Counts the number of new alerts by each community over a specified time period
// author: sekoia.io
// license: mit
// tags:
//   - mssp
//   - multi-tenant
//	 - linechart
// query:

let earliestTime = ago(7d);
let lastestTime = now();

alerts
| where created_at between (earliestTime .. lastestTime)
| aggregate count_of_alerts = count() by community_uuid, bin(created_at, 1h)
| inner join communities on community_uuid == uuid
| render linechart with (x=created_at, y=count_of_alerts, breakdown_by=community.name)