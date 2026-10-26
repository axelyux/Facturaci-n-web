-- Solo lectura. Claves primarias, únicas y foráneas declaradas. Compatible con nivel de compatibilidad 120 (sin STRING_AGG).
SELECT 'PK/UQ' AS clase, s.name AS esquema, o.name AS tabla, kc.name AS restriccion, kc.type_desc,
       STUFF((SELECT ', ' + c.name
              FROM sys.index_columns ic
              JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
              WHERE ic.object_id = kc.parent_object_id AND ic.index_id = kc.unique_index_id
              ORDER BY ic.key_ordinal
              FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '') AS columnas,
       CAST(NULL AS nvarchar(max)) AS referencia
FROM sys.key_constraints kc
JOIN sys.objects o ON o.object_id = kc.parent_object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
UNION ALL
SELECT 'FK', s.name, o.name, fk.name, 'FOREIGN_KEY',
       STUFF((SELECT ', ' + pc.name
              FROM sys.foreign_key_columns fkc
              JOIN sys.columns pc ON pc.object_id = fkc.parent_object_id AND pc.column_id = fkc.parent_column_id
              WHERE fkc.constraint_object_id = fk.object_id
              ORDER BY fkc.constraint_column_id
              FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, ''),
       rs.name + '.' + ro.name + '(' +
       STUFF((SELECT ', ' + rc.name
              FROM sys.foreign_key_columns fkc
              JOIN sys.columns rc ON rc.object_id = fkc.referenced_object_id AND rc.column_id = fkc.referenced_column_id
              WHERE fkc.constraint_object_id = fk.object_id
              ORDER BY fkc.constraint_column_id
              FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '') + ')'
FROM sys.foreign_keys fk
JOIN sys.objects o ON o.object_id = fk.parent_object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
JOIN sys.objects ro ON ro.object_id = fk.referenced_object_id
JOIN sys.schemas rs ON rs.schema_id = ro.schema_id
ORDER BY 1, 2, 3;
