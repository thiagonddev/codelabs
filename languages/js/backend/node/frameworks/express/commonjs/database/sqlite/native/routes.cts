import type { DatabaseSync } from "node:sqlite";
import type { Router } from "express";

import type { UserMessageSchema } from "../../../../../../shared/database/sqlite/user.message.types";

const express = require("express");

const createUserMessageController = require("./controller.cjs");

function createUserMessageRoutes(db: DatabaseSync, schema: UserMessageSchema) {
  const router: Router = express.Router();

  const controller = createUserMessageController(db, schema);

  router.get("/", controller.indexUserMessages);

  router.post("/", controller.storeUserMessage);

  router.delete("/:id", controller.deleteUserMessage);

  return router;
}

module.exports = createUserMessageRoutes;