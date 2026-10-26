#!/usr/bin/env bash
# Verificación completa local. Falla en el primer error. No toca Comercial Pro ni servicios externos.
set -euo pipefail
cd "$(dirname "$0")/.."
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1

echo "== Diagnóstico SQL: solo lectura =="; ./scripts/check-sql-readonly.sh
echo "== .NET: formato =="; dotnet format --verify-no-changes
echo "== .NET: compilación estricta =="; dotnet build -warnaserror
echo "== .NET: pruebas =="; dotnet test --no-build
echo "== .NET: paquetes vulnerables =="
out=$(dotnet list package --vulnerable --include-transitive 2>&1); echo "$out"
if grep -q "has the following vulnerable packages" <<<"$out"; then echo "Paquetes vulnerables"; exit 1; fi
echo "== Web: lint, tipos, build, audit =="
(cd src/web && npm ci && npm run lint && npm run typecheck && npm run build && npm audit --audit-level=high)
if [[ "${SKIP_E2E:-0}" != "1" ]]; then
  echo "== E2E (Playwright) =="; (cd tests/e2e && npm ci && npx playwright test)
fi
echo "OK"
