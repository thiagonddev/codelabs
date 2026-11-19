import type { DatabaseSync } from "node:sqlite";

import type { AuthUserSchema } from "../../../../../../../../shared/auth/types";

import type Express from 'express'
import type CORS from 'cors'
import type Helmet from 'helmet'

const express = require("express") as typeof Express;
const cors = require("cors") as typeof CORS;
const helmet = require("helmet") as typeof Helmet;

const createAuthUserRoutes = require('./routes.cjs')

const {
  createAuthTrafficLimits
} = require("../../../../../../../../shared/auth/rate.limit.middleware.ts");

function createApp(db: DatabaseSync, schema: AuthUserSchema) {
  const app = express()
  
  const { registerAuthUserLimits, loginAuthUserLimits } = createAuthTrafficLimits()
  
  app.use(cors())
  app.use(helmet())

  app.use('/register', registerAuthUserLimits.rateLimiter, registerAuthUserLimits.speedLimiter)
  app.use('/login', loginAuthUserLimits.rateLimiter, loginAuthUserLimits.speedLimiter)
  
  app.use(express.json())
  
  app.use('/', createAuthUserRoutes(db, schema))

  return app;
}

export = createApp;