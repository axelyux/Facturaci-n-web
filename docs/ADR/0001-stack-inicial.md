# ADR-0001: Stack inicial
Estado: Aceptada (etapa 0) · Fecha: 2026-10-26

**Contexto.** Portal móvil primero + integración con sistema Windows/SQL Server. Equipo con experiencia .NET. Presupuesto: herramientas gratuitas/OSS.
**Decisión.** Next.js 16/React 19/TS (web), ASP.NET Core sobre .NET 10 LTS (API y conector), SQL Server para BD de integración, xUnit + WebApplicationFactory y Playwright para pruebas.
**Alternativas.** SPA Vite (sin SSR, menos convenciones); Blazor (menor ecosistema UI móvil); Node/NestJS en backend (dos lenguajes en el lado servidor y el conector); .NET 8 LTS (soporte más corto que 10).
**Consecuencias.** Dos runtimes (Node, .NET). Si el conector exige .NET Framework/x86, el conector queda en otro TFM (ver ARQUITECTURA). Verificado: .NET SDK 10.0.113 instalado y compila; Next 16.4.3 compila.
