# RelativeQuarterNumber

This attribute helps you go back or forward a specific number of Quarters.

If Today is 1/20/2018, it is in 2018 Q1, but it is the Current Quarter which when relative to today is Quarter 0.
Tomorrow will be 1/21/2018, which is still in 2018 Q1 and so it has Relative Quarter of 0 too.

If you have a date in your set of 12/10/2017, it is in 2017 Q4, which is 1 quarter ago (compared to today 1/20/2018). It's Relative Quarter is -1, 1 quarter ago.

If you have a date in your set of 7/4/2018, it is in 2018 Q3, which is 2 quarters from now.
It's Relative Quarter is 2, or 2 quarters from now.


If my report wants to always include 4 quarters ago to this Quarter, I just have to filter on RelativeQuarterNumber BETWEEN -4 AND 0.  Which is kind of like a Trailing Twelve Months, only Trailing Four Quarters.