// name: Count of alerts by community
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - mssp
//   - multi-tenant
// query:

let earliestTime = ago(1d);
let lastestTime = now();

alerts
| where created_at between (earliestTime .. lastestTime)
| aggregate count=count() by community_uuid
| join communities on community_uuid == uuid
| render columnchart with (x=community.name, y=count)