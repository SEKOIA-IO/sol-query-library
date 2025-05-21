// name: Authentications - Top 10 Network Assets with failed logins
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - authentications
//	 - barchart
// query:

let network_assets_uuids = assets
| where type == "network"
| select uuid;

let network_assets_full = assets
| where type == "network";

events
| where timestamp >= ago(7d) and event.category == "authentication" and event.outcome == "failure"
| aggregate count() by sekoiaio.any_asset.uuid
| where sekoiaio.any_asset.uuid in network_assets_uuids
| lookup network_assets_full on sekoiaio.any_asset.uuid == uuid
| order by count desc
| limit 10
| render barchart with (x=count, y=asset.name)