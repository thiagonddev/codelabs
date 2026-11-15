import type { DatabaseSync } from "node:sqlite";
import type { Router } from "express";

import type { UserMessageSchema } from "../../../../../../shared/database/sqlite/user.message.types";

const express = require("express");

const createUserMessageController = require("./controller.cjs");

function createUserMessageRoutes(db: DatabaseSync, schema: UserMessageSchema) {
  const router: Router = express.Router();

  const controller = createUserMessageController(db, schema);

  router.get("/", controller.getAllUserMessages);

  router.post("/", controller.createUserMessage);

  router.delete("/:id", controller.removeUserMessage);

  return router;
}

module.exports = createUserMessageRoutes;