-- Solo lectura. Candidatos por palabra clave en nombres de objetos y columnas (descubrimiento, no conclusión).
-- Las palabras son búsquedas de metadatos; que una columna coincida NO prueba su función.
WITH k(palabra) AS (SELECT palabra FROM (VALUES ('folio'),('serie'),('rfc'),('uuid'),('timbr'),('cfdi'),('cancel'),('cliente'),('client'),('docum'),('movim'),('ticket'),('venta'),('factur'),('regimen'),('postal'),('uso'),('metodo'),('forma'),('impuesto'),('descuento'),('total'),('concepto'),('sucursal'),('empresa'),('xml'),('sello'),('estado')) v(palabra))
SELECT 'objeto' AS donde, s.name AS esquema, o.name AS objeto, CAST(NULL AS nvarchar(128)) AS columna, k.palabra
FROM sys.objects o JOIN sys.schemas s ON s.schema_id = o.schema_id
JOIN k ON o.name LIKE '%' + k.palabra + '%'
WHERE o.is_ms_shipped = 0 AND o.type IN ('U','V')
UNION ALL
SELECT 'columna', s.name, o.name, c.name, k.palabra
FROM sys.columns c JOIN sys.objects o ON o.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
JOIN k ON c.name LIKE '%' + k.palabra + '%'
WHERE o.is_ms_shipped = 0 AND o.type IN ('U','V')
ORDER BY 1, 5, 2, 3, 4;
