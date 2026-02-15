using Npgsql;
using NpgsqlTypes;
using System.Text.Json;
using CacheApi.Models;

namespace CacheApi.Services;

public interface ICacheService
{
    Task<string> StoreAsync(string key, object value);
    Task<object?> RetrieveAsync(string key);
}

public class CacheService : ICacheService
{
    private readonly string _connectionString;
    private readonly ILogger<CacheService> _logger;

    public CacheService(IConfiguration configuration, ILogger<CacheService> logger)
    {
        _connectionString = configuration.GetConnectionString("PostgresConnection")
            ?? throw new InvalidOperationException("Connection string 'PostgresConnection' not found.");
        _logger = logger;
    }

    public async Task<string> StoreAsync(string key, object value)
    {
        try
        {
            using var connection = new NpgsqlConnection(_connectionString);
            await connection.OpenAsync();

            var jsonValue = JsonSerializer.Serialize(value);
            
            using var cmd = new NpgsqlCommand(
                @"INSERT INTO cache (key, value, inserted_at) 
                  VALUES (@key, @value::jsonb, NOW()) 
                  ON CONFLICT (key) DO UPDATE SET value = @value::jsonb, inserted_at = NOW()
                  RETURNING key", 
                connection);
            
            cmd.Parameters.AddWithValue("@key", key);
            cmd.Parameters.AddWithValue("@value", jsonValue);

            var result = await cmd.ExecuteScalarAsync();
            _logger.LogInformation("Successfully stored cache item with key: {Key}", key);
            
            return (string?)result ?? key;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error storing cache item with key: {Key}", key);
            throw;
        }
    }

    public async Task<object?> RetrieveAsync(string key)
    {
        try
        {
            using var connection = new NpgsqlConnection(_connectionString);
            await connection.OpenAsync();

            using var cmd = new NpgsqlCommand(
                "SELECT value FROM cache WHERE key = @key", 
                connection);
            
            cmd.Parameters.AddWithValue("@key", key);

            var result = await cmd.ExecuteScalarAsync();
            
            if (result == null || result == DBNull.Value)
            {
                _logger.LogWarning("Cache item not found for key: {Key}", key);
                return null;
            }

            var jsonString = result.ToString();
            _logger.LogInformation("Successfully retrieved cache item with key: {Key}", key);
            
            return JsonSerializer.Deserialize<object>(jsonString ?? "{}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving cache item with key: {Key}", key);
            throw;
        }
    }
}
