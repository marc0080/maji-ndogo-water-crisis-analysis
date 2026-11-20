# Maji Ndogo: Water Access Analysis & Infrastructure Improvement

## Project Overview

Maji Ndogo is a data analytics project focused on investigating water access, infrastructure challenges, and service delivery across different communities.

Using SQL, I explored and analysed water infrastructure data to identify patterns in water accessibility, pollution, queue times, and infrastructure conditions. The analysis was then translated into practical recommendations to guide engineering interventions and support project progress monitoring.

The project demonstrates how data analysis can move beyond identifying problems to supporting evidence-based decision-making and implementation planning.

## Project Objectives

- Investigate water access and infrastructure conditions across different locations.
- Analyse water source distribution, population served, and queue times.
- Identify contaminated water sources and broken infrastructure.
- Investigate data quality issues and potentially suspicious field-worker records.
- Develop data-driven recommendations for infrastructure improvements.
- Implement a database table to support engineering work allocation and progress tracking.

## Tools & Technologies

- **Database:** MySQL
- **Language:** SQL
- **Techniques:** Data exploration, data cleaning, filtering, aggregation, joins, subqueries, Common Table Expressions (CTEs), window functions, CASE statements, and database implementation.

## Project Workflow

### 1. Data Exploration
Examined the available datasets and database structure to understand the relationships between water sources, locations, field visits, and water quality records.

### 2. Data Cleaning and Validation
Investigated data quality issues, inconsistencies, and suspicious records to improve the reliability of subsequent analysis.

### 3. Water Access Analysis
Analysed water source distribution and population served to understand differences in access across locations.

### 4. Queue Time Analysis
Investigated waiting times at shared water points to identify communities experiencing significant access challenges.

### 5. Data Auditing
Investigated potentially suspicious field-worker records and documented findings to support data integrity and accountability.

### 6. Practical Implementation Plan
Translated the analysis into an engineering intervention plan.

Created a `Project_progress` table to store:

- Water source identification and location details.
- Recommended infrastructure improvements.
- Project status: Backlog, In progress, or Complete.
- Completion dates and engineering comments.

The table incorporates database constraints to maintain referential integrity and restrict project status values to predefined options.

The intervention plan identifies the following improvements:

| Water infrastructure issue | Recommended intervention |
|---|---|
| River water sources | Drill wells |
| Chemically contaminated wells | Install RO filters |
| Biologically contaminated wells | Install UV and RO filters |
| Shared taps with long queues (30+ minutes) | Install additional taps |
| Broken household taps | Diagnose local infrastructure |

## Repository Structure

| File | Description |
|---|---|
| `01_data_exploration.sql` | Initial database exploration |
| `02_data_cleaning.sql` | Data cleaning and validation |
| `03_water_access.sql` | Water access analysis |
| `04_queue_analysis.sql` | Queue time analysis |
| `05_water_access_summary_report...` | Water access findings and summary |
| `06_auditor's_analysis.sql` | Data auditing and investigation |
| `07_practical_plan.sql` | Engineering intervention planning and implementation |
| `Auditor_report.csv` | Supporting audit findings |

## Key Learning Outcomes

Through this project, I strengthened my ability to:

- Query and analyse relational databases using SQL.
- Combine multiple datasets using different JOIN operations.
- Apply analytical techniques to investigate real-world problems.
- Identify data quality issues and validate analytical results.
- Translate analytical findings into practical recommendations.
- Design database tables with primary keys, foreign keys, defaults, and CHECK constraints.
- Understand how databases can support operational monitoring and implementation tracking.

## Project Status

**Current milestone:** Engineering implementation planning and database progress-tracking structure.

The `Project_progress` table provides a foundation for tracking infrastructure improvement activities, recording completion dates, and capturing updates from engineering teams.

## Repository Contents

This repository contains the SQL scripts, supporting analysis, and project documentation developed throughout the Maji Ndogo project.

