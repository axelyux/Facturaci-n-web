# Estrategia de pruebas
| Capa | Herramienta | Comando | Estado |
|---|---|---|---|
| Formato .NET | dotnet format | `dotnet format --verify-no-changes` | Operativo |
| Compilación estricta | analyzers + TreatWarningsAsErrors | `dotnet build -warnaserror` | Operativo |
| Integración API | xUnit + WebApplicationFactory | `dotnet test` | Operativo (2 pruebas de /health y 404) |
| Unitarias | xUnit | — | Se crean con la primera lógica de dominio |
| Lint/tipos web | ESLint, tsc | `npm run lint`, `npm run typecheck` (en src/web) | Operativo |
| Navegador | Playwright (móvil y escritorio) | `cd tests/e2e && npx playwright test` | Operativo (1 prueba de humo × 2 perfiles) |
| Dependencias vulnerables | NuGet audit, npm audit | `./scripts/verify.sh` | Operativo |
| SQL de diagnóstico solo lectura | grep estático | `scripts/check-sql-readonly.sh` | Operativo (incluido en verify.sh) |
| Idempotencia y concurrencia | pruebas de integración con BD de prueba | — | PENDIENTE (requiere BD de integración, ADR-0004) |
| Aislamiento entre empresas | pruebas negativas | — | PENDIENTE |
| Contra Comercial Pro real | experimentos EXP-0x | — | PENDIENTE (requiere entorno autorizado) |
No se reporta cobertura: aún no se mide.
