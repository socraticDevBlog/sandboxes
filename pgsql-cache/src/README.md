# C# Cache API Service

A simple ASP.NET Core API service for caching JSON data in PostgreSQL.

## Prerequisites

- .NET 8.0 SDK or later
- PostgreSQL running on localhost:5432
- PostgreSQL database with the cache table set up

## Setup

1. Install dependencies:
```bash
cd src
dotnet restore
```

2. Ensure your PostgreSQL database has the cache table created (refer to setup_database.sql)

3. Build the project:
```bash
dotnet build
```

4. Run the API:
```bash
dotnet run
```

The API will start on `https://localhost:7071` and `http://localhost:5000`

## API Endpoints

### Store an item in cache
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

Response:
```json
{
  "key": "my-cache-key"
}
```

### Retrieve an item from cache
**GET** `/api/v1/retrieve/{key}`

Example: `GET /api/v1/retrieve/my-cache-key`

Response:
```json
{
  "value": {
    "name": "John Doe",
    "age": 30,
    "email": "john@example.com"
  }
}
```

## Features

- Store JSON objects in PostgreSQL with a unique key
- Retrieve cached items by key
- Automatic timestamp tracking (inserted_at)
- Upsert functionality (updates if key already exists)
- Full error handling and logging
- Swagger/OpenAPI documentation

## Connection String

The connection string is configured in `appsettings.json`:
- Host: localhost
- Port: 5432
- Username: postgres
- Password: strongpassword
- Database: postgres

## Testing with curl

Store an item:
```bash
curl -X POST http://localhost:5000/api/v1/store \
  -H "Content-Type: application/json" \
  -d '{"key":"test-key","value":{"message":"Hello World"}}'
```

Retrieve an item:
```bash
curl http://localhost:5000/api/v1/retrieve/test-key
```
