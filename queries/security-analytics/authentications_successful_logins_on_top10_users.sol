// name: Authentications - Successful logins on Top 10 new Users
// description: Successful logins on recently created Assets of type User
// author: sekoia.io
// license: mit
// tags:
//   - authentications
//   - barchart
// query:

let new_users_uuids = assets
| where type == "account" and created_at >= ago(7d)
| select uuid;

let new_users_full = assets
| where type == "account" and created_at >= ago(7d);

events
| where timestamp >= ago(7d) and event.category == "authentication" and event.outcome == "success"
| where sekoiaio.any_asset.uuid in new_users_uuids
| aggregate count() by sekoiaio.any_asset.uuid
| lookup new_users_full on sekoiaio.any_asset.uuid == uuid
| order by count desc
| limit 10
| render barchart with (x=count, y=asset.name)