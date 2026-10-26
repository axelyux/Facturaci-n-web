# ADR-0005: Integración mediante mecanismo compatible; sin INSERT directo
Estado: Aceptada · Fecha: 2026-10-26

**Decisión.** La creación/timbrado de documentos solo se hará por un mecanismo oficialmente compatible con Comercial Pro (SDK/API/COM u otro que CONTPAQi confirme). SQL Server de Comercial Pro: solo lectura, y únicamente para consultas validadas por experimento. Prohibido insertar/actualizar tablas internas.
**Motivo.** Integridad fiscal, soporte y licenciamiento. Existen paquetes .NET de terceros (p. ej. ARSoftware.Contpaqi.Comercial.Sdk.Extras) que sugieren un SDK utilizable; su alcance, edición compatible (Pro vs Premium) y licencia siguen PENDIENTES.
