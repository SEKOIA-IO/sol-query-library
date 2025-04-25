// name: Shell script run
// description: 
// author: sekoia.io
// license: mit
// tags:
//   - 
// query:

let earliestTime = ago(1d);
let lastestTime = now();

events
| where updated_at between (earliestTime .. lastestTime)
| where file.name matches regex '\.sh'