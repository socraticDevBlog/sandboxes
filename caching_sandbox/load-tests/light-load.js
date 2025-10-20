import http from "k6/http";
import { check, sleep } from "k6";

// Light load test configuration
export const options = {
  stages: [
    { duration: "30s", target: 10 }, // Ramp up to 10 users
    { duration: "1m", target: 10 }, // Stay at 10 users
    { duration: "30s", target: 0 }, // Ramp down to 0
  ],
  thresholds: {
    http_req_duration: ["p(95)<500"], // 95% of requests should be below 500ms
    http_req_failed: ["rate<0.01"], // Error rate should be below 1%
  },
};

const BASE_URL = "http://api:8080";

export default function () {
  // Test health endpoint
  let healthRes = http.get(`${BASE_URL}/health`);
  check(healthRes, {
    "health check status is 200": (r) => r.status === 200,
  });

  // Test getting items from PostgreSQL
  let itemsRes = http.get(`${BASE_URL}/items`);
  check(itemsRes, {
    "items list status is 200": (r) => r.status === 200,
  });

  // Test creating an item in PostgreSQL
  let createRes = http.post(
    `${BASE_URL}/items`,
    JSON.stringify({
      name: `Item ${Date.now()}`,
      description: "Load test item",
    }),
    {
      headers: { "Content-Type": "application/json" },
    }
  );
  check(createRes, {
    "create item status is 201": (r) => r.status === 201,
  });

  // Test Redis cache write
  let cacheKey = `test-${Date.now()}`;
  let cacheWriteRes = http.post(
    `${BASE_URL}/cache/${cacheKey}?value=testvalue`,
    null
  );
  check(cacheWriteRes, {
    "cache write status is 200": (r) => r.status === 200,
  });

  // Test Redis cache read
  let cacheReadRes = http.get(`${BASE_URL}/cache/${cacheKey}`);
  check(cacheReadRes, {
    "cache read status is 200": (r) => r.status === 200,
  });

  sleep(1); // Wait 1 second between iterations
}
