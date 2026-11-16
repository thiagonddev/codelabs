import type { DatabaseSync } from "node:sqlite";
import type { RequestHandler } from "express";

import type z from "zod";

import type { UserMessageController } from "../../../../../../shared/database/user.message.types";
import type { UserMessageSchema } from "../../../../../../shared/database/sqlite/user.message.types";

const { userMessageValidationSchema } = require("../../../../../../shared/database/user.message.validation.ts");

function createUserMessageController(db: DatabaseSync, schema: UserMessageSchema): UserMessageController {
  const getAllUserMessages: RequestHandler = (_req, res) => {
    try {
      const query = db.prepare(schema.queries.selectAllUserMessages);
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
  };

  const createUserMessage: RequestHandler = (req, res) => { 
    const valid = userMessageValidationSchema.safeParse(req.body);

    if (!valid.success) {
      console.log(valid.error.issues);

      const errors = valid.error.issues.map(
        (error: z.core.$ZodIssue) => error.message
      );

      return res.status(422).json(errors);
    }

    try {
      const query = db.prepare(schema.queries.insertUserMessage);

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
  }

  const removeUserMessage: RequestHandler = (req, res) => {
    const userId = Number(req.params.id);

    if (!Number.isInteger(userId) || userId <= 0) {
      return res.status(400).send("Missing or invalid ID");
    }

    try {
      const query = db.prepare(schema.queries.deleteUserMessage);

      const result = query.get({ id: userId });

      if (!result) {
        return res.status(404).send("User not found");
      }

      console.log(`The message with ID ${userId} was successfully deleted!`);

      return res.json({
        success: true,
        deletedUser: result
      });
    } catch (error) {
      console.error("Error executing SQLite DELETE query:", error);

      return res.status(500).send("Something went wrong");
    }
  }

  return { getAllUserMessages, createUserMessage, removeUserMessage }
}

export = createUserMessageController