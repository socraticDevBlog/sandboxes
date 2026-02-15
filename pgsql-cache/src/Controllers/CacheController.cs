using CacheApi.Models;
using CacheApi.Services;
using Microsoft.AspNetCore.Mvc;

namespace CacheApi.Controllers;

[ApiController]
[Route("api/v1")]
public class CacheController : ControllerBase
{
    private readonly ICacheService _cacheService;
    private readonly ILogger<CacheController> _logger;

    public CacheController(ICacheService cacheService, ILogger<CacheController> logger)
    {
        _cacheService = cacheService;
        _logger = logger;
    }

    /// <summary>
    /// Store an item in the cache
    /// </summary>
    /// <param name="request">StoreRequest containing key and value</param>
    /// <returns>StoreResponse with the stored key</returns>
    [HttpPost("store")]
    public async Task<ActionResult<StoreResponse>> Store([FromBody] StoreRequest request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.Key))
        {
            _logger.LogWarning("Invalid store request: key is required");
            return BadRequest(new { error = "Key is required" });
        }

        try
        {
            var key = await _cacheService.StoreAsync(request.Key, request.Value);
            return Ok(new StoreResponse { Key = key });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error storing cache item");
            return StatusCode(500, new { error = "Internal server error while storing cache item" });
        }
    }

    /// <summary>
    /// Retrieve an item from the cache by key
    /// </summary>
    /// <param name="key">The cache key</param>
    /// <returns>RetrieveResponse with the cached value as JSON</returns>
    [HttpGet("retrieve/{key}")]
    public async Task<ActionResult<RetrieveResponse>> Retrieve(string key)
    {
        if (string.IsNullOrWhiteSpace(key))
        {
            _logger.LogWarning("Invalid retrieve request: key is required");
            return BadRequest(new { error = "Key is required" });
        }

        try
        {
            var value = await _cacheService.RetrieveAsync(key);
            
            if (value == null)
            {
                _logger.LogInformation("Cache item not found for key: {Key}", key);
                return NotFound(new { error = $"Cache item with key '{key}' not found" });
            }

            return Ok(new RetrieveResponse { Value = value });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving cache item");
            return StatusCode(500, new { error = "Internal server error while retrieving cache item" });
        }
    }
}
