import type { Application } from "express";
import type { DatabaseSync } from "node:sqlite";

import type { UserMessageSchema } from "../../../../../../shared/database/sqlite/user.message.types";

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const createUserMessageRoutes = require('./routes.cjs')

function createApp(db: DatabaseSync, schema: UserMessageSchema) {
  const app: Application = express();

  app.use(express.json());
  app.use(cors());
  app.use(helmet());

  app.use('/', createUserMessageRoutes(db, schema))

  return app;
}

export = createApp;