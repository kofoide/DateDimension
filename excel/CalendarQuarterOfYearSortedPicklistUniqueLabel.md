# CalendarQuarterOfYearSortedPicklistUniqueLabel

This attribute's main purpose is in the use of filtering and being able to have the "Current Quarter" the default, for instance a Tableau filter.

All the dates in the Current Quarter have a label of " Current Quarter". Notice the space in front of the word Current. This is for sorting.

All the dates prior to the Current Quarter are labeled " YYYY QX". The dates after the Current Quarter are "YYYY QZ".

Example:

Today is 1/20/2018. So today is in Q1 of 2018. It's Label will be " Current Quarter".

If you are looking at a record with date of 12/10/2017, it's label will be " 2017 Q4".
If you are looking at a record with a date of 7/4/2018, it's label will be "2018 Q3"

When you sort the DISTINCT labels you get:

" 2017 Q4"
" Current Quarter"
"2018 Q3"

In Tableau, you can set the default to " Current Quarter". This way no matter what today is. The default will be to the Current Quarter.