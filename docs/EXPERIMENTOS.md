# Plan de experimentos de integración
Reglas: entorno de pruebas autorizado (empresa de prueba/copia, nunca producción), sin CFDI reales ni cancelaciones, sin escrituras SQL, resultados registrados aquí con fecha, versión y evidencia. Credenciales solo en gestor de secretos.

| ID | Objetivo | Entradas | Criterio de éxito | Estado |
|---|---|---|---|---|
| EXP-00 | Obtener versión/edición y confirmar licencias SDK | Equipo de pruebas; contacto CONTPAQi; `Inspeccionar-Instalacion.ps1` | Versión y términos documentados | PENDIENTE (scripts listos, sin ejecutar) |
| EXP-01 | Instalar y cargar el SDK/COM en un host Windows de pruebas desde un proyecto mínimo (bitness, .NET TFM) | Instalación de prueba | Se abre empresa de prueba y se lee un catálogo | PENDIENTE |
| EXP-02 | **Lectura** de una venta por folio; mapear folio visible ↔ id interno; campos de elegibilidad | Empresa de prueba | Tabla de campos con evidencia (consulta/llamada y resultado) | PENDIENTE |
| EXP-03 | Buscar cliente por RFC y alta de cliente de prueba por el mecanismo compatible | Empresa de prueba | Alta/lectura reproducible; manejo de duplicado | PENDIENTE |
| EXP-04 | Prototipo conector↔API (sondeo saliente, reconexión, credencial) con trabajos simulados | Este repo | Trabajo entregado y resultado devuelto tras corte de red, sin duplicar | PENDIENTE |
| EXP-05 | Crear factura en entorno de pruebas con timbrado de **sandbox/pruebas** si el producto lo permite; obtener UUID/XML/PDF | Autorización escrita del usuario | UUID y archivos recuperados | PENDIENTE (requiere autorización) |
| EXP-06 | Recuperación: matar el proceso a mitad de EXP-05 y verificar detección de documento ya creado | EXP-05 | Sin duplicado tras reintento | PENDIENTE |

**Siguiente experimento recomendado: EXP-00 → EXP-01 → EXP-02** (solo lectura, riesgo mínimo).

## Registro de ejecución
| Fecha | EXP | Resultado | Evidencia |
|---|---|---|---|
| 2026-10-26 | EXP-02 (metadatos) | **BLOQUEADO**: instancia no identificada, sin credenciales, entorno sin acceso a la red del usuario. No se intentó ninguna conexión. | Inspección de entorno en la sesión; `scripts/diagnostico/` preparado |
| 2026-10-26 | EXP-00 (instalación) | **PARCIAL**: Comercial Start/Pro v10.0.0 y Punto de Venta instalados; SDK `SDKPro*` x86 presente; sin documentación ni licencia confirmadas. Ver INTEGRACION_COMERCIAL_PRO.md | `salida\instalacion.txt` del equipo del usuario |
| 2026-10-26 | Guarda de solo lectura | PROBADO: `scripts/check-sql-readonly.sh` pasa sobre 7 .sql (detectó y obligó a corregir un INSERT propio) | salida del script |
| — | EXP-03/05/06 | PENDIENTE | — |

## EXP-02b (nuevo): venta por folio en solo lectura
Se escribirá cuando existan metadatos reales. Casos: folio existente, inexistente, ambiguo (series/tipos), ya facturado, no elegible. Ninguno ejecutado.
