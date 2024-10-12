---
title: SQL Database Analysis using OpenAI Assistants
date: "2024-10-12T12:00:00.000Z"
description: "Writing database queries that know your DB schema with OpenAI's Assistants framework."
---

Generative AI tools can make writing SQL very easy: you can write down a question and the LLM will translate it into a SQL query that provides the answer. This can save a lot of time for those who are less than fluent in SQL. For example, you can just write, "how many orders have been placed by each customer this month?" instead of looking up every table name and working out the `JOIN` and `GROUP BY` syntax. For me, this has been a huge time-saver when analyzing product usage.

In order for this to work, you need to do 3 things:

1) Provide your database schema to the LLM;
2) ask questions in a way that makes sense; and
3) validate that the results aren't hallucinated trash.

This article discusses using OpenAI's Assistant Playground as a tool to take care of part 1. For now, 2 and 3 are still in human hands.


## Database Schema File

Before the LLM can generate queries, it needs to know our database structure. For this, we'll need a schema definition file.

If you have a schema definition file already, use that (for example, the Prisma ORM has a `schema.prisma` file). If that's not convenient, you can save the existing DB structure to a file using a command like this for PostgreSQL:

```sh
$ pg_dump --schema-only my_db >> my_db_schema_dump.sql
```

For illustration purposes, I've created a DB structure for a fake marketplace app called TradeSphere. The app contains `companies` that are either buyers or sellers, `orders` between the companies, and related data like items, invoices, and payments. Here's a schema diagram:

![TradeSphere Schema Diagram](./schema-diagram.png)


## Upload Schema to OpenAI Assistants Playground

With the Assistants Playground, we can upload our schema file as a reference:

![OpenAI Assistants File Search: Upload schema file](./openai-assistants-upload-schema-file.png)

This provides the Assistant with the DB schema moving forward. No more copy-pasting the schema in every conversation! *(Until the next big DB migration, at least...)*

I've also added a system prompt with instructions to reference the schema file, which seemed to help reduce hallucinations. It may be useful to add more context to the system prompt, such as:
- "When relevant, group data by customer."
- "When adding up item costs, include the tax percentage in the total."
- "Call out possible performance impacts. The `orders` table has 5 million records."

> ⚙️ *One bug/feature of the Assistants UX is that it doesn't accept `.sql` files. Rename the schema file's extension to `.txt` to get around this.*

## Ask Questions ➡️ Get SQL Queries

Now we can have fun querying our DB with human language. Let's try a prompt:

> Show me order volume by customer, including how much has been paid and how much is outstanding. Sort by most order volume first.

The playground spits out a SQL query:

![Assistants Playground Customer Volume Query](./playground-query-1.png)

Copy-pasting this into a SQL client, we get:

![Customer Volume Query Results](./playground-query-1-results.png)

Cool!


## Fact-Checking and Hallucinations

As usual with AI tools, there can be hallucinations. This isn't a replacement for having a good understanding of your datamodel: the LLM can miss nuances that aren't explicitly called out.

Documentation pays off here. If you have a schema definition file where each table has a comment explaining its usage (and ideally, each field has the same), the LLM will use that to construct more accurate queries.

## Privacy

Before using AI for production data or code, you need to think about where that data is going.

Is the AI provider training on your data? This could potentially lead to your IP being leaked. The OpenAI API, including the Assistants API and Playground, doesn't train on any data submitted to it. Per their [policies](https://openai.com/enterprise-privacy/) at the time of writing, inputs from the API are excluded from training by default. This includes the Assistants Playground, which is just a UI wrapper around the Assistants API.

Even with those terms, most of us want to minimize -- or completely eliminate -- the exposure of actual database records to third-party providers. In some cases, this may be a contractual or regulatory requirement. With the approach described here, we aren't sending any actual data through the LLM, just the DB schema.

That being said, consider this carefully for your use case. The same techniques here can be used with an open-source, self-hosted LLM. Generate a little code for a UX or command-line interface, and you've built your own SQL data analyst.

## Let's Go Build (the right) Stuff 🚀

Speaking for myself, I've often underestimated the value of DB analysis to determine where problems might lie in an application. Being able to iterate through SQL queries quickly and easily removes one hurdle to digging into the data.

Data > code. Let's use it to make better software.
