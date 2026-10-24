import type { Schema } from "../../../../../../shared/database/types";

const DatabaseSync = require("node:sqlite");

const schema =
  require("../../../../../../shared/database/sqlite/schema.ts") as Schema;

const {
  PORT,
  isInvalid,
} = require("../../../../../../shared/server/config.ts");

const { createApp } = require("./app.ts");

if (isInvalid) {
  throw new Error("Environment variable does not contain a valid port number");
}

const db = new DatabaseSync("sqlite.db");

try {
  db.exec(schema.createTable);
} catch (error) {
  console.error("Error executing SQLite CREATE TABLE command:", error);
  process.exit(1);
}

const app = createApp(db);

app.listen(PORT, () => {
  console.log(`The server is running on port ${PORT}`);
});

export {};