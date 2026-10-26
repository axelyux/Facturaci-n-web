-- Solo lectura. Inventario de tablas y vistas con filas aproximadas (sin leer datos).
SELECT s.name AS esquema, o.name AS objeto, o.type_desc,
       SUM(CASE WHEN p.index_id IN (0,1) THEN p.rows ELSE 0 END) AS filas_aprox
FROM sys.objects o
JOIN sys.schemas s ON s.schema_id = o.schema_id
LEFT JOIN sys.partitions p ON p.object_id = o.object_id
WHERE o.is_ms_shipped = 0 AND o.type IN ('U','V')
GROUP BY s.name, o.name, o.type_desc
ORDER BY o.type_desc, s.name, o.name;
