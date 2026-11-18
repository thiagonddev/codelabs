import type { DatabaseSync } from "node:sqlite";
import type { RequestHandler } from "express";

import type Bcrypt from "bcrypt";
import type JWT from "jsonwebtoken";

import type { BaseUserValidation } from "../../../../../../../../shared/database/types";

import type {
  AuthUserSchema,
  AuthRegisterUserValidation,
  AuthUserPayloadValidation,
} from "../../../../../../../../shared/auth/types";

const bcrypt = require("bcrypt") as typeof Bcrypt;
const jwt = require("jsonwebtoken") as typeof JWT;

const {
  validateUserData,
} = require("../../../../../../../../shared/auth/validation.ts");

const {
  authRegisterUserValidationSchema,
  authLoginUserValidationSchema,
} = require("../../../../../../../../shared/auth/validation.schema.ts");

function createAuthUserController(
  db: DatabaseSync,
  schema: AuthUserSchema,
  jwtSecret: string,
) {
  const registerAuthUser: RequestHandler = async (req, res) => {
    try {
      const userData = req.body;

      const valid = validateUserData(
        authRegisterUserValidationSchema,
        userData,
      );

      if (!valid.data) return res.status(422).json(valid.errors);

      const { username, email, password }: AuthRegisterUserValidation =
        valid.data;

      const existingUser = db
        .prepare(schema.queries.userRegisterMatch)
        .get({ username, email });

      if (existingUser) {
        return res.status(409).json({
          error: "User already exists",
        });
      }

      const hashedPassword = await bcrypt.hash(password, 12);

      db.prepare(schema.queries.userInsert).run({
        username,
        email,
        password: hashedPassword,
      });

      res.status(201).json({ username, email });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Server error" });
    }
  };

  const loginAuthUser: RequestHandler = async (req, res) => {
    try {
      const userData = req.body;

      const valid = validateUserData(authLoginUserValidationSchema, userData);

      if (!valid.data) return res.status(422).json(valid.errors);

      const { username, password } = valid.data;

      const user = db
        .prepare(schema.queries.userLoginMatch)
        .get({ username }) as AuthUserPayloadValidation | undefined;

      if (!user) {
        return res.status(401).json({
          error: "Invalid username and/or password",
        });
      }

      const passwordMatches = await bcrypt.compare(password, user.password);

      if (!passwordMatches) {
        return res.status(401).json({
          error: "Invalid username and/or password",
        });
      }

      const token = jwt.sign({ userId: user.id }, jwtSecret, {
        expiresIn: "1h",
      });

      res.json({ token });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Server error" });
    }
  };

  const getAuthUser: RequestHandler = (req, res) => {
    if (req.userId === undefined) {
      return res.status(401).json({
        error: "Unauthorized",
      });
    }

    const user = db
      .prepare(schema.queries.userPayload)
      .get({ id: req.userId }) as BaseUserValidation;

    if (!user) {
      return res.status(404).json({
        error: "User not found",
      });
    }

    res.json(user);
  };

  return { registerAuthUser, loginAuthUser, getAuthUser };
}

module.exports = createAuthUserController;