# SQL Sustainability Analysis

A SQL data analysis project exploring device lifecycle, energy savings, and environmental impact using joins, aggregations, CTEs, CASE expressions, and window functions.

## Project Goals

This project analyzes device repurposing data to identify patterns in:

- Device age
- Energy savings
- CO₂ reduction
- Device type
- Regional sustainability impact

## SQL Concepts Demonstrated

- `JOIN`
- `CASE WHEN`
- Common Table Expressions (`WITH`)
- `COUNT`
- `AVG`
- `SUM`
- `GROUP BY`
- `ORDER BY`
- Window functions
- `PARTITION BY`
- Data segmentation and bucketing

## Analysis Included

The SQL script includes:

- Joining device and impact datasets
- Calculating device age
- Creating age buckets:
  - newer
  - mid-age
  - older
- Calculating overall sustainability metrics
- Comparing environmental impact by device type
- Comparing impact by device age
- Comparing impact by region
- Calculating each device type's percentage contribution within each region

## Technologies

- SQL
- Relational databases
- Data aggregation
- Analytical queries

## Project Structure

```text
sql-sustainability-analysis/
├── sustainability_analysis.sql
└── README.md
```

## Example Analysis

The project creates age categories using a `CASE` expression:

```sql
CASE
    WHEN 2024 - d.model_year <= 3 THEN 'newer'
    WHEN 2024 - d.model_year <= 6 THEN 'mid-age'
    ELSE 'older'
END AS device_age_bucket
```

It also uses window functions to calculate the percentage of regional environmental impact contributed by each device type.

## Key Skills Demonstrated

- Combining datasets using relational joins
- Transforming raw fields into analytical variables
- Aggregating large datasets
- Segmenting records into meaningful categories
- Comparing sustainability metrics across multiple dimensions
- Using window functions for within-group percentage analysis

## Academic Context

Developed as part of a SQL sustainability impact analysis project focused on device repurposing and environmental performance.

## Author

**Angel Abrigo**

Information Science Student — University of Maryland  
A.S. in Computer Science — Montgomery College
