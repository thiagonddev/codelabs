import type { DatabaseSync } from "node:sqlite";
import type { RequestHandler } from "express";

import type z from "zod";

import type { UserMessageController } from "../../../../../../shared/database/user.message.types";
import type { UserMessageSchema } from "../../../../../../shared/database/sqlite/user.message.types";

const {
  userMessageValidationSchema
} = require("../../../../../../shared/database/user.message.validation.ts");

const createUserMessageRepository = require("./repository.cjs");

const { StatusCodes } = require("../../../../../../shared/types.ts");

function createUserMessageController(
  db: DatabaseSync,
  schema: UserMessageSchema
): UserMessageController {

  const { findAll, create, deleteById } = createUserMessageRepository(db, schema)

  const { CREATED, BAD_REQUEST_ERROR, BUSINESS_ERROR, NOT_FOUND_ERROR, SERVER_ERROR } = StatusCodes
  
  const indexUserMessages: RequestHandler = (_req, res) => {
    try {
      const messages = findAll()

      if (messages.length === 0) {
        return res.send("No messages were found");
      }

      console.log(`There are ${messages.length} message(s) in this database`);
      console.log(messages);

      return res.json(messages);
    } catch (error) {
      console.error("Error executing SQLite SELECT * query:", error);
      return res.status(SERVER_ERROR).send("Something went wrong");
    }
  };

  const storeUserMessage: RequestHandler = (req, res) => {
    const valid = userMessageValidationSchema.safeParse(req.body);

    if (!valid.success) {
      console.log(valid.error.issues);

      const errors = valid.error.issues.map(
        (error: z.core.$ZodIssue) => error.message,
      );

      return res.status(BUSINESS_ERROR).json(errors);
    }

    try {
      const result = create(valid)

      if (result.changes === 0) {
        throw new Error("No changes were made");
      }

      console.log(`${result.changes} message was successfully added!`);

      return res.status(CREATED).json({ success: true, result });
    } catch (error) {
      console.error("Error executing SQLite INSERT query:", error);

      return res.status(SERVER_ERROR).send("Something went wrong");
    }
  };

  const deleteUserMessage: RequestHandler = (req, res) => {
    const userId = Number(req.params.id);

    if (!Number.isSafeInteger(userId) || userId <= 0) {
      return res.status(BAD_REQUEST_ERROR).send("Missing or invalid ID");
    }

    try {
      const result = deleteById(userId)

      if (!result) {
        return res.status(NOT_FOUND_ERROR).send("User not found");
      }

      console.log(`The message with ID ${userId} was successfully deleted!`);

      return res.json({
        success: true,
        deletedUser: result
      });
    } catch (error) {
      console.error("Error executing SQLite DELETE query:", error);

      return res.status(SERVER_ERROR).send("Something went wrong");
    }
  };

  return { indexUserMessages, storeUserMessage, deleteUserMessage };
}

module.exports = createUserMessageController;