// name: Authentications - Count by Intakes over time
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - authentications
//	 - linechart
// query:

events
| where timestamp >= ago(7d) and event.category == "authentication"
| aggregate count() by sekoiaio.intake.uuid, bin(timestamp, 6h)
| inner join intakes on sekoiaio.intake.uuid == uuid
| inner join entities on intake.entity_uuid == uuid
| extend intake_custom_name = entity.name + " - " + intake.name
| render linechart with (x=timestamp, y=count, breakdown_by=intake_custom_name)