# ADR-0002: Conector local con conexión saliente
Estado: Propuesta (validar con EXP-04) · Fecha: 2026-10-26

**Contexto.** Comercial Pro y su SQL Server están en la red del cliente. El portal está alojado.
**Decisión propuesta.** Servicio Windows que inicia conexiones HTTPS salientes al portal (sondeo/long-poll) para tomar trabajos y reportar resultados. Autenticación por credencial por conector (rotatable) y, si es viable, mTLS.
**Alternativas.** VPN por cliente (operación pesada); exponer API local (puertos entrantes, riesgo); SQL Server expuesto a internet (rechazada: inseguro); portal on-premise por cliente (descarta SaaS).
**Consecuencias.** Latencia por sondeo (segundos); el conector debe tolerar caídas y reintentar sin duplicar (ADR-0004). Si hay que ofrecer modo on-premise, la API puede alojarse localmente sin cambiar el contrato.

**Actualización 2026-10-26 (fase 2).** Sigue en Propuesta. Sin acceso a SONARMANDO ni evidencia del SDK, esta decisión no puede confirmarse ni cambiar; ver ARQUITECTURA §Fase 2.

**Actualización 2026-10-26 (equipo real).** Las DLL `SDKPro*` de Comercial Start/Pro son x86: el conector deberá ser un proceso de 32 bits. Sigue Propuesta hasta confirmar la API del SDK (EXP-01).

**Actualización 2026-10-26 (SDK inspeccionado).** `SDKProNETWrapper` exige x86 y existe un puente previo en .NET Framework 4.8: el conector se tratará como proceso x86 en .NET Framework 4.8 hasta que EXP-01 pruebe lo contrario.
