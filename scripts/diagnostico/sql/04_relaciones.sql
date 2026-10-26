-- Solo lectura. Claves primarias, únicas y foráneas declaradas.
SELECT 'PK/UQ' AS clase, s.name AS esquema, o.name AS tabla, kc.name AS restriccion, kc.type_desc,
       STRING_AGG(c.name, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS columnas, CAST(NULL AS nvarchar(256)) AS referencia
FROM sys.key_constraints kc
JOIN sys.objects o ON o.object_id = kc.parent_object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
JOIN sys.index_columns ic ON ic.object_id = kc.parent_object_id AND ic.index_id = kc.unique_index_id
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
GROUP BY s.name, o.name, kc.name, kc.type_desc
UNION ALL
SELECT 'FK', s.name, o.name, fk.name, 'FOREIGN_KEY',
       STRING_AGG(pc.name, ', ') WITHIN GROUP (ORDER BY fkc.constraint_column_id),
       MIN(rs.name + '.' + ro.name) + '(' + STRING_AGG(rc.name, ', ') WITHIN GROUP (ORDER BY fkc.constraint_column_id) + ')'
FROM sys.foreign_keys fk
JOIN sys.objects o ON o.object_id = fk.parent_object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
JOIN sys.columns pc ON pc.object_id = fkc.parent_object_id AND pc.column_id = fkc.parent_column_id
JOIN sys.objects ro ON ro.object_id = fk.referenced_object_id
JOIN sys.schemas rs ON rs.schema_id = ro.schema_id
JOIN sys.columns rc ON rc.object_id = fkc.referenced_object_id AND rc.column_id = fkc.referenced_column_id
GROUP BY s.name, o.name, fk.name
ORDER BY 1, 2, 3;
