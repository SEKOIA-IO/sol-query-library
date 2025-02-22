# Query Library

## Overview

The Sekoia Query Language is used across by the Sekoia platform for both log analytics and threat hunting use-cases.

This repository contains both guidance and real examples of SKQL queries.

## The Anatomy of a SQKL Query

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
3. Limit the results to the first `100` events returned

This Query produces the following graph;

![](/assets/images/overview-bar-chart.png)

The Sekoia Platform runs through a SQKL query sequentially (as described above) That is to say; the Sekoia Platform will run each line one by one until it hits the end, or you have an error.

It is therefore **very important** to consider the logical order of your query from performance perspective.

Generally a query pipeline should take the following order (I map the query above to each part as an example);

1. select the table containing data
	* `events`
2. filter the results set in the defined table
	* `where timestamp > ago(5d) and user_agent.device.name == 'Mac'`
3. analyse the filtered results and pivot
	* `| aggregate count() by user.name`
4. prepare the result set
	* `| order by count desc | limit 100`
5. render the result set
	* `| render barchart with (x=count,y=user.name)`

## SQKL Quick-Start



When writing SKQL Queries it good to think about the order in which you construct the logic of each piped query.

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

This can be written as


```sql
events
| where timestamp > ago(7d)
| where user.email !contains "barber"
```

### Processing Results

When a set of event is results from filtering queries (using `where`) you will often want to conduct additional processing on these results to produce an output.


```sql
alerts 
| order by urgency desc, first_seen_at asc
| select short_id, rule_name, urgency, first_seen_at
| limit 100
```

Using t

You can also set Variables at the start of your query using the `let` Clause. Variables are useful where values are reused in queries, or when values are modified regularly

```sql
let StartTime = ago(24h);
let EndTime = now();

events
| where event.created > StartTime and event.created <= EndTime
| count
```


Instead of equals, we can also use contains.


