import http from "k6/http";
import { check, sleep } from "k6";

// Stress test configuration - Find breaking points
export const options = {
  stages: [
    { duration: "2m", target: 100 }, // Ramp up to 100 users
    { duration: "3m", target: 200 }, // Increase to 200 users
    { duration: "2m", target: 300 }, // Push to 300 users
    { duration: "2m", target: 400 }, // Stress at 400 users
    { duration: "3m", target: 0 }, // Gradual recovery
  ],
  thresholds: {
    http_req_duration: ["p(95)<2000"], // Allow higher latency under stress
    http_req_failed: ["rate<0.10"], // Up to 10% error rate acceptable
  },
};

const BASE_URL = "http://api:8080";

export default function () {
  // Aggressive workload - minimal sleep
  let operations = Math.floor(Math.random() * 5);

  for (let i = 0; i < operations; i++) {
    let rand = Math.random();

    if (rand < 0.3) {
      // Heavy cache reads
      let cacheKey = `stress-${Math.floor(Math.random() * 1000)}`;
      http.get(`${BASE_URL}/cache/${cacheKey}`);
    } else if (rand < 0.6) {
      // Database reads
      http.get(`${BASE_URL}/items`);
    } else if (rand < 0.85) {
      // Database writes
      http.post(
        `${BASE_URL}/items`,
        JSON.stringify({
          name: `Stress-${Date.now()}-${Math.random()}`,
          description:
            "Stress test item with longer description to increase payload size",
        }),
        { headers: { "Content-Type": "application/json" } }
      );
    } else {
      // Cache writes
      let cacheKey = `stress-${Math.floor(Math.random() * 1000)}`;
      http.post(
        `${BASE_URL}/cache/${cacheKey}?value=stress-value-${Date.now()}`,
        null
      );
    }
  }

  sleep(0.1); // Very short sleep to maintain pressure
}
