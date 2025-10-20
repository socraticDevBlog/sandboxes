using Microsoft.EntityFrameworkCore;
using StackExchange.Redis;

var builder = WebApplication.CreateBuilder(args);

// Add PostgreSQL
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("PostgreSQL")));

// Add Redis
builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
    ConnectionMultiplexer.Connect(builder.Configuration.GetConnectionString("Redis") ?? "localhost:6379"));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Auto-migrate database on startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    await db.Database.EnsureCreatedAsync();
}

app.UseSwagger();
app.UseSwaggerUI();

// Health check endpoint
app.MapGet("/health", async (AppDbContext db, IConnectionMultiplexer redis) =>
{
    var dbHealthy = await db.Database.CanConnectAsync();
    var redisHealthy = redis.IsConnected;
    
    return Results.Ok(new
    {
        status = dbHealthy && redisHealthy ? "healthy" : "unhealthy",
        database = dbHealthy ? "connected" : "disconnected",
        cache = redisHealthy ? "connected" : "disconnected"
    });
});

// Example endpoint - Create item
app.MapPost("/items", async (Item item, AppDbContext db) =>
{
    db.Items.Add(item);
    await db.SaveChangesAsync();
    return Results.Created($"/items/{item.Id}", item);
});

// Example endpoint - Get all items
app.MapGet("/items", async (AppDbContext db) =>
{
    return await db.Items.ToListAsync();
});

// Example endpoint - Cache test
app.MapGet("/cache/{key}", async (string key, IConnectionMultiplexer redis) =>
{
    var db = redis.GetDatabase();
    var value = await db.StringGetAsync(key);
    
    if (value.IsNullOrEmpty)
        return Results.NotFound();
    
    return Results.Ok(new { key, value = value.ToString() });
});

app.MapPost("/cache/{key}", async (string key, string value, IConnectionMultiplexer redis) =>
{
    var db = redis.GetDatabase();
    await db.StringSetAsync(key, value);
    return Results.Ok(new { key, value });
});

app.Run();

// Database context
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
    public DbSet<Item> Items { get; set; }
}

// Simple model
public class Item
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
}