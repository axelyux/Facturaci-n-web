-- Solo lectura. Lista vistas, procedimientos, funciones y triggers (NO ejecuta ninguno). Sin definiciones completas.
SELECT s.name AS esquema, o.name AS objeto, o.type_desc, o.create_date, o.modify_date,
       LEN(m.definition) AS longitud_definicion, m.is_schema_bound
FROM sys.objects o
JOIN sys.schemas s ON s.schema_id = o.schema_id
LEFT JOIN sys.sql_modules m ON m.object_id = o.object_id
WHERE o.is_ms_shipped = 0 AND o.type IN ('V','P','FN','IF','TF','TR')
ORDER BY o.type_desc, s.name, o.name;
-- Triggers: importantes porque una escritura "directa" podría activarlos.
SELECT t.name AS trigger_nombre, OBJECT_NAME(t.parent_id) AS tabla, t.is_disabled, t.is_instead_of_trigger
FROM sys.triggers t WHERE t.is_ms_shipped = 0 AND t.parent_class = 1 ORDER BY 2, 1;
