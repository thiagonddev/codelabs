import type { DatabaseSync } from "node:sqlite";
import type { RequestHandler } from "express";

import type Bcrypt from "bcrypt";
import type JWT from "jsonwebtoken";

import type { BaseUserValidation } from "../../../../../../../../shared/database/types";

import type {
  AuthUserSchema,
  AuthUserController,
  AuthRegisterUserValidation,
  AuthUserPayloadValidation,
} from "../../../../../../../../shared/auth/types";

const bcrypt = require("bcrypt") as typeof Bcrypt;
const jwt = require("jsonwebtoken") as typeof JWT;

const {
  validateUserData
} = require("../../../../../../../../shared/auth/validation.ts");

const {
  authRegisterUserValidationSchema,
  authLoginUserValidationSchema
} = require("../../../../../../../../shared/auth/validation.schema.ts");

const { StatusCodes } = require("../../../../../../../../shared/types.ts");

function createAuthUserController(
  db: DatabaseSync,
  schema: AuthUserSchema,
  jwtSecret: string
): AuthUserController {
  const { CREATED, BUSINESS_ERROR, UNAUTHORIZED_ERROR, DUPLICATE_ERROR, NOT_FOUND_ERROR, SERVER_ERROR } = StatusCodes

  const registerAuthUser: RequestHandler = async (req, res) => {
    try {
      const userData = req.body;

      const valid = validateUserData(
        authRegisterUserValidationSchema,
        userData
      );

      if (!valid.data) return res.status(BUSINESS_ERROR).json(valid.errors);

      const { username, email, password }: AuthRegisterUserValidation =
        valid.data;

      const existingUser = db
        .prepare(schema.queries.userRegisterMatch)
        .get({ username, email });

      if (existingUser) {
        return res.status(DUPLICATE_ERROR).json({
          error: "User already exists"
        });
      }

      const hashedPassword = await bcrypt.hash(password, 12);

      db.prepare(schema.queries.userInsert).run({
        username,
        email,
        password: hashedPassword
      });

      res.status(CREATED).json({ username, email });
    } catch (error) {
      console.error(error);
      res.status(SERVER_ERROR).json({ error: "Server error" });
    }
  };

  const loginAuthUser: RequestHandler = async (req, res) => {
    try {
      const userData = req.body;

      const valid = validateUserData(authLoginUserValidationSchema, userData);

      if (!valid.data) return res.status(BUSINESS_ERROR).json(valid.errors);

      const { username, password } = valid.data;

      const user = db
        .prepare(schema.queries.userLoginMatch)
        .get({ username }) as AuthUserPayloadValidation | undefined;

      if (!user) {
        return res.status(UNAUTHORIZED_ERROR).json({
          error: "Invalid username and/or password"
        });
      }

      const passwordMatches = await bcrypt.compare(password, user.password);

      if (!passwordMatches) {
        return res.status(UNAUTHORIZED_ERROR).json({
          error: "Invalid username and/or password"
        });
      }

      const token = jwt.sign({ userId: user.id }, jwtSecret, {
        expiresIn: "1h"
      });

      res.json({ token });
    } catch (error) {
      console.error(error);
      res.status(SERVER_ERROR).json({ error: "Server error" });
    }
  };

  const getAuthUser: RequestHandler = (req, res) => {
    if (req.userId === undefined) {
      return res.status(UNAUTHORIZED_ERROR).json({
        error: "Unauthorized"
      });
    }

    const user = db
      .prepare(schema.queries.userPayload)
      .get({ id: req.userId }) as BaseUserValidation | undefined;

    if (!user) {
      return res.status(NOT_FOUND_ERROR).json({
        error: "User not found"
      });
    }

    res.json(user);
  };

  return { registerAuthUser, loginAuthUser, getAuthUser };
}

module.exports = createAuthUserController;