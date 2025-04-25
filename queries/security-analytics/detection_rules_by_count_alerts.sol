// name: Detection rules ranked by number of alerts
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - barchart
// query:

let earliestTime = ago(7d);
let lastestTime = now();

alerts
| where created_at between (earliestTime .. lastestTime)
| aggregate count() by rule_name
| order by count desc
| render columnchart with (x=rule_name, y=count)