# Integración con CONTPAQi Comercial Pro

Leyenda: **[V]** verificado con evidencia · **[H]** hipótesis · **[P]** pendiente de confirmar. Última revisión: 2026-10-26.

## Hechos verificados
- **[V]** No existe instalación de Comercial Pro accesible desde este entorno (Linux, sin SQL Server ni cliente SQL). No se ha inspeccionado ninguna BD.
- **[V]** Existe un paquete NuGet de terceros, `ARSoftware.Contpaqi.Comercial.Sdk.Extras` (v6.3.0 listada, .NET 10 en Windows), descrito como extensión para crear/modificar/consultar catálogos y documentos de *CONTPAQi Comercial Premium*. Fuente: nuget.org (búsqueda web). No es oficial.
- **[V]** La ficha comercial oficial de Comercial Pro indica emisión de facturas electrónicas, sin describir API ni flujo para desarrolladores. Una búsqueda web no encontró documentación oficial de SDK para Comercial Pro.

## Preguntas abiertas
| # | Pregunta | Estado | Cómo resolver (evidencia requerida) |
|---|---|---|---|
| 1 | Versión exacta y edición (Pro/Premium) instalada | P | Pantalla Acerca de + versión de BD, en el equipo del cliente de pruebas |
| 2 | ¿Hay SDK/API/COM oficial para Pro? ¿Licenciamiento/costo? | P | Contactar CONTPAQi / canal de distribuidores; documento escrito |
| 3 | ¿Cómo se identifica una venta de forma inequívoca? Hipótesis: clave interna del documento (id numérico) + concepto/serie/folio; el **folio visible** de un ticket no es necesariamente único entre series/conceptos/empresas | H | EXP-02: inspeccionar metadatos (solo lectura) y comparar folio vs id interno |
| 4 | Diferencia folio visible vs identificador interno | H | EXP-02 |
| 5 | ¿Cómo validar que una venta es facturable (ya facturada, cancelada, tipo de documento, antigüedad)? | P | EXP-02 + reglas fiscales confirmadas con contador |
| 6 | Localizar cliente por RFC; evitar duplicados (RFC repetido, genérico XAXX010101000, extranjero) | P | EXP-03; política de unicidad definida con el negocio |
| 7 | Campos fiscales obligatorios del cliente para CFDI vigente (RFC, razón social tal cual constancia, régimen, CP fiscal, uso CFDI…) | P | Verificar contra anexo 20 vigente del SAT y requisitos del mecanismo de alta |
| 8 | Mecanismo compatible para crear, timbrar y recuperar la factura | P | EXP-05 en entorno de pruebas autorizado |
| 9 | Obtener UUID, XML y PDF | P | EXP-05 |
| 10 | Consultar si un documento ya fue creado (para recuperación idempotente) | P | EXP-06 |
| 11 | Cancelaciones (motivos, aceptación del receptor) y su auditoría | P | Fuera de la etapa actual; diseñar tras EXP-05 |
| 12 | Comunicación portal↔local (ADR-0002) | H | EXP-04 |
| 13 | Restricciones del SDK: bitness, Windows, sesión interactiva, concurrencia | P | EXP-01/05 |

## Entidad de integración (propia, conceptual — no son tablas de Comercial Pro)
Ver `MODELO_DATOS.md`.

## Gestión de errores y duplicados (diseño)
Estados explícitos, clave de idempotencia, lease del trabajo, consulta de existencia antes de reintentar, `RequiereRevision` ante ambigüedad. Errores internos se guardan en diagnóstico (solo personal) y al cliente se muestra mensaje genérico con id de correlación.

---
# FASE 2 — Auditoría de SONARMANDO (2026-10-26)

## Estado: BLOQUEADA por acceso (no por diseño)
**Evidencia del bloqueo (verificado en este entorno):**
- El entorno de la sesión es un contenedor Linux en la nube: sin `sqlcmd`/ODBC, sin listener en 1433/1434, sin Docker operativo y **sin variables de entorno de conexión** (solo se revisaron nombres; ninguna relacionada con SQL).
- No se conoce el nombre de la instancia ni se proporcionó contraseña. Conforme a las reglas, **no se probaron servidores, no se escaneó la red y no se intentaron credenciales**.
- Un contenedor en la nube no puede alcanzar una instancia en la red local del usuario sin un túnel que no hemos autorizado.

**Por tanto, en esta fase NO se ha inspeccionado SONARMANDO.** Todo lo que sigue sobre su estructura es PENDIENTE; no se documenta ninguna tabla ni columna.

## Lo que sí se hizo
- Búsqueda de documentación pública: **no se encontró documentación oficial de un SDK para Comercial Pro** (VERIFICADO EN DOCUMENTACIÓN, resultado negativo, no concluyente: pudo no estar indexada o requerir portal de distribuidores).
- Evidencia de terceros (no oficial): paquetes NuGet `ARSoftware.Contpaqi.Comercial.Sdk` (6.2.1, net8.0) y `...Sdk.Extras` (6.3.0, net8.0-windows / .NET 10) declaran envolver el SDK de "CONTPAQi Comercial y Factura Electrónica"; el repositorio asociado habla de **Comercial Premium**. Soporte para **Pro** no demostrado. HIPÓTESIS.
- Scripts reutilizables de solo lectura para ejecutar en el equipo autorizado: `scripts/diagnostico/` (ver su README). **No ejecutados contra SQL Server** (sin acceso); solo se verificó estáticamente que no contienen escrituras (`scripts/check-sql-readonly.sh`).

## Para desbloquear (lo único que hace falta de ti)
1. Nombre de instancia (`EQUIPO\INSTANCIA` o `host,puerto`) — o ejecutar tú los scripts en ese equipo.
2. Ejecutar `Inspeccionar-Instalacion.ps1` e `Invoke-AuditoriaSql.ps1` (contraseña solo por variable de entorno en tu sesión) y compartir la carpeta `salida\` (solo metadatos).
3. Versión/edición exacta de Comercial y si existe acuerdo de desarrollador/SDK con CONTPAQi.
4. Para Fase B (venta por folio) y C (clientes): un folio de prueba autorizado y confirmar que la base puede leerse; los experimentos de lectura se escribirán **a partir de los metadatos reales** (no antes).

## Diseños preliminares (HIPÓTESIS; sin dependencia de nombres reales de tablas)
**Búsqueda de venta (Fase B).** Entrada: (`EmpresaId`, folio, y serie/concepto/sucursal si el negocio los usa). Salida mínima: referencia opaca del documento + campos de vista previa. Reglas: si la búsqueda devuelve 0 filas → "no encontrada"; si >1 → "ambigua", pedir serie/fecha/importe (nunca elegir una); nunca devolver filas completas. Consultas parametrizadas, `SET LOCK_TIMEOUT` y timeout de comando cortos, usuario SQL de solo lectura con `SELECT` solo sobre los objetos necesarios (ver SEGURIDAD).
**Elegibilidad (por confirmar con datos):** documento existe; es de tipo ticket/venta; no cancelado; no ya relacionado con una factura; dentro del plazo fiscal; importes > 0; método de pago compatible. Cada regla se marcará VERIFICADO solo con evidencia de la base.
**Flujo de clientes (Fase C):** (1) normalizar RFC (mayúsculas, sin espacios) y validar formato, (2) buscar coincidencias exactas por RFC, (3) si hay varias, no crear: pedir confirmación de razón social/CP, (4) solicitar faltantes (razón social como en constancia, régimen, CP fiscal, uso CFDI, correo), (5) crear **solo** por interfaz compatible (BLOQUEADA hasta Fase D), (6) leer identificador interno devuelto, (7) concurrencia: bloqueo lógico por (`EmpresaId`, RFC) en la BD de integración (índice único sobre solicitud de alta pendiente) para que dos solicitudes simultáneas no creen dos clientes; tras la creación, re-consultar por RFC.
**Riesgos de duplicación:** doble clic/reintento del navegador → clave de idempotencia; caída del conector tras crear y antes de confirmar → consultar existencia antes de reintentar; dos conectores/instancias → lease exclusivo por solicitud; alta de cliente concurrente → índice único + re-consulta.

## Fase D — Mecanismo de facturación: BLOQUEADA
No existe evidencia verificada de un mecanismo que permita, en Pro: identificar el documento origen, crear/recuperar cliente, crear factura, timbrar, obtener UUID/archivos y consultar operaciones interrumpidas. **Falta:** versión/edición, documentación oficial o acuerdo SDK de CONTPAQi, e instalación de pruebas donde ejecutar EXP-01. No se instaló ningún paquete de terceros. Hasta entonces la integración fiscal queda BLOQUEADA y el portal solo puede diseñarse contra una interfaz abstracta con un `Fake`.
