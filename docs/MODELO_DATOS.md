# Modelo de datos (BD de integración propia — conceptual)
No describe tablas de Comercial Pro (desconocidas). Todo lleva `EmpresaId`.

**Empresa**: Id, Nombre, Activa, Configuración (JSON validado), fechas.
**Conector**: Id, EmpresaId, Nombre, HashCredencial (nunca texto plano), UltimoLatido, Versión, Activo.
**SolicitudFacturacion**: Id, EmpresaId, Origen (`Cliente`|`Personal`), DocumentoOrigenRef (referencia opaca devuelta por el conector tras EXP-02), FolioCapturado, **ClaveIdempotencia** (único con EmpresaId), Estado, ClienteRfc, ClienteRef, FacturaRef, **Uuid**, Intentos, LeaseHasta, ConectorId, CreadaEn/ActualizadaEn/CompletadaEn, **Diagnostico** (solo personal, sin secretos), CorrelationId.
Estados propuestos: `Recibida → Validada → EnCola → EnProceso → Completada | Fallida | RequiereRevision`.
**BitacoraEvento**: Id, EmpresaId, SolicitudId?, Actor, Acción, Fecha, Datos (sin datos sensibles innecesarios).
**UsuarioPortal / Rol**: personal del negocio, roles y permisos por empresa.
Retención y datos personales (RFC, correo): definir política (LFPDPPP) — PENDIENTE.
