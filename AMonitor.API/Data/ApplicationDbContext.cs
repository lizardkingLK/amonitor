using AMonitor.API.Data.Compiled;
using AMonitor.API.Models.Common;
using Microsoft.EntityFrameworkCore;

namespace AMonitor.API.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
#pragma warning disable IL2026 
#pragma warning disable IL3050 
        : base(options)
#pragma warning restore IL3050 
#pragma warning restore IL2026 
    {
    }

    public DbSet<AzureCommonAlertPayload> Alerts => Set<AzureCommonAlertPayload>();

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseModel(ApplicationDbContextModel.Instance);

        base.OnConfiguring(optionsBuilder);
    }
}
