namespace Facturacion.Connector;

/// <summary>
/// Esqueleto del conector local. No contiene integración con Comercial Pro:
/// el mecanismo compatible aún no está verificado (ver docs/INTEGRACION_COMERCIAL_PRO.md).
/// </summary>
public sealed partial class Worker(ILogger<Worker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        LogStarted(logger);
        try
        {
            await Task.Delay(Timeout.Infinite, stoppingToken);
        }
        catch (OperationCanceledException)
        {
            // Apagado ordenado.
        }
    }

    [LoggerMessage(Level = LogLevel.Information, Message = "Conector local iniciado (sin integración con Comercial Pro).")]
    private static partial void LogStarted(ILogger logger);
}
