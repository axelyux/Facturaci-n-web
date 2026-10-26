-- Solo lectura. Índices (útiles para saber por qué columnas se puede buscar un folio con eficiencia).
SELECT s.name AS esquema, o.name AS tabla, i.name AS indice, i.type_desc, i.is_unique, i.is_primary_key,
       STRING_AGG(CASE WHEN ic.is_included_column = 0 THEN c.name END, ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS columnas_clave
FROM sys.indexes i
JOIN sys.objects o ON o.object_id = i.object_id AND o.is_ms_shipped = 0 AND o.type = 'U'
JOIN sys.schemas s ON s.schema_id = o.schema_id
JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE i.index_id > 0
GROUP BY s.name, o.name, i.name, i.type_desc, i.is_unique, i.is_primary_key
ORDER BY s.name, o.name, i.name;
