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

## Hallazgos del equipo real (2026-10-26) — VERIFICADO EN EL EQUIPO (salida de `Inspeccionar-Instalacion.ps1`)
Equipo: Windows (10.0.26200), 64 bits, PowerShell 5.1.

| Hecho | Evidencia | Certeza |
|---|---|---|
| Producto instalado: **CONTPAQi Comercial Start / Pro v10.0.0**, en `C:\Program Files (x86)\Compac\ComercialSP` | Registro de programas | Verificado |
| También instalado: **CONTPAQi Punto de Venta (Local)** en `...\Compacw\PuntoDeVenta` | Registro de programas | Verificado |
| En la carpeta de Comercial existen `SDK.dll` (v9.01), `SDKPro.dll` (v1.0.0.60), `SDKProNETWrapper.dll` (v1.0.0.25) + `.tlb`, `SDKProPremium.dll` (v1.0.0.3), `SDKPro.WopenConfiguration.dll` | Listado de archivos | Verificado que existen; **su función, API y licencia NO están verificadas** |
| Todas esas DLL son **x86 (32 bits)** | Cabecera PE | Verificado |
| Servicio `ComercialSPWorkerService` (x64, .NET), **detenido** | Servicios + PE | Verificado; propósito desconocido |
| Servicio `ContpaqiBridge` ejecutado con **NSSM** (`nssm.exe`), en ejecución | Servicios | Verificado que existe; **no es componente conocido de CONTPAQi: ¿quién lo instaló y para qué?** |
| Servidores de licencias AppKey en ejecución | Servicios | Verificado |
| COM registrado con "CONTPAQ|MGW|Comercial": solo `Contpaq.*`/`LBS.*` (Contabilidad antigua) y `LC.XEngineNETWrapper.ContpaqiTools`. **No hay un ProgID COM de Comercial** | Registro | Verificado (según el filtro usado) |
| Punto de Venta trae `MGW_SDK.dll` v15.0.1.0 (x86) y librerías MGW*; Comercial Start/Pro trae la familia `SDKPro*` | Listado de archivos | Verificado que existen |

### Consecuencias (HIPÓTESIS derivadas)
- Existe evidencia de que Comercial Start/Pro incorpora su **propio** SDK (`SDKPro*`), distinto del `MGW_SDK` de Punto de Venta. Esto **no** demuestra que permita crear/timbrar facturas. No asumir compatibilidad con paquetes de terceros hechos para Premium.
- Cualquier proceso que cargue esas DLL será **de 32 bits**. El conector debe compilarse x86 (puede ser .NET moderno x86 si `SDKProNETWrapper` lo permite, o .NET Framework 4.8). La API y el web no se ven afectados (contrato JSON/HTTPS).
- **Pregunta crítica nueva:** el "ticket" que el cliente trae, ¿lo emite **Punto de Venta** o **Comercial** como documento de venta? Eso cambia qué base y qué SDK importan. Hay que confirmar a qué sistema pertenece SONARMANDO.
- `ContpaqiBridge` (NSSM) podría ser un puente existente, propio o de terceros: verificar antes de duplicar.

### Siguiente evidencia (script `Inspeccionar-SDK.ps1`, solo lectura, probado con archivos sintéticos, aún no ejecutado en el equipo real)
Cabeceras PE de las DLL del SDK (¿.NET o nativa? ¿32 bits requerido?), **nombres exportados** de las DLL nativas, claves de configuración del worker (valores sensibles omitidos), parámetros del servicio NSSM, puertos en escucha de procesos CONTPAQi, instancias SQL locales (por servicios locales, sin escanear la red).
