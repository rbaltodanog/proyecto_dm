-- ============================================================================
-- 1. DATA MART DATABASE CREATION
-- ============================================================================
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'ChinookDW')
BEGIN
    ALTER DATABASE ChinookDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ChinookDW;
END
GO

CREATE DATABASE ChinookDW;
GO

USE ChinookDW;
GO

-- ============================================================================
-- 2. DIMENSION TABLE CREATION (Structures with SCD and DimDate support)
-- ============================================================================

-- Dimension Table: Dim_Product (Applies SCD Type 1 and Type 3)
CREATE TABLE [dbo].[Dim_Product] (
    [SK_Product] INT IDENTITY(1,1) NOT NULL,
    [ID_Track_Original] INT NOT NULL,
    [Track_Name] NVARCHAR(200) NOT NULL,
    [Album_Title] NVARCHAR(160) NOT NULL,
    [Artist_Name] NVARCHAR(120) NULL,
    [Current_Genre_Name] NVARCHAR(120) NULL,
    [Previous_Genre_Name] NVARCHAR(120) NULL,
    [ActiveRecord] CHAR(1) NOT NULL,
    CONSTRAINT [PK_Dim_Product] PRIMARY KEY CLUSTERED ([SK_Product] ASC)
);
GO

-- Dimension Table: Dim_Customer (Applies SCD Type 1, Type 2 and Type 3)
CREATE TABLE [dbo].[Dim_Customer] (
    [SK_Customer] INT IDENTITY(1,1) NOT NULL,
    [ID_Customer_Original] INT NOT NULL,
    [Customer_Full_Name] NVARCHAR(60) NOT NULL,
    [City] NVARCHAR(40) NULL,
    [State] NVARCHAR(40) NULL,
    [Country] NVARCHAR(40) NULL,
    [Current_Support_Rep] NVARCHAR(40) NULL,
    [Previous_Support_Rep] NVARCHAR(40) NULL,
    [Valid_From] DATETIME NOT NULL,
    [Valid_To] DATETIME NULL,
    CONSTRAINT [PK_Dim_Customer] PRIMARY KEY CLUSTERED ([SK_Customer] ASC)
);
GO

-- Dimension Table: Dim_Employee (Applies SCD Type 1)
CREATE TABLE [dbo].[Dim_Employee] (
    [SK_Employee] INT IDENTITY(1,1) NOT NULL,
    [ID_Employee_Original] INT NOT NULL,
    [Employee_Full_Name] NVARCHAR(40) NOT NULL,
    CONSTRAINT [PK_Dim_Employee] PRIMARY KEY CLUSTERED ([SK_Employee] ASC)
);
GO

-- Advanced Date Dimension Table (Structure sourced from Dimdate_-_Create.sql)
CREATE TABLE	[dbo].[DimDate]
	(	[DateKey] INT primary key,
		[Date] DATETIME,
		[FullDateUK] CHAR(10), -- Date in dd-MM-yyyy format
		[FullDateUSA] CHAR(10),-- Date in MM-dd-yyyy format
		[DayOfMonth] VARCHAR(2), -- Field will hold day number of Month
		[DaySuffix] VARCHAR(4), -- Apply suffix as 1st, 2nd ,3rd etc
		[DayName] VARCHAR(9), -- Contains name of the day, Sunday, Monday
		[DayOfWeekUSA] CHAR(1),-- First Day Sunday=1 and Saturday=7
		[DayOfWeekUK] CHAR(1),-- First Day Monday=1 and Sunday=7
		[DayOfWeekInMonth] VARCHAR(2), --1st Monday or 2nd Monday in Month
		[DayOfWeekInYear] VARCHAR(2),
		[DayOfQuarter] VARCHAR(3),
		[DayOfYear] VARCHAR(3),
		[WeekOfMonth] VARCHAR(1),-- Week Number of Month
		[WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
		[WeekOfYear] VARCHAR(2),--Week Number of the Year
		[Month] VARCHAR(2), --Number of the Month 1 to 12
		[MonthName] VARCHAR(9),--January, February etc
		[MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
		[Quarter] CHAR(1),
		[QuarterName] VARCHAR(9),--First,Second..
		[Year] CHAR(4),-- Year value of Date stored in Row
		[YearName] CHAR(7), --CY 2012,CY 2013
		[MonthYear] CHAR(10), --Jan-2013,Feb-2013
		[MMYYYY] CHAR(6),
		[FirstDayOfMonth] DATE,
		[LastDayOfMonth] DATE,
		[FirstDayOfQuarter] DATE,
		[LastDayOfQuarter] DATE,
		[FirstDayOfYear] DATE,
		[LastDayOfYear] DATE,
		[IsHolidayUSA] BIT,-- Flag 1=National Holiday, 0-No National Holiday
		[IsWeekday] BIT,-- 0=Week End ,1=Week Day
		[HolidayUSA] VARCHAR(50),--Name of Holiday in US
		[IsHolidayUK] BIT Null,-- Flag 1=National Holiday, 0-No National Holiday
		[HolidayUK] VARCHAR(50) Null --Name of Holiday in UK
	)
GO

-- ============================================================================
-- 3. CENTRAL FACT TABLE CREATION (Linked to DimDate)
-- ============================================================================

CREATE TABLE [dbo].[Fact_Sales] (
    [SK_Customer] INT NOT NULL,
    [SK_Product] INT NOT NULL,
    [SK_Employee] INT NOT NULL,                  -- Support rep who manages the customer (Req 4)
    [DateKey] INT NOT NULL,                      -- Column adjusted to link with DimDate
    [ID_Invoice_Original] INT NOT NULL,
    [Quantity_Sold] INT NOT NULL,
    [Historical_Unit_Price] NUMERIC(10,2) NOT NULL,
    [Total_Line_Revenue] NUMERIC(10,2) NOT NULL,

    -- Referential Integrity Constraints
    CONSTRAINT [FK_Fact_Sales_Dim_Customer] FOREIGN KEY ([SK_Customer])
        REFERENCES [dbo].[Dim_Customer] ([SK_Customer]) ON DELETE NO ACTION ON UPDATE NO ACTION,

    CONSTRAINT [FK_Fact_Sales_Dim_Product] FOREIGN KEY ([SK_Product])
        REFERENCES [dbo].[Dim_Product] ([SK_Product]) ON DELETE NO ACTION ON UPDATE NO ACTION,

    CONSTRAINT [FK_Fact_Sales_Dim_Employee] FOREIGN KEY ([SK_Employee])
        REFERENCES [dbo].[Dim_Employee] ([SK_Employee]) ON DELETE NO ACTION ON UPDATE NO ACTION,

    CONSTRAINT [FK_Fact_Sales_DimDate] FOREIGN KEY ([DateKey])
        REFERENCES [dbo].[DimDate] ([DateKey]) ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

-- ============================================================================
-- 4. INDEXES FOR OPTIMIZATION IN BUSINESS INTELLIGENCE ENVIRONMENTS
-- ============================================================================

-- Composite clustered index on the fact table targeting the DateKey column
CREATE CLUSTERED INDEX [IX_Fact_Sales_Composite_DateKey]
ON [dbo].[Fact_Sales]([DateKey] ASC, [SK_Customer] ASC, [SK_Product] ASC);
GO

-- Non-clustered index to support employee-to-VIP-customer joins (Req 4)
CREATE NONCLUSTERED INDEX [IX_Fact_Sales_SK_Employee]
ON [dbo].[Fact_Sales]([SK_Employee] ASC)
INCLUDE ([SK_Customer], [Total_Line_Revenue]);
GO
