import type { Application } from "express";
import type { DatabaseSync as DBConfigType } from "node:sqlite";

import type Bcrypt from "bcrypt";
import type JWT from "jsonwebtoken";

import type { BaseUserValidation } from "../../../../../../../../shared/database/types";

import type {
  AuthRegisterUserValidation,
  AuthUserPayload,
} from "../../../../../../../../shared/auth/types";

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const bcrypt = require("bcrypt") as typeof Bcrypt;
const jwt = require("jsonwebtoken") as typeof JWT;

const {
  authenticateToken,
} = require("../../../../../../../../shared/auth/jwt/middleware.ts");

const {
  getJWTSecret,
} = require("../../../../../../../../shared/auth/jwt/secret.ts");

const {
  authRegisterUserValidationSchema,
  authLoginUserValidationSchema,
} = require("../../../../../../../../shared/auth/validation.schema.ts");

const {
  validateUserData,
} = require("../../../../../../../../shared/auth/validation.ts");

function createApp(db: DBConfigType, schema: any) {
  const app: Application = express();

  app.use(express.json());
  app.use(cors());
  app.use(helmet());

  const JWT_SECRET = getJWTSecret();

  app.post("/register", async (req, res) => {
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

      db.prepare(schema.queries.insertUser).run({
        username,
        email,
        password: hashedPassword,
      });

      res.status(201).json({ username, email });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Server error" });
    }
  });

  app.post("/login", async (req, res) => {
    try {
      const userData = req.body;

      const valid = validateUserData(authLoginUserValidationSchema, userData);

      if (!valid.data) return res.status(422).json(valid.errors);

      const { username, password } = valid.data;

      const user = db
        .prepare(schema.queries.userLoginMatch)
        .get({ username }) as AuthUserPayload | undefined;

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

      const token = jwt.sign({ userId: user.id }, JWT_SECRET, {
        expiresIn: "1h",
      });

      res.json({ token });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Server error" });
    }
  });

  app.get("/me", authenticateToken, (req, res) => {
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
  });

  return app;
}

export = createApp;