# pgsql database used as a cache

## deliverables

- one fully configured postgresql instance ✅
- a demo of the cron function that enforcs a TTL of one hour ✅
- a C# service that writes and reads from the cache ✅

## feature 0: unlogged table

> UNLOGGED tables don't generate WAL (Write Ahead Log) information. That gives us huge improvements in write performance and saves us some disk space. There's obviously a trade-off - UNLOGGED tables aren't crash-safe - without WAL record, if database server crashes, an unlogged table is automatically truncated, but with cache we don't really expect proper persistence, so that's OK. Additionally, UNLOGGED tables are only available on primary, not on replicas, so no distributed cache, which might or might not be an issue, you decide.

## feature 1: cron calling useful functions

- ttl: stored procedure (function) should be used to free Cache table from old records

## lab

in this lab, you will provision an already configured postgresql database in a
Docker container running on your local machine

### requirements

- Docker runtime running on your machine
- a bash terminal (tested on wsl2)
- (optionnal) a SQL IDE that can connect to Postgresql (i'm using [DBeaver](https://dbeaver.io/download/))

### instructions

```bash
chmod +x setup.sh

./setup.sh
```

#### connect to Postgresql

uri: localhost
databasename: postgres
username: postgres
password: strongpassword

#### two tables

`cache` and `cron`

`cache` is where the cached index/items are

`cron` is where the configured cron actions are configured

cron called `functions` defined in the same schema as the cache table

#### observe and learn

Let it sit for a few hour

query the `cache` table and notice that it only keeps records from at most an
hour ago.

## sources

<https://www.martinheinz.dev/blog/105>

---

## C# Cache API Service

A fully functional ASP.NET Core REST API service for caching JSON data in PostgreSQL.

### Database Schema

```sql
CREATE UNLOGGED TABLE cache (
    id serial PRIMARY KEY,
    key text UNIQUE NOT NULL,
    value jsonb,
    inserted_at timestamp
);

CREATE INDEX idx_cache_key ON cache (key);
```

**Key Features:**

- **UNLOGGED table**: No WAL (Write Ahead Log) overhead, optimized for cache use cases
- **JSONB storage**: Flexible JSON data type for storing complex objects
- **TTL enforcement**: Automatic cleanup of expired entries via pg_cron scheduler
- **Unique key constraint**: One value per key with upsert capability

### API Endpoints

#### 1. Store an Item

**POST** `/api/v1/store`

Request body:

```json
{
  "key": "my-cache-key",
  "value": {
    "name": "John Doe",
    "age": 30,
    "email": "john@example.com"
  }
}
```

Response (200 OK):

```json
{
  "key": "my-cache-key"
}
```

Response (400 Bad Request):

```json
{
  "error": "Key is required"
}
```

#### 2. Retrieve an Item

**GET** `/api/v1/retrieve/{key}`

Example: `GET /api/v1/retrieve/my-cache-key`

Response (200 OK):

```json
{
  "value": {
    "name": "John Doe",
    "age": 30,
    "email": "john@example.com"
  }
}
```

Response (404 Not Found):

```json
{
  "error": "Cache item with key 'my-cache-key' not found"
}
```

### Architecture

**Project Structure:**

```
src/
├── CacheApi.csproj           # Project configuration
├── Program.cs                # Application entry point
├── appsettings.json          # Configuration (connection strings)
├── Controllers/
│   └── CacheController.cs    # REST API endpoints
├── Services/
│   └── CacheService.cs       # Database operations
├── Models/
│   └── CacheModels.cs        # Data transfer objects
└── README.md                 # Detailed service documentation
```

### Setup & Installation

#### Prerequisites

- .NET 8.0 SDK or later
- PostgreSQL running on localhost:5432
- Database with cache table created (use `setup_database.sql`)

#### Build and Run

```bash
cd src
dotnet restore
dotnet build
dotnet run
```

The API will be available at:

- HTTP: `http://localhost:5000`

### Configuration

Connection string in `src/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "PostgresConnection": "Host=localhost;Port=5432;Username=postgres;Password=strongpassword;Database=postgres"
  }
}
```

### Testing with cURL

**Store an item:**

```bash
curl -X POST http://localhost:5000/api/v1/store \
  -H "Content-Type: application/json" \
  -d '{"key":"test-key","value":{"message":"Hello World","timestamp":"2026-02-15"}}'
```

**Retrieve an item:**

```bash
curl http://localhost:5000/api/v1/retrieve/test-key
```

### Dependencies

- **Npgsql 8.0.1**: PostgreSQL ADO.NET provider
- **System.Text.Json**: JSON serialization
- **ASP.NET Core 8.0**: Web framework

### Features

✅ **Upsert functionality**: Store overwrites existing keys  
✅ **JSON serialization**: Automatic conversion to/from JSONB  
✅ **Error handling**: Comprehensive validation and exception handling  
✅ **Logging**: Built-in ILogger integration for debugging  
✅ **Swagger/OpenAPI**: Auto-generated API documentation  
✅ **Async operations**: Non-blocking database calls

### Notes

- The cache table uses UNLOGGED mode for performance (non-persistent)
- TTL is enforced by PostgreSQL cron job (1-hour retention)
- The service automatically tracks `inserted_at` timestamp
- On database crash, the table is automatically truncated (expected behavior for cache)
