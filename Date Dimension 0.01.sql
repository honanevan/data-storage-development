-- Declare start and end dates for the date dimension table
DECLARE @StartDate DATE = '2000-01-01';
DECLARE @EndDate DATE = '2023-12-31';

-- Create partition function and scheme
CREATE PARTITION FUNCTION YearPartitionFunction (DATE)
AS RANGE RIGHT FOR VALUES (
  '2000-01-01', '2001-01-01', '2002-01-01', '2003-01-01', '2004-01-01',
  -- Add more boundary points for additional years as needed
  '2023-01-01'
);

CREATE PARTITION SCHEME YearPartitionScheme
AS PARTITION YearPartitionFunction
ALL TO ([PRIMARY]);

-- Create the DateDimension table
CREATE TABLE DateDimension (
  FullDate DATE NOT NULL,
  DayOfWeek INT,
  DayOfYear INT,
  WeekOfYear INT,
  Month INT,
  Quarter INT,
  Year INT,
  WeekOfMonth INT,
  -- Add other columns as needed
  PRIMARY KEY CLUSTERED (FullDate) ON YearPartitionScheme (FullDate)
);

-- Add non-clustered indexes on frequently used columns
-- Adjust the included columns based on your specific query patterns
CREATE NONCLUSTERED INDEX IX_DateDimension_Year
ON DateDimension (Year)
INCLUDE (Month, Day);

-- Populate the DateDimension table
WITH DateSequence AS (
  SELECT @StartDate AS [date]
  UNION ALL
  SELECT DATEADD(day, 1, [date])
  FROM DateSequence
  WHERE [date] < @EndDate
)
INSERT INTO DateDimension (FullDate, DayOfWeek, DayOfYear, WeekOfYear, Month, Quarter, Year, WeekOfMonth)
SELECT
  [date],
  DATEPART(weekday, [date]),
  DATEPART(dayofyear, [date]),
  DATEPART(week, [date]),
  DATEPART(month, [date]),
  DATEPART(quarter, [date]),
  DATEPART(year, [date]),
  (DATEPART(day, [date]) - 1) / 7 + 1
FROM DateSequence
OPTION (MAXRECURSION 0);

-- Add additional dimensions and update the table
-- Include the necessary calculations and adjustments
-- for your specific requirements
-- For example, holiday flags, trading days, etc.
-- Refer to the previous examples in the conversation for guidance

-- Reset the date sequence to prevent recursion limit issues
OPTION (MAXRECURSION 0);
