-- STEP CREAT SCHEMAS  --
----------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dev_fudgeinc')
	EXEC('CREATE SCHEMA dev_fudgeinc');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'test_fudgeinc')
	EXEC('CREATE SCHEMA test_fudgeinc');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'fudgeinc')
	EXEC('CREATE SCHEMA fudgeinc');
GO

SELECT * FROM sys.schemas WHERE name = N'dev_fudgeinc';
SELECT * FROM sys.schemas WHERE name = N'test_fudgeinc';
SELECT * FROM sys.schemas WHERE name = N'fudgeinc';