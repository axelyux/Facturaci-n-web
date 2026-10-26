-- Solo lectura. Índices (útiles para saber por qué columnas se puede buscar un folio). Compatible con nivel 120.
SELECT s.name AS esquema, o.name AS tabla, i.name AS indice, i.type_desc, i.is_unique, i.is_primary_key,
       STUFF((SELECT ', ' + c.name
              FROM sys.index_columns ic
              JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
              WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
              ORDER BY ic.key_ordinal
              FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '') AS columnas_clave
FROM sys.indexes i
JOIN sys.objects o ON o.object_id = i.object_id AND o.is_ms_shipped = 0 AND o.type = 'U'
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE i.index_id > 0
ORDER BY s.name, o.name, i.name;
