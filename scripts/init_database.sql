/* This SQL script creates a new database named 'OlistDataWarehouse', dropping and recreating it
if it already exists. The database created contains three layers/schemas: bronze, silver,
and gold, following a medallion architecture.
*/

USE master;
GO

IF EXISTS (
	SELECT name
	FROM sys.databases
	WHERE name = 'OlistDataWarehouse'
)
BEGIN
	ALTER DATABASE OlistDataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE OlistDataWarehouse
END;
GO

CREATE DATABASE OlistDataWarehouse;
GO

USE OlistDataWarehouse;
GO

CREATE SCHEMA stg;
GO

CREATE SCHEMA dwh;
GO

-- Check if the created schemas exist

SELECT SCHEMA_NAME
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME IN ('stg', 'dwh');
GO