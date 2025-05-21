// name: Authentications - Top 10 Sources Tags with successful logins
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - authentications
//   - barchart
// query:

events
| where timestamp >= ago(7d) and event.category == "authentication" and event.outcome == "success"
| aggregate count() by sekoiaio.tags.source.ip
| order by count desc
| limit 10
| render barchart with (x=count, y=sekoiaio.tags.source.ip)