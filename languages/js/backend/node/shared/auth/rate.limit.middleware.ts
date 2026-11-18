import { enforceTrafficLimits } from "../rate.limit";

export function createAuthTrafficLimits() {
  const registerAuthUserLimits = enforceTrafficLimits({
    rateLimiter: {
      reqLimit: 5,
    },
    speedLimiter: {
      reqLimitToDelay: 3,
      delayMs: 500,
      maxDelaySecs: 30,
    },

    windowMins: 60,
    retryAfterMins: 15,
  });

  const loginAuthUserLimits = enforceTrafficLimits({
    rateLimiter: {
      reqLimit: 5,
    },
    speedLimiter: {
      reqLimitToDelay: 3,
      delayMs: 500,
    },

    windowMins: 60,
    retryAfterMins: 60,
  });

  const authUserDashboard = enforceTrafficLimits({
    rateLimiter: {
      reqLimit: 5,
    },
    speedLimiter: {
      reqLimitToDelay: 3,
      delayMs: 500,
    },

    windowMins: 60,
    retryAfterMins: 60,
  });

  return { registerAuthUserLimits, loginAuthUserLimits, authUserDashboard };
}