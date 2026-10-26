#!/usr/bin/env bash
# Verificación estática: los .sql de diagnóstico no contienen operaciones de escritura/ejecución.
set -euo pipefail
cd "$(dirname "$0")/diagnostico/sql"
bad=0
for f in *.sql; do
  if sed 's/--.*//' "$f" | grep -Eiq '\b(INSERT|UPDATE|DELETE|MERGE|DROP|ALTER|CREATE|TRUNCATE|EXEC|EXECUTE|GRANT|REVOKE|DENY|BACKUP|RESTORE|DBCC|OPENROWSET|OPENQUERY|xp_[a-z_]+|sp_[a-z_]+)\b'; then
    echo "RECHAZADO: $f"; bad=1; fi
done
[ $bad -eq 0 ] && echo "SQL de diagnóstico: solo lectura OK ($(ls *.sql | wc -l) archivos)"
exit $bad
