# Emergency_Service_Triage_South_Korea
Triage accuracy using the Korean Triage and Acuity Scale (KTAS) and evaluate the causes of mistriage - SQL Server.

1. Data Source:
-  Data source found on Kaggle, then linked to the original data set in PLOS Journals (Kaggle Link).
- This cross-sectional retrospective study was based on 1267 systematically selected records of adult patients admitted to two emergency departments between October 2016 and September 2017.
- Twenty-four variables were assessed, including chief complaints, vital signs according to the initial nursing records, and clinical outcomes.
- Three triage experts, a certified emergency nurse, a KTAS provider and instructor, and a nurse recommended based on excellent emergency department experience and competence determined the true KTAS.
- Triage accuracy was evaluated by inter-rater agreement between the expert and emergency nurse KTAS scores.
- CSV file with 1267 rows and 24 columns.

2. Data Exploration:
- In SQL, the main skills used were Joins, CTE, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types.
- Get aquainted with the data and performed the main tasks:
- Check for null values in KTAS_RN and KTAS_expert;
- Cast age from double to integer;
- Convert 1 and 2 to female and male;
- Calculate mistriage and blood pressure calculation;
- Minimum, average, maximum length of stay in minutes, group and order by disposition;
- Search for acute diagnosis and compare patients complaint with nurse diagnosis;
- Creating views to store data for later visualization:
- All records partition by mistriage disposition;
- Records under and over triage.
