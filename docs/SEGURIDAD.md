# Seguridad
Amenazas principales y controles previstos (ninguno de autenticación está implementado aún; lo implementado es solo cabeceras básicas y manejo de excepciones genérico en la API).
- **Enumeración de folios / abuso del portal público**: límite de tasa por IP y folio, captcha si hace falta (alternativa gratuita a evaluar), respuestas uniformes, datos mínimos mostrados antes de confirmar.
- **Autenticación del personal**: ASP.NET Core Identity u OIDC; roles por empresa; MFA deseable. PENDIENTE decidir.
- **Aislamiento multiempresa**: `EmpresaId` obligatorio + pruebas negativas (ADR-0003).
- **Conector**: credencial por conector, rotación, solo conexión saliente TLS; nunca SQL de Comercial Pro expuesto.
- **Secretos**: gestor de secretos/user-secrets; nunca en repo/logs. Cifrado de secretos del conector con DPAPI (a validar).
- **Errores**: ProblemDetails genérico + correlación; detalle solo en bitácora interna.
- **Datos personales**: minimizar, no registrar RFC/correo en logs.
- **Cadena de suministro**: `dotnet list package --vulnerable`, `npm audit`, versiones fijadas, Dependabot (cuando haya repositorio remoto configurado).
- **Cabeceras web**: nosniff, X-Frame-Options, Referrer-Policy (API hecho); CSP y HSTS en el despliegue.
