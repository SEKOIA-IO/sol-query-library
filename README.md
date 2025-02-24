# SKQL Query Library

## Overview

The Sekoia Query Language (SKQL) is used across by the Sekoia platform for both security analytics and threat hunting use-cases.

This repository contains both guidance and real examples of SKQL queries.

## The Anatomy of a SKQL Query

A SKQL query consists of a sequence of statements connected by the **Pipe** (`|`) operator, where the output of one statement serves as the input for the next. The **Pipe** operator allows you to build complex queries from a series of simple, modular steps.

Queries reference different types of data held within the Sekoia platform as **Tables**. **Tables** hold **Datasources**. Each **Datasource** has defined properties. Typically, but not always, a **Table** is defined in the first line of a query

As an example:

```sql
events
| where timestamp > ago(5d) and user_agent.device.name == 'Mac'
| aggregate count() by user.name
| order by count desc
| limit 10
| render barchart with (x=count,y=user.name)
```

This query can be logically described as:

1. Get all data in the `events` table
2. `where`
	* the `timestamp` property of an event is greater than 5 days ago `and`
	* the `user_agent.device.name` of an event is `Mac`
3. Count the number of results by the `user.name` value in the events
4. Order the results by descending `count` (i.e. `user.name` with highest number of matching event first)
5. Then limit the sorted results to the first `10` events
6. Render these results as a bar chart

The Query produces the following graph;

![](/assets/images/overview-bar-chart.png)

## SKQL Performance Considerations

The Sekoia Platform runs through a SKQL query sequentially (as described above) That is to say; the Sekoia Platform will run each line one by one until it hits the end, or you have an error.

It is therefore **very important** to consider the logical order of your query from performance perspective.

![](/assets/images/skql-query-flow.jpg)

The above diagram simplifies an efficient query pipeline.

Generally when writing SKQL queries you should try to order the logic as follows (I map the example SKQL query used above to demonstrate);

1. select the data
	* `events`
2. filter the results set in the defined table
	* `where timestamp > ago(5d) and user_agent.device.name == 'Mac'`
3. analyse the filtered results and pivot
	* `| aggregate count() by user.name`
4. prepare the result set
	* `| order by count desc | limit 10`
5. render the result set
	* `| render barchart with (x=count,y=user.name)`

## Sigma Rules vs. SKQL Rules

The Sekoia Platform supports Sigma detection rules and correlation rules.

One of the first questions you might have is; when do I use Sigma over SKQL?

Sigma Rules are best suited to detection use-cases in the Sekoia Platform. Whilst SKQL can also achieve the same type of detection logic in the queries as Sigma, Sigma Rules can be enhanced with additional contextual information, including MITRE ATT&CK and required intakes.

SKQL are well suited to hunting, security reporting and analytics based use-cases. Unlike Sigma which is limited to live telemetry events data to make detections, SKQL queries can hunt on historic data. KSQL also has access to multiple Datasources across the Sekoia platform including telemetry events, alerts, cases, intakes and communities to support reporting and analytic based queries.

## SKQL Quick-Start

### Time

The Sekoia Platform and SKQL are highly optimised for time filters.

Therefore, if you know the time period of data you want to search, you should filter the time range straight away.

To demonstrate, the following example is **a good approach** to filter by time:

```sql
events
| where timestamp > ago(7d)
| where user.email == "denholm.reynholm@reynholm.com"
```

Retrieving the last 7 days of logs, then searching for a user email in those logs.

Compare this to the following example that achieves the same output, however, is **a bad approach** to filter by time:

```sql
events
| where user.email == "denholm.reynholm@reynholm.com"
| where timestamp > ago(7d)
```

Retrieving a user email in potentially years of logs, and then filtering the results to only include those where the email has been seen in the last 7 days.

SKQL has many options for querying particular time periods:

* Days: e.g. 7 days `ago(7d)`
* Hours: e.g. 7 hours `ago(7h)`
* Minutes: e.g. 7 minutes `ago(7m)`
* Seconds: e.g. 7 seconds `ago(7s)`
* Now: e.g. time of query execution `now()`

Time ranges can also be specified in SKQL:

```sql
events
| where timestamp > ago(14d) and timestamp < now()
```

The query above searches the `events` table for events between 14 days and now.

The same result can be achieved more elegantly using the `between` Operator:

```sql
events
| where timestamp between (ago(14d) .. now())
```

### `where` basics 

The `where` Clause is used to filter rows in a dataset based on specified conditions or criteria. Almost all queries will contain a `where` Clause.

Case sensitivivity is very important to consider when using the `where` Clause.

```sql
events
| where timestamp > ago(7d)
| where user.email == "denholm.reynholm@reynholm.com"
```

The Query above will match events where the `user.email` value is `denholm.reynholm@reynholm.com`. However;

```sql
events
| where timestamp > ago(7d)
| where user.email == "DENHOLM.REYNHOLM@REYNHOLM.COM"
```

Will **NOT** match events where the `user.email` value is `denholm.reynholm@reynholm.com`.

The `where` clause can be used to search events for multiple values;

```sql
events
| where timestamp > ago(7d)
| where user.email == "denholm.reynholm@reynholm.com" or user.email == "jen.barber@reynholm.com"
```

This query searches for events where the `user.email` property is equal to `denholm.reynholm@reynholm.com` or `jen.barber@reynholm.com`.

`in` allows for the same query output, but forms the query in a more easy to read way; 

```sql
events
| where timestamp > ago(7d)
| where user.email in ['denholm.reynholm@reynholm.com', 'jen.barber@reynholm.com']
```

Where you are not sure of the full property value the `contains` value becomes useful.

```sql
events
| where timestamp > ago(7d)
| where user.email contains "barber"
```

The above query would match `jen.barber@reynholm.com`, `barber@reynholm.com`, etc.

If you know the start or end of the string, you can also use `startswith` or `endswith` instead of `contains` to produce a more efficient search.

For example, if you wanted all users with the same email domain;

```sql
events
| where timestamp > ago(7d)
| where user.email endswith "@reynholm.com"
```

This query would match `jen.barber@reynholm.com`, `denholm.reynholm@reynholm.com`, but not `jen.barber@sekoia.io`, etc.

Or a specific email user;

```sql
events
| where timestamp > ago(7d)
| where user.email startswith "denholm.reynholm@"
```

This query would match `denholm.reynholm@reynholm.com`, `denholm.reynholm@sekoia.io`, but not `jen.barber@reynholm.com`, etc.

A number of these options also support using `!` to reverse the query and find results when the logic is not true.

```sql
events
| where timestamp > ago(7d)
| where user.email != "denholm.reynholm@reynholm.com"
```

In this query all events within the last 7 days where the `user.email` does not equal `denholm.reynholm@reynholm.com` would be returned.

### Aggregation

When a set of event is results from filtering queries (using `where`) you will often want to perform additional calculations based on the results returned.

```sql
events
| where timestamp > ago(7d)
| aggregate count() by sekoiaio.any_asset.name
```

Will count the number of events by `sekoiaio.any_asset.name`. It will produce an output with the following data:

| sekoiaio.any_asset.name | count |
| ----------------------- | ----- |
| CSASSRV01               | 27942 |
| CSASSRV02               | 27985 |
| CSASSRV03               | 27985 |
| CSASSRV04               | 27681 |
| CSASSRV05               | 28103 |

You can also sort and filter the results returned.

```sql
events
| where timestamp > ago(7d)
| aggregate count() by sekoiaio.any_asset.name
| order by count desc
| limit 5
```

Will return the top 5 events (by count of events) with a `sekoiaio.any_asset.name`.

The following query achieves the same result slightly more efficiently using the `top` command:

```sql
events
| where timestamp > ago(7d)
| aggregate count() by sekoiaio.any_asset.name
| top 5 by count
```

`aggregate` also allows for mean averages to be calculated on numbers:

```sql
alerts
| where created_at > ago(7d)
| aggregate avg(time_to_detect), avg(time_to_acknowledge), avg(time_to_respond), avg(time_to_resolve)
```

Produces results that look as follows:

| avg_time_to_detect    | avg_time_to_acknowledge | avg_time_to_respond | avg_time_to_resolve   |
| --------------------- | ----------------------- | ------------------- | --------------------- |
| 2099.5072463768115942 | 3440.3333333333333333   | 22875.567567567568  | 3621.0468750000000000 |

You will often find instances where you want to rename properties for clarity. You can use `select` to do this by passing the `new_field_name` = `old_field_name` as follows

```sql
alerts
| where created_at > ago(7d)
| aggregate avg(time_to_detect), avg(time_to_acknowledge), avg(time_to_respond), avg(time_to_resolve)
| select avg_time_to_detect_seconds = avg_time_to_detect, avg_time_to_acknowledge_seconds = avg_time_to_acknowledge, avg_time_to_respond_seconds = avg_time_to_respond, avg_time_to_resolve_seconds =  avg_time_to_resolve
```

Produces the updated table:

| avg_time_to_detect_seconds | avg_time_to_acknowledge_seconds | avg_time_to_respond_seconds | avg_time_to_resolve_seconds |
| -------------------------- | ------------------------------- | --------------------------- | --------------------------- |
| 2099.5072463768115942      | 3440.3333333333333333           | 22875.567567567568          | 3621.0468750000000000       |

You can also use nested aggregations. For example:

```sql
events
| where timestamp > ago(7d)
| aggregate count=count_distinct(user.name) by host.name
| where count >= 2
| order by count desc
```

Shows all the hosts reporting 2 or more distinct `user.name`s in events.

### Variables

You can also set Variables at the start of your query using the `let` Clause. Variables are useful where values are reused in queries, or when values are modified regularly (because it makes it easier for user to change at the top of the query).

```sql
let CompanyDomain = "@reynholm.com";

events
| where timestamp > ago(7d)
| where user.email endswith CompanyDomain
```

Above the query filter events that `endswith CompanyDomain` (`@reynholm.com`).

Variables can also call functions. For example:

```sql
let StartTime = ago(24h);
let EndTime = now();

events
| where event.created >= StartTime and event.created <= EndTime
| count
```

Here the query counts events between `StartTime` (`ago(24h)`) and `EndTime` (`now()`).

### Joins

### Visualisation

When preparing an output, [you can define how you want the results to appear from a range of rendering options](https://docs.sekoia.io/xdr/features/investigate/sekoia_operating_language/#render-results-in-chart).

The default output is a table.

You can define the rows shown in the table using the `project` functions:

```sql
events
| where timestamp > ago(7d)
| where user.email endswith "@reynholm.com"
|
| project user.email, user_agent.os.name, server.ip
```

![](/assets/images/table-viz-example.png)

Bar chart:

```sql
alerts
| aggregate AlertCount = count() by community_uuid
| left join communities on community_uuid == uuid
| order by AlertCount desc
| select community.name, AlertCount
| render barchart with (x=AlertCount,y=community.name, breakdown_by=community.name)
```

![](/assets/images/bar-chart-example.png)

Line chart:

```sql
events
| where timestamp >= ago(7d)
| inner join intakes on sekoiaio.intake.uuid == uuid
| aggregate count() by sekoiaio.intake.uuid, bin(timestamp, 1d)
| inner join intakes on sekoiaio.intake.uuid == uuid
| render linechart with (x=timestamp, y=count, breakdown_by=intake.name)
```

![](/assets/images/line-chart-example.png)
