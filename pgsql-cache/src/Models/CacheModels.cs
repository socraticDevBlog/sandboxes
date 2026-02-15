namespace CacheApi.Models;

public class StoreRequest
{
    public required string Key { get; set; }
    public required object Value { get; set; }
}

public class StoreResponse
{
    public required string Key { get; set; }
}

public class RetrieveResponse
{
    public required object Value { get; set; }
}

public class CacheItem
{
    public int Id { get; set; }
    public required string Key { get; set; }
    public object? Value { get; set; }
    public DateTime InsertedAt { get; set; }
}
