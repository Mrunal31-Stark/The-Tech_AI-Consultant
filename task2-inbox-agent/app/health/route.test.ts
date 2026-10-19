import { describe, expect, it } from "vitest";
import { GET, type Health } from "./route";

describe("GET /health", () => {
  it("returns 200 with service name", async () => {
    const response = GET();
    const body = (await response.json()) as Health;

    expect(response.status).toBe(200);
    expect(body).toEqual({ status: "ok", service: "task2-inbox-agent" });
  });
});
