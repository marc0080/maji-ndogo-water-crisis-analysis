# Maji Ndogo: From Analysis to Action

## Project Overview

Maji Ndogo is an end-to-end SQL data analysis simulation investigating a national water crisis in a fictional country.

Working as a Data Analyst, I analysed a 60,000-record survey database to investigate water accessibility, infrastructure conditions, water quality, collection times and potential data integrity issues.

The objective was to transform raw data into actionable insights that could support evidence-based water infrastructure and service delivery decisions.

## Business Problem

Millions of people face challenges accessing reliable and safe water. The project investigated:

- Which water sources serve the largest populations?
- Where are the most significant water quality and infrastructure problems?
- When do communities experience the longest water collection queues?
- How reliable are employee water quality assessments?
- Are there indicators of potential misconduct requiring further investigation?

## Tools & Technologies

- MySQL
- SQL
- MySQL Workbench

## Analytical Process

### 1. Data Exploration and Cleaning
- Explored database structure and relationships.
- Investigated inconsistencies in water pollution classifications.
- Corrected 38 misclassified pollution records.
- Cleaned employee contact information.

### 2. Water Access and Infrastructure Analysis
- Analysed water source distribution across urban and rural locations.
- Evaluated population coverage by water source.
- Identified shared taps as serving approximately 43% of the population.
- Investigated broken household water infrastructure and well contamination.
- Applied SQL window functions to prioritize water sources for intervention.

### 3. Queue Time Analysis
- Analysed water collection patterns across 924 days.
- Calculated average queue times and identified peak collection periods.
- Used conditional aggregation to compare waiting times by day and hour.
- Identified periods requiring targeted water distribution interventions.

### 4. Audit and Data Integrity Investigation
- Integrated independent auditor reports with employee assessments.
- Evaluated agreement between employee and auditor water quality scores.
- Established 94% agreement after resolving duplicate records.
- Identified four employees with above-average reporting discrepancies for further investigation.

## Key Findings

- Shared taps served approximately 43% of the surveyed population.
- Only 28% of wells were classified as clean.
- Broken household water infrastructure represented a significant service delivery gap.
- Average water collection queue time was approximately 123 minutes.
- Employee and auditor assessments agreed in approximately 94% of cases.

## Recommendations

- Prioritize shared tap infrastructure to improve access for large populations.
- Repair broken household water infrastructure.
- Introduce appropriate water treatment interventions based on contamination type.
- Optimize water distribution during peak collection periods.
- Investigate suspicious reporting patterns through appropriate audit procedures.

## Skills Demonstrated

SQL data cleaning, data validation, relational database analysis, joins, CTEs, subqueries, aggregate functions, window functions, date-time analysis, conditional aggregation, data integrity investigation and analytical storytelling.

## Project Structure

See the `sql/` directory for the queries organized by analytical stage and `documentation/` for project findings and recommendations.
