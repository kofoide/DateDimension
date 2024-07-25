--#region Relative Periods
-- Rankings for Relative Calculations
WITH RelativePeriods AS (
    SELECT
	    ID
    ,	DENSE_RANK() OVER(ORDER BY CalendarYearNumber, CalendarQuarterOfYearNumber) AS CalendarQuarterNumRank
    ,	DENSE_RANK() OVER(ORDER BY CalendarYearNumber, CalendarMonthOfYearNumber) AS CalendarMonthNumRank
    ,	DENSE_RANK() OVER(ORDER BY CalendarYearNumber, CalendarWeekOfYearNumber) AS CalendarWeekNumRank
    FROM dim.BaseDate
)
--#endregion


--#region Today Attributes
-- Data for Today
, Today AS (
    SELECT
        T.ThisDate                      AS Today
	,   T.CalendarYearNumber			AS CurrentCalendarYearNumber
    ,	T.CalendarQuarterOfYearNumber	AS CurrentCalendarQuarterOfYearNumber
    ,	T.CalendarMonthOfYearNumber		AS CurrentCalendarMonthOfYearNumber
    ,	T.CalendarWeekOfYearNumber		AS CurrentCalendarWeekOfYearNumber
    ,	T.CalendarDayOfYearNumber		AS CurrentCalendarDayOfYearNumber
    ,	T.CalendarDayOfQuarterNumber	AS CurrentCalendarDayOfQuarterNumber
    ,	T.CalendarDayOfMonthNumber		AS CurrentCalendarDayOfMonthNumber
    ,	T.CalendarDayOfWeekNumber		AS CurrentCalendarDayOfWeekNumber
    ,	RP.CalendarQuarterNumRank		AS CurrentCalendarQuarterNumRank
    ,	RP.CalendarMonthNumRank			AS CurrentCalendarMonthNumRank
    ,	RP.CalendarWeekNumRank			AS CurrentCalendarWeekNumRank
    FROM
                dim.BaseDate  	T
    INNER JOIN  RelativePeriods RP	ON T.ID = RP.ID
    WHERE
        T.ThisDate = CAST(GETDATE() AS DATE)
)
--#endregion


-- Beginning of the Returning Statement
SELECT
	D.ID
,	D.ThisDate
,   D.IsCompanyHolidayBoolean
,   D.IsWeekendBoolean
,   D.IsOfficeWorkdayBoolean


-- *******************************************************************
-- CALENDAR YEAR TTM
-- ************************************
--#region TTM
-- Is this day in the Trailing Twelve Months
,   CAST(
        CASE
            WHEN (RP.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank) BETWEEN -12 AND 0 AND D.ThisDate <= T.Today THEN 1
            ELSE 0
        END AS BIT) AS IsTTMBoolean
--#endregion
-- *******************************************************************


-- *******************************************************************
-- CALENDAR YEAR CALCULATIONS
-- ************************************
--#region Year
,	D.CalendarYearNumber

-- Date of the First Day of the Year ThisDate is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber ORDER BY D.ThisDate ASC) AS CalendarYearBeginDate

-- Date of the Last Day of the Year ThisDate is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber ORDER BY D.ThisDate DESC) AS CalendarYearEndDate


-- Number of Years Relative to the Current Year
,	D.CalendarYearNumber - T.CurrentCalendarYearNumber AS CalendarRelativeYearNumber

-- Label for Number of Years Relative to the Current Year
,	CAST(
        CASE
		    WHEN (D.CalendarYearNumber - T.CurrentCalendarYearNumber) = 0 THEN 'Current Year'
            WHEN (D.CalendarYearNumber - T.CurrentCalendarYearNumber) = 1 THEN 'Next Year'
            WHEN (D.CalendarYearNumber - T.CurrentCalendarYearNumber) = -1 THEN 'Previous Year'
		    WHEN (D.CalendarYearNumber - T.CurrentCalendarYearNumber) > 0 THEN CAST((D.CalendarYearNumber - T.CurrentCalendarYearNumber) AS VARCHAR) + ' Years From Now'
		    ELSE CAST(ABS(D.CalendarYearNumber - T.CurrentCalendarYearNumber) AS VARCHAR) + ' Years Ago'
	    END AS VARCHAR(20)) AS CalendarRelativeYearLabel

-- Is the DayOfYear for This date in the YTD zone
,	CAST(
        CASE
            WHEN D.CalendarDayOfYearNumber <= T.CurrentCalendarDayOfYearNumber THEN 1
            ELSE 0
        END AS BIT) AS IsParallelCalendarYTDByDayBoolean
--#endregion
-- *******************************************************************


-- *******************************************************************
-- CALENDAR QUARTER CALCULATIONS
-- ************************************
--#region Quarter
,	D.CalendarQuarterOfYearNumber

-- Date of the First Day of the Quarter ThisDate is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarQuarterOfYearNumber ORDER BY D.ThisDate ASC) AS CalendarQuarterBeginDate

-- Date of the Last Day of the Quarter ThisDate is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarQuarterOfYearNumber ORDER BY D.ThisDate DESC) AS CalendarQuarterEndDate

-- Quarter Of Year Unique Label
,	CAST(CAST(D.CalendarYearNumber AS VARCHAR) + ' Q' + CAST(D.CalendarQuarterOfYearNumber AS VARCHAR) AS VARCHAR(10)) AS CalendarQuarterOfYearUniqueLabel

-- Quarter Of Year Label
,	CAST('Q' + CAST(D.CalendarQuarterOfYearNumber AS VARCHAR) AS VARCHAR(5)) AS CalendarQuarterOfYearLabel

-- Number of Quarters Relative to Current Quarter
,	RP.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank AS CalendarRelativeQuarterNumber

-- Quarter Of Year Label for Picklist
--  This is meant to be sorted in ASC orderso that previous quarters are at top, current quarter is in the middle, future quarters are at the bottom
--  This is great for Tableau filters that you want the " Current Quarter" to be the default
,	CAST(
        CASE
            WHEN RP.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank = 0 THEN ' Current Quarter'
            -- Want the previous quarters to alpha sort above the word 'Current'
            WHEN RP.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank < 0 THEN ' ' + CAST(D.CalendarYearNumber AS VARCHAR) + ' Quarter ' + CAST(D.CalendarQuarterOfYearNumber AS VARCHAR)
            -- Want the future quarters to alpha sort below the word 'Current'
            ELSE CAST(D.CalendarYearNumber AS VARCHAR) + ' Quarter ' + CAST(D.CalendarQuarterOfYearNumber AS VARCHAR)
        END AS VARCHAR(20)) AS CalendarQuarterOfYearSortedPicklistLabel

-- Label for Number of Quarters Relative to Current Quarter
--  A different label
,	CAST(
        CASE
		    WHEN RP.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank = 0 THEN 'Current Quarter'
		    WHEN RP.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank = 1 THEN 'Next Quarter'
		    WHEN RP.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank = 0 THEN 'Previous Quarter'

		    WHEN RP.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank > 0
			    THEN CAST((RP.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank) AS VARCHAR) + ' Quarters From Now'
		    ELSE CAST(ABS(RP.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank) AS VARCHAR) + ' Quarters Ago'
	    END AS VARCHAR(20)) AS CalendarRelativeQuarterLabel

-- Ignoring year, what Quarter is this Date's Quarter compared to the Current Day's Quarter
,	(RP.CalendarQuarterNumRank - T.CurrentCalendarQuarterNumRank) % 4 AS CalendarRelativeQuarterByYearToCurrentQuarterNumber

-- Is the DayOfQuarter for This Date in the same QTD zone & in the SAME QuarterOfYear
,	CAST(
        CASE
		    WHEN D.CalendarDayOfQuarterNumber <= T.CurrentCalendarDayOfQuarterNumber
		    AND D.CalendarQuarterOfYearNumber = T.CurrentCalendarQuarterOfYearNumber
			    THEN 1
            ELSE 0
	    END AS BIT) AS IsParallelCalendarQTDSameQuarterByDayBoolean

-- Is the DayOfQuarter for This Date in the same QTD zone for ANY QuarterOfYear
,	CAST(
        CASE
            WHEN D.CalendarDayOfQuarterNumber <= T.CurrentCalendarDayOfQuarterNumber THEN 1
            ELSE 0
        END AS BIT) AS IsParallelCalendarQTDAnyQuarterByDayBoolean

-- Is this Day the End of a Quarter
,   CAST(
        CASE
            WHEN D.ThisDate = FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarQuarterOfYearNumber ORDER BY D.ThisDate DESC) THEN 1
            ELSE 0
        END AS BIT) AS IsCalendarEndOfQuarterDayBoolean
--#endregion
-- *******************************************************************


-- *******************************************************************
-- CALENDAR MONTH CALCULATIONS
-- ************************************
--#region Month
,	D.CalendarMonthOfYearNumber

-- Date of the First Day of the Month ThisDate is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarMonthOfYearNumber ORDER BY D.ThisDate ASC) AS CalendarMonthBeginDate

-- Date of the Last Day of the the Month ThisDate is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarMonthOfYearNumber ORDER BY D.ThisDate DESC) AS CalendarMonthEndDate

-- Calendar Month of Year Unique Label
,	CAST(CAST(D.CalendarYearNumber AS VARCHAR) + ' ' + D.CalendarMonthLabel AS VARCHAR(20)) AS CalendarMonthOfYearUniqueLabel

-- Calendar Month of Year Label
,	D.CalendarMonthLabel AS CalendarMonthOfYearLabel

-- Number of Months Relative to Current Month
,	RP.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank AS CalendarRelativeMonthNumber

-- Relative Month Label
,	CAST(
        CASE
		    WHEN RP.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank = 0	THEN 'Current Month'
		    WHEN RP.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank > 0
			    THEN CAST((RP.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank) AS VARCHAR) + ' Months From Now'
		    ELSE CAST(ABS(RP.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank) AS VARCHAR) + ' Months Ago'
	    END AS VARCHAR(20)) AS CalendarRelativeMonthLabel

-- Number of Months
,	(RP.CalendarMonthNumRank - T.CurrentCalendarMonthNumRank) % 12 AS CalendarRelativeMonthByYearToCurrentMonthNumber

-- Is the DayOfMonth for ThisDate in the same MTD zone & in the SAME MonthOfYear
,	CAST(
        CASE
		    WHEN D.CalendarDayOfMonthNumber <= T.CurrentCalendarDayOfMonthNumber
		    AND D.CalendarMonthOfYearNumber = T.CurrentCalendarMonthOfYearNumber THEN 1
            ELSE 0
	    END AS BIT) AS IsParallelCalendarMTDSameMonthByDayBoolean

-- Is the DayOfMonth for ThisDate in the same MTD zone for ANY MonthOfYear
,	CAST(
        CASE
            WHEN D.CalendarDayOfMonthNumber <= T.CurrentCalendarDayOfMonthNumber THEN 1
            ELSE 0
        END AS BIT) AS IsParallelCalendarMTDAnyMonthByDayBoolean

-- Is this Day the End of a Month
,   CAST(CASE WHEN D.ThisDate = EOMONTH(D.ThisDate) THEN 1 ELSE 0 END AS BIT) AS IsCalendarEndOfMonthDay
--#endregion
-- *******************************************************************


-- *******************************************************************
-- CALENDAR WEEK CALCULATIONS
-- ************************************
--#region Week
,	D.CalendarWeekOfYearNumber
,   D.CommonDayOfWeekLabel

-- Date of the First Day of the Week ThisDate is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarWeekOfYearNumber ORDER BY D.ThisDate ASC) AS CalendarWeekBeginDate

-- Date of the Last Day of the Week Thisdate is in
,	FIRST_VALUE(D.ThisDate) OVER (PARTITION BY D.CalendarYearNumber, D.CalendarWeekOfYearNumber ORDER BY D.ThisDate DESC) AS CalendarWeekEndDate

-- Calendar Week of Year Unique Label
,	CAST(CAST(D.CalendarYearNumber AS VARCHAR) + ' W'
		+ CASE WHEN D.CalendarWeekOfYearNumber < 10 THEN '0' ELSE '' END
		+ CAST(D.CalendarWeekOfYearNumber AS VARCHAR) AS VARCHAR(10)) AS CalendarWeekOfYearUniqueLabel

-- Calendar Week of Year Label
,	CAST('W' + CASE WHEN D.CalendarWeekOfYearNumber < 10 THEN '0' ELSE '' END + CAST(D.CalendarWeekOfYearNumber AS VARCHAR) AS VARCHAR(5)) AS CalendarWeekOfYearLabel

-- Number of weeks relative to the current week
,	RP.CalendarWeekNumRank - T.CurrentCalendarWeekNumRank AS CalendarRelativeWeekNumber
,	CAST(
        CASE
		    WHEN RP.CalendarWeekNumRank - T.CurrentCalendarWeekNumRank = 0 THEN 'Current Week'
		    WHEN RP.CalendarWeekNumRank - T.CurrentCalendarWeekNumRank > 0
			    THEN CAST((RP.CalendarWeekNumRank - T.CurrentCalendarWeekNumRank) AS VARCHAR) + ' Weeks From Now'
		    ELSE CAST(ABS(RP.CalendarWeekNumRank - T.CurrentCalendarWeekNumRank) AS VARCHAR) + ' Weeks Ago'
	    END AS VARCHAR(20)) AS CalendarRelativeWeekLabel

-- Is the DayOfPeriod for ThisDate in the same WTD zone & in the SAME WeekOfYear
,	CAST(
        CASE
		    WHEN D.CalendarDayOfWeekNumber <= T.CurrentCalendarDayOfWeekNumber
		    AND D.CalendarWeekOfYearNumber = T.CurrentCalendarWeekOfYearNumber
			    THEN 1
            ELSE 0
	    END AS BIT) AS IsParallelCalendarWTDSameWeekByDayBoolean

-- Is the DayOfPeriod for ThisDate in the same WTD zone for ANY WeekOfYear
,	CAST(
        CASE
		    WHEN D.CalendarDayOfWeekNumber <= T.CurrentCalendarDayOfWeekNumber THEN 1
		    ELSE 0
	    END AS BIT) AS IsParallelCalendarWTDAnyWeekByDayBoolean
--#endregion
-- *******************************************************************


-- *******************************************************************
-- CALENDAR DAY
-- ************************************
--#region Day
-- Number of days into the year
,	D.CalendarDayOfYearNumber

-- Number of days remaining in the year
,	FIRST_VALUE(D.CalendarDayOfYearNumber) OVER(PARTITION BY D.CalendarYearNumber ORDER BY D.ThisDate DESC)
    - D.CalendarDayOfYearNumber + 1 AS CalendarDaysRemainingInYearNumber

-- Number of Business days remaining in the year
,   (SELECT COUNT(*)
    FROM dim.BaseDate ND
    WHERE
        ND.CalendarYearNumber = D.CalendarYearNumber
    AND ND.IsOfficeWorkDayBoolean = 1
    AND ND.CalendarDayOfYearNumber >= D.CalendarDayOfYearNumber)   AS CalendarBusinessDaysRemainingInYearNumber

-- Number of Calendar days into the quarter
,	D.CalendarDayOfQuarterNumber

-- Number of Business days into the quarter
,   (SELECT COUNT(*)
    FROM dim.BaseDate ND
    WHERE
        ND.CalendarYearNumber = D.CalendarYearNumber
    AND ND.CalendarQuarterOfYearNumber = D.CalendarQuarterOfYearNumber
    AND ND.IsOfficeWorkDayBoolean = 1
    AND ND.CalendarDayOfYearNumber <= D.CalendarDayOfYearNumber)   AS CalendarBusinessDayOfQuarterNumber

-- Number of Calendar days remining in the quarter
,	FIRST_VALUE(D.CalendarDayOfQuarterNumber) OVER(PARTITION BY D.CalendarYearNumber, D.CalendarQuarterOfYearNumber ORDER BY D.ThisDate DESC)
    - D.CalendarDayOfQuarterNumber + 1 AS CalendarDaysRemainingInQuarterNumber

-- Number of Business days remaining in the quarter
,   (SELECT COUNT(*)
    FROM dim.BaseDate ND
    WHERE
        ND.CalendarYearNumber = D.CalendarYearNumber
    AND ND.CalendarQuarterOfYearNumber = D.CalendarQuarterOfYearNumber
    AND ND.IsOfficeWorkDayBoolean = 1
    AND ND.CalendarDayOfYearNumber >= D.CalendarDayOfYearNumber)   AS CalendarBusinessDaysRemainingInQuarterNumber

-- Number of days into the period ThisDate is in
,	D.CalendarDayOfMonthNumber

-- Number of days into the week ThisDate is in
,	D.CalendarDayOfWeekNumber
--#endregion
-- *******************************************************************


---- *******************************************************************
---- TODAY
---- ************************************
--#region Current Day
--,	T.CurrentCalendarYearNumber
--,	T.CurrentCalendarQuarterOfYearNumber
--,	T.CurrentCalendarMonthOfYearNumber
--,	T.CurrentCalendarWeekOfYearNumber
--,	T.CurrentCalendarDayOfYearNumber
--,	T.CurrentCalendarDayOfQuarterNumber
--,	T.CurrentCalendarDayOfMonthNumber
--,	T.CurrentCalendarDayOfWeekNumber
--#endregion
---- *******************************************************************

FROM
			dim.BaseDate    D
INNER JOIN	RelativePeriods	RP  ON	D.ID = RP.ID
CROSS JOIN	Today			T
