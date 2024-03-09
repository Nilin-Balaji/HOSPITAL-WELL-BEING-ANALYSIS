This Project presents a comprehensive solution for optimizing hospital operations through data-driven analysis. 
Leveraging a relational database model, dimensional modeling, and OLAP cube construction, the project facilitates efficient data organization and insightful querying. 
The ETL process, implemented using SQL queries and SSIS packages, ensures seamless data extraction, transformation, and loading. 
MDX queries enable in-depth analysis of metrics such as patient admissions, nurse performance, and resource allocation.  
Through visualizations and extensive documentation, this project offers a valuable toolkit for hospitals seeking to enhance efficiency and patient care.

**Key Features:**

**Relational Database Model:**
•Implemented a relational database model to organize and structure the Referral Intake Management System dataset obtained from Kaggle.
•Employed normalization techniques to reduce redundancy and improve data integrity.

**Dimensional Model:**
•Created dimensional model tables to facilitate efficient querying and analysis.
•Dimension tables include information about patients, nurses, departments, and dates, while fact tables capture relevant metrics such as patient admissions, nurse performance, and patient outcomes.

**ETL Process:**
•Utilized Extract, Transform, Load (ETL) processes to extract data from the source database, transform it as per business requirements, and load it into the dimensional model.
•Implemented ETL using SQL queries and SSIS (SQL Server Integration Services) packages.

**Multi-Dimensional Cube:**
•Built a multi-dimensional cube (OLAP cube) to enable interactive and insightful analysis of hospital operations data.
•Defined hierarchies for nurses, departments, and calendar attributes to facilitate data exploration at various levels of granularity.

**MDX Queries:**
•Developed MDX queries for querying the OLAP cube to extract relevant insights.
•MDX queries enable analysis of metrics such as total patients handled by nurses, average time spent by patients in the hospital, and total minutes spent by patients.
