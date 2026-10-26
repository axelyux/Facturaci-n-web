# Diagnóstico de solo lectura (equipo con acceso a SQL Server / Comercial Pro)

Ejecutar **en el equipo autorizado**, no en este repositorio en la nube. PowerShell 5.1 de Windows basta (sin instalar nada).

1. Definir variables en la sesión (no escribir la contraseña en comandos guardados en historial):
   `$env:CONTPAQ_SQL_SERVER='EQUIPO\INSTANCIA'; $env:CONTPAQ_SQL_USER='sa'; $env:CONTPAQ_SQL_PASSWORD=(Read-Host 'Contraseña' -MaskInput)` (pwsh 7) o con `[Net.NetworkCredential]::new('', (Read-Host -AsSecureString)).Password` en PS 5.1.
2. `.\Inspeccionar-Instalacion.ps1` → `salida\instalacion.txt` (versión, DLL y bitness, COM).
3. `.\Invoke-AuditoriaSql.ps1` → CSV de metadatos en `salida\`. Si el certificado del servidor no es de confianza, añadir `-ConfiarCertificado` (solo red local de pruebas).
4. Comprimir `salida\` y compartirla; contiene metadatos (nombres de tablas/columnas, tipos, relaciones), **sin datos de negocio**. Revísela antes.

Garantías: los `.sql` solo consultan `sys.*`; el runner rechaza palabras de escritura/ejecución, usa `ApplicationIntent=ReadOnly`, revierte la transacción siempre y falla si falta configuración. `../check-sql-readonly.sh` revisa lo mismo estáticamente (pasa en CI local).
**Estado:** estos scripts NO han sido ejecutados contra SQL Server (sin acceso). `STRING_AGG` exige SQL Server 2017+ y nivel de compatibilidad ≥110; si falla, se adaptará con evidencia.
