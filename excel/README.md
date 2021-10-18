# Date Dimension in Excel

The DatesSmall.xlsx file contains a single row for each date. This file begins with 1/1/2018 and ends with 12/31/2023.

Each row has computed columns that represent some sort of date math information about the date. Many of the columns are straightforward and seemingly obvious. Some are not so obvious. A dictionary tab is included in the xlsx doc that explains each column.

An example Tableau workbook is also included that references Superstore and the Dates worksheet in the xlsx file. A relationship between Superstore.OrderDate & Dates.ThisDate has already been setup.

Columns with words "Relative" or "Parallel" have values that change every day automatically when you open/use the file. They are formulas that do a calcuation that uses the TODAY() function. If you are extracting data into Tableau, you will need to extract from this file once every day.