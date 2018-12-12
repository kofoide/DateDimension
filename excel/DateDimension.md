# Date Dimension in Excel

Excel Column | Column Name | Column Definition | Calculation
--- | --- | --- | ---
A | ThisDate | This is the only column you need to supply. It needs to be sorted from oldest date to newest date with no gaps. | 
B | YearNumber | This is the Year of the ThisDate as a number. | ```=YEAR(A2)```
C | QuarterOfYearNumber | This is the Quarter of the Year ThisDate is in | ```=ROUNDUP(E2/3, 0)```
D | YearQuarterNumber | Year and Quarter as a single number. This column is mainly used as the basis for future calculations [QuarterBeginDate, QuarterEndDate, CalendarQuarterRank] | ```=B2*10 + C2```
E | MonthOfYearNumber | Month of the Year as a number that ThisDate is in | ```=MONTH(A2)```
F | YearMonthNumber | Year and Month as a single number | ```=B2*100 + E2```
G | DayOfYearNumber | Day of the Year | ```=A2-DATE(YEAR(A2), 1, 0)```
H | DayOfYearNumberLeapIngored | Day of the Year, but ignores Leap Day. This makes every year consistent. Lead Day is treated as the same day of the year as Feb 28 | ```=IF(MOD(B2, 4) = 0, IF(G2>59, G2-1, G2), G2)```
I | DayOfQuarterNumber | Day of the Quarter | ```=A2-N2 + 1```
J | DaysRemainingInQuarterNumber | Day of the Quarter but in reverse. Shows how many days are remaining in the quarter | ```=O2-A2+1```
K | ThisDate2 | Copy of ThisDate, used to make calculations in other columns easier | ```=A2```
L | MonthBeginDate | First day of the month ThisDate falls in | ```=VLOOKUP(F2, $F$2:$K$1828, 6,  FALSE)```
M | MonthEndDate | Last day of the month ThisDate falls in | ```=LOOKUP(2, 1/($F$2:$K$1828=F2),$A$2:$A$1828)```
N | QuarterBeginDate | First day of the quarter ThisDate falls in | ```=VLOOKUP(D2, $D$2:$K$1828, 8, FALSE)```
O | QuarterEndDate | Last day of the quarter ThisDate falls in | ```=LOOKUP(2, 1/($D$2:$D$1828=D2),$A$2:$A$1828)```
P | CalendarMonthRank | Ranks the months in the table from 1 to end. Exists for other column calculations | ```=SUMPRODUCT( (FREQUENCY($F$2:$F$1828, $F$2:$F$1828) > 0) * (F2 >= $F$2:$F$1829) )```
Q | CalendarQuarterRank | Ranks the quarters in the table from 1 to end. Eixsts for other column calculations | ```=SUMPRODUCT( (FREQUENCY($D$2:$D$1828, $D$2:$D$1828) > 0) * (D2 >= $D$2:$D$1829) )```
R | TodayYearNumber | Year "TODAY" falls in. (Mainly for calcuations) | ```=VLOOKUP(TODAY(), $A$2:$B$1828, 2, FALSE)```
S | TodayQuarterNumber | Quarter "TODAY" falls in | ```=VLOOKUP(TODAY(), $A$2:$G$1828, 7, FALSE)```
T | TodayMonthNumber | Month "TODAY" falls in. (Mainly for calcuations) | ```=VLOOKUP(TODAY(), $A$2:$E$1828, 5, FALSE)```
U | TodayDayOfYearNumber | Day of year "TODAY" is | ```=VLOOKUP(TODAY(), $A$2:$G$1828, 7, FALSE)```
V | TodayDayOfYearNumberLeapIgnored | Day of year "TODAY" is leap day ignored | ```=VLOOKUP(TODAY(), $A$2:$H$1828, 8, FALSE)```
W | TodayDayOfQuarterNumber | Day of quarter "TODAY" is | ```=VLOOKUP(TODAY(), $A$2:$I$1828, 9, FALSE)```
X | TodayQuarterRankNumber |  | ```=VLOOKUP(TODAY(), $A$2:$Q$1828, 17, FALSE)```
Y | TodayMonthRankNumber |  | ```=VLOOKUP(TODAY(), $A$2:$P$1828, 16, FALSE)```
Z | RelativeYearNumber | The number of years ThisDate is from "TODAY" | ```=B2 - R2```
AA | RelativeQuarterNumber | The number of quarters ThisDate is away from the quarter "TODAY" is in | ```=Q2 - X2```
AB | RelativeMonthNumber | The number of months ThisDate is away from the month "TODAY" is in | ```=P2 - Y2```
AC | CalendarQuarterOfYearSortedPicklistUniqueLabel | [Click here for definition](CalendarQuarterOfYearSortedPicklistUniqueLabel.md) | ```=IF(Z2>0,AG2&" Q"&AH2,IF(Z2 < 0," "&AG2&" Q"&AH2, " Current Quarter"))```
AD | CalendarMonthOfYearSortedPicklistUniqueLabel | Click here for definition | ```=IF(Z2>0,AG2&" M"&AI2,IF(Z2 < 0," "&AG2&" M"&AI2, " Current Month"))```
AE | IsParallelCalendarYTDByDayBoolean | Click here for definition | ```=IF(H2 <= V2, TRUE(), FALSE())```
AF | IsParallelCalendarQTDAnyQuarterByDayBoolean | Click here for definition | ```=IF(I2 <= W2, TRUE(), FALSE())```
AG | YearNumberString | Year of ThisDate represented as a string | ```=TEXT(B2, "0")```
AH | QuarterNumberString | Quarter of ThisDate represented as a string | ```=TEXT(C2, "0")```
AI | MonthNumberString | Month of ThisDate represented as a string, if in 1-9, a 0 is added to front of the string | ```=IF(LEN(TEXT(E2, "0")) = 1, "0" & TEXT(E2, "0"), TEXT(E2,"0"))```
AJ | CalendarQuarterOfYearUniqueLabel | Year and Quarter ThisDate is in as a string "2000 Q1" | ```=AG2 & " Q" & AH2```
AK |  |  | ``````