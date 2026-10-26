# Arquitectura inicial (propuesta evaluada, sujeta a validación)

## Diagrama lógico
```
Navegador ──HTTPS──> Next.js (web) ──HTTPS──> ASP.NET Core API ──> SQL Server (BD de integración propia)
                                                    ^
                                                    │ HTTPS saliente (el conector llama al portal)
                                          Conector local (servicio Windows, por empresa)
                                                    │
                                                    └──> Comercial Pro (mecanismo compatible: PENDIENTE de verificar)
```

## Componentes
- **web** (Next.js/React/TS): UI móvil primero. Habla solo con la API.
- **api** (ASP.NET Core, .NET 10 LTS): reglas del portal, autenticación del personal, límites de tasa, antifraude de folios, cola de solicitudes (patrón outbox propio), multiempresa. No conoce internals de Comercial Pro.
- **connector** (.NET en Windows): corre junto a Comercial Pro, toma trabajos de la API (conexión saliente, sin abrir puertos entrantes en el cliente), ejecuta operaciones mediante el mecanismo compatible, devuelve resultados. Aísla toda la dependencia de Comercial Pro.
- **BD de integración**: SQL Server propio (solicitudes, bitácora, empresas, usuarios del portal). Separada y sin relación con la BD de Comercial Pro.

## Alternativas evaluadas (resumen; detalle en ADR)
| Decisión | Elegida | Alternativas | Motivo |
|---|---|---|---|
| Frontend | Next.js + TS | Vite/React SPA, Blazor | SSR/rutas, ecosistema, Playwright; costo hosting equivalente |
| Backend | ASP.NET Core .NET 10 | Node/NestJS | Comparte lenguaje/stack con el conector y SDKs .NET de CONTPAQi (de terceros, ver INTEGRACION) |
| Comunicación portal↔local | Conector con sondeo/long-poll saliente | VPN, túnel entrante, exponer API local, SQL remoto | Sin puertos entrantes ni SQL expuesto; ver ADR-0002 |
| Datos | SQL Server (Developer/Express en dev) | PostgreSQL | Mismo motor que el cliente ya opera; PENDIENTE confirmar licencias para producción |
| Multiempresa | `EmpresaId` en toda entidad + conector por empresa | BD por empresa | Más simple al inicio; migrable. ADR-0003 |

## Restricciones y riesgos de compatibilidad (HIPÓTESIS, por confirmar)
- El SDK/COM de CONTPAQi suele ser Windows y de 32 bits o dependiente de la instalación → el conector podría requerir .NET Framework 4.8 o destino x86, en cuyo caso **la API no debe compartir tipos de ensamblado con él**; el contrato será JSON/OpenAPI. Esto es una razón para no crear aún un proyecto "Contracts" compartido.
- Edición Pro vs Premium: paquetes de terceros mencionan Premium; compatibilidad con Pro sin confirmar.

## Fase 2 — Comparación de mecanismos de comunicación (HIPÓTESIS; sin resultados reales aún)
| Criterio | A. API → SQL Server | B. Servicio Windows local | C. SDK/API del producto | D. Híbrida |
|---|---|---|---|---|
| Seguridad | Mala si SQL se expone a internet; exige VPN/túnel | Buena: conexión saliente, SQL no expuesto | Buena si corre local | Buena |
| Crear/timbrar facturas | **Insuficiente**: INSERT directo prohibido (ADR-0005); solo lectura | Solo si usa un mecanismo compatible | Es el mecanismo compatible, **si existe para Pro (BLOQUEADO)** | Lectura por SQL local + escritura por SDK |
| Compatibilidad (bitness, Windows) | Ninguna restricción | Hereda las del SDK | Hereda las del SDK (posible x86/.NET Framework) | Hereda las del SDK |
| Multiempresa | Una conexión por empresa expuesta | Un conector por empresa/instalación | Igual que B | Igual que B |
| Recuperación / duplicados | Lectura permite verificar existencia | Lease + verificación de existencia | Depende de si el SDK permite consultar estado | Mejor: SQL de solo lectura confirma lo que el SDK hizo |
| Mantenimiento | Esquema interno puede cambiar con actualizaciones | Actualizar conector por cliente | Soporte del fabricante | Dos piezas |
**Conclusión provisional (no cambia ADR-0001/0002):** C+B (o D) es la única ruta que respeta ADR-0005; A solo sirve como lectura dentro del conector. Se confirmará o descartará con EXP-00/01/02.
**Si el SDK exige .NET Framework/x86/sesión interactiva:** el conector pasa a ser un ejecutable x86 separado (no servicio puro: servicio + proceso auxiliar en sesión de usuario, o tarea programada) y el contrato con la API sigue siendo JSON sobre HTTPS; la API y el web no cambian.
