import type { Request, Response, NextFunction } from "express";

import { getJWTSecret } from "./validation";

import jwt from 'jsonwebtoken'

export function authenticateToken(req: Request, res: Response, next: NextFunction) {
  const JWT_SECRET = getJWTSecret()
  
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      error: "Missing Authorization header",
    });
  }

  const match = authHeader.match(/^Bearer\s+(\S+)$/);

  if (!match) {
    return res.status(401).json({
      error: "Invalid Authorization header",
    });
  }

  const token = match[1];

  try {
    const payload = jwt.verify(token, JWT_SECRET);

    if (typeof payload === "string" || typeof payload.userId !== "number") {
      return res.status(401).json({
        error: "Invalid token payload",
      });
    }

    req.userId = payload.userId;

    next();
  } catch {
    return res.status(401).json({
      error: "Invalid or expired token",
    });
  }
}