import type { RateLimitRequestHandler } from 'express-rate-limit';
import type { SlowDownRequestHandler } from 'express-slow-down';

import type { TrafficLimits } from './rate.limit.types'

import rateLimit from 'express-rate-limit'
import slowDown from 'express-slow-down'

import { StatusCodes } from './types';

export function enforceTrafficLimits(options: TrafficLimits) {
    const rateLimiter: RateLimitRequestHandler = rateLimit({
      limit: options.rateLimiter.reqLimit ?? undefined,
      windowMs: options.windowMins * 60 * 1000,
      message: {
        error: "Too many requests from this IP address",
        retryAfter: `${options.retryAfterMins} minutes`,
      },
      handler: (_req, res) => {
        res.status(StatusCodes.TOO_MANY_REQUESTS_ERROR).json({
          error: "Rate limit exceeded",
          message:
            "Too many requests from this IP address, please try again later",
          retryAfterMins: options.retryAfterMins,
        });
      },
      retryAfter: options.retryAfterMins
        ? options.retryAfterMins * 60
        : undefined,
      standardHeaders: "draft-8",
      legacyHeaders: false,
      skipSuccessfulRequests:
        options.countSuccessfulRequests === undefined
          ? undefined
          : !options.countSuccessfulRequests,
    });

    const speedLimiter: SlowDownRequestHandler = slowDown({
      windowMs: options.windowMins * 60 * 1000,
      delayAfter: options.speedLimiter.reqLimitToDelay,
      delayMs: (usedReqs) => {
        return (
          (usedReqs - options.speedLimiter.reqLimitToDelay) *
          options.speedLimiter.delayMs
        );
      },
      maxDelayMs:
        options.speedLimiter.maxDelaySecs === undefined || null
          ? undefined
          : options.speedLimiter.maxDelaySecs * 1000,
      retryAfter: options.retryAfterMins
        ? options.retryAfterMins * 60
        : undefined,
      skipSuccessfulRequests:
        options.countSuccessfulRequests === undefined
          ? undefined
          : !options.countSuccessfulRequests,
      standardHeaders: "draft-8",
    });

    return { rateLimiter, speedLimiter }
}