# Autofacturación web para CONTPAQi Comercial Pro

Producto comercial (SaaS B2B multiempresa): portal de autofacturación para clientes finales y personal del negocio, conectado a CONTPAQi Comercial Pro. **Comercial Pro es el sistema fiscal y administrativo de referencia**; no construimos un sistema fiscal paralelo.

## Arquitectura (ver docs/ARQUITECTURA.md y docs/ADR/)
- `src/web`: Next.js 16 + React 19 + TypeScript + Tailwind (móvil primero).
- `src/api`: ASP.NET Core (.NET 10 LTS). Único punto de entrada del portal; dueño de la BD de integración propia.
- `src/connector`: servicio local en la instalación del cliente (esqueleto). Conexión **saliente** hacia el portal. Es el único componente que hablará con Comercial Pro.
- `tests/integration` (xUnit + WebApplicationFactory), `tests/e2e` (Playwright). `tests/unit` se crea con la primera lógica de dominio.
- Idioma: documentación, UI y mensajes de commit en español; identificadores de código en inglés salvo términos del dominio fiscal (RFC, CFDI, UUID).

## Comandos (verificados)
- Todo: `./scripts/verify.sh` (`SKIP_E2E=1` omite navegador)
- API: `dotnet run --project src/api` (http://localhost:5110, `/health`)
- Compilar/probar .NET: `dotnet build -warnaserror` · `dotnet test` · `dotnet format --verify-no-changes`
- Web: `cd src/web && npm run dev | lint | typecheck | build`
- E2E: `cd tests/e2e && npx playwright test` (levanta la web solo; usa Chromium preinstalado, @playwright/test fijado a 1.63.0)

## Reglas inquebrantables
1. **No inventar** APIs, tablas, columnas, procedimientos ni flujos de Comercial Pro. Todo dato de Comercial Pro se etiqueta VERIFICADO / HIPÓTESIS / PENDIENTE en `docs/INTEGRACION_COMERCIAL_PRO.md` y solo pasa a VERIFICADO con evidencia (doc oficial o experimento registrado).
2. No escribir directo en SQL Server de Comercial Pro ni suponer que un INSERT crea una factura válida. Acceso SQL a Comercial Pro: solo lectura y solo tras experimento aprobado.
3. Nunca generar ni cancelar CFDI reales, ni escribir en bases reales, sin autorización explícita del usuario en esa sesión.
4. Sin secretos en el repo, logs ni respuestas. Solo `.env.example` con placeholders. Errores internos nunca se exponen al cliente final (usar ProblemDetails genérico + id de correlación).
5. Toda solicitud de facturación es idempotente (clave de idempotencia) y toda consulta/escritura lleva `EmpresaId` (aislamiento multiempresa).
6. Frontend y API comparten un contrato explícito (OpenAPI cuando exista); el frontend no inventa endpoints.
7. Sin dependencias, servicios de pago ni cloud sin documentar en `docs/COSTOS_OPERATIVOS.md`.
8. Cambios de comportamiento requieren prueba. No declarar éxito sin ejecutar el comando; reportar fallos tal cual. Lo que dependa de Comercial Pro real = PENDIENTE.
9. No hacer commit/push sin autorización del usuario (rama de trabajo asignada por la sesión).

## Convenciones
- C#: file-scoped namespaces, nullable, `TreatWarningsAsErrors` (Directory.Build.props), `[LoggerMessage]` para logs, sin `async void`, `CancellationToken` en I/O.
- TS: strict, componentes de servidor por defecto, sin `any`.
- Next.js 16 difiere de versiones anteriores: leer `src/web/node_modules/next/dist/docs/` antes de usar APIs (ver `src/web/AGENTS.md`).
- Decisiones importantes → ADR en `docs/ADR/` (skill `nuevo-adr`).

## Documentación
`docs/`: PRODUCTO, ARQUITECTURA, DECISIONES_TECNICAS (índice ADR), INTEGRACION_COMERCIAL_PRO, EXPERIMENTOS, MODELO_DATOS, SEGURIDAD, PRUEBAS, DESPLIEGUE, COSTOS_OPERATIVOS, PLAN_IMPLEMENTACION, HERRAMIENTAS_CLAUDE.
Agentes en `.claude/agents/`, skills en `.claude/skills/`. Úsalos de forma secuencial; nunca dos agentes editando los mismos archivos.
