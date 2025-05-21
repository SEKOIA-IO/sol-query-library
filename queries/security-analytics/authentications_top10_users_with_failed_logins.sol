// name: Authentications - Top 10 Users with failed logins
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - authentications
//   - barchart
// query:

events
| where timestamp >= ago(7d) and event.category == "authentication" and event.outcome == "failure"
| aggregate count() by user.name
| order by count desc
| limit 10
| render barchart with (x=count, y=user.name)