-- Solo lectura. Identifica instancia, versión y estado de la base.
SELECT CAST(SERVERPROPERTY('MachineName') AS nvarchar(128)) AS machine_name,
       CAST(SERVERPROPERTY('InstanceName') AS nvarchar(128)) AS instance_name,
       CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(128)) AS product_version,
       CAST(SERVERPROPERTY('ProductLevel') AS nvarchar(128)) AS product_level,
       CAST(SERVERPROPERTY('Edition') AS nvarchar(128)) AS edition,
       CAST(SERVERPROPERTY('Collation') AS nvarchar(128)) AS server_collation;
SELECT name, state_desc, compatibility_level, collation_name, recovery_model_desc, is_read_only, create_date
FROM sys.databases WHERE name = DB_NAME();
SELECT s.name AS esquema, COUNT(*) AS objetos FROM sys.objects o JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0 GROUP BY s.name ORDER BY s.name;
SELECT type_desc, COUNT(*) AS cantidad FROM sys.objects WHERE is_ms_shipped = 0 GROUP BY type_desc ORDER BY type_desc;
