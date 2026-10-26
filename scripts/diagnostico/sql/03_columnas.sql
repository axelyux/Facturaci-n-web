-- Solo lectura. Columnas de todas las tablas y vistas de usuario.
SELECT s.name AS esquema, o.name AS objeto, c.column_id, c.name AS columna,
       t.name AS tipo, c.max_length, c.precision, c.scale, c.is_nullable, c.is_identity,
       c.is_computed, CASE WHEN dc.object_id IS NULL THEN 0 ELSE 1 END AS tiene_default
FROM sys.columns c
JOIN sys.objects o ON o.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
JOIN sys.types t ON t.user_type_id = c.user_type_id
LEFT JOIN sys.default_constraints dc ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
WHERE o.is_ms_shipped = 0 AND o.type IN ('U','V')
ORDER BY s.name, o.name, c.column_id;
