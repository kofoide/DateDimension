## Date Dimension (No More Date Math - Ever)

A date dimension is vital if you do any reporting especially from a data warehouse. It is easier to use already calculated attributes about a specific date than to have to calcuate the attributes in the reporting environment. Also, a date dimension can store attributes for Fiscal Years which most reporting environments are incapble of calculating.

Some of the obvious attributes about a date are Year, Month, Day of Week, etc. This dimension has many more attributes, like How many quarters ago/in future is the date. Is the date in the YTD zone compared to today. As well as many more.

This project supplies you with date dimension objects for SQL Server and Excel. I plan on adding objects for PostgreSQL.

Do not move the columns around in the Excel version. Many of the column formulas rely on specific column locations.

In order for the "Relative" attributes to be correct, this information must be refreshed daily in your reporting system. Excel formulas and TSQL functions take care of the attributes for you. All you have to do is understand the attributes.

[See high level table definition here](excel/DateDimension.md)