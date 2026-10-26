# Autofacturación web para CONTPAQi Comercial Pro

Portal de autofacturación (cliente final y personal del negocio) conectado a CONTPAQi Comercial Pro. **Estado: etapa 0 — base del repositorio.** No hay integración fiscal implementada; ver `docs/INTEGRACION_COMERCIAL_PRO.md`.

## Requisitos
.NET SDK 10 (LTS), Node.js 22+, npm 10+. Para e2e: Chromium (Playwright 1.63.0).

## Inicio rápido
```bash
./scripts/verify.sh            # compila, analiza y prueba todo (SKIP_E2E=1 omite navegador)
dotnet run --project src/api   # API en http://localhost:5110/health
cd src/web && npm ci && npm run dev   # web en http://localhost:3000
```

## Estructura
| Ruta | Propósito |
|---|---|
| `src/web` | Portal Next.js (cliente final y personal) |
| `src/api` | API ASP.NET Core |
| `src/connector` | Conector local (esqueleto, sin integración) |
| `tests/integration`, `tests/e2e` | Pruebas de API y de navegador |
| `docs/` | Producto, arquitectura, ADR, integración, seguridad, plan |
| `.claude/` | Agentes y skills del proyecto |

Lee primero `CLAUDE.md` y `docs/PLAN_IMPLEMENTACION.md`.
