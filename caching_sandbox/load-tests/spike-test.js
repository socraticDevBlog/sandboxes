import http from "k6/http";
import { check, sleep } from "k6";

// Spike test - Sudden traffic surges
export const options = {
  stages: [
    { duration: "30s", target: 20 }, // Normal load
    { duration: "10s", target: 500 }, // Sudden spike!
    { duration: "1m", target: 500 }, // Maintain spike
    { duration: "10s", target: 20 }, // Drop back to normal
    { duration: "1m", target: 20 }, // Recovery period
    { duration: "10s", target: 0 }, // Ramp down
  ],
  thresholds: {
    http_req_duration: ["p(95)<3000"], // Acceptable degradation during spike
    http_req_failed: ["rate<0.15"], // Up to 15% errors during spike
  },
};

const BASE_URL = "http://api:8080";

export default function () {
  // Simulate realistic user behavior

  // Check health
  let health = http.get(`${BASE_URL}/health`);
  check(health, { "health check": (r) => r.status === 200 });

  // Browse items
  http.get(`${BASE_URL}/items`);
  sleep(0.2);

  // Try cache
  let cacheKey = `user-${Math.floor(Math.random() * 50)}`;
  let cached = http.get(`${BASE_URL}/cache/${cacheKey}`);

  if (cached.status === 404) {
    // Cache miss - write to cache
    http.post(
      `${BASE_URL}/cache/${cacheKey}?value=user-data-${Date.now()}`,
      null
    );
  }

  // Occasionally create new item
  if (Math.random() > 0.7) {
    http.post(
      `${BASE_URL}/items`,
      JSON.stringify({
        name: `Spike-${Date.now()}`,
        description: "Created during spike test",
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  }

  sleep(0.3);
}
