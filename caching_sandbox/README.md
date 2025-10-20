![stresstesting](https://img.shields.io/badge/stresstesting-yes-yellow)

![image](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)![image](https://img.shields.io/badge/redis-%23DD0031.svg?&style=for-the-badge&logo=redis&logoColor=white)![image](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)![image](https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)![image](https://img.shields.io/badge/Grafana-F2F4F9?style=for-the-badge&logo=grafana&logoColor=orange&labelColor=F2F4F9)![image](https://img.shields.io/badge/Prometheus-000000?style=for-the-badge&logo=prometheus&labelColor=000000)

# .NET API Sandbox with Redis & PostgreSQL - Performance Testing Suite

A complete Docker-based development sandbox featuring a .NET 8 Web API, Redis cache, PostgreSQL database, and comprehensive monitoring and load testing tools. Perfect for performance testing, benchmarking, and optimization.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Monitoring & Dashboards](#monitoring--dashboards)
- [Load Testing](#load-testing)
- [Docker Compose Commands](#docker-compose-commands)
- [API Endpoints](#api-endpoints)
- [Service Details](#service-details)
- [Performance Metrics](#performance-metrics)
- [Troubleshooting](#troubleshooting)

## 🏗️ Architecture

This sandbox consists of eight interconnected services:

**Application Stack:**
- **Web API**: .NET 8 minimal API with Swagger documentation
- **Redis**: In-memory cache for fast data access
- **PostgreSQL**: Relational database with persistent storage

**Monitoring Stack:**
- **Prometheus**: Metrics collection and time-series database
- **Grafana**: Real-time visualization and dashboards
- **PostgreSQL Exporter**: Exposes PostgreSQL metrics to Prometheus
- **Redis Exporter**: Exposes Redis metrics to Prometheus

**Load Testing:**
- **k6**: Modern load testing tool for performance evaluation

All services run in Docker containers and communicate via a dedicated bridge network.

## 📦 Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (version 20.10 or higher)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0 or higher)

No .NET SDK, Grafana, or other dependencies required on your host machine!

## 📁 Project Structure

```
sandbox/
├── docker-compose.yml              # Multi-container orchestration
├── README.md                       # This file
├── api/
│   ├── Dockerfile                  # API container definition
│   ├── Program.cs                  # API application code
│   └── SandboxApi.csproj           # .NET project file
├── monitoring/
│   ├── prometheus.yml              # Prometheus configuration
│   └── grafana/
│       ├── dashboards/
│       │   ├── dashboard.yml       # Dashboard provisioning
│       │   └── performance-dashboard.json
│       └── datasources/
│           └── datasource.yml      # Prometheus datasource
└── load-tests/
    ├── light-load.js               # Light load test (10 users)
    ├── medium-load.js              # Medium load test (50-100 users)
    ├── stress-test.js              # Stress test (400+ users)
    └── spike-test.js               # Spike test (sudden surge)
```

## 🚀 Quick Start

### Start All Services

```bash
# Start the entire stack
docker-compose up -d

# View logs
docker-compose logs -f
```

### Access Services

- **API**: http://localhost:5000
- **Swagger UI**: http://localhost:5000/swagger
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

### Verify Health

```bash
curl http://localhost:5000/health
```

## 📊 Monitoring & Dashboards

### Grafana Setup

1. **Access Grafana**: http://localhost:3000
2. **Login**: Username: `admin`, Password: `admin`
3. **Dashboard**: Navigate to "Dashboards" → "API Performance - PostgreSQL & Redis"

The dashboard is automatically provisioned and includes panels for all key metrics.

### Available Metrics

**PostgreSQL Metrics:**
- Active connections
- Query duration (read/write time)
- Transactions per second (commits/rollbacks)
- Cache hit ratio
- Deadlocks
- Buffer statistics

**Redis Metrics:**
- Connected clients
- Operations per second
- Memory usage
- Keyspace hit rate
- Evicted keys
- Command statistics

### Direct Prometheus Access

Query metrics directly at http://localhost:9090

**Example queries:**
```promql
# PostgreSQL connections
pg_stat_database_numbackends{datname="apidb"}

# Redis memory usage
redis_memory_used_bytes

# Redis operations per second
rate(redis_commands_processed_total[1m])

# PostgreSQL cache hit ratio
rate(pg_stat_database_blks_hit[5m]) / (rate(pg_stat_database_blks_hit[5m]) + rate(pg_stat_database_blks_read[5m]))
```

## 🔥 Load Testing

### Available Test Scenarios

#### 1. Light Load Test
**Purpose**: Baseline performance with minimal load  
**Users**: 10 concurrent users  
**Duration**: 2 minutes  
**Use case**: Verify system works correctly under normal conditions

```bash
docker-compose run --rm k6 run /scripts/light-load.js
```

#### 2. Medium Load Test
**Purpose**: Realistic production load simulation  
**Users**: 50-100 concurrent users  
**Duration**: 8 minutes  
**Use case**: Test typical production traffic patterns with mixed read/write operations

```bash
docker-compose run --rm k6 run /scripts/medium-load.js
```

#### 3. Stress Test
**Purpose**: Find breaking points and maximum capacity  
**Users**: Ramps up to 400 users  
**Duration**: 12 minutes  
**Use case**: Identify system limits and failure modes

```bash
docker-compose run --rm k6 run /scripts/stress-test.js
```

#### 4. Spike Test
**Purpose**: Evaluate response to sudden traffic surges  
**Users**: Sudden spike from 20 to 500 users  
**Duration**: 4 minutes  
**Use case**: Test system resilience during traffic spikes (e.g., flash sales, viral content)

```bash
docker-compose run --rm k6 run /scripts/spike-test.js
```

### Monitoring Load Tests in Real-Time

**Best Practice Workflow:**

1. **Start monitoring** before running tests:
   ```bash
   docker-compose up -d
   ```

2. **Open Grafana dashboard**: http://localhost:3000

3. **Run your load test** in another terminal:
   ```bash
   docker-compose run --rm k6 run /scripts/medium-load.js
   ```

4. **Watch metrics update** in real-time as load increases

### Understanding k6 Output

k6 provides detailed statistics after each test:

```
     ✓ health check status is 200
     ✓ items list status is 200
     ✓ create item status is 201

     checks.........................: 100.00% ✓ 15000      ✗ 0
     data_received..................: 1.2 MB  40 kB/s
     data_sent......................: 234 kB  7.8 kB/s
     http_req_blocked...............: avg=1.2ms    min=0s    med=1ms    max=50ms   p(95)=3ms
     http_req_duration..............: avg=145ms    min=10ms  med=120ms  max=2s     p(95)=340ms
     http_req_failed................: 0.50%   ✓ 12         ✗ 2388
     http_reqs......................: 2400    80/s
     iteration_duration.............: avg=1.2s     min=1s    med=1.18s  max=3s     p(95)=1.4s
     iterations.....................: 2400    80/s
     vus............................: 100     min=10       max=100
     vus_max........................: 100     min=100      max=100
```

**Key Metrics:**
- **checks**: Percentage of successful validations
- **http_req_duration**: Response time (p95 is critical)
- **http_req_failed**: Error rate
- **http_reqs**: Total requests per second
- **vus**: Virtual users (concurrent users)

### Custom Load Test

Create your own test in `load-tests/custom-test.js`:

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 50 },
    { duration: '2m', target: 50 },
    { duration: '1m', target: 0 },
  ],
};

export default function () {
  const res = http.get('http://api:8080/health');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
```

Run it:
```bash
docker-compose run --rm k6 run /scripts/custom-test.js
```

## 🐳 Docker Compose Commands

### Starting Services

```bash
# Start all services (including monitoring)
docker-compose up -d

# Start with logs visible
docker-compose up

# Start and rebuild
docker-compose up --build -d

# Start only core services (no monitoring)
docker-compose up -d api postgres redis
```

### Stopping Services

```bash
# Stop all services (containers remain)
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove containers + volumes (DELETES ALL DATA)
docker-compose down -v

# Stop and remove everything including images
docker-compose down -v --rmi all
```

### Managing Services

```bash
# View running containers
docker-compose ps

# View logs from all services
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View logs for specific service
docker-compose logs -f api
docker-compose logs -f postgres
docker-compose logs -f grafana

# Restart a specific service
docker-compose restart api

# Execute command in running container
docker-compose exec api bash
docker-compose exec postgres psql -U postgres -d apidb
docker-compose exec redis redis-cli
```

### Load Testing Commands

```bash
# Run specific load test
docker-compose run --rm k6 run /scripts/light-load.js

# Run with custom options
docker-compose run --rm k6 run --vus 50 --duration 30s /scripts/light-load.js

# Run and output results to file
docker-compose run --rm k6 run /scripts/medium-load.js --out json=results.json
```

### Maintenance

```bash
# Rebuild specific service
docker-compose build --no-cache api

# Pull latest images
docker-compose pull

# Check configuration validity
docker-compose config

# Remove unused resources
docker system prune
```

## 🔌 API Endpoints

### Health Check

**GET** `/health`

Check the status of database and cache connections.

**Response:**
```json
{
  "status": "healthy",
  "database": "connected",
  "cache": "connected"
}
```

**cURL Example:**
```bash
curl http://localhost:5000/health
```

---

### Items Management (PostgreSQL)

#### Create Item

**POST** `/items`

Create a new item in the PostgreSQL database.

**Request Body:**
```json
{
  "name": "Sample Item",
  "description": "This is a test item"
}
```

**Response:** `201 Created`
```json
{
  "id": 1,
  "name": "Sample Item",
  "description": "This is a test item"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:5000/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Sample Item","description":"This is a test item"}'
```

#### Get All Items

**GET** `/items`

Retrieve all items from the database.

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "name": "Sample Item",
    "description": "This is a test item"
  }
]
```

**cURL Example:**
```bash
curl http://localhost:5000/items
```

---

### Cache Management (Redis)

#### Set Cache Value

**POST** `/cache/{key}`

Store a value in Redis cache.

**Query Parameters:**
- `key` (string): Cache key
- `value` (string, query param): Value to store

**Response:** `200 OK`
```json
{
  "key": "mykey",
  "value": "myvalue"
}
```

**cURL Example:**
```bash
curl -X POST "http://localhost:5000/cache/mykey?value=myvalue"
```

#### Get Cache Value

**GET** `/cache/{key}`

Retrieve a value from Redis cache.

**Parameters:**
- `key` (string): Cache key

**Response:** `200 OK`
```json
{
  "key": "mykey",
  "value": "myvalue"
}
```

**Response:** `404 Not Found` (if key doesn't exist)

**cURL Example:**
```bash
curl http://localhost:5000/cache/mykey
```

---

### API Documentation

**Swagger UI**: http://localhost:5000/swagger

Interactive API documentation where you can test all endpoints directly from your browser.

## 🔧 Service Details

### .NET Web API

- **Technology**: .NET 8.0 with ASP.NET Core Minimal APIs
- **Port**: 5000 (host) → 8080 (container)
- **Features**:
  - Swagger/OpenAPI documentation
  - Entity Framework Core with PostgreSQL
  - StackExchange.Redis client
  - Automatic database schema creation
  - Health check endpoint

**Key Dependencies:**
- `Npgsql.EntityFrameworkCore.PostgreSQL` - PostgreSQL provider
- `StackExchange.Redis` - Redis client
- `Swashbuckle.AspNetCore` - Swagger/OpenAPI

### PostgreSQL Database

- **Image**: `postgres:latest`
- **Port**: 5432
- **Default Credentials**:
  - Username: `postgres`
  - Password: `postgres123`
  - Database: `apidb`
- **Volume**: `postgres-data` (persistent storage)

**Direct Connection:**
```bash
# Using docker-compose
docker-compose exec postgres psql -U postgres -d apidb

# From host (if psql installed)
psql -h localhost -p 5432 -U postgres -d apidb
```

### PostgreSQL Exporter

- **Image**: `prometheuscommunity/postgres-exporter:latest`
- **Port**: 9187
- **Metrics endpoint**: http://localhost:9187/metrics

### Redis Cache

- **Image**: `redis:latest`
- **Port**: 6379
- **Volume**: `redis-data` (persistent storage)

**Direct Connection:**
```bash
# Using docker-compose
docker-compose exec redis redis-cli

# From host (if redis-cli installed)
redis-cli -h localhost -p 6379
```

### Redis Exporter

- **Image**: `oliver006/redis_exporter:latest`
- **Port**: 9121
- **Metrics endpoint**: http://localhost:9121/metrics

### Prometheus

- **Image**: `prom/prometheus:latest`
- **Port**: 9090
- **UI**: http://localhost:9090
- **Config**: `monitoring/prometheus.yml`
- **Volume**: `prometheus-data` (persistent metrics)

### Grafana

- **Image**: `grafana/grafana:latest`
- **Port**: 3000
- **UI**: http://localhost:3000
- **Default credentials**: admin/admin
- **Volume**: `grafana-data` (persistent dashboards)

### k6 Load Testing

- **Image**: `grafana/k6:latest`
- **Scripts**: `load-tests/` directory
- **Profile**: `load-test` (only runs on demand)

## 📈 Performance Metrics

### What to Monitor During Load Tests

#### PostgreSQL Performance Indicators

**Good Performance:**
- Connection count < 100
- Cache hit ratio > 95%
- Query duration p95 < 100ms
- Zero deadlocks

**Warning Signs:**
- Cache hit ratio < 90%
- Connection count growing continuously
- Query duration p95 > 500ms
- Increasing rollback rate

**Critical Issues:**
- Connection pool exhausted
- Deadlocks occurring
- Query duration > 2s
- Database unresponsive

#### Redis Performance Indicators

**Good Performance:**
- Sub-millisecond latency
- Hit rate > 90%
- Memory usage stable
- Zero evictions

**Warning Signs:**
- Hit rate < 80%
- Memory usage growing
- Occasional evictions
- Latency spikes

**Critical Issues:**
- Memory maxed out
- High eviction rate
- Commands timing out
- Connection errors

### Optimization Tips

**Based on metrics, you might:**

1. **High PostgreSQL connection count**:
   - Add connection pooling to API
   - Increase PostgreSQL max_connections
   - Optimize long-running queries

2. **Low cache hit ratio**:
   - Adjust cache TTL
   - Implement cache warming
   - Review caching strategy

3. **High Redis memory**:
   - Implement eviction policy
   - Add Redis maxmemory limit
   - Review data structure sizes

4. **Slow query performance**:
   - Add database indexes
   - Optimize queries
   - Consider read replicas

## 🔍 Troubleshooting

### Monitoring Configuration Issues

**Symptom**: Prometheus shows "down" targets

**Solution**:
```bash
# Check if exporters are running
docker-compose ps

# View exporter logs
docker-compose logs postgres-exporter
docker-compose logs redis-exporter

# Test exporter endpoints
curl http://localhost:9187/metrics
curl http://localhost:9121/metrics
```

### Grafana Dashboard Not Loading

**Symptom**: Dashboard shows "No data"

**Solution**:
1. Verify Prometheus is scraping:
   - Go to http://localhost:9090/targets
   - All targets should show "UP"
2. Check datasource connection in Grafana
3. Wait 15-30 seconds for first metrics to appear

### k6 Cannot Reach API

**Symptom**: k6 tests fail with connection errors

**Solution**:
```bash
# Verify API is running
docker-compose ps api

# Check API logs
docker-compose logs api

# Verify network connectivity
docker-compose run --rm k6 run --vus 1 --duration 10s /scripts/light-load.js
```

### High Memory Usage During Tests

**Symptom**: System becomes slow during stress tests

**Solution**:
- This is expected during stress tests
- Reduce concurrent users in test scripts
- Monitor with: `docker stats`
- Increase Docker memory allocation if needed

### Load Test Timeout Errors

**Symptom**: Many failed requests during tests

**Solution**:
- Expected under extreme load (stress test)
- Review thresholds in test scripts
- Check if system reached its limits
- Analyze Grafana metrics to identify bottleneck

## 📝 Typical Workflow

### 1. Baseline Performance

```bash
# Start stack
docker-compose up -d

# Wait for services to be ready (30 seconds)
sleep 30

# Run light load test
docker-compose run --rm k6 run /scripts/light-load.js
```

Record baseline metrics from Grafana.

### 2. Realistic Load Testing

```bash
# Run medium load test while monitoring Grafana
docker-compose run --rm k6 run /scripts/medium-load.js
```

Compare with baseline. Look for:
- Response time degradation
- Resource utilization
- Error rates

### 3. Stress Testing

```bash
# Find breaking point
docker-compose run --rm k6 run /scripts/stress-test.js
```

Identify:
- Maximum sustainable load
- Failure modes
- Recovery behavior

### 4. Optimization Cycle

1. Identify bottleneck from metrics
2. Make code/config changes
3. Rebuild and restart
4. Re-run tests
5. Compare results

### 5. Generate Report

```bash
# Export Grafana dashboard as PDF
# Or take screenshots of key metrics

# Save k6 results
docker-compose run --rm k6 run /scripts/medium-load.js --out json=results.json
```

## 🎯 Next Steps

- Add custom metrics to your API
- Implement distributed tracing (Jaeger)
- Add alerting rules in Prometheus
- Configure Grafana alert notifications
- Test with different PostgreSQL configurations
- Experiment with Redis persistence modes
- Add APM (Application Performance Monitoring)
- Implement circuit breakers
- Test database replication scenarios

## 📄 License

This sandbox is provided as-is for development, learning, and performance testing purposes.