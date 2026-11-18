import type { DatabaseSync } from 'node:sqlite'

import type { AuthUserSchema } from '../../../../../../../../shared/auth/types'

import type Express from 'express'

const express = require('express') as typeof Express

const createAuthUserController = require('./controller.cts')

const { getJWTSecret } = require('../../../../../../../../shared/auth/jwt/secret.ts')
const { authenticateToken } = require('../../../../../../../../shared/auth/jwt/middleware.ts')

function createAuthUserRoutes(db: DatabaseSync, schema: AuthUserSchema) {
    const router = express.Router()

    const JWT_SECRET = getJWTSecret()

    const controller = createAuthUserController(db, schema, JWT_SECRET)

    router.post('/register', controller.registerAuthUser)
    router.post('/login', controller.loginAuthUser)
    router.get('/me', authenticateToken, controller.getAuthUser)

    return router
}

module.exports = createAuthUserRoutes