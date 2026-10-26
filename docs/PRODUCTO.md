# Producto

Plataforma web de autofacturación sobre CONTPAQi Comercial Pro, ofrecida por nosotros (distribuidores y desarrolladores) a distintos negocios. Dos experiencias sobre **el mismo motor de validación y facturación**.

## A. Cliente final (móvil o escritorio, vía URL o QR)
1. Captura folio del ticket/folio del negocio.
2. El sistema consulta la venta en Comercial Pro y valida que existe y es facturable.
3. Muestra datos pertinentes de la compra.
4. Busca cliente por RFC; si no existe, captura datos fiscales para darlo de alta.
5. Confirma información fiscal y solicita la factura.
6. Ve el estado real de la operación; obtiene documentos fiscales disponibles y los recibe por correo cuando corresponda.

## B. Personal del negocio (autenticado)
Buscar ventas por folio, consultar datos, seleccionar/crear cliente, gestionar solicitudes, ver pendientes/completadas/fallidas, recuperar operaciones interrumpidas **sin duplicar facturas**, consultar bitácoras y errores según permisos.

## Principios UX
Pocos pasos, rápido, profesional, cómodo en móvil. La complejidad vive en integración, seguridad y fiabilidad. Estados honestos (nunca "listo" sin confirmación real). Mensajes de error comprensibles y sin detalles internos.

## Fuera de alcance (por ahora)
Sistema fiscal propio, reemplazo de Comercial Pro, cancelaciones (diseño pendiente, ver INTEGRACION_COMERCIAL_PRO.md §Cancelaciones).
