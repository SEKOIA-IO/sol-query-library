// name: Events by community
// description: Counts the number of events by each community you have access to.
// author: sekoia.io
// license: mit
// tags:
//   - mssp
//   - multi-tenant
//	 - linechart
// query:

let earliestTime = ago(24h);
let lastestTime = now();

events
| where timestamp between (earliestTime .. lastestTime)
| aggregate count_of_events = count() by sekoiaio.customer.community_uuid
, bin(timestamp, 1h)
| inner join communities on sekoiaio.customer.community_uuid == uuid
| render linechart with (x=timestamp, y=count_of_events, breakdown_by=community.name)