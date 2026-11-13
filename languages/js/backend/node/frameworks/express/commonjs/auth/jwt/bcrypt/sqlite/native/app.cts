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
} = require("../../../../../../../../shared/auth/jwt/validation.ts");

const {
  authRegisterUserValidationSchema,
  authLoginUserValidationSchema,
} = require("../../../../../../../../shared/auth/validation.ts");

const validateUserData = require("../../../../validation.ts");

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

      const validData: AuthRegisterUserValidation = {
        username: valid.data.username,
        email: valid.data.email,
        password: valid.data.password,
      };

      const existingUser = db
        .prepare(schema.queries.userRegisterMatch)
        .get({ username: validData.username, email: validData.email });

      if (existingUser) {
        return res.status(409).json({
          error: "User already exists",
        });
      }

      const hashedPassword = await bcrypt.hash(validData.password, 12);

      db.prepare(schema.queries.insertUser).run({
        username: validData.username,
        email: validData.email,
        password: hashedPassword,
      });

      res
        .status(201)
        .json({ username: validData.username, email: validData.email });
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

      const validData = {
        username: valid.data.username,
        password: valid.data.password,
      };

      const result = db
        .prepare(schema.queries.userLoginMatch)
        .get({ username: validData.username });

      if (!result) {
        return res.status(401).json({
          error: "Invalid username and/or password",
        });
      }

      const user = result as AuthUserPayload;

      const passwordMatches = await bcrypt.compare(
        validData.password,
        user.password,
      );

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

    const result = db
      .prepare(schema.queries.userPayload)
      .get({ id: req.userId });

    if (!result) {
      return res.status(404).json({
        error: "User not found",
      });
    }

    const user = result as BaseUserValidation;

    res.json(user);
  });

  return app;
}

export = createApp;