# Plan de implementación
0. **Base del repositorio** — hecho (ver informe).
1. **Descubrimiento de integración** (EN CURSO, BLOQUEADO por acceso a SONARMANDO; scripts listos en `scripts/diagnostico/`): EXP-00 a EXP-03 (solo lectura). Salida: INTEGRACION_COMERCIAL_PRO.md con [V].
2. **Contrato API** (OpenAPI) y BD de integración (EF Core/migraciones o Dapper — decidir en ADR), estados e idempotencia.
3. **Prototipo conector↔API** (EXP-04) con integración simulada (fake) tras una interfaz definida por el contrato.
4. **UI cliente final** (folio → venta → RFC → confirmación → estado), con diseño móvil primero.
5. **Autenticación y UI de personal**.
6. **Facturación real en entorno de pruebas** (EXP-05/06) con autorización.
7. Endurecimiento: seguridad, observabilidad, pruebas de carga/concurrencia, despliegue.

**Ruta crítica actual:** (a) usuario ejecuta diagnóstico y entrega `salida\`; (b) mapear ventas/clientes con evidencia; (c) EXP-02b lectura por folio; (d) EXP-00/01 SDK. Mientras tanto se puede avanzar (sin tocar Comercial Pro) en contrato OpenAPI, BD de integración y UI contra un `Fake`.
