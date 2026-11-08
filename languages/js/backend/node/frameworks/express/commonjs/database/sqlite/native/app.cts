import type { DatabaseSync } from "node:sqlite";
import type { Application } from "express";
import type { z } from "zod";

import type { Schema } from "../../../../../../shared/database/types";

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const schema =
  require("../../../../../../shared/database/sqlite/schema.ts") as Schema;

const { UserSchema } = require("../../../../../../shared/database/types.ts");

function createApp(db: DatabaseSync): Application {
  const app: Application = express();

  app.use(express.json());
  app.use(cors());
  app.use(helmet());

  app.get("/", (_req, res) => {
    try {
      const query = db.prepare(schema.queries.selectAllMessages);
      const messages = query.all();

      if (messages.length === 0) {
        return res.send("No messages were found");
      }

      console.log(`There are ${messages.length} message(s) in this database`);
      console.log(messages);

      return res.json(messages);
    } catch (error) {
      console.error("Error executing SQLite SELECT * query:", error);
      return res.status(500).send("Something went wrong");
    }
  });

  app.post("/", (req, res) => {
    const userData = req.body;

    const valid = UserSchema.safeParse(userData);

    if (!valid.success) {
      console.log(valid.error.issues);

      const errors = valid.error.issues.map(
        (error: z.core.$ZodIssue) => error.message,
      );

      return res.status(422).json(errors);
    }

    try {
      const query = db.prepare(schema.queries.insertMessage);

      const result = query.run(valid.data);

      if (result.changes === 0) {
        throw new Error("No changes were made");
      }

      console.log(`${result.changes} message was successfully added!`);

      return res.status(201).json({ success: true, result });
    } catch (error) {
      console.error("Error executing SQLite INSERT query:", error);

      return res.status(500).send("Something went wrong");
    }
  });

  app.delete("/:id", (req, res) => {
    const id = req.params.id;

    const userId = Number(id);

    if (!Number.isInteger(userId) || userId <= 0) {
      return res.status(400).send("Missing or invalid ID");
    }

    try {
      const query = db.prepare(schema.queries.deleteMessage);

      const result = query.get({ id: userId });

      if (!result) {
        return res.status(404).send("User not found");
      }

      console.log(`The message with ID ${userId} was successfully deleted!`);

      return res.json({
        success: true,
        deletedUser: result,
      });
    } catch (error) {
      console.error("Error executing SQLite DELETE query:", error);

      return res.status(500).send("Something went wrong");
    }
  });

  return app;
}

module.exports = createApp;