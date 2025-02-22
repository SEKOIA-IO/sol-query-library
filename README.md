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
| limit 100
```

This query can be logically described as:

1. Get all data in the `events` table
2. `where`
	* the `timestamp` property of an event is greater than 5 days ago `and`
	* the `user_agent.device.name` of an event is `Mac`
3. Limit the results to the first `100` events returned

## SQKL Quick-Start

### Time

The Sekoia Platform will then run through a SQKL query sequentially, so it will run each line one by one until it hits the end, or you have an error. It is therefore very important to consider the logical order of your query from performance perspective/

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

Days:

```sql
events
| where timestamp > ago(7d)
```

Hours:

```sql
events
| where timestamp > ago(7h)
```

Minutes:

```sql
events
| where timestamp > ago(7m)
```

SKQL also supports querying between time ranges:

```sql
events
| where timestamp between (ago(14d) .. ago(7d))
```

The query above searches the `events` table for events between 14 days and 7 days ago.


### Where 



