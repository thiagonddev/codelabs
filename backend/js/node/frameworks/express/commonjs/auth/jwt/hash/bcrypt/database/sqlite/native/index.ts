import type { Express, Request, Response, NextFunction } from "express";
import type { DatabaseSync as DBConfigType } from "node:sqlite";
import type Bcrypt from "bcrypt";
import type JWT from "jsonwebtoken";

import type {
  User,
  UserPayload,
} from "../../../../../../../../../../shared/auth/types";

const { DatabaseSync } = require("node:sqlite");
const express = require("express");
const helmet = require("helmet")

const bcrypt = require("bcrypt") as typeof Bcrypt;
const jwt = require("jsonwebtoken") as typeof JWT;

const {
  schema,
} = require("../../../../../../../../../../shared/auth/database/sqlite/native/schema.ts");

const {
  PORT,
  isInvalid,
} = require("../../../../../../../../../../shared/server/config.ts");

if (isInvalid) {
  throw new Error("Environment variable does not contain a valid port number");
}

const app: Express = express();

app.use(express.json());
app.use(helmet())

const db: DBConfigType = new DatabaseSync("sqlite.db");

const JWT_SECRET = process.env.JWT_SECRET ?? "";

if (!JWT_SECRET) {
  throw new Error("Environment variable does not contain a valid JWT secret");
}

try {
  db.exec(schema.createTable);
} catch (error) {
  console.error("Error executing SQLite CREATE TABLE command:", error);
  process.exit(1);
}

function authenticateToken(req: Request, res: Response, next: NextFunction) {
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

app.post("/register", async (req, res) => {
  try {
    let { username, email, password } = req.body;

    if (
      typeof username !== "string" ||
      typeof email !== "string" ||
      typeof password !== "string"
    ) {
      return res.status(400).json({
        error: "Username, email and password must be strings",
      });
    }

    username = username.trim();
    email = email.trim();

    const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

    if (!username || !email || !password) {
      return res.status(400).json({
        error: "All fields are required",
      });
    }

    if (username.length < 5) {
      return res.status(400).json({
        error: "Username must have at least 5 characters",
      });
    }

    if (!emailRegex.test(email)) {
      return res.status(400).json({
        error: "Invalid email format",
      });
    }

    if (password.length < 10) {
      return res.status(400).json({
        error: "Password must have at least 10 characters",
      });
    }

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
    let { username, password } = req.body;

    if (typeof username !== "string" || typeof password !== "string") {
      return res.status(400).json({
        error: "Username and password must be strings",
      });
    }

    username = username.trim();

    const result = db.prepare(schema.queries.userLoginMatch).get({ username });

    if (!result) {
      return res.status(401).json({
        error: "Invalid username and/or password",
      });
    }

    const user = result as User;

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

  const result = db.prepare(schema.queries.userPayload).get({ id: req.userId });

  if (!result) {
    return res.status(404).json({
      error: "User not found",
    });
  }

  const user = result as UserPayload;

  res.json(user);
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
