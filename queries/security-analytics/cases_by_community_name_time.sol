// name: Cases by community name over time
// description: Counts the number of cases by each community over a specified time period
// author: sekoia.io
// license: mit
// tags:
//   - mssp
//   - multi-tenant
//	 - linechart
// query:

let earliestTime = ago(7d);
let lastestTime = now();

cases
| where updated_at between (earliestTime .. lastestTime)
| aggregate count_of_cases = count() by community_uuid, bin(updated_at, 1h)
| inner join communities on community_uuid == uuid
| render linechart with (x=updated_at, y=count_of_cases, breakdown_by=community.name)