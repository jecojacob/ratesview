﻿using WCC.Rates.RatesView.Client;
using WCC.Rates.RatesView.Client.Services;

using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.Extensions.DependencyInjection.Extensions;

using System.Net.Http.Headers;
using Microsoft.FluentUI.AspNetCore.Components;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.Services.AddOptions();
builder.Services.AddAuthorizationCore();
builder.Services.TryAddSingleton<AuthenticationStateProvider, HostAuthenticationStateProvider>();
builder.Services.TryAddSingleton(sp => (HostAuthenticationStateProvider)sp.GetRequiredService<AuthenticationStateProvider>());
builder.Services.AddTransient<AuthorizedHandler>();
builder.RootComponents.Add<App>("#app");

builder.Services.AddHttpClient("default", client =>
{
    client.BaseAddress = new Uri(builder.HostEnvironment.BaseAddress);
    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
});

builder.Services.AddHttpClient("authorizedClient", client =>
{
    client.BaseAddress = new Uri(builder.HostEnvironment.BaseAddress);
    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
}).AddHttpMessageHandler<AuthorizedHandler>();

builder.Services.AddFluentUIComponents();
builder.Services.AddSingleton<GlobalState>();
builder.Services.AddSingleton<LibraryConfiguration>();

builder.Services.AddTransient(sp => sp.GetRequiredService<IHttpClientFactory>().CreateClient("default"));
builder.Services.AddTransient<IAntiforgeryHttpClientFactory, AntiforgeryHttpClientFactory>();

await builder.Build().RunAsync();
