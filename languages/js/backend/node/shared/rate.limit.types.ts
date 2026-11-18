import type { RateLimitRequestHandler } from "express-rate-limit";
import type { SlowDownRequestHandler } from "express-slow-down";

export type EnforceTrafficLimits = {
  rateLimiter: RateLimitRequestHandler
  speedLimiter: SlowDownRequestHandler
}

export type TrafficLimits = {
  rateLimiter: {
    reqLimit?: number;
  };

  speedLimiter: {
    reqLimitToDelay: number;
    delayMs: number;
    maxDelaySecs?: number;
  };

  windowMins: number;
  retryAfterMins?: number;
  countSuccessfulRequests?: boolean;
};