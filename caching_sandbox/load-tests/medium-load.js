import http from "k6/http";
import { check, sleep } from "k6";

// Medium load test configuration
export const options = {
  stages: [
    { duration: "1m", target: 50 }, // Ramp up to 50 users
    { duration: "3m", target: 50 }, // Stay at 50 users
    { duration: "1m", target: 100 }, // Spike to 100 users
    { duration: "2m", target: 100 }, // Stay at 100 users
    { duration: "1m", target: 0 }, // Ramp down to 0
  ],
  thresholds: {
    http_req_duration: ["p(95)<800", "p(99)<1200"], // Performance targets
    http_req_failed: ["rate<0.05"], // Error rate should be below 5%
  },
};

const BASE_URL = "http://api:8080";

export default function () {
  // Weighted workload simulation
  let rand = Math.random();

  if (rand < 0.4) {
    // 40% - Read from cache (hot path)
    let cacheKey = `item-${Math.floor(Math.random() * 100)}`;
    let res = http.get(`${BASE_URL}/cache/${cacheKey}`);
    check(res, {
      "cache read success": (r) => r.status === 200 || r.status === 404,
    });
  } else if (rand < 0.7) {
    // 30% - Read from database
    let res = http.get(`${BASE_URL}/items`);
    check(res, { "db read success": (r) => r.status === 200 });
  } else if (rand < 0.9) {
    // 20% - Write to database
    let res = http.post(
      `${BASE_URL}/items`,
      JSON.stringify({
        name: `Item ${Date.now()}-${Math.random()}`,
        description: "Medium load test item",
      }),
      { headers: { "Content-Type": "application/json" } }
    );
    check(res, { "db write success": (r) => r.status === 201 });
  } else {
    // 10% - Write to cache
    let cacheKey = `item-${Math.floor(Math.random() * 100)}`;
    let res = http.post(
      `${BASE_URL}/cache/${cacheKey}?value=cached-value-${Date.now()}`,
      null
    );
    check(res, { "cache write success": (r) => r.status === 200 });
  }

  sleep(0.5); // Shorter sleep for higher throughput
}
