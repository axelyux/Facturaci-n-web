# ADR-0004: Idempotencia y cola de solicitudes
Estado: Propuesta · Fecha: 2026-10-26

**Decisión.** Cada `SolicitudFacturacion` tiene `ClaveIdempotencia` única por (`EmpresaId`, documento de origen) y una máquina de estados explícita. El conector reclama trabajos con arrendamiento (lease) y reporta resultado; ante timeout o reinicio, primero **consulta** si el documento ya existe en Comercial Pro (mecanismo por definir en EXP) antes de reintentar la creación.
**Riesgo central.** Si la creación de factura no es transaccional/consultable, un reintento ciego puede duplicar. Hasta resolverlo, estado `RequiereRevision` en lugar de reintento automático.
