// name: Authentications - Top 10 Host Assets with successful logins
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - authentications
//   - barchart
// query:

let host_assets_uuids = assets
| where type == "host"
| select uuid;

let host_assets_full = assets
| where type == "host";

events
| where timestamp >= ago(7d) and event.category == "authentication" and event.outcome == "success"
| aggregate count() by sekoiaio.any_asset.uuid
| where sekoiaio.any_asset.uuid in host_assets_uuids
| lookup host_assets_full on sekoiaio.any_asset.uuid == uuid
| order by count desc
| limit 10
| render barchart with (x=count, y=asset.name)