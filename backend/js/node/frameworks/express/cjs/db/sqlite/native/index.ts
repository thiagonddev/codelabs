import type { DatabaseSync as DBConfigType } from "node:sqlite";
import type { Application } from "express";
import type { Message } from "../../../../../../utils/db/sqlite/schema";

const { DatabaseSync } = require("node:sqlite");
const express = require("express");
const { schema } = require("../../../../../../utils/db/sqlite/schema.ts");

const PORT = Number(process.env.PORT ?? 3000);

const db: DBConfigType = new DatabaseSync("sqlite.db");

try {
  db.exec(schema.createTable);
} catch (error) {
  console.error("Error executing SQLite CREATE TABLE command:", error);
  process.exit(1);
}

const app: Application = express();

app.get("/", (_, res) => {
  const query = db.prepare(schema.queries.selectAllMessages);
  const messages = query.all() as Message[];

  if (messages.length === 0) {
    return res.send("No messages were found");
  }

  const usersList = messages.map((message) => ({
    id: message.id,
    name: message.username,
    email: message.email,
    message: message.message,
  }));

  console.log(`There are ${messages.length} message(s) in this database`);
  console.log(usersList);

  return res.json(usersList);
});

app.post("/", (_, res) => {
  try {
    const query = db.prepare(schema.queries.insertMessage);

    const result = query.run({
      username: "Thiago Nogueira",
      email: "thiagond360@gmail.com",
      message: "This is a INSERT SQL statement!",
    });

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

  if (!id || Number.isNaN(userId)) {
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

app.listen(PORT, () => {
  console.log(`The server is running on port ${PORT}`);
});