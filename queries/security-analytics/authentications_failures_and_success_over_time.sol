// name: Authentications - failures and success over time
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - authentications
//   - columnchart
// query:

let authentication_labels = {"failure": "Failed login", "success": "Success login"};

events
| where timestamp >= ago(7d) and event.category == "authentication"
| aggregate count() by event.outcome, bin(timestamp, 12h)
| extend authentication_outcome = authentication_labels[event.outcome]
| render columnchart with (x=timestamp, y=count, breakdown_by=authentication_outcome)