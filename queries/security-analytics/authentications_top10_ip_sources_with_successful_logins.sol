// name: Authentications - Top 10 IP Sources with successful logins
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - authentications
//   - barchart
// query:

events
| where timestamp >= ago(7d) and event.category == "authentication" and event.outcome == "success"
| aggregate count() by source.ip
| order by count desc
| limit 10
| render barchart with (x=count, y=source.ip)