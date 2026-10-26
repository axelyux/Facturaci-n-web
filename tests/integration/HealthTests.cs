using Microsoft.AspNetCore.Mvc.Testing;

namespace Facturacion.Api.IntegrationTests;

public sealed class HealthTests(WebApplicationFactory<Program> factory) : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task Health_devuelve_200_y_cabeceras_de_seguridad()
    {
        using var client = factory.CreateClient();

        using var response = await client.GetAsync("/health");

        Assert.Equal(System.Net.HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("nosniff", response.Headers.GetValues("X-Content-Type-Options").Single());
        Assert.Equal("DENY", response.Headers.GetValues("X-Frame-Options").Single());
    }

    [Fact]
    public async Task Ruta_inexistente_devuelve_404()
    {
        using var client = factory.CreateClient();

        using var response = await client.GetAsync("/no-existe");

        Assert.Equal(System.Net.HttpStatusCode.NotFound, response.StatusCode);
    }
}
