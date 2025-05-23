// name: Cases by community name by priority
// description: Counts the number of cases by each community over a specified time period breaking them down by priority
// author: sekoia.io
// license: mit
// tags:
//   - mssp
//   - multi-tenant
//	 - columchart
// query:

let earliestTime = ago(7d);
let lastestTime = now();

cases
| where updated_at between (earliestTime .. lastestTime)
| aggregate count_of_cases = count() by community_uuid, priority
| inner join communities on community_uuid == uuid
| render columnchart with (x=community.name, y=count_of_cases, breakdown_by=priority)