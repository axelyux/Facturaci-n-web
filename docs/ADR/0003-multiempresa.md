# ADR-0003: Multiempresa
Estado: Propuesta · Fecha: 2026-10-26

**Decisión.** Una BD de integración compartida; toda tabla/consulta lleva `EmpresaId` obligatorio (filtro global + pruebas de aislamiento). Cada empresa tiene uno o más conectores con credenciales propias y configuración (series, reglas de elegibilidad, plantillas de correo).
**Alternativas.** BD por empresa (mejor aislamiento, mayor costo operativo; se puede migrar después si un cliente lo exige).
**Consecuencias.** Hay que probar que ninguna consulta omite `EmpresaId` y que un conector solo recibe trabajos de su empresa.
