# HR Attrition and Engagement

## Business question
Which departments and tenure bands had the highest attrition, and did leavers report lower engagement than people who stayed?

## Data and method
All data is synthetic. It is not real employee or company data. The file lists the 300 employees on payroll on 2025-01-01, and 54 of them left during 2025. Cleaning steps (written in Power Query M in Queries.pq, not yet run in Power BI Desktop; the .pbix embeds the already-cleaned tables):
- Fixed 3 rows where hire date and leave date were swapped.
- Set 6 engagement scores of 99 (a placeholder) to null. With 40 existing nulls, 254 valid scores remain.
- Used DIVIDE so Data Science, which has no employees, shows a blank attrition rate, not 0%.

## Findings
Attrition was 18.0% overall (54 of 300), and 40 leavers (74.1%) left voluntarily. By department: Sales 35.0%, Marketing 20.0%, Operations 17.1%, Engineering 12.5%, Finance 6.7%, HR 5.0%. By tenure: under 1 year 35.0%, 1-3 years 17.5%, 3 years or more 10.0%. Average engagement was 2.67 for leavers and 3.94 for stayers, a gap of 1.26.

## Model and measures
Star schema: FactEmployment linked many-to-one to DimDate (via leave date, with a YearMonth column for chart ordering), DimDepartment and DimLocation. Measures: Opening Headcount, Leavers (counts non-blank leave dates), Attrition Rate, Voluntary Share, Avg Engagement, Avg Engagement Leavers, Avg Engagement Stayers, Engagement Gap. Monthly Attrition Rate divides that month's leavers by the full-year opening headcount of 300, so the twelve monthly rates add up to 18.0%. The engagement measures cover the full year and ignore any month filter. The report has two pages: attrition overview, and engagement signal.

## Limits
Small synthetic sample, for illustration only. Low engagement here is an association, not a proven cause of leaving. Small departments give unstable rates.

## Status
Results were recomputed in Python (pandas) and the DAX was checked with a third-party DAX engine. The generated .pbix file has not yet been opened in Power BI Desktop and still needs to be tested there.

## Provenance
Design (schema, measures, report pages, data rules) was drafted with Claude, then implemented by a separate tool chain. Data generation, the .pbix build and all number checks were done outside Claude. Nothing here is verified by Claude or by Power BI Desktop. Prepared with assistant support, not prior independent work or a real company engagement.
